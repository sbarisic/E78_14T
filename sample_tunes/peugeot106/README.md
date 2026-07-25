# Marelli IAW 8P.40 Peugeot 106 EPROM Notes

This directory contains reverse-engineering notes and calibration evidence for the Peugeot 106 1.3 Rallye Marelli IAW 8P.40 27C512 image.

## Documents

- `LOGIC.md` - firmware behavior, disassembly notes, map candidates, offset markup, checksum logic, and XDF implementation notes.
- `EVIDENCE.md` - evidence status, external/public-source references, sensor clues, comparison evidence, XDF crash-bisect notes, and generated analyzer snapshots.
- `reverse_eng/v1/IAW8P40_peugeot106_reverse_engineering_report.md` - original conservative executable-code report, code/data boundary findings, and stock/MOD2 diff summary.
- `reverse_eng/v3/README.md` - latest reproducible annotation/symbol-database package and corrected executable ownership model.

## Key Local Files

- `M27C512_original.BIN` - local stock EPROM read.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin` - internet stock duplicate; byte-identical to the local read.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin` - direct tuned-vs-stock comparison image.
- `1_3L_8V_IAW8P40/ecu2_modded.bin` - current road-tested MOD2-derived image with the corrected stock limiter pair, revised WOT timing, additional Bank A smoothing edits, and a valid checksum.
- `IAW8P40_peugeot106_firstpass.xdf` - current broad TunerPro definition.
- `IAW8P40_peugeot106_tunerpro_safe_v014.xdf` - safer TunerPro-focused definition.
- `tools/iaw8p40_analyze.py` - read-only comparison/scanner used to regenerate the analyzer snapshot inside `EVIDENCE.md`.
- `reverse_eng/v1/` - original annotated listing, code ranges, direct-call edges, symbols, vectors, and exact stock/MOD2 difference regions.
- `reverse_eng/v3/` - current raw/annotated listing, canonical symbols, resolved CSV/SQLite outputs, routine code blocks, and ownership regression tests. `v2` is retained as superseded history.

## Regeneration

```powershell
python tools/iaw8p40_analyze.py --write-analysis
```

The command updates only the generated-analysis block in `EVIDENCE.md`. Console-only section output is still available with `--section`.

The v3 annotation regression suite is standard-library-only:

```powershell
python reverse_eng\v3\test_generator.py
```

`reverse_eng\v3\verify_reproducibility.py` currently verifies CSV content but
reports platform-serialization mismatches for ASM line endings and SQLite file
bytes on Windows; `EVIDENCE.md` records the distinction between semantic and
byte-for-byte reproducibility.

## Current Interpretation

- `LOGIC.md` is the source of truth for local code paths, offsets, and XDF naming confidence.
- `EVIDENCE.md` separates confidence, public-source context, same-family comparison evidence, and generated scanner output.
- Public pages and same-family binaries are supporting evidence only. Local disassembly, MOD2 deltas, axes, and controlled behavior remain the authority for Peugeot offsets.

## 2026-07-25 ECU and Road-Test Log

### Stock identity and original MOD2 startup fault

- `1_3L_8V_IAW8P40/ecu2_ori.BIN`, `M27C512_original.BIN`, and `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin` were confirmed byte-identical, with SHA-256 `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681`.
- The untouched `1.3L_8V_IAW8P40_MOD2.bin` had a valid checksum pair (`0x47BE/0xB841`) but started the engine for only about half a second before it stopped.
- The fault was traced to the primary RPM-limiter words at `0x879E-0x87A1`. Stock uses `07 EB 07 EF`, approximately 7400 RPM set and 7386 RPM clear. MOD2 used `00 FA FF FF`; the `0xFFFF` clear threshold cannot be exceeded by the 16-bit engine-period value, so a limiter flag set while the period is initially zero can remain latched.
- Restoring `07 EB 07 EF` and repairing the checksum produced a working `MOD2_fixed_limiter.bin` (`0x48CE/0xB731`). The car then started and continued running normally. That file was subsequently renamed to `ecu2_modded.bin`.

### Timing and limiter history for `ecu2_modded.bin`

- The current image retains the original MOD2 calibration changes; it is not a stock image with only a timing adjustment.
- Relative to the original MOD2, the later WOT bypass-vector edit at `0x8C1D-0x8C30` adds approximately 1 degree from 1000-3200 RPM and 2 degrees from 3501-7500 RPM. The 550-950 RPM sites are unchanged.
- Fourteen additional high-RPM smoothing/boundary cells in default Spark Bank A were changed by approximately 0.5-1.5 degrees.
- Reported WOT AFR was approximately `12.0-12.2`, with no meaningful AFR difference observed between the compared stock and modified pulls.
- A temporary test raised the primary limiter to `07 83 07 87`, approximately 7800.3 RPM set and 7784.1 RPM clear/re-enable. That image had a valid `0x4945/0xB6BA` checksum pair.
- During the 7800 RPM-limiter test, the check-engine lamp reportedly illuminated for about one second and then went out while driving in the normal RPM range. No DTC or live RAM state was captured, so the exact cause is unresolved. The valid checksum makes a simple checksum-repair omission unlikely, but it does not rule out a runtime integrity, limiter-state, or other transient diagnostic event.
- After that observation, the limiter was restored to the stock `07 EB 07 EF` pair: approximately 7400.1 RPM set and 7385.5 RPM clear/re-enable.
- The current checksum pair is `0x4875/0xB78A`; validation gives pair sum `0xFFFF` and byte sum `0xB78A`.
- Current `ecu2_modded.bin` SHA-256: `7361E4D171152D0415312FF62167B255102F703441B4D940E4CCCED4EF806003`.
- Compared with the untouched MOD2 image, the current file differs in 42 bytes: four checksum bytes, four repaired limiter bytes, fourteen Bank A cells, and twenty RPM-only bypass-vector cells. Compared with stock, it differs in 502 bytes.
- The final stock-limiter checksum repair was performed in place without creating another backup.

### Dragy third-gear comparison

The comparison method was changed to a fixed third-gear WOT pull from 50 to
115 km/h so that gear-change time did not contaminate the result. An earlier
run containing a shift was therefore not used as the controlled baseline.

The following are representative verified passes shown during testing, not
means or medians of all runs:

| Speed range | Stock cumulative | `ecu2_modded` cumulative | Time difference | Shorter time |
| --- | ---: | ---: | ---: | ---: |
| 50-60 km/h | 1.76 s | 1.69 s | 0.07 s | 4.0% |
| 50-70 km/h | 3.73 s | 3.56 s | 0.17 s | 4.6% |
| 50-80 km/h | 5.54 s | 5.34 s | 0.20 s | 3.6% |
| 50-90 km/h | 7.40 s | 7.11 s | 0.29 s | 3.9% |
| 50-100 km/h | 9.17 s | 8.87 s | 0.30 s | 3.3% |
| 50-110 km/h | 11.12 s | 10.67 s | 0.45 s | 4.0% |
| 50-115 km/h | 12.02 s | 11.68 s | 0.34 s | 2.8% |

Derived individual segments:

| Segment | Stock | `ecu2_modded` | Modified minus stock |
| --- | ---: | ---: | ---: |
| 50-60 km/h | 1.76 s | 1.69 s | -0.07 s |
| 60-70 km/h | 1.97 s | 1.87 s | -0.10 s |
| 70-80 km/h | 1.81 s | 1.78 s | -0.03 s |
| 80-90 km/h | 1.86 s | 1.77 s | -0.09 s |
| 90-100 km/h | 1.77 s | 1.76 s | -0.01 s |
| 100-110 km/h | 1.95 s | 1.80 s | -0.15 s |
| 110-115 km/h | 0.90 s | 1.01 s | +0.11 s |

Multiple passes were made with both images, and the overall timings were
reported to be fairly close. The representative 50-110 result is about 4.0%
shorter in time (about 4.2% higher average acceleration), but the smaller 2.8%
50-115 difference and normal road-test variation mean the result should not be
attributed solely to the added timing. Same AFR also does not establish
knock safety or prove that additional ignition advance is beneficial.

## Safety

This XDF and the notes are for reverse engineering and inspection. Treat spark labels as strong working names, but do not treat fuel/correction candidates as confirmed main-fuel tuning targets without more disassembly, known map-pack evidence, live behavior, or bench/test validation.
