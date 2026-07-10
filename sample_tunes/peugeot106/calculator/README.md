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

Executes the currently decoded static arithmetic from the `0xE927`, `0xE5E8`, and `0xE652` paths. It does not start from `baseFuelPulseRaw`; that field is retained only for common result reporting. The calculated starting point is the decoded load/air-charge word `$00CE` plus the synthesized correction `$204B`.

The central terms are:

```text
$204B = 2 * (sign($204A) + $2596 + sign($2050))
       + optional sign($2610)
       + $24D9

$204E = max(0, sign($204D) + $0006 + ROM_WORD[$8028])

$00C1 = max(0, $00CE + $204B)
$00C1 = round($00C1 * $204E / 256)
$00C1 = min($00C1, 3000)
```

`$204A` and `$204D` are the signed outputs from `0x802B` and `0x8103`. The optional `$2610` term is used only by the alternate bank path and is doubled when `A9.40` is set. Arithmetic wraps like the 68HC11 before the explicit clamps.

The remaining firmware-order stages are:

- signed IAT/RPM corrections;
- signed quantity trim `$2084`;
- adaptive trim `$20B9`, centered at `0x8000`;
- CTS warmup factor `$2085` and afterstart factor `$00C5`;
- `$2055 + $2057 + $2590 - $2584`, with zero/32000 saturation;
- engine-period `$00BA` duration limit;
- multiplier `$2053`;
- fast lambda correction `$2049` and a second period limit;
- optional stateless `0x85BA` high-load duration support.

The extra RAM terms are read from the config because their producer state machines are not yet executed by the calculator. Zero is neutral for the additive terms and most positive factors; `adaptiveTrim20B9: 32768` (`0x8000`) is the neutral adaptive value. Even with all manual terms neutral, the IAT/RPM tables and ROM word at `0x8028` remain active.

This mode is deterministic and useful for sensitivity analysis or replaying a captured RAM snapshot, but it is not a complete ECU runtime emulator.

### Inputs required for a complete dynamic fuel calculation

A complete calculation has two different input boundaries.

For **single-instant replay**, the calculator needs current sensor/axis values plus all live RAM terms consumed by the final fuel routines. For **dynamic simulation**, those RAM terms must instead be produced from an initialized ECU state and a time-ordered input stream. Independent sweep points cannot reproduce afterstart, transient, lambda, adaptive, or hysteresis behavior.

#### External and per-step inputs

| Input group | Required values | Purpose / boundary |
| --- | --- | --- |
| Time | elapsed ECU-loop ticks, timer/capture progression, and step duration | Drives counters, filters, slew rates, afterstart, transient decay, and output scheduling. |
| Engine lifecycle | key-on/reset, cranking/running transition, engine-start elapsed time, stall/restart state | Selects initialization, cranking, afterstart, and normal-running paths. |
| Speed | engine period `$00BA` or RPM, previous period, and period delta | Produces `$2036`, duration limits, RPM gates, and transient/multiplier conditions. |
| Load/air path | current and previous raw load-model inputs, `$00C9/$0011` or the derived positive delta `$2017`, and load history | Produces `$00CE/$00D0/$2034` and load-rate terms. Exact physical pressure conversion remains provisional. |
| Driver demand | current and previous TPS/pedal ADC or normalized values and their rate of change | Needed for a real pedal transient. The current sweep's pedal percentage is only a linear `loadDeltaByte` proxy. |
| Temperature | raw/filtered ADC `$2008` and `$200A`, or replayed `$2038/$203A/$203C/$203E` axes | Drives IAT correction, CTS warmup, afterstart, transient scaling, and the state-12 helper. CTS/IAT assignment is strong but still hardware-provisional. |
| Lambda/O2 | raw and filtered samples, filtered word `$00CC`, sensor-valid/heater state, and previous samples | Produces `$2040`, fast correction `$2049`, closed-loop control, and learned trim. Exact sensor transfer remains provisional. |
| Electrical | battery/supply ADC and any confirmed injector-output voltage compensation input | Required before raw duration can be presented as a physical injector command. The compensation/dead-time path is not fully proven. |
| Digital operating inputs | idle/WOT switches, start request, fuel-cut/limiter state, bank/mode selection, and relevant actuator/system flags | Selects alternate trims, bypass paths, closed-loop eligibility, transient gates, and special operating states. |

#### Persistent ECU state

| State group | Required state or representative RAM | Why it must persist between steps |
| --- | --- | --- |
| Mode flags | `$00A1`, `$00A2`, `$00A3`, `$00A9`, `$0090`, `$009E`, `$009F`, `$00B1`, `$00B3`, `$00D7`, `$202D`, `$20B1`, `$21A6` | These bits gate trim banks, transient logic, multiplier paths, high-load hysteresis, and operating-state-12 behavior. |
| Correction synthesis | `$2596`, `$2050`, `$2610`, `$24D9`, `$0006` | These feed `$204B/$204E`; several are filtered or mode-dependent producers rather than direct calibration constants. |
| Afterstart | `$2059`, `$2060`, `$2062`, `$00C5`, `$20F7`, associated flags and counters | Afterstart tables depend on temperature, start phase, counters, and decay history. |
| Transient fuel | `$2054`, `$2055`, `$2057`, `$206B`, `$2079`, `$207A`, `$207B`, `$2080`, `$2082`, `$2582`, `$2584`, `$2586`, `$2588`, `$2590` | Acceleration/deceleration enrichment uses previous samples, filters, caps, accumulators, and decay. |
| Closed-loop/adaptive | `$2040`, `$2049`, `$2090-$20A8`, `$20B9`, learned RAM cells `$0060/$0069`, integrators and timers | Lambda feedback and learned trim are history-dependent and cannot be inferred from one lambda sample. |
| Multiplier path | `$2053`, `$25A1`, `$25A2`, `$20DE-$20E1`, `$00D0`, and their mode flags | `$2053` is synthesized from load and prior state; it is not a direct ROM table output. |
| High-load final stage | `$00BF`, `$00A1.40`, `$2063`, `$00C1`, `$00C3` | The `0x85BA` addition uses a carried hysteresis bit and scheduler/event-width limits. |
| Output scheduler | `$00BC`, `$00BE`, `$21C6`, timer captures/compare state, event phase and pending-output flags | Needed to turn the calculated duration into injector start/end events rather than only a fuel accumulator. |

#### Current manual replay fields

The current `from-intermediates` configuration exposes the principal final-stack RAM values directly:

| Configuration field | Firmware value |
| --- | --- |
| `adaptive2596` | `$2596` correction term |
| `signedFuelCorrection2050` | signed `$2050` |
| `signed2610` | optional signed `$2610` |
| `correction24D9` | `$24D9` correction |
| `ram0006` | `$0006` blend term |
| `adaptiveTrim20B9` | `$20B9` adaptive word, neutral at `0x8000` |
| `warmupFuelCorrection2085` | `$2085` CTS warmup factor |
| `afterstartCorrectionC5` | `$00C5` afterstart factor |
| `transientFuelAdd2055`, `transientFuelAdd2057` | `$2055/$2057` transient additions |
| `slowCorrection2590`, `subtractiveFilter2584` | `$2590/$2584` final-stack add/subtract terms |
| `fuelMultiplier2053` | `$2053` synthesized multiplier |
| `fastLambdaFuelCorrection2049` | `$2049` fast lambda correction |
| `stateFlagsA3`, `fuelEventWidthLimitBF` | high-load stage gate inputs `$00A3/$00BF` |

#### Terms that can be automated next

Disassembly is already sufficient to remove several manual inputs once their required state is represented:

- `$2085` can be looked up from CTS axis `$203E` through `0x8408`.
- `$2050` can be selected from ROM scalar `0x81DB` and its mode flags.
- `$2049` can be looked up through `0x84E3` when filtered `$00CC -> $2040` is supplied or simulated.
- Operating state 12 can execute `0x96F3`: raw `$200A * ROM[0x96D0]`, followed by the firmware divide-by-two.
- Afterstart and transient table outputs can be calculated when their counters, flags, previous samples, and accumulators are modeled.
- `$2053` can be synthesized when `$25A1/$25A2`, `$20DE-$20E1`, `$00D0`, period, and gate flags are available.
- The `0x85BA` final addition can be made stateful by carrying `$00A1.40` and the event-width limit between steps.

A full simulator should therefore use a persistent `FuelRuntimeState`, accept a `FuelStepInput` for each elapsed time step, execute producer routines in firmware order, and then call the already implemented `0xE927 -> 0xE5E8 -> 0xE652` final stack. Every derived term should retain its ROM/RAM trace and confidence level.

### Reference stock/MOD2 point

The default 4000-RPM single-point run resolves load axis `7.719` and likely IAT/CTS temperature near `37.2 C` under the current NTC interpretation. At that point:

- stock core spark is `75 raw = 37.5 degrees`;
- MOD2 core spark is `79 raw = 39.5 degrees`, a `+2.0 degree` change;
- MOD2 changes IAT/RPM correction A from `-70` to `-64` and B from `-22` to `-17`;
- both images select quantity trim `+19 raw = +7.422%`;
- `apply-trim-only` therefore produces the same `1074` ticks from a configured `1000`-tick starting pulse.

Those IAT/RPM changes are reported but intentionally do not change final duration in `apply-trim-only`. The degree and millisecond displays remain subject to the spark-scale and timer-tick boundaries below.

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
