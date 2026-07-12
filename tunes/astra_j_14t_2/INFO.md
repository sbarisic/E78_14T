# Astra J 1.4T E78 Table Search Notes

Working folder: `E:\Projects\E78_14T\tunes\astra_j_14t_2`

Target binary: `opel_astra_original.bin`

SHA256: `2E562B30BB48A72205F9DD4756E152BC44EEF6B07D2F76F3FE25E222952824CD`

Primary working XDF: `E78_Astra_047922_TableSearch.xdf`

## Purpose

This folder is for locating and documenting tables in `opel_astra_original.bin`, especially tables seen in HP Tuners/VCM Editor and then represented in TunerPro XDF form.

`E78_HexView.xdf` in `E:\Projects\E78_14T\xdf` is used as a numeric raw view in VCM Editor to see where bytes changed and how much. `E78_Astra_047922_TableSearch.xdf` is the focused TunerPro work file for the `HexView047922` area and the nearby knock-airmass calibration block.

## Project Orientation

Goal: build a usable TunerPro XDF for the Opel Astra J 1.4T E78 calibration by finding HP Tuners/VCM Editor tables in `opel_astra_original.bin`, validating the offsets against available Damos/WinOLS/reference-XDF sources, and recording enough evidence that future work can continue without rediscovering the same landmarks.

Primary working files:

- Main folder: `E:\Projects\E78_14T\tunes\astra_j_14t_2`
- Target binary: `E:\Projects\E78_14T\tunes\astra_j_14t_2\opel_astra_original.bin`
- Working XDF: `E:\Projects\E78_14T\tunes\astra_j_14t_2\E78_Astra_047922_TableSearch.xdf`
- Knowledge log: `E:\Projects\E78_14T\tunes\astra_j_14t_2\INFO.md`
- Raw VCM Editor numeric view: `E:\Projects\E78_14T\xdf\E78_HexView.xdf`
- Load-test/quarantine XDFs: `E:\Projects\E78_14T\tunes\astra_j_14t_2\_quarantine\load_tests`

Important source/reference files:

- Damos/WinOLS CSV for the Astra OS: `E:\Projects\E78_14T\sources\Uni78\DamosCSVParser\data\winols_astra.csv`
- Corsa reference/change-bin folder: `E:\Projects\E78_14T\tunes\Opel Corsa E 1.4 Turbo 2019\change_everything_bins`
- Corsa original bin: `E:\Projects\E78_14T\tunes\Opel Corsa E 1.4 Turbo 2019\change_everything_bins\Original.bin`
- Corsa edited bin: `E:\Projects\E78_14T\tunes\Opel Corsa E 1.4 Turbo 2019\change_everything_bins\Change1.bin`
- Corsa sandbox bin: `E:\Projects\E78_14T\tunes\Opel Corsa E 1.4 Turbo 2019\change_everything_bins\Sandbox.bin`
- Corsa local WinOLS export: `E:\Projects\E78_14T\tunes\Opel Corsa E 1.4 Turbo 2019\change_everything_bins\winols_desc.csv`
- Corsa local XDFs: `E78_Test.xdf`, `E78_Adam.xdf`, and `E78_DesiredECT_OS_12646746.xdf` in the Corsa `change_everything_bins` folder.
- Shared XDF references: `E:\Projects\E78_14T\xdf\acdelco_e78_views.xdf`, `E:\Projects\E78_14T\xdf\acdelco_e78_os12669508.xdf`, and `E:\Projects\E78_14T\xdf\E78_DesiredECT_OS_12646746.xdf`
- Relocation report: `E:\Projects\E78_14T\tunes\astra_j_14t_2\opel_astra_original_relocation_report.md`
- High-confidence relocation CSV: `E:\Projects\E78_14T\tunes\astra_j_14t_2\relocations_high_confidence.csv`

Useful meaning of each source:

- `winols_astra.csv` is the main symbol and metadata source. It gives source names, comments, nominal dimensions, unit, factor/offset, data organization, and source addresses. Its addresses are not always the final Astra BIN address, so use it as a map, not as proof.
- Reference XDFs show table shapes and TunerPro XML conventions. They can have wrong or misleading data types for this BIN; always validate the bytes. Example: `E78_DesiredECT_OS_12646746.xdf` declares a THMC table as 32-bit floats, but the real bytes are packed `00xx` word pairs.
- HP Tuners screenshots provide table names, dimensions, axes, units, and approximate values. Screenshots are often from a different or edited calibration, so exact values may differ.
- `E78_HexView.xdf` and VCM Editor HexView screenshots show where bytes changed. Treat the HexView window base as a clue; it is not always a direct file-address base in this Astra BIN.
- Edited/reference bins are best for fingerprints: compare original vs edited bytes, then search the same changed byte pattern or nearby table structure in `opel_astra_original.bin`.
- Quarantine/load-test XDFs preserve intermediate states. Use them when TunerPro starts crashing or when bisecting a bad table/category definition.

## Table-Finding Methodology

Default workflow for a new HP Tuners table request:

1. Capture the HP Tuners metadata from the user screenshot: ECM number, full display name, units, axis labels, dimensions, value range, and visible values.
2. Search `winols_astra.csv` by likely subsystem prefix and keywords. Examples: `BSTC`/`BSTD` for turbo, `ECPR` for engine torque, `DTRC` for driver demand, `FEQR` for enrichment, `SPRK` for spark, `THMC` for thermal/coolant.
3. Inspect reference XDFs for matching table names, dimensions, axes, math, and storage type.
4. Decode candidate byte regions from the Astra bin as all plausible formats: 8-bit signed/unsigned, 16-bit big-endian signed/unsigned, 32-bit big-endian float, and common fixed-point scales.
5. Search for exact fingerprints first: full table bytes, axis bytes, changed-bin byte diffs, or known reference-table byte sequences.
6. If exact fingerprints fail, search by shape and values: dimensions, monotonic axes, common axis sets, value ranges, repeated neighboring tables, and local count markers.
7. Establish relocation deltas from source/reference addresses to Astra target addresses. Prefer a cluster of matching table/axis deltas over a single table hit.
8. Confirm axes separately. A table body can be right while the nearest duplicate axis is wrong; record X and Y axis addresses explicitly.
9. Add the table to the XDF only when the offset, dimensions, storage format, math, units, and axes are good enough to be useful. Mark candidates as candidate/raw when uncertainty remains.
10. Validate the XDF mechanically: XML parse, unique `uniqueid` values, category membership references, and address bounds against the 3 MB bin.
11. Preserve a backup or load-test XDF before risky edits. If TunerPro crashes, bisect by table group and category metadata before changing confirmed offsets.
12. Update this `INFO.md` with the new table name, address, dimensions, format, math, units, axes, confidence, source evidence, and any caveats.

Confidence rules:

- Confirmed: exact changed-byte or reference fingerprint plus matching axes/shape/value range, or multiple independent sources agree.
- High confidence: strong symbol/cluster relocation and matching axes/shape/value range, but no edited-bin fingerprint yet.
- Candidate: plausible local match, but one or more of source symbol, axes, values, or conversion is unresolved.
- Raw/inspection view: useful for looking at bytes, but not yet a proper table definition.

XDF editing conventions:

- TunerPro category convention used here: `<CATEGORY index="0x0">` is referenced by `<CATEGORYMEM category="1">`; category declarations are zero-based and table memberships are one-based.
- Keep category names stable. Prior TunerPro crashes were caused by bad XDF metadata/order, so add tables in small groups and preserve load-test copies.
- Use 32-bit big-endian floats with `mmedtypeflags="0x10000"` only after byte-level float decoding is verified.
- Use `mmedtypeflags="0x01"` for signed table data where previous definitions established it.
- Do not blindly copy reference XDF storage definitions. Verify the target bytes first.
- Do not edit `opel_astra_original.bin` directly without checksum/CVN handling.

## Current Confirmed Tables

### HP Tuners [ECM] 33482 - Turbocharger Knock Max Airmass

Confirmed TunerPro entries:

- Editable native view: `TurbochargerKnockMaxAirmass_EDIT_MG_X1000_04DD68`
- Decimal display-only view: `TurbochargerKnockMaxAirmass_DISPLAY_G_DO_NOT_EDIT_04DD68`

- Z table address: `0x04DD68`
- Format: `8 x 11`, 32-bit big-endian float
- Stored/display values: native `mg/cyl`, approximately `275-725` stock
- TunerPro math: `X`
- Editing rule: enter the HP Tuners value in grams multiplied by `1000`; for example, enter `485` for `0.485 g`
- Reason: TunerPro's native 32-bit floating-point type does not support a conversion transformation for safe write-back. The earlier `X / 1000` view could display correctly but wrote `0.485` directly into storage instead of `485`. This matches the TunerPro author's documented limitation: <https://forum.tunerpro.net/viewtopic.php?t=4034> and the floating-point release note at <https://www.tunerpro.net/downloadApp.htm>.
- Defensive display: zero decimal places and an editable range of `100-1000 mg/cyl`. A correctly loaded stock BIN must show values around `275-725`, never `0.275-0.725`.
- Decimal display companion: `0.001 * X`, three decimal places, and units `g (display only)`. It shows stock values as approximately `0.275-0.725`, but must never be used to edit or apply table functions because TunerPro cannot safely write a transformed 32-bit float.
- This table cannot be a base-address-only clone of `TurbochargerKnockAirmassScav_04E350`. Max uses 88 consecutive 32-bit IEEE-754 floats (`352` bytes) at `0x04DD68`; Scav uses 88 consecutive 16-bit unsigned counts (`176` bytes) at `0x04E350` with `0.0000625 * X`. A full-bin search found the exact Max first-row sequence only at `0x04DD68` in float form and found no 16-bit scaled duplicate.
- The 2026-07-12 modified BIN proves the distinction: all 88 Max cells stored at `0x04DD68` match the Scav engineering values within `0.0005`, but they are stored as float `0.275-0.900` instead of native float `275-900`. Therefore the apparent `0` and `1` values in the guarded editor are the corrupt floats rounded to zero decimal places, not a table-address or decimal-place error.
- X axis address: `0x04DEC8`
- X axis values: `-25, -20, -15, -13, -11, -9, -7, -5, -3, -1, 0`
- Y axis address: `0x04DF3C`
- Y axis values: `1400, 1700, 2000, 2300, 3000, 4000, 5000, 6000`

Equivalent HP Tuners values in grams for the stock BIN:

```text
RPM \ deg   -25    -20    -15    -13    -11     -9     -7     -5     -3     -1      0
1400      0.275  0.330  0.380  0.400  0.425  0.450  0.485  0.525  0.565  0.605  0.625
1700      0.285  0.340  0.395  0.415  0.440  0.465  0.500  0.540  0.585  0.625  0.645
2000      0.315  0.375  0.440  0.475  0.510  0.550  0.590  0.630  0.665  0.700  0.720
2300      0.320  0.385  0.460  0.495  0.530  0.570  0.615  0.650  0.685  0.715  0.725
3000      0.330  0.405  0.490  0.530  0.570  0.620  0.665  0.705  0.725  0.725  0.725
4000      0.340  0.435  0.535  0.580  0.620  0.665  0.705  0.715  0.725  0.725  0.725
5000      0.330  0.410  0.500  0.540  0.585  0.630  0.675  0.710  0.725  0.725  0.725
6000      0.300  0.390  0.470  0.510  0.550  0.590  0.620  0.630  0.635  0.640  0.640
```

## Scan Result - 2026-07-07

Task: compare the HP Tuners `[ECM] 33482 - Turbocharger Knock Max Airmass` screenshot against `opel_astra_original.bin` and search for an `8 x 11` float table with similar values near `TurbochargerKnockMaxAirmass`.

Result: the best full-bin match is the already-added table at `0x04DD68`. The next best matches are the same table shifted by `-0x04`, `+0x04`, `-0x08`, etc., not separate tables.

Top score from the scan:

- `0x04DD68`, big-endian float, stored as `g * 1000`
- RMSE vs screenshot values: `0.0554 g`
- Mean absolute error vs screenshot values: `0.0451 g`
- Range after conversion: `0.275-0.725 g`
- Row monotonicity check: `80/80` adjacent row steps nondecreasing within tolerance

The HP Tuners screenshot values are lower in some cells, but the table shape, axes, dimensions, value range, and full-bin similarity score line up cleanly with `0x04DD68`.

### HP Tuners [ECM] 33495 - Knock Airmass Scav

Confirmed TunerPro entry: `TurbochargerKnockAirmassScav_04E350`

- Z table address: `0x04E350`
- Format: `8 x 11`, 16-bit big-endian unsigned
- Stored values: raw counts at `0.0625 mg/count`
- TunerPro math: `0.0000625 * X`
- Display units: `g`
- X axis address: `0x04E588`
- X axis values: `-25, -20, -15, -13, -11, -9, -7, -5, -3, -1, 0`
- Y axis address: `0x04E50C`
- Y axis values: `1400, 1700, 2000, 2300, 3000, 4000, 5000, 6000`

Displayed table values in this BIN:

```text
RPM \ deg   -25    -20    -15    -13    -11     -9     -7     -5     -3     -1      0
1400      0.270  0.300  0.335  0.350  0.370  0.395  0.430  0.475  0.530  0.585  0.615
1700      0.295  0.330  0.370  0.390  0.415  0.445  0.480  0.525  0.580  0.635  0.665
2000      0.315  0.360  0.410  0.435  0.460  0.490  0.530  0.575  0.620  0.670  0.695
2300      0.325  0.375  0.440  0.470  0.500  0.535  0.570  0.605  0.645  0.690  0.715
3000      0.330  0.400  0.470  0.500  0.535  0.570  0.610  0.645  0.675  0.705  0.725
4000      0.340  0.425  0.510  0.545  0.580  0.615  0.655  0.690  0.715  0.725  0.725
5000      0.330  0.400  0.475  0.510  0.545  0.580  0.620  0.660  0.690  0.710  0.720
6000      0.300  0.375  0.445  0.475  0.510  0.535  0.560  0.580  0.605  0.630  0.645
```

Evidence:

- Your edited `[ECM] 33495` HexView screenshot shows a changed 16-bit byte-pair block in the second knock/scav neighborhood.
- Reference `Astra J A14NET- ECU Orig.bin` has `KtBSTC_m_MaxKnk` as a 16-bit `0.0625 mg/count` table in this neighborhood.
- In this OS, the coherent relocated block is at `0x04E350`, using the second spark-retard axis at `0x04E588` and the `1400..6000` RPM axis at `0x04E50C`.

### Knock-airmass to total-airflow calculation - 2026-07-12

For this `1364 cc`, four-cylinder, four-stroke engine, each cylinder has one intake event every two crankshaft revolutions. A table cell in `g/cyl` converts to ideal total engine airflow as:

`MAF (g/s) = airmass (g/cyl) * 4 cylinders * RPM / 120 = airmass * RPM / 30`

Displacement is not required for this mass-per-intake-event conversion. It gives a swept volume of `341 cc/cyl` and theoretical volume flow `1.364 * RPM / 120 L/s`, which can be used only for approximate charge-density/MAP context.

Current BIN comparison:

- `opel_astra_original.bin`: SHA-256 `2E562B30BB48A72205F9DD4756E152BC44EEF6B07D2F76F3FE25E222952824CD`.
- `opel_astra_mod1.bin`: SHA-256 `F1C6BA04B0C0D912A8C66179F07F5D668B337DE0566CBDC14BF571EC35923E26` after synchronizing both knock-airmass tables to the larger values.
- Turbocharger Knock Max Airmass at `0x04DD68` now has `30/88` cells changed from stock and is engineering-value equivalent to the modified Scav table in all 88 cells. Max stores native 32-bit float `mg/cyl`; Scav stores 16-bit counts at `0.0625 mg/count`.
- Knock Airmass Scav at `0x04E350` has `83/88` changed cells.
- In `mod1`, all eight Scav rows from `-25` through `-7 deg` are exact copies of the stock Max Airmass table. The `-5`, `-3`, and `-1 deg` cells then form a linear ramp from the `-7 deg` value to a custom row endpoint, and the `0 deg` cell repeats that endpoint.
- The custom `-1/0 deg` Scav endpoints by RPM are `0.625, 0.645, 0.750, 0.900, 0.900, 0.900, 0.800, 0.750 g/cyl` at `1400, 1700, 2000, 2300, 3000, 4000, 5000, 6000 rpm`.

Least-retarded (`0 deg`) limits and calculated total airflow:

| RPM | Stock Max g/cyl | Stock Max g/s | Stock Scav g/cyl | Stock Scav g/s | mod1 Scav g/cyl | mod1 Scav g/s | Scav delta g/s |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1400 | 0.625 | 29.17 | 0.615 | 28.70 | 0.625 | 29.17 | +0.47 |
| 1700 | 0.645 | 36.55 | 0.665 | 37.68 | 0.645 | 36.55 | -1.13 |
| 2000 | 0.720 | 48.00 | 0.695 | 46.33 | 0.750 | 50.00 | +3.67 |
| 2300 | 0.725 | 55.58 | 0.715 | 54.82 | 0.900 | 69.00 | +14.18 |
| 3000 | 0.725 | 72.50 | 0.725 | 72.50 | 0.900 | 90.00 | +17.50 |
| 4000 | 0.725 | 96.67 | 0.725 | 96.67 | 0.900 | 120.00 | +23.33 |
| 5000 | 0.725 | 120.83 | 0.720 | 120.00 | 0.800 | 133.33 | +13.33 |
| 6000 | 0.640 | 128.00 | 0.645 | 129.00 | 0.750 | 150.00 | +21.00 |

Approximate pressure context only: dividing by `0.341 L/cyl` gives charge density. At `25 deg C` and an assumed `100%` volumetric efficiency, `0.900 g/cyl` corresponds to about `226 kPa absolute`, while `0.750 g/cyl` corresponds to about `188 kPa absolute`. Real MAP differs with charge temperature, volumetric efficiency, valve timing, residual gas, and model conventions. These tables are knock-related airmass limits, not boost targets or proof of achieved airflow.

### Stock versus mod1 power estimate - 2026-07-12

Relevant `mod1` changes considered for this estimate:

- Peak Engine Torque, Max Engine Torque Limit, and Overboost Torque Limit are raised to `340 Nm` from `3000 rpm` upward. These are ceilings/model limits, not a commanded or achievable torque curve.
- Driver Demand A/B/C are unchanged through the `80%` pedal row; the `90%` row is increased about `10%` and the `100%` row about `20%`.
- Max Boost Limit changes from `205-225 kPa` to `240 kPa` from `-30` through `45 deg C`, then `200 kPa` at `60 deg C`.
- Turbo Overspeed Max Pressure Ratio changes from a falling `3.00-1.00` curve to `3.25` across all eight airflow breakpoints. Compressor Surge Limit is raised about `10%`.
- Knock Airmass Scav is changed as documented above, and Turbocharger Knock Max Airmass is now synchronized to the same larger engineering values using its native 32-bit float `mg/cyl` storage.
- High/Low Octane base spark, Flex Fuel/VCP/Humidity spark tables, PE EQ ratio, PE enable/delay/ramp tables, and Knock Enrichment fueling are byte-for-byte unchanged. Spark smoothing reference count changes from `20` to `5`, but this does not establish an advance increase.
- P0068 airflow-correlation diagnostic thresholds, driveline torque scalars, TCS enable temperature, and cold ECT tables are changed but do not directly create engine power.

The stock power estimate uses the most restrictive confirmed stock torque limit at each requested RPM and `hp = Nm * RPM / 7127`. It predicts approximately `85, 115, 147, 142 hp` at `3000, 4000, 5000, 6000 rpm`, which is internally consistent with the stock airflow ceilings.

The raw `340 Nm` mod ceiling mathematically equals `143, 191, 239, 286 hp` at those RPMs, but the stock turbo/airflow model cannot support that curve. It must not be reported as expected output.

For an airflow-supported estimate, use the modified least-retarded Scav limits and a gasoline conversion range of approximately `1.20-1.30 crank hp per g/s`. This range is consistent with the unchanged PE table, which is roughly `13.2 AFR` around `3000-4000 rpm`, `12.3` around `5000 rpm`, and `12.0` around `6000 rpm` at the middle temperature row.

| RPM | Stock limiting torque | Stock estimate | mod1 Scav airflow | mod1 airflow-supported estimate | Approx. mod1 torque equivalent |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 3000 | 201 Nm | 85 hp | 90.0 g/s | 108-117 hp | 257-278 Nm |
| 4000 | 205 Nm | 115 hp | 120.0 g/s | 144-156 hp | 257-278 Nm |
| 5000 | 209 Nm | 147 hp | 133.3 g/s | 160-173 hp | 228-247 Nm |
| 6000 | 169 Nm | 142 hp | 150.0 g/s | 180-195 hp | 214-232 Nm |

Interpretation: `mod1` appears calibrated to permit roughly a `180-195 hp` airflow ceiling near `6000 rpm`, not `286 hp`. Both normal Max and Scav knock-airmass paths now contain the same larger engineering values, removing the previous stock-Max-versus-modified-Scav control-path discrepancy. This remains an upper calibration-supported estimate, not a dyno prediction; actual output depends on achieved boost/load, charge temperature, lambda, ignition timing, knock correction, and turbo efficiency.

Post-synchronization rerun: the stock Max Engine Torque Limit curve peaks at approximately `146.6 hp` at `5000 rpm`. The synchronized mod tables permit `150 g/s` at `6000 rpm`, corresponding to `180-195 crank hp` with the `1.20-1.30 hp/(g/s)` assumption and a central estimate of `187.5 hp`. The raw `340 Nm` limit still calculates to `286.2 hp` at `6000 rpm`, but remains only a non-achievable calibration ceiling.

## HexView047922 Findings

`HexView047922` starts at raw file address `0x047922`.

Useful items currently represented in the XDF:

- `FloatVector047DEC_8_RPMAxis`: `0x047DEC`, values `1000, 1500, 2000, 2500, 3000, 4000, 5000, 6000`
- `FloatTable047E0C_2x8_Candidate`: `0x047E0C`, a coherent `2 x 8` direct-float table after that RPM axis

This area did not contain the HP Tuners `[ECM] 33482` `8 x 11` airmass table in this BIN. The confirmed table is `0x6446` bytes after `0x047922`.

## Nearby Knock-Air Calibration Cluster

Known axes and clusters near the confirmed table:

- Spark-retard axis `-25..0`: `0x04DEC8`
- RPM axis `1400..6000`: `0x04DF3C`
- Second exact spark-retard axis `-25..0`: `0x04E588`
- Duplicate `1400..6000` RPM axes: `0x04E50C` and `0x04E52C`
- Nearby `1300..6000` RPM axis: `0x04E62C`

`TurbochargerKnockAirmassScav_Candidate_04E088` remains an inspection view only. It is an `8 x 11` direct-float block nearby, but it is not a close match to `[ECM] 33482` or `[ECM] 33495` and should not be treated as confirmed.

`TurbochargerKnockAirmassScav_04E350` is the confirmed `[ECM] 33495` equivalent. The nearby duplicate `1400..6000` RPM axis at `0x04E52C` appears to belong to a neighboring table; the `[ECM] 33495` table uses `0x04E50C`.

### HP Tuners [ECM] 33460 - Max Boost Limit

Confirmed TunerPro entry: `MaxBoostLimit_04DFB4`

- Z table address: `0x04DFB4`
- Format: `1 x 7`, 32-bit big-endian float
- TunerPro math: `X`
- Display units: `kPa`
- Editor/display range: `0-512 kPa`
- X axis address: `0x04E4F0`
- X axis values: `-30, -15, 0, 15, 30, 45, 60`
- X axis units: `deg C`
- Y axis: static row label `Boost Limit`

Displayed table values in this BIN:

```text
Manifold Temp (deg C)   -30      -15       0      15      30      45      60
Boost Limit (kPa)     205.000  208.333  211.667 215.000 218.333 221.667 225.000
```

Evidence:

- Your HP Tuners `[ECM] 33460` screenshot shows a `1 x 7` Max Boost Limit table with manifold-temperature axis `-30..60`.
- The target BIN has the exact 32-bit big-endian float sequence at `0x04DFB4`.
- The exact 32-bit big-endian float axis `-30, -15, 0, 15, 30, 45, 60` is at `0x04E4F0`.
- The reference description names this table `KtBSTC_p_MaxBoostLim`.

### HP Tuners [ECM] 33491 / 33435 - Turbo Pressure Ratio and Surge

XDF category tags are currently stripped from the main XDF because TunerPro crashed when category declarations/memberships were present. These entries are left uncategorized until table-level load testing passes.

Confirmed/high-confidence TunerPro entries:

- `[ECM] 33491 Turbo Overspeed Max Pressure Ratio`: `TurboOverspeedMaxPressureRatio_04D9BC`
- `[ECM] 33435 Compressor Surge Limit`: `CompressorSurgeLimit_029858`

`[ECM] 33491 Turbo Overspeed Max Pressure Ratio`:

- Z table address: `0x04D9BC`
- Source/reference name: `KaBSTC_r_CompPressRatioMaxSpd`
- Format: `1 x 8`, 32-bit big-endian float
- TunerPro math: `X`
- Display units: `Pressure Ratio`
- Editor/display range: `0.00-10.00`
- X axis address: `0x04DC44`
- X axis source/reference name: `KaBSTC_dm_CompCor`
- X axis values: `124.75, 128.5, 132.3, 136.1, 139.85, 143.6, 147.4, 151.2`
- X axis units: `g/s`

Displayed table values in this BIN:

```text
Mass Airflow (g/s)  124.75  128.50  132.30  136.10  139.85  143.60  147.40  151.20
Pressure Ratio       3.00    2.85    2.675   2.475   2.275   1.975   1.575   1.00
```

Evidence/caveat:

- The Corsa reference row `KaBSTC_r_CompPressRatioMaxSpd` is described as "Maximum compressor pressure ratio to avoid turbo overspeed or surge" and is indexed by corrected massflow.
- The target axis at `0x04DC44` is the best full-BIN match to the HPT screenshot axis; TunerPro will display it as `124.8, 128.5, 132.3, 136.1, 139.9, 143.6, 147.4, 151.2`.
- The target row at `0x04D9BC` is the only plausible 8-cell pressure-ratio row in the local cluster before that axis. The middle cells are higher than the screenshot values (`2.475/2.275/1.975/1.575` vs screenshot `2.43/2.05/1.78/1.42`), so treat this as the stock Astra original equivalent unless an edited-bin fingerprint proves a separate target.

`[ECM] 33435 Compressor Surge Limit`:

- Z table address: `0x029858`
- Source/reference name: `KtBSTD_r_SurgeLim`
- Format: `1 x 6`, 32-bit big-endian float
- TunerPro math: `X`
- Display units: `Pressure Ratio`
- Editor/display range: `0.00-10.00`
- X axis address: `0x029870`
- X axis source/reference name: `KnBSTD_dm_AirFlowBP`
- X axis values: `16, 18, 36, 41, 77, 103`
- X axis units: `g/s`

Displayed table values in this BIN:

```text
Mass Airflow (g/s)  16    18    36    41    77    103
Surge Limit         1.12  1.23  1.60  1.85  2.46  3.20
```

Evidence:

- The reference row `KtBSTD_r_SurgeLim` is described as the turbo compressor bypass valve diagnosis surge area limit.
- Both the Z row at `0x029858` and the X axis at `0x029870` are exact 32-bit big-endian float matches to the HP Tuners screenshot.

### HP Tuners [ECM] 32920/32923/32924 - Torque Tables

Confirmed TunerPro entries:

- `[ECM] 32920 Peak Engine Torque`: `PeakEngineTorque_0534A4`
- `[ECM] 32923 Max Engine Torque Limit`: `MaxEngineTorqueLimit_0535A4`
- `[ECM] 32924 Overboost Torque Limit`: `OverboostTorqueLimit_053464`

Shared axes:

- RPM X axis address: `0x053AD0`
- RPM X axis values: `750, 1500, 1750, 1850, 2000, 2500, 3000, 3500, 4000, 4500, 4800, 4918, 5000, 5500, 6000, 6500`
- Alcohol composition Y axis address: `0x053B10`
- Alcohol composition Y axis values: `0, 20, 60, 80`

Format and range:

- Storage: 32-bit big-endian float
- TunerPro math: `X`
- Display units: `Nm`
- Editor/display range: `-8192 to 8192 Nm`

`[ECM] 32920 Peak Engine Torque`:

- Z table address: `0x0534A4`
- Format: `4 x 16`

```text
Alcohol % \ RPM   750 1500 1750 1850 2000 2500 3000 3500 4000 4500 4800 4918 5000 5500 6000 6500
0                200  200  214  218  218  219  224  227  229  233  235  239  236  213  196  173
20               200  200  214  218  218  219  224  227  229  233  235  239  236  213  196  173
60               200  200  214  218  218  219  224  227  229  233  235  239  236  213  196  173
80               200  200  214  218  218  219  224  227  229  233  235  239  236  213  196  173
```

`[ECM] 32923 Max Engine Torque Limit`:

- Z table address: `0x0535A4`
- Format: `4 x 16`

```text
Alcohol % \ RPM   750 1500 1750 1850 2000 2500 3000 3500 4000 4500 4800 4918 5000 5500 6000 6500
0                150  157  193  198  198  199  201  203  205  207  208  212  209  186  169  148
20               150  157  193  198  198  199  201  203  205  207  208  212  209  186  169  148
60               150  157  193  198  198  199  201  203  205  207  208  212  209  186  169  148
80               150  157  193  198  198  199  201  203  205  207  208  212  209  186  169  148
```

`[ECM] 32924 Overboost Torque Limit`:

- Z table address: `0x053464`
- Format: `1 x 16`

```text
RPM     750 1500 1750 1850 2000 2500 3000 3500 4000 4500 4800 4918 5000 5500 6000 6500
Torque  185  195  207  212  220  232  237  239  243  248  253  255  254  238  221  202
```

Evidence:

- The HP Tuners screenshots show 16-point RPM axes and, for `[ECM] 32920`/`32923`, the 4-point alcohol composition axis `0, 20, 60, 80`.
- The target BIN has the exact 16-point RPM axis at `0x053AD0` and exact alcohol axis at `0x053B10`.
- Full-bin float similarity scan against the screenshot values found the strongest coherent ECPR torque cluster at `0x053464-0x053664`.
- The reference descriptions identify the neighboring ECPR torque calibrations as `KtECPR_M_Overboost` and `KtECPR_M_IndicatedPeakTorq`.
- The HexView04C122 screenshot is a useful visual clue, but it does not map byte-for-byte to raw `0x04C122` in `opel_astra_original.bin`; the confirmed target tables are the float cluster above.

### HP Tuners [ECM] 33050 - Driver Demand A/B/C

Confirmed TunerPro entries:

- `[ECM] 33050 Driver Demand - A`: `DriverDemand_A_046944`
- Driver Demand - B equivalent: `DriverDemand_B_046DC8`
- Driver Demand - C equivalent: `DriverDemand_C_04724C`

Source/reference names:

- `KtDTRC_P_M_PedProgReqA`
- `KtDTRC_P_M_PedProgReqB`
- `KtDTRC_P_M_PedProgReqC`

Format and range:

- Storage: 32-bit big-endian float
- Format: `17 x 17`
- TunerPro math: `X`
- HP Tuners nominal edit range: `-500000 to 500000`
- TunerPro graph/display Z range in the XDF: `-100 to 160 Nm`

Target axes in `opel_astra_original.bin`:

- X axis address: `0x047D0C`
- X axis values: `400, 800, 1200, 1600, 2000, 2400, 2800, 3200, 3600, 4000, 4400, 4800, 5200, 5600, 6000, 6400, 6800`
- Y axis address: `0x047C1C`
- Y axis values: `0, 3, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100`

Target table addresses:

- Driver Demand A: `0x046944`, target min/max approximately `-20.096` to `139.520`
- Driver Demand B: `0x046DC8`, target min/max approximately `-20.096` to `139.520`
- Driver Demand C: `0x04724C`, target min/max approximately `-20.096` to `139.520`

Quick readback from this BIN:

```text
A row 0%:    0.00  0.00 -1.28 -2.56 -4.42 -6.28 -7.54 -8.79 -10.05 -11.30 -12.56 -13.82 -15.07 -16.33 -17.58 -18.84 -20.10
A row 100%:  8.34 19.90 31.46 43.03 54.59 66.16 76.64 87.12  97.60 108.08 118.56 129.04 139.52 139.52 139.52 139.52 139.52
B row 0%:    0.00  0.00  0.00 -2.56 -5.12 -6.28 -7.54 -8.79 -10.05 -11.30 -12.56 -13.82 -15.07 -16.33 -17.58 -18.84 -20.10
B row 100%:  8.34 19.90 31.46 43.03 54.59 66.16 76.64 87.12  97.60 108.08 118.56 129.04 139.52 139.52 139.52 139.52 139.52
```

Notes:

- In this target BIN, Driver Demand C is byte-identical to Driver Demand A.
- The HP Tuners screenshot row values match the Corsa 2019 WinOLS reference `KtDTRC_P_M_PedProgReqA` more closely than the target `opel_astra_original.bin` values. The target has a milder relocated calibration.
- The source/reference X axis is `500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500`; an exact copy of that axis was not found in `opel_astra_original.bin`.
- The exact source/reference pedal axis at `0x040E04` relocates by `+0x6E18` to the target pedal axis at `0x047C1C`.
- The clean target table bodies begin one 17-float row after the raw source+`0x6E18` body anchors, at `0x046944`, `0x046DC8`, and `0x04724C`.
- A full-bin signed-16-bit similarity scan did not find a better direct match to the HP Tuners screenshot values.
- The raw target bytes at `0x03D922 + 0x0500..0x06F0` are erased `0xFF`, so the HP Tuners `HexView03D922` screenshot is not a direct raw-file address in `opel_astra_original.bin`.
- 2026-07-07 graph-view fix: TunerPro's table graph view did not behave well with the original `-500000 to 500000` Z min/max on these small-value float tables. The XDF now keeps the linked embedded X/Y axis addresses, adds static `LABEL` values for graph compatibility, adds Z units `Nm`, and uses a graph-scaled Z min/max of `-100 to 160`.

### HP Tuners Airflow Correlation / P0068 - TPSD Limits

Confirmed TunerPro entries:

- `Enable RPM`: `AirflowCorrelationEnableRPM_07A570`
- `Max Airflow vs. RPM`: `MaxAirflowVsRPM_07A59C`
- `Max Airflow vs. IGNV`: `MaxAirflowVsIGNV_07A586`
- `Airflow Delta` / `[ECM] 14044 Maximum Airflow Delta vs. TPS`: `MaximumAirflowDeltaVsTPS_07A59E`
- `MAP Delta` / `[ECM] 14045 Maximum MAP Delta vs. TPS`: `MaximumMAPDeltaVsTPS_07A5B2`

Format and range:

- `Enable RPM`: 32-bit big-endian float at `0x07A570`.
- The four `1 x 9` tables use 16-bit big-endian storage and value math `X / 128`.
- `Max Airflow vs. RPM`, `Max Airflow vs. IGNV`, and `Airflow Delta` are unsigned `g/s` views.
- `MAP Delta` is signed-style, XDF range `-256 to 256 kPa`.

Target axis in `opel_astra_original.bin`:

- `Max Airflow vs. RPM`: generated RPM axis `600, 1400, 2200, 3000, 3800, 4600, 5400, 6200, 7000`.
- `Max Airflow vs. IGNV`: generated voltage axis `6, 7, 8, 9, 10, 11, 12, 13, 14 V`.
- TPS axis address: `0x07A5C6`
- TPS axis storage: 16-bit big-endian, math `X / 655.35`
- Target TPS axis values: `1.0, 6.0, 12.0, 15.0, 20.0, 25.0, 30.0, 40.0, 60.0`

Target table addresses and readback:

```text
Enable RPM @ 0x07A570:
800

Max Airflow vs. IGNV @ 0x07A586:
1.48 1.95 13.74 42.67 102.67 205.24 300.70 300.70 300.70

Max Airflow vs. RPM @ 0x07A59C:
0.07 5.50 7.00 9.60 11.70 14.84 19.13 27.27 56.00

14044 / Airflow Delta @ 0x07A59E:
5.50 7.00 9.60 11.70 14.84 19.13 27.27 56.00 150.00

14045 / MAP Delta @ 0x07A5B2:
36.00 37.00 32.00 42.00 41.50 46.00 47.00 69.00 150.00
```

Evidence:

- The Astra WinOLS CSV names this family as TPSD airflow actuation diagnostics: `KeTPSD_n_AirflowActMin`, `KtTPSD_dm_MaxMAF_VsVoltage`, `KtTPSD_dm_MaxMAF_VsRPM`, `KtTPSD_dm_MAF_DesThrDelt`, and `KtTPSD_p_MAP_DesThrDelt`.
- The CSV/Damos TPSD source block maps to this Astra target block with a local `+0x1AB0` shift: `0x078AC0 -> 0x07A570`, `0x078AD6 -> 0x07A586`, `0x078AEC -> 0x07A59C`, `0x078AEE -> 0x07A59E`, and `0x078B02 -> 0x07A5B2`.
- `Max Airflow vs. RPM` intentionally starts two bytes before `Airflow Delta`; this overlap exists in the WinOLS/Damos layout too.
- The HP Tuners screenshot values are an exact 16-bit big-endian `X / 128` fingerprint in the Corsa reference bin: `[ECM] 14044` at `0x07BFEE`, `[ECM] 14045` at `0x07C002`.
- The reference TPS axis follows at `0x07C016`, stored as 16-bit big-endian percent with math `X / 655.35`, and decodes to `5, 12, 15, 20, 25, 30, 35, 40, 60`.
- A local exact-context match maps source `0x07BF00` to target `0x07A4C8`, so the surrounding neighborhood relocates by `-0x1A38`; the clean table-to-table starts use `-0x1A50`, landing at `0x07A59E` and `0x07A5B2`.
- The HP Tuners `HexView07B922` screenshot is not a direct raw-file address in `opel_astra_original.bin`; raw `0x07B922 + 0x0650` is erased `0xFF` in this target BIN.
- The target calibration differs from the reference screenshot values and has a different TPS axis first cells, but the table shape, count markers, axis encoding, and local relocation are coherent.

### HP Tuners [ECM] 12400 - Power Enrich EQ Ratio

Confirmed TunerPro entries:

- `[ECM] 12400 Power Enrich EQ Ratio`: `PowerEnrichEQRatio_06233E`
- Companion E80 table: `PowerEnrichEQRatioE80_06248C`

Source/reference names:

- `KtFEQR_eqr_PE_RPM`
- `KtFEQR_eqr_PE_RPM_E80`

Format and range:

- Storage: unsigned 16-bit big-endian
- Format: `5 x 33`
- Value math: `X / 1024`
- Display units: EQ Ratio
- Editor range: `0 to 64`

Target axes used in the XDF:

- X axis: static/generated `CM_T_RPMa` engine-speed axis, `0, 256, 512, ... 8192 rpm`
- Y axis: static manifold temperature labels, `8, 20, 32, 44, 56 deg C`

Target table addresses and readback:

```text
PowerEnrichEQRatio_06233E:
8 deg C:   1.066 1.066 1.066 1.066 1.066 ... 1.110 1.110 1.110
20 deg C:  1.066 1.066 1.066 1.066 1.066 ... 1.200 1.200 1.200
32 deg C:  1.111 1.111 1.111 1.111 1.111 ... 1.230 1.230 1.230
44 deg C:  1.161 1.161 1.161 1.161 1.161 ... 1.250 1.250 1.250
56 deg C:  1.210 1.210 1.210 1.210 1.210 ... 1.250 1.250 1.250
```

Evidence:

- The HP Tuners screenshot shape is `33 x 5`, with RPM columns `0..8192` and manifold-temp rows `8, 20, 32, 44, 56`.
- Full-bin scaled-u16 fingerprint search found the strongest coherent matches at `0x06233E` and `0x06248C`.
- Both target blocks are byte-identical in this BIN and are separated by `0x14E`, matching two `5 x 33` tables plus the local `00 21 00 05` dimension marker.
- The raw marker and table bytes appear as `00 21 00 05 04 44 ...` at `0x06233A` and `0x062488`, matching the HexView screenshot pattern around the table start. HP Tuners rounds `0x0444 / 1024 = 1.0664` as approximately `1.067`.
- The WinOLS reference identifies the PE family as `KtFEQR_eqr_PE_RPM` and `KtFEQR_eqr_PE_RPM_E80`; `CM_T_RPMa` is generated/user-defined, so the XDF uses static RPM labels rather than a linked X-axis address.
- Exact `8, 20, 32, 44, 56 deg C` axis fingerprints exist in the target BIN at `0x062018` and `0x0629C6`, but because this FEQR cluster has duplicate compatible temp axes and the reference RPM axis is generated, the XDF uses static Y labels for stable TunerPro display.

### Power Enrichment Enable, Delay, and Ramp Tables

Confirmed TunerPro entries added with the FEQR power-enrichment cluster:

- `PowerEnrichmentMinRPM_062096`: scalar, unsigned 16-bit big-endian, `X * 0.125`, `rpm`. Target readback is `700 rpm`; the screenshot example shows `8000 rpm`, so this calibration differs.
- `PowerEnrichmentEnableTorquePct_0620AE`: likely HP Tuners `[ECM] 12418 Power Enrichment Enable Torque %`, `1 x 17`, unsigned 16-bit big-endian, `X * 0.001525878906`, `%`. Target readback is all `0.0%`; the screenshot example shows all `97.0%`.
- `PowerEnrichmentEnablePedalPct_0620D2`: `1 x 17`, unsigned 16-bit big-endian, `X * 0.001525878906`, `%`. Target readback is all `80.0%`.
- `PowerEnrichmentDelayRPM_0620A0`: scalar, unsigned 16-bit big-endian, `X * 0.125`, `rpm`. Target readback is `6000 rpm`.
- `PowerEnrichmentDelayTorquePct_0625D8`: `KeFEQR_Pct_PE_DelayLoadThrsh`, scalar, 32-bit big-endian float, `%`. Source `0x05C3DC` relocates to target `0x0625D8` by `+0x61FC`; target readback is `100.0%`.
- `PowerEnrichmentDelayStep_0620F8`: `17 x 17`, unsigned 16-bit big-endian, `X * 0.05`, seconds. Static axes are accelerator pedal `0.0..100.0%` by engine speed `0..6400 rpm`; target visible cells are `0.100`.
- `PowerEnrichmentRampIn_0620A6`: scalar, unsigned 16-bit big-endian, `X * 0.000030517578`. Target readback is `0.1000`.
- `PowerEnrichmentRampOut_0620A8`: scalar, unsigned 16-bit big-endian, `X * 0.000030517578`. Target readback is `0.0100`.

Source/reference names:

- `KeFEQR_n_PE_EngSpdThrsh`
- `KtFEQR_Pct_PE_LoadThrsh`
- `KtFEQR_Pct_PE_ThrotThrshEngSpd`
- `KfFEQR_n_PE_DelayRPM_HiThrsh`
- `KtFEQR_t_PE_DelayAdjust`
- `KfFEQR_eqr_PE_RampIn`
- `KfFEQR_eqr_PE_RampOut`

Additional active PE calibrations mapped from the same `+0x61FC` FEQR block:

- `KeFEQR_n_PE_EngSpdLoHys_062094`: PE enable RPM hysteresis, target `50 rpm`.
- `KeFEQR_Pct_PE_ThrotLoHys_062098`: PE throttle/pedal hysteresis, target about `5%`.
- `KeFEQR_Pct_PE_LoadLoHys_06209A`: PE load/torque hysteresis, target `0%`.
- `KfFEQR_T_PE_DelayCoolLoThrsh_06209C` and `KfFEQR_T_PE_DelayCoolHiThrsh_06209E`: bypass PE delay below/above `-50 deg C` and `135 deg C`.
- `KfFEQR_Pct_PE_DeltThrotRise_0620A2`: rising-throttle bypass threshold, target `0%`.
- `KfFEQR_v_PE_DeltThrotVehSpdHi_0620A4`: vehicle-speed criterion paired with throttle delta, target `250 kph`.
- `KwFEQR_t_PE_DelayMax_0620AA`: maximum PE condition delay, exposed as `X * 0.05 s`. Stock raw `0xFFFF` displays `3276.75 s` and may be a disabled/sentinel value; do not interpret it as a normal literal delay without code-flow confirmation.

Evidence:

- The main FEQR PE scalar/table run relocates from the Corsa reference by the same `+0x61FC` family delta used for `[ECM] 12400`.
- The local dimension markers line up with the table starts: `0x0011` before the two `1 x 17` tables and `0x0011 0x0011` immediately before `PowerEnrichmentDelayStep_0620F8`.
- `KeFEQR_Pct_PE_DelayLoadThrsh` at source `0x05C3DC` relocates exactly to `PowerEnrichmentDelayTorquePct_0625D8` and decodes as a clean 32-bit float `100.0`, matching the green `Delay Torque %` screenshot value.

### Knock Enrichment / FEQR Pre-Ignition Protection

Confirmed TunerPro entries:

- `KnockEnrichmentAirmassHyst_05FB44`: scalar, unsigned 16-bit big-endian, stored as `0.125 mg/count`, displayed as `X * 0.000125 g`. Target readback is `0.030 g`.
- `KnockEnrichmentEnableRPM_05FB46`: scalar, unsigned 16-bit big-endian, `X * 0.125`, `rpm`. Target readback is `3200 rpm`.
- `KnockEnrichmentRPMHyst_05FB48`: scalar, unsigned 16-bit big-endian, `X * 0.125`, `rpm`. Target readback is `200 rpm`.
- `KnockEnrichmentEnableECT_05FB4A`: scalar, signed 16-bit big-endian, `X * 0.0078125`, `deg C`. Target readback is `60 deg C`.
- `KnockEnrichmentDelayStep_05FB50`: `9 x 9`, unsigned 16-bit big-endian, `X * 0.05`, seconds.
- `KnockEnrichmentEnableDelay_05FBF2`: scalar, unsigned 16-bit big-endian, `X * 0.05`. Target readback is `60.0` in the HP Tuners display unit.
- `KnockEnrichmentEQRatio_05FBF8`: `9 x 9`, unsigned 16-bit big-endian, `X / 1024`, EQ Ratio.
- `KnockEnrichmentRampIn_05FC9C`: scalar, unsigned 16-bit big-endian, `X * 0.000030517578`. Target readback is `0.0060`.
- `KnockEnrichmentRampOut_05FC9A`: scalar, unsigned 16-bit big-endian, `X * 0.000030517578`. Target readback is `0.0300`.

Axes:

- RPM axis count marker is at `0x05FB1C`; actual axis values start at `0x05FB1E` and decode as `1600, 1700, 1800, 1950, 2050, 2200, 2400, 2600, 3000 rpm`.
- Airmass axis count marker is at `0x05FB30`; actual axis values start at `0x05FB32` and decode as `0.470, 0.500, 0.530, 0.560, 0.590, 0.620, 0.650, 0.680, 0.710 g`.
- `KnockEnrichmentDelayStep_05FB50` has `0x0009 0x0009` dimension markers at `0x05FB4C/0x05FB4E`.
- `KnockEnrichmentEQRatio_05FBF8` has `0x0009 0x0009` dimension markers at `0x05FBF4/0x05FBF6`.

Evidence and caveats:

- The scalar values match the HP Tuners Knock Enrichment pane: `60 deg C`, `3200 rpm`, `200 rpm`, `0.030 g`, `60.0`, `0.0060`, and `0.0300`.
- The confirmed `0x05FBF8` EQ-ratio table is the coherent target table in this Astra BIN. The separate HP Tuners `EQ Ratio (Alcohol)` equivalent has not been uniquely isolated yet because the reference E80/pre-ignition table pattern is mostly `1.0` and produces many false positives.
- Do not start the XDF axes at `0x05FB1C` or `0x05FB30`; those first words are count markers, not real breakpoints. The graph view should use `0x05FB1E` and `0x05FB32`.

### Fuel Temperature Control / Protection

The older mixed CCTI temperature-control batch was quarantined on 2026-07-08 while isolating a TunerPro load crash. Proven FEQR hot-engine and piston-protection calibrations are now active under `Fuel->Protection`; the separate CCTI candidates below retain their original confidence notes.

Confirmed or high-confidence TunerPro entries:

- `COTMaxEnrichment_0636CC`: likely HP Tuners `[ECM] 12232 COT Max Enrichment` HPT-shaped `1 x 5` alcohol-composition view. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio, static X axis `0, 25, 50, 75, 100%`. Target readback is `1.373` across all five cells.
- `COTMaxEnrichmentScalar_04E900`: local CCTI maximum enrichment scalar in the catalyst protection cluster. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.370`.
- `COTMinEnrichment_04EA10`: local CCTI minimum enrichment scalar. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.000`.
- `COTTempThresholds_04E8FA`: catalyst protection threshold group. Unsigned 16-bit big-endian, `X * 0.0625`, deg C. Target readback is `950, 945, 930`.
- `COTTempSetpoint_04E908`: catalyst protection setpoint. Unsigned 16-bit big-endian, `X * 0.0625`, deg C. Target readback is `930`.
- `PistonProtectEnableRPM_05FAF0`: FEQR component/piston protection enable RPM. Unsigned 16-bit big-endian, `X * 0.125`, rpm. Target readback is `3600`.
- `PistonProtectDisableRPM_05FAF2`: FEQR component/piston protection disable RPM. Unsigned 16-bit big-endian, `X * 0.125`, rpm. Target readback is `3500`.
- `PistonProtectMaxEnrichment_05FAAC`: FEQR piston protection enrichment row over static `0..8192 rpm` axis. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.000` across the row.
- `HotEngineEnableECT_05FA46`: FEQR hot-engine enable ECT. Signed 16-bit big-endian, `X / 128`, deg C. Target readback is `255.99`, matching HPT display `256`.
- `KfFEQR_T_HotCoolantECT_Lo_05FA48`: FEQR hot-engine low/disable ECT. Signed 16-bit big-endian, `X / 128`, deg C. Target readback is `120`. Address `0x05FA44` is the final value of the preceding 17-cell axis, not this scalar.
- `HotEngineMaxEnrich_05FA5A`: FEQR hot-engine maximum enrichment. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.399`.
- `TurboOvertempMaxEnrichment_04E960`: CCTI turbo overtemperature maximum enrichment. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.420`.
- `TurboOvertempMinEnrichment_04EA26`: CCTI turbo overtemperature minimum enrichment. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.026`, matching HPT display `1.03`.
- `TurboTempThresholds_04E9D2`: likely turbo protection threshold group. Unsigned 16-bit big-endian, `X * 0.0625`, deg C. Target readback is `700, 800, 850, 900, 1000`.

Evidence and caveats:

- The FEQR hot-engine/piston scalars match the HP Tuners Temperature Control screenshot values directly: `3600 rpm`, `3500 rpm`, `256 deg C`, `120 deg C`, and `1.399`.
- The CCTI turbo enrichment scalars match the screenshot values directly: `1.42` max enrichment and `1.03` min enrichment.
- The HPT `[ECM] 12232` COT Max Enrichment screenshot is a `1 x 5` alcohol table with all cells around `1.37`; the contiguous repeated block at `0x0636CC` fits that display shape. The nearby CCTI scalar at `0x04E900` also decodes to `1.370`, so both are kept in the XDF until the exact HPT source symbol is nailed down.
- `COT` enable and `Turbo Overtemp` enable dropdown enum/boolean targets were not added yet because the local raw words near the cluster do not uniquely identify the HPT switch without a changed-bin fingerprint.

## Full FEQR Flash Mapping - 2026-07-12

The complete FEQR inventory from `winols_astra.csv` is recorded in `feqr_mapping.csv`. The CSV contains `204` unique FEQR symbols: `94` flash calibrations and `110` `0x400...` RAM/runtime variables. Only flash calibrations are candidates for editable BIN/XDF entries.

Disposition of the `94` flash calibrations:

- `90` high-confidence Astra mappings: `19` were already represented in the XDF and `71` were added in this pass.
- `3` are demonstrably absent from this target layout: `KtFEQR_eqr_PreIgnProtectE80` (`0x05995E`), `KtFEQR_Cnt_BlndOpenToClosedLoop` (`0x059A04`), and `KeFEQR_Cnt_BlendDriveability` (`0x059B9A`). The neighboring target blocks close the exact source-sized gaps where these would otherwise occur.
- `1` remains unresolved and is not active: `KtFEQR_K_EquivRatioBlendFactor` (`0x05C800`). It has no unique target fingerprint or coherent local anchor.

Confirmed source-to-target relocation blocks:

| DAMOS source range | Astra rule | Functional block |
| --- | ---: | --- |
| `0x059330-0x059704` | `+0x631C` | clear flood, crank, green-engine enrichment |
| `0x059706-0x0598B8` | `+0x6340` | hot-engine, piston, pre-ignition protection |
| `0x059AB0-0x059B98` | `+0x61F4` | stoichiometry and general FEQR controls |
| `0x059B9E-0x05BE97` | `+0x61F0` | AIR and open-loop fueling |
| `0x05BE98-0x05C3DC` | `+0x61FC` | power enrichment |
| `0x059A00-0x059A02` | explicit `0x05FC9A-0x05FC9C` | pre-ignition ramp-out/ramp-in scalars |

Mapping method and confidence rules:

1. Parse semicolon-delimited WinOLS rows by `IdName`, storage organization, signedness, dimensions, factor, units, source address, and reference values.
2. Exclude RAM/runtime symbols and build ordered flash islands. Use already confirmed PE and pre-ignition tables as independent anchors.
3. Search `opel_astra_original.bin` for exact or structurally distinctive raw fingerprints, then compare symbol order, dimensions, count markers, inter-table gaps, and decoded engineering values across the whole island.
4. Promote a relocation only when multiple neighbors preserve source ordering and spacing or a unique raw fingerprint independently confirms the address. Constant/all-zero patterns alone are not sufficient.
5. Preserve source storage, signedness, dimensions, factor, offset, and units in the XDF. Use static/index axes where target axis storage is not independently proven; this avoids creating plausible-looking but unsafe editable axis links.
6. Record every source row and disposition in `feqr_mapping.csv`, including target preview/min/max, confidence evidence, XDF status, and title. Absent and unresolved rows remain documented but are not added as active tables.

The active FEQR additions are split into functional folders: `Fuel->Cranking`, `Fuel->Open Loop`, `Fuel->Protection`, `Fuel->AIR`, `Fuel->General`, `Fuel->Power Enrich`, and `Fuel->Knock Enrichment`.

TunerPro load test on 2026-07-12:

- Loaded the expanded `E78_Astra_047922_TableSearch.xdf` with `opel_astra_original.bin` without a crash; all `19` categories appeared with the expected entry counts.
- Opened `KfFEQR_Pct_ClearFloodEnter_05F64C` and confirmed `90.0%`.
- Opened `KtFEQR_eqr_Crank_05F654` and confirmed the complete `17 x 17`, 16-bit table renders with numeric axes and decoded values.
- Opened `KwFEQR_t_PE_DelayMax_0620AA` and confirmed raw `0xFFFF` renders as `3276.75 s` with the sentinel warning visible in the description.
- A programmatic audit of all `90` active FEQR mappings found no storage width, signed/float flag, dimensions, or equation factor/offset mismatches against the DAMOS rows. XML parsing, unique-ID, category-membership, target-address uniqueness, and BIN-bound checks also passed.

### DAMOS-derived XDF descriptions - 2026-07-12

All XDF entries with a unique, proven `winols_astra.csv` symbol match now include structured functional and technical descriptions:

- `131` of the `158` XDF entries are enriched: `90` resolve through `feqr_mapping.csv`, and `41` resolve through the exact DAMOS symbol already present in their local description.
- Each enriched description contains the cleaned CSV calibration purpose, X/Y axis notes when present, dimensions, storage organization, signedness, engineering conversion, units, source symbol/address, and the complete pre-existing Astra mapping/local notes.
- Existing warnings and confidence language are preserved verbatim after the `Astra mapping/local notes:` label. This includes candidate status, static-axis caveats, raw/display guidance, and the `KwFEQR_t_PE_DelayMax` `0xFFFF` sentinel warning.
- The remaining `27` entries have no unique CSV symbol match and are intentionally unchanged rather than receiving a guessed description.
- CSV HTML/line-break boilerplate is normalized, but source technical wording is not substantively rewritten.
- The repeatable updater is `_quarantine/analysis/enrich_xdf_descriptions.py`. `build_feqr_xdf.py` uses the same formatter so future generated FEQR entries receive equivalent descriptions automatically.
- Validation compares the enriched XDF with its committed predecessor after blanking description text. The non-description XML is identical, proving that IDs, categories, addresses, dimensions, axes, equations, and storage flags were not changed by this pass.

## Spark Table Search - 2026-07-08

Spark entries were added to `E78_Astra_047922_TableSearch.xdf` under new `Spark->...` categories. Category declarations continue the stable TunerPro convention: declarations are zero-based and `CATEGORYMEM` references are one-based.

Confirmed/high-confidence additions:

| XDF title | Source symbol | Address | Shape / format | Axes | Notes |
| --- | --- | ---: | --- | --- | --- |
| `SparkHighOctaneBase_07394D` | `KtSPRK_phi_BaseHiOctane` | `0x07394D` | `33 x 33`, signed byte, `X * 0.5 deg` | RPM33 `0x073900`, APC33 `0x077360` | High Octane base spark. |
| `SparkLowOctaneBase_073FC5` | `KtSPRK_phi_BaseLowOctane` | `0x073FC5` | `33 x 33`, signed byte, `X * 0.5 deg` | RPM33 `0x073900`, APC33 `0x077360` | Low Octane base spark. |
| `SparkSmoothingRunFilterRefs_075C36` | `KeSPRK_Cnt_RunSprkFilterRefs` | `0x075C36` | scalar, unsigned 16-bit, count | static scalar axes | Closest local equivalent for HPT Spark Smoothing; Astra value is `20`. |
| `SparkFlexFuel_075D6F` | `KtSPRK_phi_FFS` | `0x075D6F` | `33 x 33`, signed byte, `X * 0.5 deg` | RPM33 `0x073900`, APC33 `0x077360` | Flex Fuel spark correction; stock Astra table is zero-filled. |
| `SparkFlexFuelEqRatio_075C3F` | `KtSPRK_phi_FFS_EqRatio1` | `0x075C3F` | `17 x 17`, signed byte, `X * 0.5 deg` | static `800-7200 rpm`, EQR17 `0x07727A` | Flex Fuel EQ-ratio spark correction; stock Astra table is zero-filled. |
| `SparkFlexFuelBlendFactor_075D62` | `KtSPRK_Scl_FFS_BlendFactor` | `0x075D62` | `1 x 5`, unsigned 16-bit, `X * 0.000015258789 ratio` | static alcohol labels | Nearby Flex Fuel support row; stock Astra row is zero-filled. |
| `SparkVCPSpark_07463D` | `KtSPRK_phi_Phaser` | `0x07463D` | `33 x 17`, signed byte, `X * 0.5 deg` | RPM17 `0x0784AC`, APC33 `0x077360` | VCP Spark / cam phaser spark table. |
| `MinimumSparkBase_07895E` | `KtSPRK_phi_MinSpkAdvLimitSht` | `0x07895E` | `33 x 17`, signed 16-bit, `X * 0.0078125 deg` | RPM17 `0x0784AC`, APC33 `0x077360` | Minimum Spark Base / short-term minimum spark limit. |

Candidate additions that need an HPT edit fingerprint:

| XDF title | Source symbol / reason | Address | Shape / format | Notes |
| --- | --- | ---: | --- | --- |
| `SparkHumidityBaseMax_Candidate_076843` | `KtSPRK_phi_HumidityMax` structural relocation | `0x076843` | `33 x 33`, signed byte, `X * 0.5 deg` | Layout fits the SPRK humidity/minimum-spark cluster, but decoded values are implausibly wide. Treat as weak until an HPT edit proves the address. |
| `SparkVCPHumidityAdderDry_Candidate_076C87` | `KtSPRK_phi_PhaserHumidMin` structural relocation | `0x076C87` | `33 x 17`, signed byte, `X * 0.5 deg` | Candidate for HPT VCP Humidity Adder Dry; stock Astra table is zero-filled. |
| `SparkVCPHumidityAdderWet_Candidate_076EBB` | `KtSPRK_phi_PhaserHumidMax` structural relocation | `0x076EBB` | `33 x 17`, signed byte, `X * 0.5 deg` | Candidate for HPT VCP Humidity Adder Wet; stock Astra table is zero-filled. |
| `MinimumSparkLongTerm_Candidate_078E2A` | clean local 33x17 table near `KtSPRK_phi_MinSpkAdvLimitLng` | `0x078E2A` | `33 x 17`, signed 16-bit, `X * 0.0078125 deg` | Direct expected long-term address `0x078DC4` decodes into mixed data; `0x078E2A` is clean and all `-15 deg`, but remains candidate. |

Spark axis notes:

- The target RPM/APC/EQR axes have count words before the real breakpoint data. Use `0x073900`, `0x077360`, `0x0784AC`, and `0x07727A`, not the preceding count-marker addresses.
- The main SPRK relocation is not one global delta. Base/Flex/VCP Spark body addresses use the `CSV + 0x386C` family, while the humidity/minimum-spark cluster uses a different local layout.
- TunerPro XML validation after insertion: 61 tables, 61 unique IDs, 13 valid categories, no out-of-bounds embedded addresses.

## Offset Ledger - Confirmed HPT Tables

These offsets are additive deltas to the Astra target address in `opel_astra_original.bin`. They are useful search hints, but they are not one global OS-to-OS offset. The most reliable pattern is by calibration family or local cluster.

Reference/WinOLS source to Astra target:

| Family | HPT table | Source/reference address | Astra XDF address | Delta | Notes |
| --- | --- | ---: | ---: | ---: | --- |
| BSTC knock-air | `[ECM] 33482` Turbocharger Knock Max Airmass | `KtBSTC_m_MaxKnk` `0x048364` | `0x04DD68` | `+0x5A04` | X axis `0x0485FC -> 0x04DEC8` is `+0x58CC`; Y axis `0x048580 -> 0x04DF3C` is `+0x59BC`. |
| BSTC knock-air | `[ECM] 33495` Knock Airmass Scav | unresolved exact CSV symbol | `0x04E350` | n/a | Confirmed from edited HexView fingerprint and local 16-bit scaled table shape. |
| BSTC boost | `[ECM] 33460` Max Boost Limit | `KtBSTC_p_MaxBoostLim` `0x047FB0` | `0x04DFB4` | `+0x6004` | Manifold-temp axis `0x048564 -> 0x04E4F0` is `+0x5F8C`. |
| BSTC turbo compressor | `[ECM] 33491` Turbo Overspeed Max Pressure Ratio | `KaBSTC_r_CompPressRatioMaxSpd` `0x047984` | `0x04D9BC` | `+0x6038` | Corrected massflow axis `0x047C18 -> 0x04DC44` is `+0x602C`; axis is a very strong HPT screenshot match. |
| BSTD turbo compressor diag | `[ECM] 33435` Compressor Surge Limit | `KtBSTD_r_SurgeLim` `0x029D0C` | `0x029858` | `-0x04B4` | Axis `0x029D24 -> 0x029870` is also `-0x04B4`; exact screenshot match. |
| ECPR torque | `[ECM] 32924` Overboost Torque Limit | `KtECPR_M_Overboost` `0x04C0B8` | `0x053464` | `+0x73AC` | Shared RPM axis `0x04C920 -> 0x053AD0` is `+0x71B0`. |
| ECPR torque | `[ECM] 32920` Peak Engine Torque | `KtECPR_M_IndicatedPeakTorq` `0x04C0D8` | `0x0534A4` | `+0x73CC` | Alcohol axis `0x04C988 -> 0x053B10` is `+0x7188`. |
| ECPR torque | `[ECM] 32923` Max Engine Torque Limit | unresolved exact CSV symbol | `0x0535A4` | n/a | In the target cluster it is exactly `+0x100` after Peak Engine Torque. |
| TSXC driveline torque | Trans Output Max | `KeTSXC_M_TransOutputTorqLimit` `0x021D28` | `0x021648` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `100000 Nm`; HPT screenshot example shows `131072 Nm`. |
| TSXC driveline torque | Front Axle Max | `KeTSXC_M_FrontAxleTorqLimit` `0x021D18` | `0x021638` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `100000 Nm`. |
| TSXC driveline torque | Front Axle Max 4WD Low | `KeTSXC_M_4LoFrontAxleTorqLimit` `0x021D10` | `0x021630` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `131072 Nm`. |
| TSXC driveline torque | Front Propshaft Max | `KeTSXC_M_FrontDrvShftTorqLimit` `0x021D1C` | `0x02163C` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `100000 Nm`. |
| TSXC driveline torque | Rear Axle Max | `KeTSXC_M_RearAxleTorqLimit` `0x021D20` | `0x021640` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `100000 Nm`; HPT screenshot example shows `2000 Nm`. |
| TSXC driveline torque | Rear Axle Max 4WD Low | `KeTSXC_M_4LoRearAxleTorqLimit` `0x021D14` | `0x021634` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `131072 Nm`. |
| TSXC driveline torque | Rear Propshaft Max | `KeTSXC_M_RearDrvShftTorqLimit` `0x021D24` | `0x021644` | `-0x06E0` | High-confidence local TSXC scalar island. Astra stock decodes to `100000 Nm`; HPT screenshot example shows `500 Nm`. |
| BRKC brake torque | Brake Torque Limit / driver intended brake torque scale | `KeBRKC_M_MaxDrvIntBrkTorq` `0x03F620` | `0x047CE4` | `+0x86C4` | High-confidence scalar from the DTRC/BRKC target island. Astra stock decodes to `6000 Nm`. This may correspond to HPT Brake Torque Limit, but the separate BTRC BTM table remains unresolved. |
| DTRC driver demand | `[ECM] 33050` Driver Demand A | `KtDTRC_P_M_PedProgReqA` `0x03FAE8` | `0x046944` | `+0x6E5C` | Source axes relocate by `+0x6E18`: X `0x040EF4 -> 0x047D0C`, Y `0x040E04 -> 0x047C1C`. |
| DTRC driver demand | Driver Demand B | `KtDTRC_P_M_PedProgReqB` `0x03FF6C` | `0x046DC8` | `+0x6E5C` | Same shared target axes as A/C. |
| DTRC driver demand | Driver Demand C | `KtDTRC_P_M_PedProgReqC` `0x0403F0` | `0x04724C` | `+0x6E5C` | Same shared target axes as A/B. |
| TPSD airflow correlation | P0068 Enable RPM | `KeTPSD_n_AirflowActMin` `0x078AC0` | `0x07A570` | `+0x1AB0` | 32-bit big-endian float; target decodes to `800 rpm`. |
| TPSD airflow correlation | P0068 Max Airflow vs. IGNV | `KtTPSD_dm_MaxMAF_VsVoltage` `0x078AD6` | `0x07A586` | `+0x1AB0` | 1x9 unsigned 16-bit big-endian, `X / 128`; generated axis `6-14 V`. |
| TPSD airflow correlation | P0068 Max Airflow vs. RPM | `KtTPSD_dm_MaxMAF_VsRPM` `0x078AEC` | `0x07A59C` | `+0x1AB0` | 1x9 unsigned 16-bit big-endian, `X / 128`; generated axis `600-7000 rpm`. |
| TPSD airflow correlation | `[ECM] 14044` Airflow Delta / Maximum Airflow Delta vs. TPS | `KtTPSD_dm_MAF_DesThrDelt` `0x078AEE`; HPT/Corsa fingerprint `0x07BFEE` | `0x07A59E` | `+0x1AB0` / `-0x1A50` | Shared TPS axis `0x07C016 -> 0x07A5C6` is also `-0x1A50`. |
| TPSD airflow correlation | `[ECM] 14045` MAP Delta / Maximum MAP Delta vs. TPS | `KtTPSD_p_MAP_DesThrDelt` `0x078B02`; HPT/Corsa fingerprint `0x07C002` | `0x07A5B2` | `+0x1AB0` / `-0x1A50` | Same shared TPS axis. |
| FEQR power enrichment | `[ECM] 12400` Power Enrich EQ Ratio | `KtFEQR_eqr_PE_RPM` `0x05C142` | `0x06233E` | `+0x61FC` | Generated/static RPM axis in XDF. |
| FEQR power enrichment | `[ECM] 12400` companion E80 | `KtFEQR_eqr_PE_RPM_E80` `0x05C290` | `0x06248C` | `+0x61FC` | Byte-identical companion in this Astra BIN. |
| FEQR power enrichment | `[ECM] 12418` Power Enrichment Enable Torque % | `KtFEQR_Pct_PE_LoadThrsh` `0x05BEB2` | `0x0620AE` | `+0x61FC` | Target values are all `0%`, unlike the `97%` screenshot example. |
| FEQR power enrichment | Power Enrichment Enable Pedal | `KtFEQR_Pct_PE_ThrotThrshEngSpd` `0x05BED6` | `0x0620D2` | `+0x61FC` | Target values are all `80%`. |
| FEQR power enrichment | Power Enrichment Delay Step | `KtFEQR_t_PE_DelayAdjust` `0x05BEFC` | `0x0620F8` | `+0x61FC` | `17 x 17`, pedal by RPM, values around `0.100`. |
| FEQR power enrichment | Power Enrichment Delay Torque % | `KeFEQR_Pct_PE_DelayLoadThrsh` `0x05C3DC` | `0x0625D8` | `+0x61FC` | 32-bit big-endian float `100.0%`. |
| FEQR knock enrichment | Knock Enrichment scalars and EQ ratio | FEQR pre-ignition protection island | `0x05FB44-0x05FC9C` | n/a | Scalars match HPT pane; axes start at `0x05FB1E` and `0x05FB32` after count markers. |
| CCTI temperature protection | Catalyst and turbo enrichment/threshold scalars | CCTI catalyst/turbo protection island | `0x04E8FA-0x04EA26` | n/a | COT scalar max/min, COT thresholds, turbo max/min enrichment, and likely turbo temp thresholds. |
| FEQR temperature protection | Hot engine and piston/component protection | FEQR hot-engine/piston island | `0x05FA46-0x05FAF2` | n/a | Hot-engine scalars start at `0x05FA46`; `0x05FA44` is the final preceding axis breakpoint. |
| COT max enrichment table | `[ECM] 12232` COT Max Enrichment | unresolved exact CSV symbol | `0x0636CC` | n/a | HPT-shaped `1 x 5` alcohol-composition row, all cells about `1.373`; nearby scalar at `0x04E900` is also retained. |

HPT HexView window name to Astra target:

| HPT HexView window | HPT table | Astra XDF address | Delta from window base |
| --- | --- | ---: | ---: |
| `HexView047922` | `[ECM] 33482` Turbocharger Knock Max Airmass | `0x04DD68` | `+0x6446` |
| `HexView047922` | `[ECM] 33495` Knock Airmass Scav | `0x04E350` | `+0x6A2E` |
| `HexView047922` | `[ECM] 33460` Max Boost Limit | `0x04DFB4` | `+0x6692` |
| `HexView04C122` | `[ECM] 32924` Overboost Torque Limit | `0x053464` | `+0x7342` |
| `HexView04C122` | `[ECM] 32920` Peak Engine Torque | `0x0534A4` | `+0x7382` |
| `HexView04C122` | `[ECM] 32923` Max Engine Torque Limit | `0x0535A4` | `+0x7482` |
| `HexView03D922` | `[ECM] 33050` Driver Demand A | `0x046944` | `+0x9022` |
| `HexView03D922` | Driver Demand B | `0x046DC8` | `+0x94A6` |
| `HexView03D922` | Driver Demand C | `0x04724C` | `+0x992A` |
| `HexView07B922` | `[ECM] 14044` Maximum Airflow Delta vs. TPS | `0x07A59E` | `-0x1384` |
| `HexView07B922` | `[ECM] 14045` Maximum MAP Delta vs. TPS | `0x07A5B2` | `-0x1370` |
| `HexView05C122` | `[ECM] 12400` Power Enrich EQ Ratio | `0x06233E` | `+0x621C` |
| `HexView05C122` | `[ECM] 12400` companion E80 | `0x06248C` | `+0x636A` |
| `HexView05C122` | `[ECM] 12418` Power Enrichment Enable Torque % | `0x0620AE` | `+0x5F8C` |
| `HexView05C122` | Power Enrichment Enable Pedal | `0x0620D2` | `+0x5FB0` |
| `HexView05C122` | Power Enrichment Delay Step | `0x0620F8` | `+0x5FD6` |
| `HexView05C122` | Power Enrichment Delay Torque % | `0x0625D8` | `+0x64B6` |
| `HexView05C122` | Knock Enrichment scalar cluster | `0x05FB44` | `+0x3A22` |
| `HexView05C122` | Knock Enrichment EQ Ratio | `0x05FBF8` | `+0x3AD6` |
| `HexView05C122` | Hot engine / piston protection cluster | `0x05FA44` | `+0x3922` |
| `HexView05C122` | COT Max Enrichment HPT-shaped row | `0x0636CC` | `+0x75AA` |
| THMC float value block | `KaTHMC_T_EngCool_Labels_Candidate` | `0x079C88` | Candidate 32-bit big-endian float row inferred from the OS12646746 reference XDF. Exact symbol is absent from the Astra WinOLS CSV; inspection context only. |
| THMC float value block | `KaTHMC_T_EngCool_Candidate` | `0x079C50` | Candidate 2x7 32-bit big-endian float view using labels at `0x079C88`. The standalone `KaTHMC_T_EngCool` symbol is absent from the Astra WinOLS CSV and the values look implausible as Max/Min desired ECT. |
| THMC float value block | `KaTHMC_T_EngCoolReq_Candidate` | `0x079C6C` | Candidate 1x24 32-bit big-endian float view from the OS12646746 reference XDF. Astra WinOLS has no `KaTHMC_T_EngCoolReq`; the closest real 24-cell symbol is `KaTHMC_T_TMS_EngCoolReq[x]` at source `$781B8`. |
| THMC float value block | Cold Max Desired ECT / `KaTHMC_T_EngCoolLoAmbMaxLim[x]` | `0x079CB0` | Corsa float row `0x07B694 -> 0x079CB0`; values are `105 deg C` across all 7 cells. |
| THMC float value block | Cold Min Desired ECT / `KaTHMC_T_EngCoolLoLim[x]` | `0x079CCC` | Corsa float row `0x07B6B0 -> 0x079CCC`; values are `97.5, 97.5, 100, 100, 105, 105, 105 deg C`. |
| THMC float value block | Cold Desired ECT threshold / `KaTHMC_T_EngCoolTrshLo[x]` | `0x079D18` | Corsa float row `0x07B6CC -> 0x079D18`; values are `10, 5, 0, -5, -10, -20, -40 deg C`. |
| OS12646746 packed reference | Desired ECT / `KaTHMC_T_TMS_EngCoolReq[x]` | `0x077B56` | `-0x0662` from source `0x0781B8`; raw inspection only until the matching engineering-value row is confirmed. |
| OS12646746 packed reference | Cold Max/Min/threshold packed context | `0x077B02-0x077B47` | Exact packed relocation from source `0x078164-0x0781A9`, but not the editable degree-C float rows. |
| OS12646746 packed reference | `E78_DesiredECT_OS_12646746.xdf` `KaTHMC_T_EngCool` block | `0x077B9E` | `-0x0662` from source `0x078200`; raw inspection only. |

## Torque Limiter Search - 2026-07-09

Source material used:

- Damos CSV: `E:\Projects\E78_14T\sources\Uni78\DamosCSVParser\data\winols_astra.csv`
- Corsa comparison CSV: `E:\Projects\E78_14T\tunes\Opel Corsa E 1.4 Turbo 2019\change_everything_bins\winols_desc.csv`
- Target BIN: `E:\Projects\E78_14T\tunes\astra_j_14t_2\opel_astra_original.bin`
- Current XDF: `E:\Projects\E78_14T\tunes\astra_j_14t_2\E78_Astra_047922_TableSearch.xdf`

New active XDF candidate views:

| XDF title | Source hint | Address | Shape / format | Axes | Confidence / notes |
| --- | --- | ---: | --- | --- | --- |
| `BrakeTorqueLimitMult_CandidateA_50268` | `KtBTRC_K_TorqLimit_ExtBrk_OBD` | `0x050268` | `3 x 9`, 32-bit big-endian float, `X` | static pedal `%`: `0,12.5,25,37.5,50,62.5,75,87.5,100`; static vehicle speed `kph`: `0,12.5,25` | Candidate only. Astra stock rows decode to `0.5000`, `0.4375`, and `0.3750`. |
| `BrakeTorqueLimitMult_CandidateB_507F4` | same | `0x0507F4` | same | same | Candidate duplicate; byte-identical shape/value block to copy A. |
| `BrakeTorqueLimitMult_CandidateC_510EC` | same | `0x0510EC` | same | same | Candidate duplicate; byte-identical shape/value block to copy A. |

BTRC notes:

- `KtBTRC_K_TorqLimit_ExtBrk_OBD` in the Damos CSV is source `0x0488CC`, `9 x 3`, `eFloatHiLo`, factor `1`. The source value list is `0.8/0.6/0.5/0.4/0.3` shaped and the axis lists are pedal `%` and vehicle speed `kph`.
- Exact Damos byte-pattern matching did not find that source value list in the Astra target BIN. A shape search found three local 3x9 multiplier-looking float blocks at `0x050268`, `0x0507F4`, and `0x0510EC`.
- The first candidate gives a plausible table-body delta from source: `0x0488CC -> 0x050268` (`+0x799C`), but nearby BTRC single-byte/scalar rows do not decode cleanly with that same delta. Treat the views as edit-fingerprint targets, not confirmed HPT equivalents.
- `KtBTRC_M_BTM_Lim` at source `0x0488F0` is a `1 x 17` `eHiLo` table with factor `4`, described as the brake vacuum pressure indexed BTM limit. It overlaps the multiplier bytes in the Damos layout and still has no clean Astra target. Do not add it as an active editable table yet.

TTQC / transmission torque limiter notes:

- Damos rows checked:
  - `KtTTQC_M_TransDfltTorqLmt`, source `0x07938E`, `1 x 9`, `eHiLo`, factor `0.25`, values all `400 Nm`. This is the best source-name match for HPT `Default Trans Limit`.
  - `KtTTQC_M_TransTorqReqLimitGr1` through `Gr5`, sources `0x0794CA-0x07951A`, `1 x 9`, `eHiLo`, factor `0.25`, values all `200 Nm` for Gr1-Gr4 and `150 Nm` for Gr5.
  - `KtTTQC_M_ClutchProtectLimits`, source `0x079542`, `5 x 9`, `eHiLo`, factor `0.25`, Damos values `400,400,350,325,250,150,100,100,70` repeated by pedal row.
  - Manual gearbox torque limit rows `KtTTQC_M_ManlRvrsGearboxTorqLim` and `KtTTQC_M_Manl1st...6thGearboxTorqLim`, sources `0x0792DE-0x079356`, `1 x 9`, `eHiLo`, factor `0.125`.
- Direct source addresses in the Astra BIN do not decode to the Damos values. Exact raw searches found many generic matches for all-`400` and all-`200` rows, so those are weak by themselves.
- Notable raw hits kept for future fingerprinting:
  - all-`400 Nm` row (`raw 0x0640`, factor `0.25`): many hits including `0x020286`, `0x0204EC`, `0x06FB86`, `0x06FD52`.
  - all-`200 Nm` row (`raw 0x0320`, factor `0.25`): many hits including `0x024A16`, `0x04E968`, `0x057048`, `0x05705C`.
  - all-`150 Nm` row (`raw 0x0258`, factor `0.25`): unique exact hit at `0x057022`, inside a count-prefixed 9-cell row cluster.
- These TTQC candidates were not added to the active XDF because the all-constant value rows are too common and the surrounding local clusters do not yet prove the Damos symbol mapping. Use a changed-bin/HPT edit fingerprint before promoting `Default Trans Limit` or the per-gear transmission torque request limits.

Search heuristics from the confirmed tables:

- For BSTC knock/boost tables, try nearby source-to-target deltas around `+0x5A00` to `+0x6000`, then confirm by axes and storage type.
- For BSTC turbo compressor pressure-ratio tables, `KaBSTC_r_CompPressRatioMaxSpd` used a local `+0x603x` body/axis delta in this BIN; the body and axis are close but not identical deltas.
- For BSTD turbo compressor diagnostic/surge tables, the Corsa reference to Astra target shift was `-0x04B4` for both table and axis.
- For DTRC driver-demand tables, body anchors used `+0x6E5C`; shared axes used `+0x6E18`.
- For ECPR torque, table bodies are around `+0x73xx`; shared axes are around `+0x71xx`.
- For TSXC driveline torque limit scalars, the confirmed target subgroup uses a clean `-0x06E0` shift from the CSV source symbols. Values in this Astra BIN differ from the provided HPT screenshot for several limits, so use symbol order and local island shape rather than exact screenshot values.
- For the THMC Desired ECT cluster, do not use the packed `00xx` relocation block at `0x077B02` as the editable degree-C table. It is a useful context/fingerprint match, but raw-pair views can read straight through adjacent calibrations. The confirmed Astra cold-limit degree-C views are normal 32-bit big-endian floats at `0x079CB0`, `0x079CCC`, and `0x079D18`; surrounding OS12646746-style `KaTHMC_T_EngCool*` views are candidates only until a changed-bin fingerprint confirms them.
- For the TPS delta pair, the table and axis relocation was a clean `-0x1A50`.
- For FEQR Power Enrich EQ Ratio, both table bodies used a clean `+0x61FC`.
- For FEQR Power Enrichment enable/delay/ramp tables, the nearby `0x0620xx` entries also use the `+0x61FC` family delta, but the Astra calibration values can differ heavily from the HPT screenshot example.
- For Knock Enrichment / FEQR pre-ignition protection, confirm count markers before axes and table bodies. The real axes start after the `0x0009` count words, not on them.
- For Fuel Temperature Control, search both the CCTI catalyst/turbo island near `0x04E8FA-0x04EA26` and the FEQR hot-engine/piston island with scalars at `0x05FA46-0x05FAF2`; they are different calibration families despite landing in the same HPT pane. The preceding FEQR axis ends at `0x05FA44`.
- HPT HexView windows are useful visual clues, but several do not map byte-for-byte to raw file addresses in this Astra BIN. Prefer source/fingerprint relocation plus table-shape validation over the HexView window delta alone.

Name notes:

- `[ECM] 33495` HPT display name is `Turbocharger Knock Airmass Scav` / short display `Knock Airmass Scav`. The WinOLS symbol `KtBSTC_m_MaxKnkSC` has a similar "Max allowed airmass with regards to knock" description, but its source axes do not cleanly match the confirmed `[ECM] 33495` target axes, so keep the exact source symbol unresolved for now.
- `[ECM] 32923` HPT display name is `Max Engine Torque Limit`. The matching RAM/output name in the reference export is `VeECPR_M_EngMaxTorqLimit`, but the exact calibration-source `Kt*` symbol for the confirmed `0x0535A4` target table is still unresolved. Do not use `KtECPR_M_MaxBrkTorqLmt` as the source match; its reference values are a 1000 Nm limit table and do not match the HPT screenshot.

## Traction Control Search - 2026-07-09

Source material and search method:

- Searched `E:\Projects\E78_14T\sources\Uni78\DamosCSVParser\data\winols_astra.csv` for `traction control`, `TCS`, `EBCM`, `ABS controller`, `wheel slip`, torque-reduction enable/inhibit wording, and the `TCSC`, `TCSI`, `DTMC`, and `ETQC` calibration families.
- Used `E:\Projects\E78_14T\tunes\astra_j_14t\Astra J A14NET- ECU Orig.bin` as the byte-level Damos/reference BIN and aligned distinctive mixed float/word/byte calibration islands against `opel_astra_original.bin`. This was more reliable than applying one global source-address delta.
- The ECM can suppress its engine-torque response to traction control, but the EBCM owns brake-based traction and stability intervention. Nothing found in this ECM BIN is proof of a complete ABS/EBCM traction-control disable.

New active XDF controls under `Engine->Torque`:

| XDF title | Damos symbol | Target address | Format / stock | Intended use and confidence |
| --- | --- | ---: | --- | --- |
| `TCS_MaxTorqueDecrement_051D90` | `KeDTMC_M_TCSMaxDecrTorq` | `0x051D90` | 32-bit big-endian float, `65535 Nm` | High-confidence direct ECM control. The symbol is the maximum torque decrement available to traction control; setting it to `0` is the strongest ECM-side disable candidate. Verify requested and delivered torque in logs. |
| `TCS_TorqueReductionEnableECT_04B5B4` | `KfTCSC_T_TractionCoolEnbl` | `0x04B5B4` | signed 16-bit big-endian, `X / 128`, stock `-255 deg C` | High-confidence secondary inhibit. Torque reduction is allowed only above this threshold; a value near `+255 deg C` should keep the condition false at normal coolant temperatures. |
| `TCS_MinEngineRunTime_04B5BC` | `KfTCSC_t_MinTC_EngRunTime` | `0x04B5BC` | unsigned 16-bit big-endian, `X * 0.00625 s`, stock `0 s` | High-confidence test/temporary inhibit. Maximum representable delay is only `409.59 s`, so this cannot provide a permanent disable by itself. |
| `TCS_PresenceConfig_079BB8` | `KeTCSI_b_TCS_Present`, `KeTCSI_b_UseSerialData` | `0x079BB8` | two unsigned bytes, stock `[0, 1]` | Exact configuration pair. Stock uses EBCM serial data and ignores the false fallback. Setting `Use Serial Data` to `0` while leaving the fallback at `0` forces the ECM-side TCS-present result false; this may affect network diagnostics. |

Mapping evidence:

- The TCSC reference island at file offset `0x044920` aligns to the Astra target at `0x04B580`. It has a 36-byte exact prefix and additional exact anchors through the local calibration group. This pins the ECT gate at `0x04B5B4` and the run-time gate at `0x04B5BC` despite calibration-value changes between OS versions.
- The TCSI core pattern in the reference BIN at `0x0773F2` maps exactly to target `0x07996A`; the associated configuration block at reference `0x07763E` maps with the same `+0x2578` shift to target `0x079BB6`. The two presence bytes therefore land at `0x079BB8-0x079BB9` and decode exactly as Damos describes.
- The DTMC tail at reference `0x04A7C0` matches target `0x051DA0` byte-for-byte for the first 17 bytes. Following the documented DTMC scalar order backward pins `KeDTMC_M_TCSMaxDecrTorq` at target `0x051D90`; its target value is the expected large positive float limit.

Relevant CSV entries not promoted as disable switches:

- `KeBTRC_b_DisableBTM_ByTCS` does not disable traction control. It disables brake torque management after a driver-requested TCS disable has already been detected.
- `KeTCSI_b_AllowWheelSlip` is only documented as `Wheel slip enable cal`, is stock `0`, and is not sufficiently explicit to use as the master switch.
- `KtETQC_M_DsrdTorqMin` clips both ABS torque and TCM spark-torque requests. Raising it could suppress TCS reduction, but its broader shared behavior makes it a poor first choice.
- `KfTCSC_Pct_TorqRdctThrsh` changes when torque reduction is considered active; it does not directly prevent the reduction request.

## XDF Maintenance Notes

- Keep `TurbochargerKnockMaxAirmass_EDIT_MG_X1000_04DD68` as the only editable view for HP Tuners `[ECM] 33482`. It deliberately displays native `mg/cyl` values with `MATH X`, zero decimal places, and a `100-1000` range so 32-bit float edits write back correctly. Enter `485` for an HPT value of `0.485 g`.
- Keep `TurbochargerKnockMaxAirmass_DISPLAY_G_DO_NOT_EDIT_04DD68` only as a decimal presentation view. It overlaps the editable view by design and uses `0.001 * X` to show `0.275-0.725 g`; never edit or apply table functions in it.
- Do not re-add the ambiguously named `TurbochargerKnockMaxAirmass_04DD68_RawStored` view. Its purpose is now covered explicitly by the guarded editable view and the clearly labeled display-only view.
- Second `opel_astra_mod1.bin` audit on 2026-07-12: SHA-256 `A232147FEC447278428C6E4F17EF35060ABC76BCAD100E76CD1B810982810D27`, `1054` bytes differ from stock, and all 88 cells at `0x04DD68` are stored as `0.275-0.900`. The screenshot values around `0.3` are those invalid native floats rounded to one decimal place, not a valid engineering-unit display. Do not use this BIN as the next edit base.
- Third `opel_astra_mod1.bin` audit on 2026-07-12 after the user restored Max: SHA-256 `8226503D5416A4731762E60D364F6852D33B13C54FCE181A44C2E530A151B0B3`, `717` bytes differ from stock, and all 88 cells at `0x04DD68` are byte-for-byte identical to stock (`275-725` native floats). The Scav table at `0x04E350` remains modified in 83 of 88 cells and displays `0.275-0.900 g`. This was the state before synchronizing both tables to the larger values.
- Fourth `opel_astra_mod1.bin` audit on 2026-07-12 after knock-airmass synchronization: SHA-256 `F1C6BA04B0C0D912A8C66179F07F5D668B337DE0566CBDC14BF571EC35923E26`, `769` bytes differ from stock. The existing Scav table was left byte-for-byte unchanged. Its 88 values were converted from raw counts to `mg/cyl` and written to Max as native 32-bit big-endian floats; `30/88` Max cells and `52` bytes changed. Both tables now decode identically over `0.275-0.900 g/cyl`. The pre-sync BIN is preserved at `_quarantine/bin_backups/opel_astra_mod1_before_knock_airmass_sync_20260712.bin` with SHA-256 `8226503D5416A4731762E60D364F6852D33B13C54FCE181A44C2E530A151B0B3`.
- Keep `TurbochargerKnockAirmassScav_04E350` as the main editable/display table for HP Tuners `[ECM] 33495`.
- Keep `TurbochargerKnockAirmassScav_04E350_RawStored` as a raw verification view; it should show approximately `4320-11600`.
- Keep `MaxBoostLimit_04DFB4` as the main editable/display table for HP Tuners `[ECM] 33460`; its Z range is `0-512 kPa`.
- Keep `TurboOverspeedMaxPressureRatio_04D9BC` and `CompressorSurgeLimit_029858` active in the main XDF. They load successfully in the regenerated `09_all_quarantined_groups_regenerated.xdf` layout, with turbo pressure-ratio/surge entries inserted before the PE and knock-enrichment blocks.
- Treat `CompressorSurgeLimit_029858` as confirmed exact. Treat `TurboOverspeedMaxPressureRatio_04D9BC` as high confidence because its axis matches exactly, but the stock Astra original row is higher in the middle cells than the provided HPT screenshot.
- Keep `PeakEngineTorque_0534A4`, `MaxEngineTorqueLimit_0535A4`, and `OverboostTorqueLimit_053464` as the confirmed torque-table views for HP Tuners `[ECM] 32920`, `[ECM] 32923`, and `[ECM] 32924`; their Z ranges are `-8192 to 8192 Nm`.
- Keep `TransOutputMax_021648`, `FrontAxleMax_021638`, `FrontAxleMax4WDLow_021630`, `FrontPropshaftMax_02163C`, `RearAxleMax_021640`, `RearAxleMax4WDLow_021634`, and `RearPropshaftMax_021644` as the high-confidence TSXC driveline torque limit scalars. Current Astra stock values are `100000/131072 Nm` depending on scalar and do not exactly match the HPT screenshot example.
- Keep `BrakeTorqueLimit_MaxDriverIntended_047CE4` as the high-confidence `KeBRKC_M_MaxDrvIntBrkTorq` scalar (`6000 Nm`). Treat it as the best current brake torque limit scalar match, not as proof that the BTRC brake torque management limit table has been found.
- Keep the three `BrakeTorqueLimitMult_Candidate*` views active only as candidate/fingerprint views. They are plausible `KtBTRC_K_TorqLimit_ExtBrk_OBD`-style multiplier tables, but the active HPT copy is not proven yet.
- Keep the four `TCS_*` entries under `Engine->Torque`. `TCS_MaxTorqueDecrement_051D90` is the preferred direct ECM-side disable candidate; the ECT and presence controls are independent confirmation/fallback paths, and the run-time control is temporary only. None of these disables EBCM brake intervention.
- Do not add `Default Trans Limit`, the true BTRC `Brake Torque Limit` vacuum-indexed table, or TTQC per-gear request limits until a changed-bin fingerprint or cleaner local match is available. The CSV BTRC entry `KtBTRC_M_BTM_Lim` (`0x0488F0`, `1 x 17` eHiLo) overlaps the source multiplier layout and still has no trustworthy Astra target.
- Keep the OS12646746-style THMC entries in `Engine->Thermal` as candidate/inspection views only: `KaTHMC_T_EngCool_Labels_Candidate_079C88`, `KaTHMC_T_EngCool_Candidate_079C50`, and `KaTHMC_T_EngCoolReq_Candidate_079C6C`. The scales decode as literal 32-bit big-endian floats, but the Astra WinOLS CSV does not contain those exact symbols and the `0x079C50` values are not credible as a confirmed Max/Min desired ECT table.
- Keep the editable cold ECT entries in `Engine->Thermal`: `ColdMaxDesiredECT_079CB0`, `ColdMinDesiredECT_079CCC`, and `ColdDesiredECTThreshold_079D18`. These are normal 32-bit big-endian float rows in deg C and match the Damos/WinOLS value lists.
- Keep `DesiredECT_TMSRequest_RawPairs_077B56` and `KaTHMC_T_EngCool_OS12646746_RawPairs_077B9E` as raw inspection views only. Do not reintroduce `ColdMaxDesiredECT_RawPairs_077B02` or `ColdMinDesiredECT_RawPairs_077B1E` as editable views; those windows showed one table plus the next adjacent table, which is why they looked wrong in TunerPro.
- Keep `DriverDemand_A_046944`, `DriverDemand_B_046DC8`, and `DriverDemand_C_04724C` as the confirmed target Driver Demand A/B/C views; their HPT nominal range is `-500000 to 500000`, but the XDF uses `-100 to 160 Nm` for TunerPro graph readability.
- Keep the P0068 Airflow Correlation entries active in `Airflow->P0068 Correlation`: `AirflowCorrelationEnableRPM_07A570`, `MaxAirflowVsIGNV_07A586`, `MaxAirflowVsRPM_07A59C`, `MaximumAirflowDeltaVsTPS_07A59E`, and `MaximumMAPDeltaVsTPS_07A5B2`. The two delta tables use the shared TPS axis at `0x07A5C6`; `MaxAirflowVsRPM_07A59C` intentionally overlaps the first eight Airflow Delta cells.
- Keep `PowerEnrichEQRatio_06233E` as the confirmed HP Tuners `[ECM] 12400` Power Enrich EQ Ratio view; `PowerEnrichEQRatioE80_06248C` is the byte-identical E80 companion in this BIN.
- Keep the `PowerEnrichment*` entries around `0x062096-0x0625D8` active in the main XDF, with the caveat that `PowerEnrichmentMinRPM_062096` and `PowerEnrichmentEnableTorquePct_0620AE` do not match the screenshot values in this Astra BIN (`700 rpm` vs `8000 rpm`, and `0%` vs `97%`).
- Keep `KnockEnrichment*` entries around `0x05FB44-0x05FC9C` active in the main XDF as the confirmed FEQR pre-ignition/knock-enrichment cluster. Do not claim a separate alcohol/E80 knock enrichment EQ table until a unique non-all-1.0 fingerprint is found.
- For knock enrichment graph axes, keep the XDF axes at `0x05FB1E` and `0x05FB32`; the preceding `0x05FB1C` and `0x05FB30` words are axis count markers.
- HP Tuners tree triage from 2026-07-09: do not prioritize `Manual Trans Spark Smoothing (RDSC) Master Enable`, `Piston Slap Spark`, `PDA Spark`, EGR spark add/PDA/DOD tables, or `Minimum Spark Advance Double Pulse` for this XDF pass. User confirmed `SparkSmoothingRunFilterRefs_075C36` is functionally similar enough for the manual-trans spark smoothing/RDSC control, and Piston Slap, PDA, EGR, and Double Pulse tables are zeroed out in this calibration.
- After that triage, the useful unresolved items from the compared HP Tuners tree are mainly `High Octane DP`, `High Octane DOD`, `Low Octane DOD`, `VCP Spark PDA`, `Trans Default Torque Limit`, the true BTRC `Brake Torque Limit` table, and confirmation of which `BrakeTorqueLimitMult_Candidate*` copy HPT edits, plus any collapsed `Fuel->Temperature Control` items that are not already represented by the CCTI/FEQR temperature-protection notes.
- Proven FEQR temperature-protection entries are active under `Fuel->Protection`. The separate CCTI catalyst/turbo candidates remain subject to their individual confidence notes and prior load-test history.
- Current active XDF has 158 table entries as of 2026-07-12: the prior 87-entry layout plus 71 newly proven FEQR flash calibrations.
- Current categories are `Search->Raw Views`, `Airflow->Turbocharger`, `Engine->Torque`, `Engine->Driver Demand`, `Airflow->P0068 Correlation`, `Fuel->Power Enrich`, `Fuel->Knock Enrichment`, `Spark->Base`, `Spark->Fuel`, `Spark->VCT`, `Spark->Humidity`, `Spark->Minimum Spark`, `Spark->General`, `Engine->Thermal`, `Fuel->Cranking`, `Fuel->Open Loop`, `Fuel->Protection`, `Fuel->AIR`, and `Fuel->General`.
- TunerPro category convention used here: `<CATEGORY index="0x0">` is referenced by `<CATEGORYMEM category="1">`, so declarations are zero-based and memberships are one-based.
- A known-good no-category backup of the same 49-table layout is preserved at `_quarantine/load_tests/12_main_49_no_categories_loaded_backup.xdf`; the categorized copy is also preserved at `_quarantine/load_tests/13_main_49_with_categories.xdf`.
- Load-test variants created under `_quarantine/load_tests/` on 2026-07-08:
  - `01_turbo_pressure_ratio_only.xdf`: base XDF plus `TurboOverspeedMaxPressureRatio_04D9BC` and `CompressorSurgeLimit_029858` only.
  - `02_power_enrich_eq_only.xdf`: base XDF plus `PowerEnrichEQRatio_06233E` and `PowerEnrichEQRatioE80_06248C` only.
  - `03_power_enrich_enable_delay_only.xdf`: base XDF plus the eight `PowerEnrichment*` scalar/table entries only.
  - `04_knock_enrichment_only.xdf`: base XDF plus the nine `KnockEnrichment*` entries only.
  - `05_power_enrich_all.xdf`: base XDF plus both PE EQ tables and all PE enable/delay/ramp entries.
  - `06_turbo_plus_power_enrich_all.xdf`: base XDF plus turbo pressure-ratio/surge and all PE entries.
- Suggested test order: confirm the main XDF loads, then try load-test files `01` through `04`. If all individual groups load, try `05`, then `06`, then the full crash candidate `_quarantine/E78_Astra_047922_TableSearch_recent_crash_candidate_20260708.xdf`.
- User confirmed load-test files `01` through `06` all load in TunerPro. Second-stage interaction variants created:
  - `07_turbo_plus_knock_enrichment.xdf`: base XDF plus turbo pressure-ratio/surge and knock-enrichment entries.
  - `08_power_enrich_plus_knock_enrichment.xdf`: base XDF plus all PE entries and knock-enrichment entries.
  - `09_all_quarantined_groups_regenerated.xdf`: base XDF plus turbo, PE, and knock-enrichment groups regenerated from the quarantine blocks.
  - `10_full_crash_candidate_direct_copy.xdf`: direct copy of the full 49-table crash candidate, for checking whether regeneration/order changed behavior.
- User confirmed `07`, `08`, and regenerated full variant `09` load, while direct copy `10` crashes. The main XDF was promoted from `09` on 2026-07-08. The crash appears tied to the old direct candidate's metadata/order/line-ending state, not the table definitions themselves.
- If the categorized main XDF crashes in TunerPro, compare against `_quarantine/load_tests/12_main_49_no_categories_loaded_backup.xdf` first before changing table definitions.
- Treat `COTMaxEnrichment_0636CC` as the HPT-shaped `[ECM] 12232` view and `COTMaxEnrichmentScalar_04E900` as the local CCTI scalar reference until a changed-bin fingerprint proves which one HPT edits.
- Embedded float axes in the confirmed knock-airmass views use XDF `datatype` `6` plus `<embedinfo type="1" />`; leaving either out can make TunerPro display zeroed axis labels.
- Do not patch `opel_astra_original.bin` directly without checksum/CVN handling.
- When a table is found, record at minimum: table name, address, dimensions, endian/format, math, units, axes, confidence level, and how it was validated.
