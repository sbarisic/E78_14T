# Astra J 1.4T E78 Table Search Notes

Working folder: `E:\Projects\E78_14T\tunes\astra_j_14t_2`

Target binary: `opel_astra_original.bin`

SHA256: `2E562B30BB48A72205F9DD4756E152BC44EEF6B07D2F76F3FE25E222952824CD`

Primary working XDF: `E78_Astra_047922_TableSearch.xdf`

## Purpose

This folder is for locating and documenting tables in `opel_astra_original.bin`, especially tables seen in HP Tuners/VCM Editor and then represented in TunerPro XDF form.

`E78_HexView.xdf` in `E:\Projects\E78_14T\xdf` is used as a numeric raw view in VCM Editor to see where bytes changed and how much. `E78_Astra_047922_TableSearch.xdf` is the focused TunerPro work file for the `HexView047922` area and the nearby knock-airmass calibration block.

## Current Confirmed Tables

### HP Tuners [ECM] 33482 - Turbocharger Knock Max Airmass

Confirmed TunerPro entry: `TurbochargerKnockMaxAirmass_04DD68`

- Z table address: `0x04DD68`
- Format: `8 x 11`, 32-bit big-endian float
- Stored values: grams * 1000
- TunerPro math: `X / 1000`
- Display units: `g`
- X axis address: `0x04DEC8`
- X axis values: `-25, -20, -15, -13, -11, -9, -7, -5, -3, -1, 0`
- Y axis address: `0x04DF3C`
- Y axis values: `1400, 1700, 2000, 2300, 3000, 4000, 5000, 6000`

Displayed table values in this BIN:

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

### HP Tuners [ECM] 14044 / 14045 - TPS Delta Limits

Confirmed TunerPro entries:

- `[ECM] 14044 Maximum Airflow Delta vs. TPS`: `MaximumAirflowDeltaVsTPS_07A59E`
- `[ECM] 14045 Maximum MAP Delta vs. TPS`: `MaximumMAPDeltaVsTPS_07A5B2`

Format and range:

- Storage: 16-bit big-endian
- Format: `1 x 9`
- Value math: `X / 128`
- `[ECM] 14044` is unsigned, XDF range `0 to 512`; screenshot unit is `g/s`
- `[ECM] 14045` is signed-style, XDF range `-256 to 256 kPa`

Target axis in `opel_astra_original.bin`:

- TPS axis address: `0x07A5C6`
- TPS axis storage: 16-bit big-endian, math `X / 655.35`
- Target TPS axis values: `1.0, 6.0, 12.0, 15.0, 20.0, 25.0, 30.0, 40.0, 60.0`

Target table addresses and readback:

```text
14044 / Airflow Delta @ 0x07A59E:
5.50 7.00 9.60 11.70 14.84 19.13 27.27 56.00 150.00

14045 / MAP Delta @ 0x07A5B2:
36.00 37.00 32.00 42.00 41.50 46.00 47.00 69.00 150.00
```

Evidence:

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
- `PowerEnrichmentDelayTorquePct_0625D8`: scalar, 32-bit big-endian float, `%`. Target readback is `100.0%`.
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

Evidence:

- The main FEQR PE scalar/table run relocates from the Corsa reference by the same `+0x61FC` family delta used for `[ECM] 12400`.
- The local dimension markers line up with the table starts: `0x0011` before the two `1 x 17` tables and `0x0011 0x0011` immediately before `PowerEnrichmentDelayStep_0620F8`.
- The `PowerEnrichmentDelayTorquePct_0625D8` scalar is farther from the `0x0620xx` run, but decodes as a clean 32-bit float `100.0`, matching the green `Delay Torque %` screenshot value.

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

Quarantined from the main XDF on 2026-07-08 because TunerPro crashed while loading the Fuel temperature-control table block. Addresses/scaling are retained here for re-adding in smaller batches.

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
- `HotEngineDisableECT_05FA44`: FEQR hot-engine disable ECT. Signed 16-bit big-endian, `X / 128`, deg C. Target readback is `120`.
- `HotEngineMaxEnrich_05FA5A`: FEQR hot-engine maximum enrichment. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.399`.
- `TurboOvertempMaxEnrichment_04E960`: CCTI turbo overtemperature maximum enrichment. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.420`.
- `TurboOvertempMinEnrichment_04EA26`: CCTI turbo overtemperature minimum enrichment. Unsigned 16-bit big-endian, `X / 1024`, EQ Ratio. Target readback is `1.026`, matching HPT display `1.03`.
- `TurboTempThresholds_04E9D2`: likely turbo protection threshold group. Unsigned 16-bit big-endian, `X * 0.0625`, deg C. Target readback is `700, 800, 850, 900, 1000`.

Evidence and caveats:

- The FEQR hot-engine/piston scalars match the HP Tuners Temperature Control screenshot values directly: `3600 rpm`, `3500 rpm`, `256 deg C`, `120 deg C`, and `1.399`.
- The CCTI turbo enrichment scalars match the screenshot values directly: `1.42` max enrichment and `1.03` min enrichment.
- The HPT `[ECM] 12232` COT Max Enrichment screenshot is a `1 x 5` alcohol table with all cells around `1.37`; the contiguous repeated block at `0x0636CC` fits that display shape. The nearby CCTI scalar at `0x04E900` also decodes to `1.370`, so both are kept in the XDF until the exact HPT source symbol is nailed down.
- `COT` enable and `Turbo Overtemp` enable dropdown enum/boolean targets were not added yet because the local raw words near the cluster do not uniquely identify the HPT switch without a changed-bin fingerprint.

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
| DTRC driver demand | `[ECM] 33050` Driver Demand A | `KtDTRC_P_M_PedProgReqA` `0x03FAE8` | `0x046944` | `+0x6E5C` | Source axes relocate by `+0x6E18`: X `0x040EF4 -> 0x047D0C`, Y `0x040E04 -> 0x047C1C`. |
| DTRC driver demand | Driver Demand B | `KtDTRC_P_M_PedProgReqB` `0x03FF6C` | `0x046DC8` | `+0x6E5C` | Same shared target axes as A/C. |
| DTRC driver demand | Driver Demand C | `KtDTRC_P_M_PedProgReqC` `0x0403F0` | `0x04724C` | `+0x6E5C` | Same shared target axes as A/B. |
| TPS delta | `[ECM] 14044` Maximum Airflow Delta vs. TPS | HPT/Corsa fingerprint `0x07BFEE` | `0x07A59E` | `-0x1A50` | Shared TPS axis `0x07C016 -> 0x07A5C6` is also `-0x1A50`. |
| TPS delta | `[ECM] 14045` Maximum MAP Delta vs. TPS | HPT/Corsa fingerprint `0x07C002` | `0x07A5B2` | `-0x1A50` | Same shared TPS axis. |
| FEQR power enrichment | `[ECM] 12400` Power Enrich EQ Ratio | `KtFEQR_eqr_PE_RPM` `0x05C142` | `0x06233E` | `+0x61FC` | Generated/static RPM axis in XDF. |
| FEQR power enrichment | `[ECM] 12400` companion E80 | `KtFEQR_eqr_PE_RPM_E80` `0x05C290` | `0x06248C` | `+0x61FC` | Byte-identical companion in this Astra BIN. |
| FEQR power enrichment | `[ECM] 12418` Power Enrichment Enable Torque % | `KtFEQR_Pct_PE_LoadThrsh` `0x05BEB2` | `0x0620AE` | `+0x61FC` | Target values are all `0%`, unlike the `97%` screenshot example. |
| FEQR power enrichment | Power Enrichment Enable Pedal | `KtFEQR_Pct_PE_ThrotThrshEngSpd` `0x05BED6` | `0x0620D2` | `+0x61FC` | Target values are all `80%`. |
| FEQR power enrichment | Power Enrichment Delay Step | `KtFEQR_t_PE_DelayAdjust` `0x05BEFC` | `0x0620F8` | `+0x61FC` | `17 x 17`, pedal by RPM, values around `0.100`. |
| FEQR power enrichment | Power Enrichment Delay Torque % | unresolved exact CSV symbol | `0x0625D8` | n/a | 32-bit big-endian float `100.0%`; found in the same local FEQR delay group. |
| FEQR knock enrichment | Knock Enrichment scalars and EQ ratio | FEQR pre-ignition protection island | `0x05FB44-0x05FC9C` | n/a | Scalars match HPT pane; axes start at `0x05FB1E` and `0x05FB32` after count markers. |
| CCTI temperature protection | Catalyst and turbo enrichment/threshold scalars | CCTI catalyst/turbo protection island | `0x04E8FA-0x04EA26` | n/a | COT scalar max/min, COT thresholds, turbo max/min enrichment, and likely turbo temp thresholds. |
| FEQR temperature protection | Hot engine and piston/component protection | FEQR hot-engine/piston island | `0x05FA44-0x05FAF2` | n/a | Hot-engine ECT/enrichment and piston enable/disable RPM plus 0-8192 rpm enrichment row. |
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

Search heuristics from the confirmed tables:

- For BSTC knock/boost tables, try nearby source-to-target deltas around `+0x5A00` to `+0x6000`, then confirm by axes and storage type.
- For BSTC turbo compressor pressure-ratio tables, `KaBSTC_r_CompPressRatioMaxSpd` used a local `+0x603x` body/axis delta in this BIN; the body and axis are close but not identical deltas.
- For BSTD turbo compressor diagnostic/surge tables, the Corsa reference to Astra target shift was `-0x04B4` for both table and axis.
- For DTRC driver-demand tables, body anchors used `+0x6E5C`; shared axes used `+0x6E18`.
- For ECPR torque, table bodies are around `+0x73xx`; shared axes are around `+0x71xx`.
- For the TPS delta pair, the table and axis relocation was a clean `-0x1A50`.
- For FEQR Power Enrich EQ Ratio, both table bodies used a clean `+0x61FC`.
- For FEQR Power Enrichment enable/delay/ramp tables, the nearby `0x0620xx` entries also use the `+0x61FC` family delta, but the Astra calibration values can differ heavily from the HPT screenshot example.
- For Knock Enrichment / FEQR pre-ignition protection, confirm count markers before axes and table bodies. The real axes start after the `0x0009` count words, not on them.
- For Fuel Temperature Control, search both the CCTI catalyst/turbo island near `0x04E8FA-0x04EA26` and the FEQR hot-engine/piston island near `0x05FA44-0x05FAF2`; they are different calibration families despite landing in the same HPT pane.
- HPT HexView windows are useful visual clues, but several do not map byte-for-byte to raw file addresses in this Astra BIN. Prefer source/fingerprint relocation plus table-shape validation over the HexView window delta alone.

Name notes:

- `[ECM] 33495` HPT display name is `Turbocharger Knock Airmass Scav` / short display `Knock Airmass Scav`. The WinOLS symbol `KtBSTC_m_MaxKnkSC` has a similar "Max allowed airmass with regards to knock" description, but its source axes do not cleanly match the confirmed `[ECM] 33495` target axes, so keep the exact source symbol unresolved for now.
- `[ECM] 32923` HPT display name is `Max Engine Torque Limit`. The matching RAM/output name in the reference export is `VeECPR_M_EngMaxTorqLimit`, but the exact calibration-source `Kt*` symbol for the confirmed `0x0535A4` target table is still unresolved. Do not use `KtECPR_M_MaxBrkTorqLmt` as the source match; its reference values are a 1000 Nm limit table and do not match the HPT screenshot.

## XDF Maintenance Notes

- Keep `TurbochargerKnockMaxAirmass_04DD68` as the main editable/display table for HP Tuners `[ECM] 33482`.
- Keep `TurbochargerKnockMaxAirmass_04DD68_RawStored` as a raw verification view; it should show approximately `275-725`.
- Keep `TurbochargerKnockAirmassScav_04E350` as the main editable/display table for HP Tuners `[ECM] 33495`.
- Keep `TurbochargerKnockAirmassScav_04E350_RawStored` as a raw verification view; it should show approximately `4320-11600`.
- Keep `MaxBoostLimit_04DFB4` as the main editable/display table for HP Tuners `[ECM] 33460`; its Z range is `0-512 kPa`.
- Keep `TurboOverspeedMaxPressureRatio_04D9BC` and `CompressorSurgeLimit_029858` active in the main XDF. They load successfully in the regenerated `09_all_quarantined_groups_regenerated.xdf` layout, with turbo pressure-ratio/surge entries inserted before the PE and knock-enrichment blocks.
- Treat `CompressorSurgeLimit_029858` as confirmed exact. Treat `TurboOverspeedMaxPressureRatio_04D9BC` as high confidence because its axis matches exactly, but the stock Astra original row is higher in the middle cells than the provided HPT screenshot.
- Keep `PeakEngineTorque_0534A4`, `MaxEngineTorqueLimit_0535A4`, and `OverboostTorqueLimit_053464` as the confirmed torque-table views for HP Tuners `[ECM] 32920`, `[ECM] 32923`, and `[ECM] 32924`; their Z ranges are `-8192 to 8192 Nm`.
- Keep `DriverDemand_A_046944`, `DriverDemand_B_046DC8`, and `DriverDemand_C_04724C` as the confirmed target Driver Demand A/B/C views; their HPT nominal range is `-500000 to 500000`, but the XDF uses `-100 to 160 Nm` for TunerPro graph readability.
- Keep `MaximumAirflowDeltaVsTPS_07A59E` and `MaximumMAPDeltaVsTPS_07A5B2` as the confirmed HP Tuners `[ECM] 14044`/`[ECM] 14045` equivalents; both use the shared TPS axis at `0x07A5C6`.
- Keep `PowerEnrichEQRatio_06233E` as the confirmed HP Tuners `[ECM] 12400` Power Enrich EQ Ratio view; `PowerEnrichEQRatioE80_06248C` is the byte-identical E80 companion in this BIN.
- Keep the `PowerEnrichment*` entries around `0x062096-0x0625D8` active in the main XDF, with the caveat that `PowerEnrichmentMinRPM_062096` and `PowerEnrichmentEnableTorquePct_0620AE` do not match the screenshot values in this Astra BIN (`700 rpm` vs `8000 rpm`, and `0%` vs `97%`).
- Keep `KnockEnrichment*` entries around `0x05FB44-0x05FC9C` active in the main XDF as the confirmed FEQR pre-ignition/knock-enrichment cluster. Do not claim a separate alcohol/E80 knock enrichment EQ table until a unique non-all-1.0 fingerprint is found.
- For knock enrichment graph axes, keep the XDF axes at `0x05FB1E` and `0x05FB32`; the preceding `0x05FB1C` and `0x05FB30` words are axis count markers.
- Fuel temperature-control entries are currently not active in the main XDF; re-add them in smaller batches and load-test TunerPro after each batch.
- Current active XDF uses the regenerated 49-table layout from `09_all_quarantined_groups_regenerated.xdf`: stable 28-table base plus turbo pressure-ratio/surge, PE EQ, PE enable/delay/ramp, and knock-enrichment entries. Fuel temperature-control definitions remain quarantined.
- Categories were re-added to the main XDF on 2026-07-08 after the regenerated 49-table layout load-tested successfully. Current categories are `Search->Raw Views`, `Airflow->Turbocharger`, `Engine->Torque`, `Engine->Driver Demand`, `Airflow->TPS Delta`, `Fuel->Power Enrich`, and `Fuel->Knock Enrichment`.
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
