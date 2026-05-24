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
- Exact physical meaning is not confirmed yet.
- Because it is MOD2-touched and bilinear-interpolated, it is a high-priority map candidate.

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
- It is likely a load/throttle/pressure-style normalized axis, but the physical input is not named yet.

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
- This strongly suggests `0x2036` is a normalized axis generated from a timer period or engine-speed-related period.

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
- This is a hysteresis-style threshold pair controlling `RAM[0x00A4] bit 0x10`.

MOD2 changes:

```text
0x879E: 0x07EB -> 0x00FA
0x87A0: 0x07EF -> 0xFFFF
```

This is a significant behavior change, possibly lowering one threshold and effectively disabling or delaying the opposite transition. Exact physical meaning depends on naming `RAM[0x00BA]` and flag `0x00A4 bit 0x10`.

## `0x91xx-0x92xx` Region

The earlier `15x9 @ 0x91D9` view was visually useful but misaligned. The current disassembly confirms a larger parent table:

- `0x9187-0x925E` is a code-confirmed `24x9` 2D byte table.
- The old `0x91D9` slice starts one byte after row 9 begins.
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

## `0x802E-0x81D4` Region

The `47x9 @ 0x802E` region is MOD2-touched and table-like, but direct code usage has not been confirmed yet.

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

- Keep `0x802E-0x81D4` as MOD2-backed data.
- Do not call it code-confirmed yet.
- It may be accessed indirectly after startup copy / calibration overlay, or by descriptor data not yet decoded.

## Practical XDF Changes From This Pass

`IAW8P40_peugeot106_firstpass.xdf` version `0.5` now includes the previous `0.4` confirmed entries plus the new continuation-pass findings.

Previously added in `0.4`:

- `Code-Confirmed Signed Offset Byte @ 0x8A68`
- `Code-Confirmed Bank A 24x9 @ 0x8A69`
- `Code-Confirmed Bank B 24x9 @ 0x8B41`
- `Code-Referenced Control Scalars 1x6 @ 0x89ED`
- `Code-Confirmed 1D Vector 1x19 @ 0x89F3`

New in `0.5`:

- `Code-Confirmed 2D Table 24x9 @ 0x9187`
- `Code-Confirmed 1D Vector 1x19 @ 0x89C7`
- `Code-Confirmed 1D Vector 1x19 @ 0x89DA`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A27`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A3A`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A52`
- `Code-Referenced Scalar Block 1x5 @ 0x8A4D`
- `Code-Referenced Scalar Block 1x3 @ 0x8A65`
- `Code-Confirmed 2D Table 24x5 @ 0x85BA`
- `Code-Confirmed 2D Table 5x5 @ 0x8A0A`

It also renames the old `MOD2 Compared Candidate 15x9 Table @ 0x91D9` as a legacy misaligned slice because the confirmed parent table begins at `0x9187`.

## Next Disassembly Targets

Highest value next:

1. Decode RAM variables:
   - `0x00CE` as the source of `0x2034`.
   - `0x00D4` as the source of `0x2044`.
   - `0x00BA`, `0x00D9`, and `0x00B8` as the period source for `0x2036`.
2. Decode the descriptor/state routine at `0x58F2` and its helper set around `0x5982`.
3. Trace writes to output variables:
   - `0x2147` for the banked 2D table result.
   - `0x20BC`, `0x20BD-0x20C5`, `0x242F`, `0x2431` for the `0x89xx` routines.
   - `0x2063` for the `0x85BA` table result.
   - the caller/use sites of the `0x9187` table result returned through `A/B`.
4. Continue from runtime scheduler calls after reset, especially:
   - `0x67A3`
   - `0xBB98`
   - `0xB555`
   - `0x5652`
