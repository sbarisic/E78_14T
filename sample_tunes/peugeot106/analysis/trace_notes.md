## Targeted Trace Notes

- `0x802E` `21x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `57/189` cells (`+4..+6`, avg `+5.6`).
  - `xantia_607c` differs in `189/189` cells (`-76..+62`, avg `-14.9`).
  - `peug_106rally_org` differs in `0/189` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `116/189` cells (`-13..+38`, avg `+0.5`).
- `0x802E` `24x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `75/216` cells (`+4..+6`, avg `+5.4`).
  - `xantia_607c` differs in `216/216` cells (`-76..+82`, avg `-11.8`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `133/216` cells (`-25..+68`, avg `-0.1`).
- `0x80EB` `21x9` (raw): Peugeot immediate word-reference hits `0`.
  - `peugeot_mod2` differs in `60/189` cells (`-251..+5`, avg `+0.7`).
  - `xantia_607c` differs in `189/189` cells (`-240..+245`, avg `-3.8`).
  - `peug_106rally_org` differs in `0/189` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `126/189` cells (`-184..+250`, avg `-1.5`).
- `0x80F1` `25x9` (signed8): Peugeot immediate word-reference hits `0`.
  - `peugeot_mod2` differs in `90/225` cells (`+5..+18`, avg `+5.9`).
  - `xantia_607c` differs in `225/225` cells (`-91..+100`, avg `+21.2`).
  - `peug_106rally_org` differs in `0/225` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `150/225` cells (`-50..+146`, avg `+1.2`).
- `0x81A8` `5x9` (raw): Peugeot immediate word-reference hits `0`.
  - `peugeot_mod2` differs in `30/45` cells (`-251..+18`, avg `-60.7`).
  - `xantia_607c` differs in `45/45` cells (`-245..+239`, avg `-46.0`).
  - `peug_106rally_org` differs in `0/45` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `30/45` cells (`-161..+254`, avg `+1.5`).

Spark alignment scan against Peugeot stock 24x9+24x9+1x24 bundle:

| ROM | Best high-bank start | Shift vs 0x8A69 | RMSE high | RMSE low | RMSE WOT | Notes |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `peugeot_stock` | `0x8A69` | `+0` | 0.0 | 0.0 | 0.0 | same-offset |
| `peugeot_stok` | `0x8A69` | `+0` | 0.0 | 0.0 | 0.0 | same-offset |
| `peugeot_mod2` | `0x8A69` | `+0` | 3.6 | 6.9 | 0.0 | same-offset |
| `xantia_607c` | `0x89BB` | `-174` | 19.8 | 16.7 | 12.7 | same-family offset candidate only |
| `peug_106rally_org` | `0x8A69` | `+0` | 23.8 | 27.7 | 0.0 | same-offset but heavily altered spark banks; WOT vector unchanged |
| `rally13_ori` | `0x8A84` | `+27` | 0.0 | 0.0 | 0.0 | exact stock spark bundle shifted +0x1B |

- `0x20EB`: `4` scanned refs; stores/clears at 0xBB9A, 0xBD39; loads/math at 0xBC67, 0xBC7A.
- `0x20ED`: `4` scanned refs; stores/clears at 0xBB9D, 0xBD4F; loads/math at 0xBCB1, 0xBCC1.
- `0x242B`: `3` scanned refs; stores/clears at 0xBD1B; loads/math at 0xBC64, 0xBC76.
- `0x242D`: `2` scanned refs; stores/clears at 0xBCAE; loads/math at 0xBCBD.
- `0x20BC`: `2` scanned refs; stores/clears at 0xBAB1, 0xBBEC; loads/math at -.
- `0x242F`: `5` scanned refs; stores/clears at 0xBAB5, 0xBAC6; loads/math at 0xBABE, 0xBB49, 0xBB53.
- `0x2431`: `2` scanned refs; stores/clears at 0xBB68, 0xBB79; loads/math at -.

- `0x1030` ADC/load path: `16` scanned refs; first sites 0x40E8, 0x4133, 0x51EF, 0x52D1, 0xB82C, 0xB8C0, 0xBC23, 0xBCD0, 0xDA6B, 0xDA88, 0xDDB0, 0xDDFD.
- `0x1031` ADC/load path: `8` scanned refs; first sites 0x401E, 0x4113, 0x53CC, 0xBC2B, 0xBCD8, 0xDAB8, 0xDE48, 0xE116.
- `0x1032` ADC/load path: `5` scanned refs; first sites 0x403B, 0x4140, 0x52A8, 0x53D9, 0xDE31.
- `0x1033` ADC/load path: `7` scanned refs; first sites 0x4024, 0x4041, 0x4119, 0x4146, 0x52B5, 0x53E6, 0xDE17.
- `0x1034` ADC/load path: `7` scanned refs; first sites 0x402D, 0x405A, 0x411F, 0x414C, 0x52C2, 0x53F3, 0xDE5F.
- `0x2007` ADC/load path: `5` scanned refs; first sites 0x4044, 0x4149, 0x5E97, 0x5EEC, 0x96D3.
- `0x2008` ADC/load path: `7` scanned refs; first sites 0x4021, 0x40CE, 0x4116, 0x4322, 0x5C19, 0x96E9, 0xBB8A.
- `0x2009` ADC/load path: `6` scanned refs; first sites 0x40D7, 0x432B, 0x5BA0, 0x5BC4, 0x5CE9, 0xC61B.
- `0x200A` ADC/load path: `7` scanned refs; first sites 0x4030, 0x40B0, 0x4123, 0x4372, 0x5D1F, 0x6D25, 0x96F3.
- `0x200B` ADC/load path: `5` scanned refs; first sites 0x40B9, 0x437B, 0x47F1, 0x5D5D, 0x9554.
- `0x200C` ADC/load path: `4` scanned refs; first sites 0x403E, 0x4143, 0x5B1B, 0x5B8E.
- `0x200D` ADC/load path: `4` scanned refs; first sites 0x4027, 0x411C, 0x415D, 0x6933.
- `0x200E` ADC/load path: `7` scanned refs; first sites 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x5DA8, 0x96DA.
- `0x2013` ADC/load path: `11` scanned refs; first sites 0x404D, 0x4128, 0x5F20, 0x9792, 0x97AF, 0x98FF, 0x997E, 0x99A9, 0x99EB, 0x9CC4, 0x9D03.
- `0x00CE` ADC/load path: `19` scanned refs; first sites 0x4073, 0x409C, 0x412B, 0x41A1, 0x42E1, 0x45F3, 0x4FC1, 0x5E5E, 0x5E7C, 0x97E7, 0x98C1, 0x992C.
- `0x00D0` ADC/load path: `22` scanned refs; first sites 0x574A, 0x57BD, 0x5E5C, 0x5E77, 0x5F07, 0x5FAA, 0x8073, 0x96DE, 0x96F7, 0x97F4, 0x9800, 0x9953.
- `0x2034` ADC/load path: `8` scanned refs; first sites 0x41AD, 0x4913, 0x495F, 0x6EA9, 0x7258, 0xBA34, 0xBE78, 0xE3CF.

