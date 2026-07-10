# IAW8P40 Calculator

A dependency-free .NET 9 command-line calculator for the Peugeot 106 Marelli IAW 8P.40 calibration image.

The program reads `ecu-calculator.json`, loads a 64 KiB BIN, performs the decoded 68HC11 table lookups and fixed-point arithmetic, and prints spark/fuel results. When `comparisonBinPath` is set, the same inputs are evaluated against both images and a delta is printed.

## Run

```powershell
dotnet run --project .
```

The default configuration file is `ecu-calculator.json` in the current working directory. An alternate path can be passed explicitly:

```powershell
dotnet run --project . -- C:\path\to\my-config.json
```

Run the built-in synthetic arithmetic tests with:

```powershell
dotnet run --project . -- --self-test
```

Run the default stock-versus-MOD2 RPM/load sweep with:

```powershell
dotnet run --project . -- --sweep
```

The supplied sweep covers `1500..5000 RPM` in 250-RPM steps and a `0..100%` pedal proxy in 10% steps, producing 165 operating points. It writes:

- `ecu-calculator-sweep.csv` for plotting and filtering in a spreadsheet.
- `ecu-calculator-sweep.json` for structured processing.

Set `sweep.enabled` to `true` to make sweep mode the default, or edit the range, step, mapping, and output paths under the `sweep` object. An explicit configuration can also be used:

```powershell
dotnet run --project . -- C:\path\to\my-config.json --sweep
```

For Visual Studio 2022, open `IAW8P40.Calculator.sln`, select the `IAW8P40.Calculator` startup project, and run it. The .NET 9 SDK is required. With no explicit argument, the program checks the working directory and then walks upward from the executable to find the project-level `ecu-calculator.json`; the config is not copied beside the executable because its BIN paths are relative to the source directory.

## What is calculated

### Axes

- Physical RPM -> engine period using the configured `15000000 / rpm` relationship.
- Engine period -> firmware Q8.8 RPM index through the 24-word axis at `0x929E`.
- Processed load-delta byte -> axis `0x9291` -> table `0x9187` -> `0x00CE` -> load index `0x2034`.
- Processed IAT-like byte -> axis `0x92D9`, including the firmware inversion into `0x2038` and doubling into `0x203A`.
- Processed CTS-like byte -> axis `0x92CF`, including the firmware inversion into `0x203C` and doubling into `0x203E`.

Direct Q8.8 overrides are available for every axis. This is useful when replaying logged RAM values. Overrides are validated against the actual table dimensions so an invalid index cannot read unrelated ROM bytes:

- RPM `0x0000..0x1700` (24 points).
- Load `0x0000..0x07FF` (9 points; the firmware clamps below the next cell).
- IAT-like and CTS-like `0x0000..0x0800` (9 points).

An explicit `enginePeriodTicks` can be used without a physical RPM input. The period remains required because the fuel path uses it as a duration limit even when `rpmAxisQ8_8` is supplied directly.

### Pedal/load sweep boundary

The firmware path currently accepts a processed `loadDeltaByte`, not a physical throttle angle. Sweep mode therefore maps the displayed pedal proxy linearly to that byte, then runs the decoded nonlinear `0x9291 -> 0x9187 -> 0x00CE -> 0x2034` load path independently for each BIN. The default mapping is `0% -> 0` and `100% -> 201`, covering the proven `0x9291` breakpoint span. CSV output includes the resulting load-axis index, so plateaus and differences remain visible.

This is useful for calibration comparison, but it is not a transient throttle simulation: manifold filling, TPS rate, acceleration enrichment state, and engine history are not inferred from pedal percentage.

### Spark

The core decoded path follows the routine at `0x48D8`:

1. Select `0x8C19` in RPM-only/bypass mode, otherwise select `0x8A69` or `0x8B41` from `0x20B1`.
2. Bilinearly interpolate the selected base table.
3. Apply signed byte `0x8A68` when the relevant mode bit is set.
4. Apply signed CTS/load correction `0x8D15`.
5. Apply signed IAT/load correction `0x8C7C`.
6. Convert the resulting raw accumulator with the configured `0.5 degree/raw` scaling.

`additionalSparkRaw` can represent later mode-specific additions. The program reports the decoded core accumulator separately. It does not claim to reproduce history-dependent slew limiting or the final OC2/OC4 event schedule.

`clampSparkCommandTo0Through127` is disabled by default. The final command clamp is not proven for every operating path, so enabling it is an explicit what-if assumption rather than part of the authoritative decoded core.

### Fuel

The selected signed quantity trim is calculated exactly from:

- `0x83F0` in RPM-only/bypass mode;
- `0x821C` or `0x8318` in the normal 24x9 path;
- `0x81F8` or `0x82F4` only when RPM axis `<= 0x0300`, `A9.40` is set, and the remaining RAM guards (`$0090 != 0`, `$202D == 0`) are represented by `lowRpmFuelTrimGuardsSatisfied: true`.

The signed trim is applied as the decoded firmware operation, approximately:

```text
pulse += pulse * signed_raw / 256
```

The actual implementation uses the same half-up byte-product rounding as the 68HC11 helper. The later adaptive-high-byte and `$2053` stages use the distinct firmware sequence that rounds the byte product first and then halves it.

Two fuel modes are available.

#### `apply-trim-only`

Starts with `baseFuelPulseRaw` and applies only the selected signed quantity trim. This is the safest mode for answering questions such as “what does changing this table cell do to an already known pulse width?”

The two signed IAT/RPM table outputs at `0x802B` and `0x8103` are still shown, but are not silently inserted into the pulse calculation.

#### `from-intermediates`

Executes the currently decoded static arithmetic from the `0xE927`, `0xE5E8`, and `0xE652` paths:

- signed IAT/RPM corrections;
- `0x204B` correction sum;
- `0x204E` Q8.8 blend;
- 3000-count base cap;
- signed quantity trim;
- adaptive trim centered at `0x8000`;
- warmup and afterstart factors;
- transient additions/subtraction and 32000-count saturation;
- engine-period limit;
- `0x2053` multiplier;
- fast lambda correction;
- optional stateless `0x85BA` high-load duration support.

The extra RAM terms are read from the config because their state machines are not yet reconstructed from physical inputs. This mode is deterministic and useful for sensitivity analysis, but it is not a complete ECU runtime emulator.

## Important model boundaries

- Exact physical MAP, IAT and CTS transfer functions are not proven. The program therefore uses processed bytes or direct firmware axis indices rather than pretending that a table column is an exact kPa or Celsius value.
- The physical timer tick duration is not proven. Raw duration ticks are authoritative. The included `2.0 us/tick` value is only a configurable provisional display conversion.
- The spark-bank physical names remain working labels. Table addresses, shapes and selection logic are stronger than the high-octane/low-octane naming.
- The optional final spark clamp is unproven and disabled in the supplied configurations.
- `from-intermediates` does not model the operating-state-12 helper at `0x96F3`.
- The optional high-load stage is stateless; the actual firmware carries an `A1.40` state bit between calls.
- Only the Peugeot stock/Stok/MOD2 firmware lineage should be used. Xantia 607C and RALLY13 are different firmware builds with different addresses.

## Output

The console report gives the principal values. A detailed JSON file contains:

- resolved Q8.8 axes;
- every table lookup result;
- only the source cell addresses and values that actually contribute to each interpolation result;
- intermediate fuel stages;
- model warnings;
- base-versus-comparison deltas.

This makes a result auditable: every output can be traced back to the exact BIN bytes used for interpolation.

Sweep CSV rows include RPM, pedal proxy, processed load byte, resolved load axes, base-table addresses, spark components, fuel corrections, final duration, and comparison-minus-base deltas. Sweep JSON contains the same compact point summaries and the exact sweep settings.
