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

The `15x9 @ 0x91D9` view is still visually table-like and MOD2-touched, but the current disassembly does not yet prove it is a simple `15x9` map.

Observed code behavior:

- Many routines load `Y` with small descriptors in `0x9131-0x9167`.
- These descriptors feed the routine at `0x58F2`.
- `0x925F`, `0x9260`, and `0x9261` are direct scalar/flag/threshold bytes in nearby code.

Example caller:

```asm
5E3E: CE 00 1B      LDX #$001B
5E41: 18 CE 91 3A   LDY #$913A
5E45: BD 58 F2      JSR $58F2
...
5E6A: B6 92 5F      LDAA $925F
5E6D: 27 05         BEQ $5E74
5E6F: F6 91 7C      LDAB $917C
...
5E82: B6 92 60      LDAA $9260
5E87: B6 92 61      LDAA $9261
5E9A: B1 92 60      CMPA $9260
5E9F: B1 92 61      CMPA $9261
```

Descriptor pointers found:

```text
0x9131, 0x9134, 0x9137, 0x913A, 0x913D,
0x9143, 0x9146, 0x9149, 0x914C, 0x914F,
0x9152, 0x9155, 0x9158, 0x915B, 0x915E,
0x9161, 0x9164, 0x9167
```

Status:

- `0x91D9-0x925F` remains a strong MOD2-touched data region.
- It is not yet code-confirmed as a plain `15x9` map.
- The `0x91EC: 0xCD -> 0x6F` MOD2 change is still notable, but should not be judged until the descriptor format is decoded.

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

`IAW8P40_peugeot106_firstpass.xdf` version `0.4` adds:

- `Code-Confirmed Signed Offset Byte @ 0x8A68`
- `Code-Confirmed Bank A 24x9 @ 0x8A69`
- `Code-Confirmed Bank B 24x9 @ 0x8B41`
- `Code-Referenced Control Scalars 1x6 @ 0x89ED`
- `Code-Confirmed 1D Vector 1x19 @ 0x89F3`

It also renames older views as legacy/raw where disassembly corrected the interpretation.

## Next Disassembly Targets

Highest value next:

1. Decode RAM variables:
   - `0x2034`, `0x2036` for the `0x8A69/0x8B41` banks.
   - `0x2044` for the `0x89F3` vector.
   - `0x00BA` for the `0x879E/0x87A0` threshold pair.
2. Decode the descriptor/state routine at `0x58F2` and its helper set around `0x5982`.
3. Trace writes to output variables:
   - `0x2147` for the banked 2D table result.
   - `0x20BC`, `0x20BD-0x20C5`, `0x242F`, `0x2431` for the `0x89xx` routines.
4. Continue from runtime scheduler calls after reset, especially:
   - `0x67A3`
   - `0xBB98`
   - `0xB555`
   - `0x5652`
