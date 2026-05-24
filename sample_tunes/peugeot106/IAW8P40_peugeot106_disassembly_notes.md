# Marelli IAW 8P.40 Peugeot 106 68HC11 Disassembly Notes

Analysis date: 2026-05-24

## CPU Target

The ROM should be treated as Motorola/Freescale `68HC11` family code.

Local ROM evidence:

- 68HC11-style vector table at `0xFFF0-0xFFFF`.
- Reset vector `0xFFFE = 0xB800`.
- Code uses normal 68HC11 prebytes:
  - `0x18` page-2 / Y-index forms.
  - `0x1A` page-3 forms such as `CPD`.
  - `0xCD` page-4 forms such as `STX offset,Y`.
- The reset code writes the 68HC11 register block at `0x1000`.

External reference used for opcode confirmation:

- Motorola `M68HC11 E Series Technical Data`, instruction set table:
  `https://mekatronix.com/downloads/docs/hc11_tech_data.pdf`

The exact MCU mask/variant still needs PCB chip markings, but the disassembly target is confidently `68HC11`.

## Reset Path @ `0xB800`

Reset vector:

```text
0xFFFE -> 0xB800
```

Important reset observations:

- Initializes RAM flags such as `0x008E`, `0x008F`, `0x0094`, `0x0095`, `0x0096-0x009B`.
- Writes many registers in the `0x1000` range.
- Performs watchdog/service writes to `0x103A` using `0x55` / `0xAA`.
- Copies logical range `0x8000-0x9314`:

```asm
B843: CE 80 00      LDX #$8000
B846: 18 CE 80 00   LDY #$8000
B84A: 8C 93 15      CPX #$9315
B84D: 27 0A         BEQ $B859
B84F: A6 00         LDAA $00,X
B851: 18 A7 00      STAA $00,Y
B854: 08            INX
B855: 18 08         INY
B857: 20 F1         BRA $B84A
```

This may be a calibration RAM overlay / same logical read-write address window, or a redundant copy depending on ECU memory mapping. It is still important because the copied range contains most MOD2-touched calibration data.

After initialization, reset calls many setup and runtime routines, including:

```text
0x4017, 0x4034, 0x40A8, 0x409C,
0x9E98, 0xEF71, 0xD176, 0x729D,
0xB95F, 0xCAD7, 0xBC12, 0xCB6E,
0x4079, 0xD6AC, 0x956B, 0x4421,
0xE77E, 0xCB43, 0x9B61, 0xA012,
0xCBC4, 0x5652, 0x67A3, 0xBB98,
0xB555
```

## ADC / Raw Input Paths

The reset/runtime setup calls two ADC preload routines that copy ADR result
bytes into the `0x2007-0x200E` RAM channel area.

Representative copies:

```asm
401D: B6 10 31      LDAA $1031
4020: B7 20 08      STAA $2008
4023: B6 10 33      LDAA $1033
4026: B7 20 0D      STAA $200D
402C: B6 10 34      LDAA $1034
402F: B7 20 0A      STAA $200A

403A: B6 10 32      LDAA $1032
403D: B7 20 0C      STAA $200C
4040: B6 10 33      LDAA $1033
4043: B7 20 07      STAA $2007
404C: B7 20 13      STAA $2013      ; after helper 0x5E82
4059: B6 10 34      LDAA $1034
405C: B7 20 0E      STAA $200E
```

Current raw/processed channel matrix:

| RAM | Source | Main consumer clues | Status |
| ---: | --- | --- | --- |
| `0x2007` | `$1033` in second ADC group | `0x5E97`, `0x5EEC`, `0x96D3` | likely load/TPS/MAP-adjacent, not final |
| `0x2008` | `$1031` in first ADC group | `0x40CE`, `0x4322`, `0x5C19`, `0x96E9` | raw analog channel |
| `0x2009` | processed from `0x2008` path | `0x5BA0`, `0x5BC4`, `0x5CE9` | filtered/derived channel |
| `0x200A` | `$1034` in first ADC group | `0x40B0`, `0x4372`, `0x5D1F`, `0x6D25`, `0x96F3` | raw analog channel |
| `0x200B` | processed from `0x200A` path | `0x47F1`, `0x5D5D` | filtered/derived channel |
| `0x200C` | `$1032` in second ADC group | `0x5B1B`, `0x5B8E`, thresholds near `0x52A8/0x53D9` | raw analog channel |
| `0x200D` | `$1033` in first ADC group | helper `0x415D`, thresholds near `0x52B5/0x53E6` | raw analog channel |
| `0x200E` | `$1034` in second ADC group | `0x4173`, `0x418E`, `0x42F7`, `0x5DA8`, `0x96DA` | raw analog channel |
| `0x2013` | helper result from `$1033` path | multiple mode/threshold checks | processed sensor/status value |

The code confirms the RAM channel structure but not exact sensor names. MAP is
still the best candidate behind the normalized `0x2034` load axis because the
vehicle uses a 100 kPa PRT03-family MAP sensor and the axis clamps near
`0x0800`, but ADC transfer proof is still open.

## Checksum Routine @ `0x5AD8-0x5B18`

The checksum routine is confirmed as 68HC11 code.

Core behavior:

- Uses `X` as the current ROM pointer stored at RAM `0x2188`.
- Uses `Y` as the accumulated byte sum stored at RAM `0x218A`.
- Reads byte at `0,X`.
- Adds it into `Y` with `ABY`.
- Decrements `X`.
- Skips `0xB600-0xB7FF`.
- When `X < 0x4000`, compares `Y` against the 16-bit word at `0x800E`.
- Sets/clears flag `0x99 bit 0x04` based on pass/fail.

Important excerpt:

```asm
5ADC: FE 21 88      LDX $2188
5ADF: 18 FE 21 8A   LDY $218A
5AE3: 8C B6 00      CPX #$B600
5AE6: 25 05         BCS $5AED
5AE8: 8C B7 FF      CPX #$B7FF
5AEB: 23 08         BLS $5AF5
5AED: E6 00         LDAB $00,X
5AEF: 18 3A         ABY
5AF1: 18 FF 21 8A   STY $218A
5AF5: 09            DEX
5AF6: FF 21 88      STX $2188
5AF9: 8C 40 00      CPX #$4000
5AFC: 24 1A         BCC $5B18
5AFE: 18 BC 80 0E   CPY $800E
5B02: 26 05         BNE $5B09
```

This confirms the checksum notes already documented:

- `0x800E` is the byte-sum target / complement word.
- `0x800C` is its one's complement.

## Interpolation Helpers

### 1D Byte Interpolation @ `0xB2AB`

`0xB2AB` is a signed-aware byte interpolation helper.

Input pattern:

- `Y` points to byte vector/table.
- `D` is an 8.8-style index:
  - `A` = integer index.
  - `B` = fractional part.
- Output is in `A`.

Core behavior:

```asm
B2AB: 37             PSHB
B2AC: 16             TAB
B2AD: 18 3A         ABY
B2AF: 18 A6 01      LDAA $01,Y
B2B2: 18 A0 00      SUBA $00,Y
...
B2C7: 3D            MUL
B2C8: 89 00         ADCA #$00
...
B2D1: 18 AB 00      ADDA $00,Y
B2D4: 39            RTS
```

Meaning:

```text
result = table[index] + ((table[index + 1] - table[index]) * fraction) / 256
```

The routine handles negative slopes too.

### 2D Byte Interpolation @ `0xB2D6`

`0xB2D6` is a 2D/bilinear byte interpolation helper.

Descriptor layout at `Y`:

| Offset | Meaning |
| ---: | --- |
| `Y+0` | X/column integer index |
| `Y+1` | X/column fractional part |
| `Y+2` | Y/row integer index |
| `Y+3` | Y/row fractional part |
| `Y+4..Y+5` | table base pointer |
| `Y+6` | row stride / column count |

Core behavior:

```asm
B2D6: 18 E6 06      LDAB $06,Y       ; stride
B2D9: 18 A6 02      LDAA $02,Y       ; row integer
B2DC: 3D            MUL
B2DD: 18 EB 00      ADDB $00,Y       ; add column integer
B2E2: 18 E3 04      ADDD $04,Y       ; add table base
B2E5: 8F            XGDX             ; X = cell pointer
...
B2F9: AB 00         ADDA $00,X       ; interpolate first row
...
B300: 3A            ABX              ; next row
...
B314: AB 00         ADDA $00,X       ; interpolate next row
...
B318: 18 E6 03      LDAB $03,Y       ; row fraction
...
B328: 1B            ABA              ; final bilinear blend
B329: 39            RTS
```

This is now the strongest tool for proving which XDF views are real maps.

## Code-Confirmed Banked 2D Table @ `0x8A69` / `0x8B41`

The earlier raw `48x9 @ 0x8A68` view was close but off by one byte.

The routine at `0x48EE-0x4941` proves the actual structure:

- `0x8A68` is a separate signed offset byte.
- `0x8A69` is a `24x9` 2D table bank.
- `0x8B41` is a second `24x9` 2D table bank.
- `0x8C18` is the final cell of the `0x8B41` bank, not a separate adjacent vector.

Important excerpt:

```asm
48EE: CC 00 00      LDD #$0000
48F1: FD 21 47      STD $2147
48F4: 13 A9 20 0C   BRCLR $A9, #$20, $4904
48F8: 18 CE 8C 19   LDY #$8C19
48FC: FC 20 36      LDD $2036
48FF: BD B2 AB      JSR $B2AB
4902: 20 35         BRA $4939

4904: CE 8A 69      LDX #$8A69
4907: 7D 20 B1      TST $20B1
490A: 26 03         BNE $490F
490C: CE 8B 41      LDX #$8B41
490F: 18 CE 21 3A   LDY #$213A
4913: FC 20 34      LDD $2034
4916: 18 ED 00      STD $00,Y
4919: FC 20 36      LDD $2036
491C: 18 ED 02      STD $02,Y
491F: CD EF 04      STX $04,Y
4922: 86 09         LDAA #$09
4924: 18 A7 06      STAA $06,Y
4927: BD B2 D6      JSR $B2D6
```

Bank select:

```text
if RAM[0x20B1] != 0:
    table = 0x8A69
else:
    table = 0x8B41
```

Selector source:

```asm
CBEF: B6 80 0A      LDAA $800A
CBF2: 26 08         BNE $CBFC
...
CBFB: 4A            DECA
CBFC: B7 20 B1      STAA $20B1
CBFF: 39            RTS
```

Stock and MOD2 both have `0x800A = 0x00`. Because the routine decrements the
value before storing it, runtime `0x20B1` becomes `0xFF`, so stock runtime
behavior should select the nonzero `0x8A69` bank. If `0x800A` were `0x01`, the
stored selector would become `0x00` and the `0x8B41` bank would be selected.

Working bank naming:

- `0x8A69`: likely high-octane/default spark advance bank.
- `0x8B41`: likely low-octane/alternate spark advance bank.
- Reasoning: stock selector behavior defaults to `0x8A69`, and a stock
  table-to-table comparison shows `0x8B41` is usually lower in high-load
  columns even though it has a mid-load advance ridge.

Inputs:

```text
RAM 0x2034 -> descriptor Y+0/Y+1
RAM 0x2036 -> descriptor Y+2/Y+3
```

Column count:

```text
9 columns
```

Optional signed offset:

```asm
492A: 13 A2 02 0B   BRCLR $A2, #$02, $4939
492E: F6 8A 68      LDAB $8A68
4931: 2A 03         BPL $4936
4933: 73 21 47      COM $2147
4936: F7 21 48      STAB $2148
4939: 16            TAB
493A: 4F            CLRA
493B: F3 21 47      ADDD $2147
493E: FD 21 47      STD $2147
4941: 39            RTS
```

This sign-extends byte `0x8A68` and adds it to the interpolated result when flag `0xA2 bit 0x02` is set.

Status:

- This is a real code-confirmed 2D calibration structure.
- Screenshot-assisted inference: likely spark advance bank pair.
- The online Peugeot 106 Rallye XDF screenshot shows spark tables in `0.5 deg/bit` units.
- These two banks display in plausible spark advance ranges when scaled as `raw / 2`.
- Stock selector behavior points at `0x8A69` as the normal/default active bank.
- Current working names are:
  - `0x8A69`: likely high-octane/default spark advance bank.
  - `0x8B41`: likely low-octane/alternate spark advance bank.
  - `0x20B1`: likely `spark_bank_selector_state`.
- This is still marked likely until the knock/fallback path is fully traced.
- Because it is MOD2-touched and bilinear-interpolated, it is a high-priority map candidate.

Downstream `0x2147` trace:

| Address | Operation | Meaning |
| ---: | --- | --- |
| `0x4481` | `STD $2147` after loading `0x8C79` with `A = 0` | initial spark/correction seed |
| `0x48F1` | `STD $2147` with zero | clear accumulator before map/vector selection |
| `0x493B-0x493E` | `ADDD $2147`, `STD $2147` | add banked-map or WOT-vector result |
| `0x454E`, `0x4602`, `0x462C`, `0x489A`, `0x4978` | `ADDD $2147` | add correction terms |
| `0x45C4`, `0x45E2`, `0x4684`, `0x49B5` | writes to `$2147` | clamp/post-process accumulator |
| `0x4642-0x468F` | reads `$2147`, writes `$2001` and `$2148` | near-final byte command outputs |

Interpretation:

- `0x2147` is best treated as a spark-angle accumulator or intermediate command.
- `0x2001` and `0x2148` are likely final or near-final spark command bytes.
- A direct path from these bytes into the `0xBC12/0xBC90` output-compare
  scheduler is not yet proven.

## Shared Axis / Source Variable Tracing

The current high-value table axes now trace back to a few shared RAM values.

### `RAM 0x2034`

`0x2034` feeds the first descriptor axis for the `0x8A69/0x8B41` banked tables and at least one other 2D table.

Producer around `0x4188-0x41AD`:

```asm
41A1: DC CE         LDD $CE
41A3: 05            ASLD
41A4: 1A 83 07 FF   CPD #$07FF
41A8: 23 03         BLS $41AD
41AA: CC 07 FF      LDD #$07FF
41AD: FD 20 34      STD $2034
```

Meaning so far:

- `0x2034` is an 8.8-style axis/index value.
- It is derived from RAM word `0x00CE`.
- It is doubled and clamped to `0x07FF`.
- It is likely a load/throttle/pressure-style normalized axis.

`0x00CE` is now partly traced. In the routine at `0x5D8D-0x5E80`, one path
uses the `0x9187` lookup result as `0x00D0`, then stores `0x00CE = 0x00D0 << 2`:

```asm
5E6A: B6 92 5F      LDAA $925F
5E6D: 27 05         BEQ $5E74
5E6F: F6 91 7C      LDAB $917C       ; fallback/calibrated value
5E72: 20 03         BRA $5E77
5E74: BD 63 44      JSR $6344        ; 0x9187 table lookup
5E77: D7 D0         STAB $D0
5E79: 4F            CLRA
5E7A: 05            ASLD
5E7B: 05            ASLD
5E7C: DD CE         STD $CE
```

An alternate state-machine path at `0x5E5C-0x5E5E` stores `B -> 0x00D0` and
`X -> 0x00CE` after the `0x58F2` descriptor routine. This means the `0x9187`
table is tied to normalized load-axis generation, not just to a final output
correction.

Current naming:

| RAM | Producer evidence | Consumer evidence | Working name |
| ---: | --- | --- | --- |
| `0x00D0` | `0x5E77` from `0x9187` or fallback `0x917C`; `0x5E5C` from `0x58F2` path | consumers at `0x574A`, `0x57BD`, `0x5F07`, `0x5FAA`, `0x96DE`, `0x96F7`, `0x9953`, `0x99CC`, `0xBAB8`, `0xBE0E`, `0xD10F`, `0xD169`, `0xE5C1` | load_model_byte / air-charge byte |
| `0x00CE` | `0x5E7C` as `0x00D0 << 2`; `0x5E5E` from state path | `0x41A1-0x41AD` builds `0x2034`; additional consumers at `0x45F3`, `0x97E7`, `0x992C`, `0x99DC`, `0x9CB0`, `0xE411`, `0xE5EB`, `0xE975` | raw_load_or_aircharge_word |
| `0x2034` | clamped `0x00CE * 2` | first axis for `0x8A69/0x8B41`, `0x85BA`, `0x87B1`, `0x888E`, `0x8A0A` | load/MAP-like_axis_8p8 |

This separates the normal `0x9187` lookup path from the `0x58F2`
state/descriptor path. Both can influence the same load-model RAM, but they are
not the same table subsystem.

### `RAM 0x2036`

`0x2036` feeds the second descriptor axis for the `0x8A69/0x8B41`, `0x85BA`, and `0x9187` 2D tables.

Producer around `0xD46D-0xD47F`:

```asm
D46D: CE 92 9E      LDX #$929E
D470: F6 92 CE      LDAB $92CE
...
D47A: DC BA         LDD $BA
D47C: BD B3 B9      JSR $B3B9
D47F: FD 20 36      STD $2036
```

Meaning so far:

- `0x2036` is derived from `RAM 0x00BA`.
- The helper at `0xB3B9` walks/interpolates against the table/vector area around `0x929E`.
- `0x92CE = 0x18`, so the breakpoint table at `0x929E` has 24 entries.
- The `0x929E-0x92CD` words are timer periods. Using `15000000 / period` gives clean RPM breakpoints:

```text
550, 750, 850, 950, 1000, 1200, 1400, 1600,
1800, 2000, 2300, 2600, 2900, 3200, 3501, 3800,
4201, 4500, 5000, 5501, 6000, 6502, 7003, 7500
```

This confirms `0x2036` as the main RPM-normalized axis used by the code-confirmed 2D maps.

### `RAM 0x2044`

`0x2044` feeds a family of 1D interpolated vectors in the `0x89C7-0x8A67` area.

Producer around `0xD482-0xD498`:

```asm
D482: DC D4         LDD $D4
D484: 1A 83 1C 20   CPD #$1C20
D488: 25 05         BCS $D48F
D48A: CC 12 00      LDD #$1200
D48D: 20 09         BRA $D498
D48F: CE 00 19      LDX #$0019
D492: 02            IDIV
D493: 8F            XGDX
D494: 05            ASLD
D495: 05            ASLD
D496: 05            ASLD
D497: 05            ASLD
D498: FD 20 44      STD $2044
```

Meaning so far:

- `0x2044` is an 8.8-style 1D index.
- It is derived from `RAM 0x00D4`.
- It is clamped at `0x1200`, giving integer index `18`.
- This explains why many nearby vectors expose 19 useful cells; the helper may read the next byte when the fraction is zero, so immediately-following scalar/sentinel bytes should not be blindly folded into the curve.

### `RAM 0x00BA`

`0x00BA` is used by the `0x879E/0x87A0` threshold pair and by the `0x2036` axis conversion.

Observed update around `0x7660`:

```asm
7660: DC BA         LDD $BA
7662: FD 24 DB      STD $24DB
...
7667: DC D9         LDD $D9
7669: 93 B8         SUBD $B8
766B: DD BA         STD $BA
```

Observed timer capture/update hints:

```asm
7392: FC 10 14      LDD $1014
7395: DD D9         STD $D9
...
7701: DC D9         LDD $D9
7703: DD B8         STD $B8
```

Meaning so far:

- `0x00BA` is a delta between two captured timer values, `0x00D9 - 0x00B8`.
- It is very likely period-like rather than raw RPM.
- `0x2036` appears to be the map-axis conversion of this period-like value.

## Code-Confirmed 1D Vector @ `0x89F3`

The earlier raw `1x20 @ 0x89F2` view mixed control scalars and vector data.

Confirmed structure:

- `0x89ED-0x89F2`: scalar/control bytes.
- `0x89F3` starts a 1D byte vector interpolated by `0xB2AB`.
- `0x8A06`, `0x8A07`, and `0x8A08` are also direct scalar/limit bytes in nearby code.

Important excerpt:

```asm
BAA8: FC 20 44      LDD $2044
BAAB: 18 CE 89 F3   LDY #$89F3
BAAF: BD B2 AB      JSR $B2AB
BAB2: B7 20 BC      STAA $20BC
```

The routine uses `RAM 0x2044` as an 8.8 index into the byte vector at `0x89F3`.

Nearby control/scalar usage:

```asm
BADA: F6 89 ED      LDAB $89ED
BAF7: F6 89 ED      LDAB $89ED
BB14: F6 89 ED      LDAB $89ED
BB31: F6 89 ED      LDAB $89ED
BB44: F6 8A 06      LDAB $8A06
BB70: F6 89 F0      LDAB $89F0
BB80: F6 89 F2      LDAB $89F2
BB8D: B1 8A 08      CMPA $8A08
BB92: B6 8A 08      LDAA $8A08
```

Status:

- `0x89F3` is now code-confirmed as a 1D interpolation vector.
- `0x89ED-0x89F2` should be treated as control scalars, not part of the vector.
- Exact physical meaning is still unknown.

## Code-Confirmed `0x2044` Vector Family

The routine around `0xBA35-0xBAB2` uses `RAM 0x2044` as the common 1D index for several vectors.

Confirmed calls:

```asm
BA5D: FC 20 44      LDD $2044
BA60: 18 CE 8A 27   LDY #$8A27
BA64: BD B2 AB      JSR $B2AB
BA67: B7 20 DD      STAA $20DD

BA6A: FC 20 44      LDD $2044
BA6D: 18 CE 89 C7   LDY #$89C7
BA71: BD B2 BA      JSR $B2BA
BA74: B7 20 E7      STAA $20E7

BA77: FC 20 44      LDD $2044
BA7A: 18 CE 89 DA   LDY #$89DA
BA7E: BD B2 AB      JSR $B2AB
BA81: B7 20 E8      STAA $20E8

BA84: FC 20 44      LDD $2044
BA87: 18 CE 8A 3A   LDY #$8A3A
BA8B: BD B2 AB      JSR $B2AB
BA8E: B7 20 D4      STAA $20D4

BA91: FC 20 44      LDD $2044
BA94: 18 CE 8A 52   LDY #$8A52
BA98: BD B2 AB      JSR $B2AB
BA9B: B7 20 E6      STAA $20E6

BAA8: FC 20 44      LDD $2044
BAAB: 18 CE 89 F3   LDY #$89F3
BAAF: BD B2 AB      JSR $B2AB
BAB2: B7 20 BC      STAA $20BC
```

Clean XDF slices from this pass:

| Offset | Shape | Output RAM | MOD2 changed? | Notes |
| ---: | ---: | ---: | --- | --- |
| `0x89C7` | `1x19` | `0x20E7` | no | Uses helper `0xB2BA` |
| `0x89DA` | `1x19` | `0x20E8` | no | Ends before scalar block at `0x89ED` |
| `0x89F3` | `1x19` | `0x20BC` | yes | Main MOD2-touched vector in this family |
| `0x8A27` | `1x19` | `0x20DD` | no | Constant `0x06` curve |
| `0x8A3A` | `1x19` | `0x20D4` | no | Followed by scalar/sentinel bytes `0x8A4D-0x8A51` |
| `0x8A52` | `1x19` | `0x20E6` | no | Followed by scalar bytes `0x8A65-0x8A67` |

Direct reference scans show `0x8A4D`, `0x8A4F`, `0x8A51`, `0x8A65`, `0x8A66`, and `0x8A67` are used outside the interpolation vectors, so they are now exposed as scalar blocks in the XDF instead of being merged into the curves.

## Threshold/Hysteresis Pair @ `0x879E` / `0x87A0`

The changed words at `0x879E` and `0x87A0` are not a map. They are threshold constants used by a flag-control routine.

Important excerpt:

```asm
6F01: DC BA         LDD $BA
6F03: 13 A4 10 16   BRCLR $A4, #$10, $6F1D
...
6F12: 1A B3 87 A0   CPD $87A0
6F16: 23 2A         BLS $6F42
6F18: 15 A4 10      BCLR $A4, #$10
...
6F28: 1A B3 87 9E   CPD $879E
6F2C: 24 05         BCC $6F33
6F2E: 14 A4 10      BSET $A4, #$10
```

Meaning:

- `D = RAM[0x00BA]` is compared against thresholds.
- `0x879E` is used on the flag-set side.
- `0x87A0` is used on the flag-clear side.
- `0x87A2` and `0x87A4` are alternate set/clear thresholds used when `RAM 0x214F` is nonzero.
- This is a hysteresis-style threshold pair controlling `RAM[0x00A4] bit 0x10`.

MOD2 changes:

```text
0x879E: 0x07EB -> 0x00FA
0x87A0: 0x07EF -> 0xFFFF
```

Using the same `15000000 / period` scaling as the `0x929E` RPM axis:

```text
0x879E stock 0x07EB -> about 7400 RPM
0x87A0 stock 0x07EF -> about 7386 RPM
0x87A2 stock 0x1770 -> about 2500 RPM
0x87A4 stock 0x1979 -> about 2300 RPM
```

This is now a strong RPM limiter or RPM-related limiter candidate. MOD2 changes the primary pair to about `60000 RPM` and `229 RPM`, which looks like an attempt to disable or greatly move the limiter behavior.

## RPM-Only Bypass Vector @ `0x8C19`

The banked `0x8A69/0x8B41` lookup has a bypass path:

```asm
48F4: 13 A9 20 0C   BRCLR $A9, #$20, $4904
48F8: 18 CE 8C 19   LDY #$8C19
48FC: FC 20 36      LDD $2036
48FF: BD B2 AB      JSR $B2AB
```

When `RAM 0x00A9 bit 0x20` is set, the ECU skips the banked 2D table and uses a 1D vector indexed only by the RPM axis `0x2036`.

The first 24 bytes at `0x8C19`, displayed as `raw / 2`, are:

```text
8.0, 11.0, 12.5, 14.0, 15.0, 18.0, 20.0, 21.0,
22.5, 23.5, 25.5, 27.5, 29.0, 31.0, 31.0, 31.0,
31.0, 31.0, 31.0, 31.0, 31.0, 31.0, 31.0, 31.0
```

This is a strong candidate for the online XDF's "spark advance wide open throttle" or a related RPM-only spark fallback.

## `0x91xx-0x92xx` Region

The earlier `15x9 @ 0x91D9` view was visually useful but misaligned. The current disassembly confirms a larger parent table:

- `0x9187-0x925E` is a code-confirmed `24x9` 2D byte table.
- The old `0x91D9` slice starts one byte after row 9 begins and has been
  removed from the normal XDF tree.
- MOD2 changes `62` bytes inside the confirmed `0x9187` table.
- `0x925F`, `0x9260`, and `0x9261` remain direct scalar/flag/threshold bytes after the table.

Code-confirming routine around `0x6344-0x636A`:

```asm
6344: B6 20 17      LDAA $2017
6347: 18 CE 21 8D   LDY #$218D
634B: F6 92 9A      LDAB $929A
634E: 18 E7 06      STAB $06,Y       ; stride = 9
6351: CE 92 91      LDX #$9291
6354: BD B3 83      JSR $B383        ; derive descriptor axis from 0x9291 vector
6357: 18 ED 00      STD $00,Y
635A: FC 20 36      LDD $2036
635D: 18 ED 02      STD $02,Y
6360: CC 91 87      LDD #$9187
6363: 18 ED 04      STD $04,Y
6366: BD B2 D6      JSR $B2D6
6369: 16            TAB
636A: 39            RTS
```

Axis / support bytes:

```text
0x9291-0x9299: 00 03 0B 16 25 36 59 84 C9
0x929A:        09
```

`0x929A` is loaded as the row stride/column count. The `0x9291` vector is used by helper `0xB383` to generate the first interpolation axis. `RAM 0x2036` supplies the second axis, matching the banked `0x8A69/0x8B41` maps.

Direct calls to this routine were found at `0x58EA` and `0x5E74`; those callers are now the best next places to trace the returned interpolated value into strategy state.

The online XDF screenshot is useful as a scaling clue for this table. If the raw
bytes are viewed as `raw / 230`, the result is a factor-like surface of roughly
`0.00-1.10`, similar in range to the screenshot's correction-factor maps. The
XDF now includes this as `Correction Factor Candidate 24x9 @ 0x9187`. This is
still a physical-meaning hypothesis: the code proves the table and consumers,
but not yet whether it is air density correction, VE correction, fuel correction,
or another compensation path.

MOD2 change pattern in the confirmed table:

```text
0x91EC-0x91EC: 1 byte
0x91FE-0x9201: 4 bytes
0x9207-0x920A: 4 bytes
0x9210-0x9213: 4 bytes
0x9219-0x921C: 4 bytes
0x9222-0x9225: 4 bytes
0x922B-0x9231: 7 bytes
0x9234-0x923A: 7 bytes
0x923D-0x9243: 7 bytes
0x9246-0x924C: 7 bytes
0x924F-0x9255: 7 bytes
0x9259-0x925E: 6 bytes
```

The isolated `0x91EC: 0xCD -> 0x6F` change is no longer an out-of-context anomaly; it is row 11, column 2 of the confirmed `24x9` table.

The nearby `0x9131-0x9167` data still feeds the state/descriptor routine at `0x58F2`. That routine appears to manage small state machines or ramps using RAM state pointed to by `X` and 3-byte descriptors pointed to by `Y`; it is separate from the `0x9187` 2D map.

Confirmed `0x58F2` descriptor calls:

| Call site | State block | Descriptor | Event ID |
| ---: | ---: | ---: | ---: |
| `0x5A6C` | `0x0012` | `0x9131` | `0x00` |
| `0x5C67` | `0x0015` | `0x9134` | `0x01` |
| `0x5D4C` | `0x0018` | `0x9137` | `0x02` |
| `0x5E45` | `0x001B` | `0x913A` | `0x03` |
| `0x5EDB` | `0x001E` | `0x913D` | `0x04` |
| `0x5F64` | `0x0024` | `0x9143` | `0x05` |
| `0x5FCC` | `0x0027` | `0x9146` | `0x06` |
| `0x604E` | `0x002A` | `0x9149` | `0x07` |
| `0x609F` | `0x002D` | `0x914C` | `0x08` |
| `0x60F5` | `0x0030` | `0x914F` | `0x09` |
| `0x6124` | `0x0033` | `0x9152` | `0x0A` |
| `0x6205` | `0x0036` | `0x9155` | `0x0B` |
| `0x62FB` | `0x0039` | `0x9158` | `0x0C` |
| `0x6331` | `0x003C` | `0x915B` | `0x0D` |
| `0x6022` | `0x003F` | `0x915E` | `0x0E` |
| `0x5B68` | `0x0042` | `0x9161` | `0x0F` |
| `0x617A` | `0x0045` | `0x9164` | `0x10` |
| `0x614E` | `0x0048` | `0x9167` | `0x11` |

The descriptor entries are 3 bytes wide. A raw `19x3` XDF view from
`0x9131-0x9169` keeps the observed entries aligned and includes the apparent
reserved slot at `0x9140`.

Raw descriptor bytes:

```text
0x9131: 01 01 01
0x9134: 01 19 0A
0x9137: 01 19 0A
0x913A: 01 19 0A
0x913D: 01 19 01
0x9140: 01 01 01
0x9143: 20 61 40
0x9146: 01 01 01
0x9149: 01 01 FE
0x914C: 01 05 02
0x914F: 01 05 02
0x9152: 04 05 02
0x9155: 01 01 01
0x9158: 01 01 01
0x915B: 01 01 01
0x915E: 01 01 01
0x9161: 01 01 01
0x9164: 01 01 01
0x9167: 01 01 01
```

## Repeatable Multi-BIN Analysis Script

`tools/iaw8p40_analyze.py` is a read-only support script for this reverse
engineering pass. It loads the four available 64 KiB binaries:

- `M27C512_original.BIN`.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin`.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin`.
- `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin`.

The script reports hashes, checksum words, reset vectors, diff regions,
candidate-table statistics, same-offset Peugeot/Xantia comparisons, immediate
table-base byte-pattern hints, helper-call sites, and RAM/register references.
It does not modify BIN files.

Confirmed by the script:

| BIN | SHA256 | Checksum pair | Sum | Reset |
| --- | --- | --- | --- | --- |
| Peugeot stock | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xFFFF` | `0xB800` |
| Peugeot `Stok` | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xFFFF` | `0xB800` |
| Peugeot MOD2 | `D3E4A451EDD236104C79190372FA1BE1E45AAD09398EABE6F7B7E1479D810855` | `0x47BE/0xB841` | `0xFFFF` | `0xB800` |
| Xantia 607C | `05470171F86B8525F962F13370846E6D4A1A6FBABC0107D90E1497F88A5DFE89` | `0x9F83/0x607C` | `0xFFFF` | `0xB800` |

Diff summary:

- Peugeot stock vs folder `Stok`: `0` differing bytes.
- Peugeot stock vs MOD2: `479` differing bytes in `87` contiguous regions.
- Peugeot stock vs Xantia 607C: `42021` differing bytes in `1038`
  contiguous regions.

Scanner limitation:

- The immediate-reference scan is a byte-pattern scanner. Hits must be decoded
  in alignment before they are treated as code evidence.
- The apparent Peugeot `0x802E` hit remains the known false positive around
  `0xC620`, not a confirmed table-base load.
- Peugeot helper references and Xantia helper references are deliberately kept
  separate. Peugeot uses the already traced `0xB2D6`, `0xB2AB`, `0xB383`, and
  `0xB3B9` helper family; the script's focused Xantia helper candidates are
  `0xB2CB` with `7` calls and `0xB349` with `4` calls. Those Xantia helpers
  need separate local tracing before any Xantia table role is used as evidence
  for the Peugeot ROM.

## `0x802E-0x81D4` Region

The `0x802E-0x81D4` region is MOD2-touched and table-like, but direct code
usage has not been confirmed yet. The preferred working view is now the
`21x9 @ 0x802E` surface, which looks like a fuel/VE/air-charge correction
candidate rather than spark.

Important correction:

- A naive byte-reference scan appeared to find `0x802E` around `0xC620`.
- Correct 68HC11 decoding shows this is not a table reference:

```asm
C61A: 1A 83 FF 80   CPD #$FF80
C61E: 2E 03         BGT $C623
C620: CC FF 80      LDD #$FF80
C623: FD 24 56      STD $2456
```

Status:

- The old combined `47x9 @ 0x802E` view was removed from the XDF because the
  screenshot and byte pattern suggest a split after row 23.
- Primary candidate `21x9 @ 0x802E`: `57 / 189` changed cells, mostly `+4`,
  `+5`, and `+6` raw-count increases. It uses RPM-like rows `550-6000` and
  load/MAP-like columns `0-1024`.
- Peugeot stock raw values are `135-248`, roughly `52.9-97.3%` under the
  unconfirmed `raw / 2.55` visualization hypothesis. Xantia 607C at the same
  offset is `144-214`, roughly `56.5-83.9%`.
- Alternate boundary view `24x9 @ 0x802E`: `75 / 216` changed cells. Rows
  `21-23` may be adjacent calibration or tail data until code proves otherwise.
- Adjacent probe `21x9 @ 0x80EB`: the script reports `60 / 189` MOD2-touched
  cells and full Peugeot/Xantia same-offset disagreement. The modulo-byte wraps
  and lack of direct code reference keep it below the primary `0x802E` surface.
- Tail probe `5x9 @ 0x81A8`: the script reports `30 / 45` MOD2-touched cells;
  this remains a tail/alignment probe rather than a normal tune map.
- Lower adjacent candidate `23x9 @ 0x8106`: `72 / 207` changed cells, mostly
  parent rows `35-46` and columns `0-5`, with modulo-byte `+5` changes and one
  `+18` group. This remains raw-indexed.
- Do not call `0x802E` code-confirmed main fuel yet. The next proof must be a
  consumer path into injection pulse width, fuel time, lambda correction,
  air-charge calculation, or scheduling.
- It may be accessed indirectly after startup copy / calibration overlay, or by descriptor data not yet decoded.

## Diagnostic / Service Routines

The ROM contains confirmed diagnostic/service communication code. This does not yet prove there is a full interactive developer debugger, but it does show factory/service style protocol handling.

Confirmed hardware blocks:

- SCI serial registers:
  - `0x102B`: BAUD
  - `0x102C`: SCCR1
  - `0x102D`: SCCR2
  - `0x102E`: SCSR
  - `0x102F`: SCDR
- SPI registers:
  - `0x1028`: SPCR
  - `0x1029`: SPSR
  - `0x102A`: SPDR

Startup initializes SCI/service state through `0xA6E5` and `0xA696`:

```asm
A6B2: B6 80 0B      LDAA $800B
A6B7: 86 00         LDAA #$00
A6B9: B7 21 A6      STAA $21A6
A6BC: B6 80 09      LDAA $8009
A6BF: B7 10 2B      STAA $102B       ; BAUD
...
A72D: B7 10 2C      STAA $102C       ; SCCR1 = 0
A732: B7 10 2D      STAA $102D       ; SCCR2 = 0x24
A740: B7 10 2B      STAA $102B       ; BAUD = 0x33 in this path
```

The main serial state machine is in `0xA7D8-0xAFxx`. It reads/writes SCDR using the expected SCI sequence:

```asm
A9C6: F6 10 2E      LDAB $102E       ; read SCI status
A9C9: B7 10 2F      STAA $102F       ; transmit byte
...
A9F5: B6 10 2F      LDAA $102F       ; receive byte
```

`0xAA3F-0xAA78` is a compact command/response decoder:

```text
RX DD -> response 33
RX F0 -> response AA
RX 36 -> response 15
RX 35 -> response 14
RX 34 -> response 16
RX CC -> response 66
RX 99 -> response 55
```

The `0x55` response path is especially important because it changes the ECU into mode `0x06` and jumps to `0xD80B`:

```asm
AAE0: 86 06         LDAA #$06
AAE2: B7 21 A6      STAA $21A6
AAE5: BE 91 6A      LDS $916A
AAE8: 7E D8 0B      JMP $D80B
```

`0xD80B` is a special service loop. It sets up a separate context, services the watchdog, and keeps running only while `0x21A6 == 0x06`; otherwise it jumps to the fail-stop path `0xB94D`.

```asm
D80B: 0F            SEI
D80C: 8D 1B         BSR $D829
D80E: 0E            CLI
D80F: B6 21 A6      LDAA $21A6
D812: 81 06         CMPA #$06
D816: 7E B9 4D      JMP $B94D        ; if not mode 6
D819: 86 55         LDAA #$55
D81B: B7 10 3A      STAA $103A
D81E: 43            COMA
D81F: B7 10 3A      STAA $103A
D822: 8D 72         BSR $D896
D824: BD D9 41      JSR $D941
D827: 20 E6         BRA $D80F
```

The runtime also has a fault/status queue:

- `0x5982` maps an event ID through table `0x55A0`.
- `0x59A8` inserts/updates entries in queue RAM `0x004B-0x005B`.
- `0x59CA` removes/compacts entries.
- `0x59F4` updates queue summary flags in `RAM 0x00A4`.
- `0x005B` is the moving end pointer.

Queue entries appear to use the upper bits as class/severity bits and lower bits as an event number. `0x55A0` should therefore be treated as a diagnostic/event-code table candidate, not as normal calibration.

Observed descriptor callers use event IDs `0x00-0x11`, so the XDF now exposes
`0x55A0-0x55B1` as an 18-byte raw diagnostic/event-code view. This is for
inspection only; changing it would likely change service-visible fault/status
codes rather than normal engine tuning behavior.

Stock event-code bytes:

```text
0x55A0: 6C 0C 0B 1B 11 21 17 62 65 6F 12 6A 19 13 24 2B 0D 1C
```

The dispatcher around `0x67A3` / `0x6836` includes a service-visible RAM list:

```text
0x680F-0x682F:
004B 004C 004D 004E 004F 0050 0051 0052
0053 0054 0055 0056 0057 0058 0094 009A 0099
```

This strongly suggests the diagnostic protocol can expose fault queue bytes and status/reset/checksum flags.

## Output Compare / Timed Actuator Scheduling

The `0xBC12/0xBC90` block is confirmed as 68HC11 timer output-compare logic.

Important register/RAM usage:

| Address | Role |
| ---: | --- |
| `0x101C` | TOC4-like output compare register |
| `0x1023` | TFLG1-like timer flag register |
| `0x20EB` | scheduled offset word |
| `0x20ED` | next scheduled offset word |
| `0x242B` | previous/base compare time |
| `0x242D` | captured/current compare time |

Key scheduling patterns:

```asm
BC64: FC 24 2B      LDD $242B
BC67: F3 20 EB      ADDD $20EB
BC6A: FD 10 1C      STD $101C
...
BCAB: FC 10 1C      LDD $101C
BCAE: FD 24 2D      STD $242D
BCB1: F3 20 ED      ADDD $20ED
BCB4: FD 10 1C      STD $101C
```

Flag acknowledge:

```asm
BC80: C6 10         LDAB #$10
BC82: F7 10 23      STAB $1023
```

Interpretation:

- This is a timed output scheduler, not a calibration table.
- It likely controls an engine actuator pulse or compare event, but ignition vs
  injection vs another output is still open.
- The repeatable scanner finds `0x20EB` stores at `0xBB9A` and `0xBD39`, then
  loads/math at `0xBC67` and `0xBC7A`.
- It finds `0x20ED` stores at `0xBB9D` and `0xBD4F`, then loads/math at
  `0xBCB1` and `0xBCC1`.
- `0x242B` is stored at `0xBD1B` and consumed at `0xBC64/0xBC76`.
- `0x242D` is captured from TOC4 at `0xBCAE` and consumed at `0xBCBD`.
- The next useful trace is upstream from `0xBB9A/0xBB9D` and `0xBD39/0xBD4F`,
  plus forward from the spark command bytes `0x2001/0x2148`.

## Practical XDF Changes From This Pass

`IAW8P40_peugeot106_firstpass.xdf` version `0.14` now includes the previous confirmed entries plus provisional load/MAP-like x-axis labels for the likely spark maps, raw diagnostic/service views for code-confirmed descriptor data, confidence-tier labels for likely fuel/correction candidates, public-index alignment probes, and a deduplicated table tree where each major structure has one best inspection entry.

Previously added in `0.4`:

- `Code-Confirmed Signed Offset Byte @ 0x8A68`
- code-confirmed spark-bank raw views at `0x8A69` and `0x8B41`, later
  condensed into the retained scaled likely spark entries
- `Code-Referenced Control Scalars 1x6 @ 0x89ED`
- `Likely Speed/Transient Correction Vector 1x19 @ 0x89F3`

New in `0.5`:

- code-confirmed raw `24x9 @ 0x9187`, later condensed into the retained
  `Load Model / Correction Factor Candidate 24x9 @ 0x9187`
- `Code-Confirmed 1D Vector 1x19 @ 0x89C7`
- `Code-Confirmed 1D Vector 1x19 @ 0x89DA`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A27`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A3A`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A52`
- `Code-Referenced Scalar Block 1x5 @ 0x8A4D`
- `Code-Referenced Scalar Block 1x3 @ 0x8A65`
- `Code-Confirmed 2D Table 24x5 @ 0x85BA`
- `Code-Confirmed 2D Table 5x5 @ 0x8A0A`

The old `MOD2 Compared Candidate 15x9 Table @ 0x91D9` was later removed from
the normal XDF tree because the confirmed parent table begins at `0x9187`.

New in `0.6`:

- `Code-Confirmed RPM Axis 1x24 @ 0x929E`, displayed as `15000000 / raw period`.
- `Likely Spark Advance High Octane / Default 24x9 @ 0x8A69`, displayed as `raw / 2` degrees.
- `Likely Spark Advance Low Octane / Alternate 24x9 @ 0x8B41`, displayed as `raw / 2` degrees.
- `Likely WOT Spark Advance Vector 1x24 @ 0x8C19`, displayed as `raw / 2` degrees.
- `Likely RPM Limiter Set/Clear Thresholds @ 0x879E/0x87A0`, displayed as `15000000 / raw period`.
- `Alternate RPM Thresholds @ 0x87A2/0x87A4`, displayed as `15000000 / raw period`.
- `Code-Referenced Axis Vector 1x9 @ 0x9291`.
- `Code-Referenced Axis Vector 1x9 @ 0x92CF`.
- `Load Model / Correction Factor Candidate 24x9 @ 0x9187`, displayed as `raw / 230`.

New in `0.7`:

- `Code-Confirmed 2D Table 24x9 @ 0x869A`.
- `Code-Confirmed 2D Table 24x9 @ 0x87B1`.
- `Code-Confirmed 2D Table 24x9 @ 0x888E`.
- `Code-Confirmed 2D Table 11x9 @ 0x9073`.
- `Code-Confirmed 2D Table 17x5 @ 0x8E6F`.
- `Code-Confirmed 2D Table 17x5 @ 0x8EC7`.
- `Code-Confirmed 2D Table 17x5 @ 0x8F1C`.
- `Code-Confirmed 2D Table 17x5 @ 0x8F71`.

Alignment notes for `0.7`:

- The old visual `0x86DB` candidate is inside the code-confirmed `0x869A`
  parent table.
- The old visual `0x88CD` candidate is inside the code-confirmed `0x888E`
  parent table.
- The `0x8E6F/0x8EC7/0x8F1C/0x8F71` cluster is exposed as bounded `17x5`
  views because the table starts and ends line up cleanly at those boundaries.

New in `0.8`:

- likely spark advance high/default `24x9 @ 0x8A69` x-axis labels changed from
  placeholder `0-8` to provisional load/MAP-like `0, 128, 256, 384, 512, 640,
  768, 896, 1024`.
- likely spark advance low/alternate `24x9 @ 0x8B41` received the same x-axis labels.
- This is based on the code-confirmed `0x2034` 8.8 axis range clamped near
  `0x0800`. The exact physical mbar scaling is still not proven.

New in `0.9`:

- Added external sensor-reference documentation in
  `IAW8P40_peugeot106_sensor_references.md`.
- Updated the likely spark-bank descriptions to tie the `0x2034` x-axis labels
  to Peugeot 106 TU2J2/MFZ 100 kPa MAP-sensor evidence.
- The best current interpretation for spark-map x-axis labels is provisional
  MAP/load in mbar-like units, `0-1024`, pending ADC transfer confirmation.

New in `0.10`:

- Renamed the scaled spark views as:
  - `Likely Spark Advance High Octane / Default 24x9 @ 0x8A69`.
  - `Likely Spark Advance Low Octane / Alternate 24x9 @ 0x8B41`.
- Kept the `raw / 2` degree scaling and provisional `0-1024` MAP/load-style
  x-axis labels.
- Added the MOD2-backed `0x9187` correction-factor candidate view.

New in `0.11`:

- Added category `Diagnostics / Service Data`.
- Added raw diagnostic/event view `0x55A0-0x55B1` for the `0x5982` event-code
  table used by IDs `0x00-0x11`.
- Added raw state descriptor view `0x9131-0x9169` as `19x3` triples for the
  `0x58F2` descriptor subsystem.
- No `.bin` files were edited.

New in `0.12`:

- Removed the combined `47x9 @ 0x802E` view.
- Promoted `0x802E-0x8105` as the upper `24x9` tune candidate with provisional
  load/RPM-style labels.
- Kept `0x8106-0x81D4` as the lower adjacent `23x9` tune candidate with raw
  parent-row labels.
- Removed duplicate raw spark-bank views at `0x8A69` and `0x8B41`; the retained
  scaled spark entries now carry the code-confirmed lookup evidence.
- Removed the duplicate raw `0x9187` view; the retained `raw / 230` correction
  candidate now carries the code-confirmed lookup evidence.
- Removed the old duplicate `0x86DB` visual views because that region is inside
  the code-confirmed `0x869A` parent table.
- Removed the misleading early `8x19 @ 0x88CA` triangular view and demoted the
  old `17x9 @ 0x88CD` view to historical context inside the code-confirmed
  `24x9 @ 0x888E` parent table.

New in `0.13`:

- Renamed the then-primary MOD2/correction candidates with confidence-tier
  working labels:
  - `Likely Fuel/VE Correction Upper Candidate 24x9 @ 0x802E`, later demoted
    in `0.14` to a boundary/debug view
  - `Likely Fuel/Enrichment Lower Adjacent Candidate 23x9 @ 0x8106`
  - `Likely Speed/Transient Correction Vector 1x19 @ 0x89F3`
  - `Load Model / Correction Factor Candidate 24x9 @ 0x9187`
- Removed the misleading legacy `0x89F2` and `0x91D9` views from the normal XDF
  tree. Screenshots alone are no longer enough to keep an active view when later
  code proves that it mixes structures or starts on a misaligned row.
- Added category `Public Index Leads`.
- Added raw BTDig/Digital-Kaos-derived alignment probe views:
  - `21x9 @ 0x802E`
  - `21x9 @ 0x80EB`
  - `5x9 tail @ 0x81A8`
- These probes test the public claim of two 9-load-site, about-21-speed-site
  fuel/correction maps. In `0.14`, the first `21x9 @ 0x802E` probe was promoted
  to the primary fuel/VE/air-charge candidate; the second `21x9` and tail views
  remain lower-confidence adjacent probes.
- Updated the `0x879E/0x87A0` limiter descriptions to mention the public
  `21000000 / value` formula as a lead only; the retained scaling remains the
  locally supported `15000000 / period`.

New in `0.14`:

- Promoted `21x9 @ 0x802E` to
  `Likely Fuel/VE/Air-Charge Correction Candidate 21x9 @ 0x802E`.
- Demoted the overlapping `24x9 @ 0x802E` to
  `Alternate 24-Row Boundary View for 0x802E Fuel/VE Candidate`.
- Kept `raw` display for `0x802E`; `raw / 2.55` is documented only as a
  percent/VE visualization hypothesis.
- Kept `21x9 @ 0x80EB` and `5x9 @ 0x81A8` as lower-confidence adjacent
  fuel/correction probes.
- Main fuel remains unconfirmed until a code consumer path reaches injection or
  fuel-specific calculations.

External evidence integration:

- Added `IAW8P40_peugeot106_external_evidence.md` as a public-source and
  deep-research-report cross-check.
- The checked sources support the Peugeot 106 1.3 Rallye / IAW 8P.40
  application, `27C512` media, generic 8P-family sensors/pins, the public
  OldSkullTuning map-family checklist, and the 100 kPa MAP clue.
- No XDF names or offsets were promoted from external sources alone. The local
  disassembly remains the authority for code-confirmed structures.

Air-density screenshot lead:

- A public TunerPro screenshot labelled `Air density correction factor by
  temperature` was tested as a `24x9` table lead.
- The visible axes are RPM-like rows and temperature columns
  `-5, 10, 20, 30, 40, 50, 60, 70, 80`.
- The matrix was not found verbatim in stock, Stok, or MOD2 dumps using likely
  equations `raw / 230`, `raw / 100`, `raw / 128`, or `raw / 200`, including
  reversed and transposed orientations.
- `0x9187` remains the closest functional correction/load-model candidate, but
  the screenshot data does not match its bytes.
- Loose numerical matches around `0x8A9C` are inside the code-confirmed spark
  bank and should be ignored for air-density naming.
- Next proof path: follow IAT/CTS ADC channels and fallback thresholds into
  table lookups before adding an air-density XDF entry.

## Free ROM Space / Custom Logic

Measured zero-filled regions:

| Region | Size | Notes |
| ---: | ---: | --- |
| `0x0000-0x3FFF` | `16384` bytes | Lower half is zero-filled, but should not be assumed usable without ECU memory-map confirmation. |
| `0xF021-0xFFD5` | `4021` bytes | Best current code-cave candidate; starts after an `RTS` at `0xF020` and stops before vectors at `0xFFD6-0xFFFF`. |
| `0xB600-0xB7FF` | `512` bytes | Zero-filled and skipped by the checksum routine. Possible patch area, but special because checksum deliberately ignores it. |

The apparent zero blocks at `0x87B1`, `0x9073`, and parts of `0x8Fxx` are not
free space; they are code-confirmed calibration table regions.

The stock 27C512 image cannot be extended past `0xFFFF`. Custom logic would
need to be inserted into a code cave and reached by patching an existing call or
jump. Any patch outside `0xB600-0xB7FF` needs checksum repair. Assembly is the
most realistic route; compiled C would need a 68HC11 target, absolute placement,
and no hidden runtime assumptions.

## Next Disassembly Targets

Highest value next:

1. Trace output scheduling:
   - producers of `0x20EB/0x20ED`.
   - consumers of `0x2001/0x2148`.
   - whether the spark-angle command reaches `0xBC12/0xBC90` or a different
     timer channel.
2. Decode diagnostic/service protocol details:
   - SCI state tables at `0xA778`, `0xA792`, `0xA7A6`, `0xA7C0`, and `0xA7D8`.
   - event IDs `0x00-0x11` mapped through `0x55A0`.
   - service-visible RAM list around `0x680F-0x682F`.
   - special service loop `0xD80B`.
3. Finish ADC channel naming:
   - follow thresholds and fallback behavior for `0x2007-0x200E`.
   - map channels to MAP, TPS, IAT, CTS, lambda, battery/other.
   - specifically trace IAT/CTS consumers for any RPM-by-temperature correction
     table matching the public air-density map family.
4. Continue fuel proof:
   - find a real consumer for `0x802E-0x81D4`.
   - trace injection pulse-width/output code separately from spark.
5. Keep tracing table outputs:
   - `0x20BC`, `0x20BD-0x20C5`, `0x242F`, `0x2431`.
   - `0x2063`, `0x2391`, `0x00BE`, `0x2484`, `0x243C`, `0x24AB`,
     `0x24AC`, `0x24AD`, and `0x24AF`.
