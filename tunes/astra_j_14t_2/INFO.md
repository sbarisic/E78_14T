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
- Editor/display range: `-500000 to 500000`

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

## XDF Maintenance Notes

- Keep `TurbochargerKnockMaxAirmass_04DD68` as the main editable/display table for HP Tuners `[ECM] 33482`.
- Keep `TurbochargerKnockMaxAirmass_04DD68_RawStored` as a raw verification view; it should show approximately `275-725`.
- Keep `TurbochargerKnockAirmassScav_04E350` as the main editable/display table for HP Tuners `[ECM] 33495`.
- Keep `TurbochargerKnockAirmassScav_04E350_RawStored` as a raw verification view; it should show approximately `4320-11600`.
- Keep `MaxBoostLimit_04DFB4` as the main editable/display table for HP Tuners `[ECM] 33460`; its Z range is `0-512 kPa`.
- Keep `PeakEngineTorque_0534A4`, `MaxEngineTorqueLimit_0535A4`, and `OverboostTorqueLimit_053464` as the confirmed torque-table views for HP Tuners `[ECM] 32920`, `[ECM] 32923`, and `[ECM] 32924`; their Z ranges are `-8192 to 8192 Nm`.
- Keep `DriverDemand_A_046944`, `DriverDemand_B_046DC8`, and `DriverDemand_C_04724C` as the confirmed target Driver Demand A/B/C views; their Z ranges are `-500000 to 500000`.
- Embedded float axes in the confirmed knock-airmass views use XDF `datatype` `6` plus `<embedinfo type="1" />`; leaving either out can make TunerPro display zeroed axis labels.
- Do not patch `opel_astra_original.bin` directly without checksum/CVN handling.
- When a table is found, record at minimum: table name, address, dimensions, endian/format, math, units, axes, confidence level, and how it was validated.
