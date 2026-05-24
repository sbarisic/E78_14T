# Marelli IAW 8P.40 Firmware Logic Notes

Analysis date: 2026-05-24

This file is a living description of the ECU firmware behavior while the Peugeot 106 1.3 Rallye Marelli `IAW 8P.40` ROM is being reverse engineered.

Confidence labels used below:

- Confirmed: directly supported by decoded instruction flow.
- Strong inference: supported by code shape and 68HC11 register usage, but physical meaning is not fully named.
- Open: visible in code, but not understood enough to name.

## Firmware / CPU Model

Confirmed:

- The EPROM is a full `27C512` image, `0x10000` bytes.
- `0x0000-0x3FFF` is zero-filled.
- Real firmware and calibration content starts at `0x4000`.
- The target CPU family is Motorola/Freescale `68HC11`.
- The reset vector at `0xFFFE` points to `0xB800`.
- The firmware uses the 68HC11 internal register block at `0x1000`.

Important 68HC11 register addresses used by the ROM:

| Address | 68HC11 role | Observed firmware use |
| ---: | --- | --- |
| `0x1000` | Port A | Output/input bit manipulation |
| `0x1008` | Port D | Port/config use |
| `0x1009` | DDRD | Direction setup |
| `0x100B` | CFORC | Timer/output compare force use |
| `0x100E` | TCNT | Main free-running timer / timebase |
| `0x1014` | TIC3 | Captured timer value used in period calculation |
| `0x101C` | TOC4 | Output compare scheduling |
| `0x1023` | TFLG1 | Timer flag acknowledgement |
| `0x1024` | TMSK2 | Timer interrupt mask / status logic |
| `0x1025` | TFLG2 | Timer overflow flag acknowledgement |
| `0x1028` | SPCR | SPI control setup / transfer setup |
| `0x1029` | SPSR | SPI status polling |
| `0x102A` | SPDR | SPI data transfer |
| `0x102B` | BAUD | SCI baud setup for service/diagnostic comms |
| `0x102C` | SCCR1 | SCI control setup |
| `0x102D` | SCCR2 | SCI transmit/receive enable and interrupt setup |
| `0x102E` | SCSR | SCI status read before serial data access |
| `0x102F` | SCDR | SCI receive/transmit data register |
| `0x1030` | ADCTL | ADC conversion control |
| `0x1031-0x1034` | ADR1-ADR4 | ADC result bytes copied into RAM |
| `0x103A` | COPRST | Watchdog service writes `0x55` / `0xAA` |
| `0x103D` | INIT | Register/RAM mapping setup at reset |

The register names are from the standard 68HC11 register layout. Exact MCU mask/variant still requires PCB markings.

## Boot / Reset Flow

Confirmed reset entry:

```text
0xFFFE -> 0xB800
```

The reset path at `0xB800` performs these broad steps:

1. Clears or initializes core status bytes such as `0x0094`, `0x008E`, `0x008F`, `0x0095-0x009B`.
2. Loads the stack pointer from the word at `0x916A`.
   - Bytes at `0x916A-0x916B` are `0x27 0xFF`.
   - This makes the expected stack top `0x27FF`.
3. Configures 68HC11 registers in the `0x1000` range.
4. Services the watchdog with the standard `0x55`, `0xAA` sequence at `0x103A`.
5. Copies the calibration/data window `0x8000-0x9314`.
6. Calls a series of initialization routines.
7. Enables runtime operation and jumps to the main runtime entry at `0xD2D9`.

Calibration/window copy:

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

This is probably a calibration RAM overlay or mirrored logical memory window. The source and destination addresses are the same logical range, so board-level memory mapping matters here.

High-confidence reset call groups:

| Address | Current interpretation |
| ---: | --- |
| `0x4017`, `0x4034`, `0x4079`, `0x409C`, `0x40A8` | ADC/input preload and core RAM initialization |
| `0xD6AC` | Main runtime variable initializer |
| `0x956B` | Period/timer history initializer, including `0x00BA = 0xFFFF` |
| `0x4421` | Initializes the `0x21xx` calculation/output block |
| `0x5652` | Initializes/updates a mode or control block using timer/ADC state |
| `0x67A3` | Initializes a state-machine/communication-looking block |
| `0xBB98` | Initializes the `0x89xx/0x8Axx` vector output variables |
| `0xB555` | Initializes a countdown/timer pair at `0x2469/0x246A` and flag `0x009C` |
| `0xA6E5` | Initializes SCI/service buffers and packet state |
| `0xA696` | Initializes SCI diagnostic mode from calibration/config bytes at `0x8009/0x800B` |

## Interrupt / Fault Vector Behavior

Confirmed vector table:

| Vector address | Target |
| ---: | ---: |
| `0xFFF0` | `0x95F3` |
| `0xFFF2` | `0x6405` |
| `0xFFF4` | `0xB94D` |
| `0xFFF6` | `0xB94D` |
| `0xFFF8` | `0xB948` |
| `0xFFFA` | `0xB93D` |
| `0xFFFC` | `0xB942` |
| `0xFFFE` | `0xB800` |

The short handlers at `0xB93D`, `0xB942`, `0xB948`, and `0xB94D` set bits in RAM byte `0x0094`.

Observed behavior:

- `0xB93D` sets `0x0094 bit 0x01`, then jumps back into reset flow near `0xB806`.
- `0xB942` sets `0x0094 bit 0x02`, then jumps back into reset flow near `0xB806`.
- `0xB948` sets `0x0094 bit 0x04`, then falls into the fatal path.
- `0xB94D` sets `0x0094 bit 0x08`, zeros several I/O registers, and loops forever.

Inference:

- `0x0094` records reset/interrupt/fault cause bits.
- Some vectors cause a soft restart.
- Some vectors force a fail-safe stop loop.

## Main Runtime Loop

Confirmed:

- Reset eventually jumps to `0xD2D9`.
- `0xD2D9` performs scheduler/timebase checks, stack-integrity checks, watchdog service, and then enters the main ordered runtime body.
- The loop eventually jumps back to `0xD2D9` through `0xD6A7`.

### Runtime Entry / Guard @ `0xD2D9`

Important behavior:

- Reads the free-running timer at `0x100E`.
- Updates timebase RAM values around `0x24E5`, `0x24E7`, and `0x24EA`.
- Stores the stack pointer and compares it with the expected reset stack top at `0x916A`.
- Services the watchdog through `0x103A`.
- Depending on flags, either continues into runtime or jumps back into reset/init sections.

Stack check pattern:

```asm
D2ED: BF 24 EA      STS $24EA
D2F0: FE 24 EA      LDX $24EA
D2F3: BC 91 6A      CPX $916A
D2F6: 26 18         BNE $D310
```

Inference:

- `0x916A` stores the expected stack top.
- The main loop checks for stack imbalance/corruption.
- A mismatch changes fault/status bits and can alter the runtime path.

### Main Body Call Order @ `0xD36D-0xD6A7`

The main loop has a long fixed call order. Some calls are still unnamed, but the execution shape is now visible.

High-level order:

```text
D36D: enable/enter periodic section
D370: call B476
D373: call B48C
D376: call C910
D379: call 5828
D37C: call B562
D37F: call 650D

D384-D3D6: decrement small RAM countdown/state blocks

D3D9: call 42D0
D3DC: call 4C5B
D3DF: call 4ECD
D3E2: call 9D25
D3E5: call 4214

D3E8-D40C: decrement descriptor/state timers in 0x0012-0x004A

D40F: call 5AD6       ; checksum service/check
D412: call 602F
D415: call 6107
D418: call 6133
D41B: call 615B
D41E: call 6187
D421: call 62DC

D426-D459: branch on mode/state byte 0x21A6
           calls 6836, 68F3, 6BBE, 6A12, or 6D43

D45D: call C000

D46D-D498: build normalized axes 0x2036, 0x2044, 0x2046

D4A9-D517: additional period/sensor/correction calculations

D590-D6A6: final runtime calls, map helpers, output/state updates

D6A7: JMP D2D9
```

Important caution:

- Some byte patterns look like `JSR`/`JMP` if scanned naively, but are really operands inside other instructions.
- The list above is based on alignment from the visible runtime flow, but individual callee meaning still needs confirmation.

## ADC / Raw Input Preprocessing

Confirmed:

- ADC conversion control is written at `0x1030`.
- ADC result bytes at `0x1031-0x1034` are copied into RAM.

Examples:

```asm
4017: CE 10 00      LDX #$1000
401D: B6 10 31      LDAA $1031
4020: B7 20 08      STAA $2008
4023: B6 10 33      LDAA $1033
4026: B7 20 0D      STAA $200D
4029: BD 41 55      JSR $4155
402C: B6 10 34      LDAA $1034
402F: B7 20 0A      STAA $200A
```

```asm
4034: CE 10 00      LDX #$1000
403A: B6 10 32      LDAA $1032
403D: B7 20 0C      STAA $200C
4040: B6 10 33      LDAA $1033
4043: B7 20 07      STAA $2007
4046: B7 21 97      STAA $2197
4049: BD 5E 82      JSR $5E82
404C: B7 20 13      STAA $2013
4059: B6 10 34      LDAA $1034
405C: B7 20 0E      STAA $200E
```

Strong inference:

- RAM `0x2007-0x200E` contains raw or lightly processed ADC channel values.
- The physical meanings are not named yet.
- `0x2034` is later derived from the processed RAM word `0x00CE`.

## Timebase / Engine Period Logic

### Timer Delta `0x00BA`

Confirmed:

- `0x00BA` is a timer delta.
- It is computed as current captured timer value minus previous captured timer value.

Capture/update evidence:

```asm
7392: FC 10 14      LDD $1014
7395: DD D9         STD $D9
```

```asm
7701: DC D9         LDD $D9
7703: DD B8         STD $B8
```

```asm
7667: DC D9         LDD $D9
7669: 93 B8         SUBD $B8
766B: DD BA         STD $BA
```

Strong inference:

- `0x1014` is a timer input-capture register.
- `0x00BA` is an engine-period-like value.
- Because it is a period delta, smaller values probably mean higher speed.

### Normalized Axis `0x2036`

Confirmed:

`0x2036` is generated from `0x00BA` using helper `0xB3B9` and calibration data around `0x929E`.

```asm
D46D: CE 92 9E      LDX #$929E
D470: F6 92 CE      LDAB $92CE
...
D47A: DC BA         LDD $BA
D47C: BD B3 B9      JSR $B3B9
D47F: FD 20 36      STD $2036
```

Interpretation:

- `0x2036` is an 8.8-style normalized axis.
- It feeds multiple 2D maps.
- It is likely the speed/RPM axis, but the exact physical scaling is not confirmed.

### Inverse/Speed-Like Value `0x00D4`

Confirmed:

- `0x00D4` is derived from the period value `0x00BA`.
- The routine around `0x4292-0x42C8` divides the constant `0xE4E2` by `0x00BA`.

```asm
4292: FC 21 2D      LDD $212D
4295: FD 21 2F      STD $212F
4298: DC D4         LDD $D4
429A: FD 21 2D      STD $212D
...
42A8: CC E4 E2      LDD #$E4E2
42AB: DE BA         LDX $BA
42AD: 02            IDIV
...
42B6: DD D4         STD $D4
```

Strong inference:

- `0x00D4` is speed-like or RPM-like because it is inverse period.
- The firmware stores previous values in `0x212D/0x212F`.

### Normalized Axis `0x2044`

Confirmed:

`0x2044` is derived from `0x00D4` and clamped to `0x1200`.

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

Interpretation:

- `0x2044` is an 8.8-style index into 19-cell 1D vectors.
- Max value is `0x1200`, integer index `18`.
- This explains why 19-cell curves are common in the `0x89C7-0x8A67` vector family.

### Normalized Axis `0x2034`

Confirmed:

`0x2034` is built from RAM word `0x00CE`, doubled, and clamped to `0x07FF`.

```asm
41A1: DC CE         LDD $CE
41A3: 05            ASLD
41A4: 1A 83 07 FF   CPD #$07FF
41A8: 23 03         BLS $41AD
41AA: CC 07 FF      LDD #$07FF
41AD: FD 20 34      STD $2034
```

Strong inference:

- `0x2034` is a load-like 8.8 axis.
- It may represent throttle, pressure, or air/load after filtering.
- `0x00CE` is now partly traced: the routine at `0x5D8D-0x5E80` can update
  `0x00D0` from the `0x9187` lookup and then write `0x00CE = 0x00D0 << 2`.

Relevant producer path:

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
5E7C: DD CE         STD $CE          ; D0 * 4
```

There is also an alternate state-machine path at `0x5E5C-0x5E5E` that stores
`B -> 0x00D0` and `X -> 0x00CE` after the `0x58F2` descriptor/state routine.
So `0x2034` should be treated as a normalized air-charge/load axis whose source
can be either the `0x9187` model path or a state-machine/substitute path.

## Interpolation / Calibration Helpers

### 1D Helper `0xB2AB`

Confirmed:

- `Y` points to a byte vector.
- `D` is an 8.8 index.
- `A` is integer index.
- `B` is fraction.
- Result returns in `A`.

Formula:

```text
result = table[index] + ((table[index + 1] - table[index]) * fraction) / 256
```

The routine handles negative slopes.

### 1D Helper Variant `0xB2BA`

Confirmed:

- Used similarly to `0xB2AB`.
- Confirmed callers include `0x89C7`, `0x9303`, and `0x83F0` vectors.

Open:

- Exact behavioral difference from `0xB2AB` still needs final decode.

### 2D Helper `0xB2D6`

Confirmed descriptor layout at `Y`:

| Offset | Meaning |
| ---: | --- |
| `Y+0` | X/column integer index |
| `Y+1` | X/column fraction |
| `Y+2` | Y/row integer index |
| `Y+3` | Y/row fraction |
| `Y+4..Y+5` | Table base pointer |
| `Y+6` | Row stride / column count |

Confirmed:

- Used by code-confirmed 2D tables at `0x8A69`, `0x8B41`, `0x9187`, `0x85BA`, `0x8A0A`, and several others still being reviewed.
- Returns an interpolated byte result in `A`.

### Axis Lookup Helper `0xB383`

Confirmed:

- Called with `X` pointing at a breakpoint vector and `B` as count/stride metadata.
- Produces an 8.8 index in `D`.
- Used for the `0x9187` table axis via `0x9291`.

Known caller for `0x9187`:

```asm
6351: CE 92 91      LDX #$9291
6354: BD B3 83      JSR $B383
6357: 18 ED 00      STD $00,Y
```

### Period Axis Helper `0xB3B9`

Confirmed:

- Only direct caller found so far is at `0xD47C`.
- Converts period-like `0x00BA` into normalized axis `0x2036`.
- Uses the 24-entry 16-bit breakpoint table at `0x929E`.
- The count byte is `0x92CE = 0x18`, i.e. 24 entries.

Breakpoint interpretation:

The words at `0x929E-0x92CD` are timer periods. Using `15000000 / period` produces clean engine-speed breakpoints:

| Index | Period | Approx RPM |
| ---: | ---: | ---: |
| 0 | `27273` | `550` |
| 1 | `20000` | `750` |
| 2 | `17647` | `850` |
| 3 | `15789` | `950` |
| 4 | `15000` | `1000` |
| 5 | `12500` | `1200` |
| 6 | `10714` | `1400` |
| 7 | `9375` | `1600` |
| 8 | `8333` | `1800` |
| 9 | `7500` | `2000` |
| 10 | `6521` | `2300` |
| 11 | `5769` | `2600` |
| 12 | `5172` | `2900` |
| 13 | `4687` | `3200` |
| 14 | `4285` | `3501` |
| 15 | `3947` | `3800` |
| 16 | `3571` | `4201` |
| 17 | `3333` | `4500` |
| 18 | `3000` | `5000` |
| 19 | `2727` | `5501` |
| 20 | `2500` | `6000` |
| 21 | `2307` | `6502` |
| 22 | `2142` | `7003` |
| 23 | `2000` | `7500` |

Strong inference:

- `0x2036` is the main RPM-normalized table axis.
- The online XDF screenshot uses a similar RPM axis concept, but this ROM's code-confirmed table has 24 RPM breakpoints rather than the 19-row screenshot table.

## Code-Confirmed Calibration Logic

### Banked 2D Table Pair `0x8A69` / `0x8B41`

Confirmed routine:

```asm
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

Confirmed behavior:

- If `RAM 0x20B1 != 0`, use `24x9 @ 0x8A69`.
- If `RAM 0x20B1 == 0`, use `24x9 @ 0x8B41`.
- Axis 1: `0x2034`.
- Axis 2: `0x2036`.
- Output: RAM word around `0x2147`.
- Optional signed offset byte: `0x8A68`.

Bank selector source:

```asm
CBEF: B6 80 0A      LDAA $800A
CBF2: 26 08         BNE $CBFC
...
CBFB: 4A            DECA
CBFC: B7 20 B1      STAA $20B1
CBFF: 39            RTS
```

- Calibration byte `0x800A` seeds runtime bank selector `0x20B1`.
- The stock value is `0x00`, so the `DECA` step underflows it to `0xFF`.
- Therefore stock runtime behavior should select the nonzero bank at `0x8A69`.
- If `0x800A` were `0x01`, the stored selector would become `0x00` and the
  routine would select the `0x8B41` bank.

Special bypass:

```asm
48F4: 13 A9 20 0C   BRCLR $A9, #$20, $4904
48F8: 18 CE 8C 19   LDY #$8C19
48FC: FC 20 36      LDD $2036
48FF: BD B2 AB      JSR $B2AB
```

If `RAM 0x00A9 bit 0x20` is set, the code bypasses the banked 2D maps and uses a 1D vector at `0x8C19` indexed by `0x2036`.

Physical meaning:

- Screenshot-assisted inference: likely spark advance bank pair.
- The raw values display in a plausible spark-advance range when scaled as `raw / 2` degrees.
- This matches the online XDF screenshot convention for spark tables using `0.5 deg/bit`.
- MOD2 touched these heavily, so they are high-priority tune-relevant maps.
- Stock selector behavior points at `0x8A69` as the normal/default active bank.
  The exact physical bank names, such as high octane vs low octane, are not
  proven yet.

Downstream trace:

- Direct references to `0x2147` cluster in `0x44xx-0x49xx`.
- The routine family around `0x4421-0x477B` initializes and post-processes a calculation block using `0x2147`, `0x2148`, `0x2149`, `0x214C`, and nearby `0x215x` values.
- `0x460A-0x463E` applies an additional correction to `0x2147` when `0x20B1` is zero/nonzero dependent.
- `0x4642-0x468F` clamps or converts the `0x2147` word and writes related byte outputs including `0x2001` and `0x2148`.

Interpretation:

- `0x2147` is an intermediate command/correction value, not yet proven to be a final actuator register value.
- It appears to be combined with other corrections and clamped before becoming smaller byte-sized runtime outputs.
- Tracing from `0x2001`, `0x2148`, and the `0x44xx-0x49xx` block is the next step for naming the banked maps.

### 2D Table `0x9187`

Confirmed routine:

```asm
6344: B6 20 17      LDAA $2017
6347: 18 CE 21 8D   LDY #$218D
634B: F6 92 9A      LDAB $929A
634E: 18 E7 06      STAB $06,Y
6351: CE 92 91      LDX #$9291
6354: BD B3 83      JSR $B383
6357: 18 ED 00      STD $00,Y
635A: FC 20 36      LDD $2036
635D: 18 ED 02      STD $02,Y
6360: CC 91 87      LDD #$9187
6363: 18 ED 04      STD $04,Y
6366: BD B2 D6      JSR $B2D6
6369: 16            TAB
636A: 39            RTS
```

Confirmed behavior:

- Table base: `0x9187`.
- Shape: `24x9`.
- Stride: `0x929A = 9`.
- Axis 1: generated by `0xB383` using vector `0x9291-0x9299`.
- Axis 2: `0x2036`.
- Direct callers found at `0x58EA` and `0x5E74`.

Caller behavior:

```asm
58EA: BD 63 44      JSR $6344
58ED: F7 21 0F      STAB $210F
```

```asm
5E74: BD 63 44      JSR $6344
5E77: D7 D0         STAB $D0
```

So the same `0x9187` lookup can feed at least:

- RAM `0x210F`.
- Direct RAM `0x00D0`.

Physical meaning:

- Open. MOD2 changes 62 bytes inside this table.
- The online XDF screenshot helps here: a `raw / 230` view turns this table into
  factor-like values, roughly `0.00-1.10`, which resembles the displayed air/fuel
  correction factor style more than an ignition-degree table.
- This is now exposed in the XDF as `Correction Factor Candidate 24x9 @ 0x9187`.
  The code confirms the lookup, axes, and consumers, but not yet whether the
  factor is air density, VE, fuel, or another compensation path.
- The old `15x9 @ 0x91D9` view is misaligned and should be treated as legacy only.

### 2D Table `0x85BA`

Confirmed routine:

```asm
6EAA: FC 20 34      LDD $2034
...
6EBA: FC 20 36      LDD $2036
...
6EC0: CE 85 BA      LDX #$85BA
6EC3: CD EF 04      STX $04,Y
6EC6: 86 05         LDAA #$05
6EC8: 18 A7 06      STAA $06,Y
6ECA: BD B2 D6      JSR $B2D6
6ECD: B7 20 63      STAA $2063
```

Confirmed behavior:

- Table base: `0x85BA`.
- Shape currently exposed as `24x5`.
- Axis 1: `0x2034`.
- Axis 2: `0x2036`.
- Output: `0x2063`.
- MOD2 did not change this table.

### 2D Table `0x8A0A`

Confirmed routine:

```asm
BA35: FC 20 34      LDD $2034
...
BA47: FC 20 46      LDD $2046
...
BA4E: CC 8A 0A      LDD #$8A0A
BA51: 18 ED 04      STD $04,Y
BA54: C6 05         LDAB #$05
BA56: 18 E7 06      STAB $06,Y
BA57: BD B2 D6      JSR $B2D6
BA5A: B7 20 BB      STAA $20BB
```

Confirmed behavior:

- Table base: `0x8A0A`.
- Shape currently exposed as `5x5`.
- Axis 1: `0x2034`.
- Axis 2: `0x2046`.
- Output: `0x20BB`.
- MOD2 did not change this table.

### Additional `B2D6` Table Inventory

The full scan currently finds 12 calls to the bilinear helper `0xB2D6`. The
known MOD2-backed/spark-candidate calls are not the only real maps in the ROM.
The newest XDF pass adds raw views for these additional code-confirmed tables:

| Base | Shape exposed | Call site | Axes / source | Output / role clue |
| ---: | ---: | ---: | --- | --- |
| `0x869A` | `24x9` | `0x9B79-0x9BB4` | axis 1 derived from `0x2014`, axis 2 `0x2036` | stores `0x2391` |
| `0x87B1` | `24x9` | `0x7254-0x729B` | `0x2034` by `0x2036` | updates `0x00BE`; stock table is all zero |
| `0x888E` | `24x9` | `0xBE74-0xBE93` | `0x2034` by `0x2036` | stores `0x2484`, later combined with `0x8970` vector |
| `0x9073` | `11x9` | `0xC282-0xC2BE` | `0x9291`-derived axis by transformed `0x2044` | compared with `0x243C` for ramp/state update |
| `0x8E6F` | `17x5` | `0xD105-0xD134` | `0x00D0`-derived axis by `0x2044` | stores `0x24AB` |
| `0x8F1C` | `17x5` | `0xD137-0xD140` | same descriptor as `0x8E6F` | stores `0x24AC` |
| `0x8F71` | `17x5` | `0xD143-0xD151` | same descriptor as `0x8E6F` | shifted down four bits into `0x24AD` |
| `0x8EC7` | `17x5` | `0xD154-0xD15D` | same descriptor as `0x8E6F` | stores `0x24AF` |

Important alignment corrections:

- The visually interesting old `0x86DB` candidate sits inside the larger
  code-confirmed `0x869A` parent table, not as a standalone proven table.
- The visually interesting old `0x88CD` candidate sits inside the larger
  code-confirmed `0x888E` parent table.
- The `0x8E6F/0x8EC7/0x8F1C/0x8F71` cluster is exposed as bounded `17x5`
  views because those boundaries line up cleanly with adjacent table starts.
  The code's `0x2044` source axis still needs live-range confirmation.

### `0x2044`-Indexed Vector Family

Confirmed:

The routine around `0xBA5D-0xBAB2` uses `0x2044` to interpolate several vectors.

| Vector | Helper | Output RAM | MOD2 changed? |
| ---: | ---: | ---: | --- |
| `0x89C7` | `0xB2BA` | `0x20E7` | no |
| `0x89DA` | `0xB2AB` | `0x20E8` | no |
| `0x89F3` | `0xB2AB` | `0x20BC` | yes |
| `0x8A27` | `0xB2AB` | `0x20DD` | no |
| `0x8A3A` | `0xB2AB` | `0x20D4` | no |
| `0x8A52` | `0xB2AB` | `0x20E6` | no |

Nearby scalar blocks:

- `0x89ED-0x89F2`: direct control scalars.
- `0x8A4D-0x8A51`: direct scalar/sentinel bytes.
- `0x8A65-0x8A67`: direct scalar bytes.

Physical meaning:

- Open. Because `0x2044` is speed-like, these are speed-indexed correction curves or limits.
- `0x89F3` is MOD2-touched and highest priority in this family.

### Threshold / Hysteresis Pair `0x879E` / `0x87A0`

Confirmed:

- These are not maps.
- They are 16-bit threshold constants.
- They compare against `RAM 0x00BA`.
- They control `RAM 0x00A4 bit 0x10`.
- When `RAM 0x214F == 0`, the active pair is `0x879E` / `0x87A0`.
- When `RAM 0x214F != 0`, the alternate pair is `0x87A2` / `0x87A4`.

Key logic:

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

MOD2 changes:

| Address | Stock | MOD2 |
| ---: | ---: | ---: |
| `0x879E` | `0x07EB` | `0x00FA` |
| `0x87A0` | `0x07EF` | `0xFFFF` |

Interpretation:

- Strongly likely RPM limiter or RPM-related limiter hysteresis.
- Using the same `15000000 / period` scaling as the `0x929E` axis, stock `0x879E` is about `7400 RPM` and stock `0x87A0` is about `7386 RPM`.
- The alternate `0x87A2` / `0x87A4` pair is about `2500 RPM` / `2300 RPM` and is selected when `0x214F` is nonzero.
- MOD2 changes the primary pair to about `60000 RPM` and `229 RPM`, which looks like an attempt to disable or greatly move the limiter behavior.

### RPM-Only Bypass Vector `0x8C19`

Confirmed:

- If `RAM 0x00A9 bit 0x20` is set, the `0x48EE` routine bypasses the `0x8A69/0x8B41` 2D banked maps.
- The bypass uses a 1D vector at `0x8C19`.
- The vector is indexed by `0x2036`, now confirmed as the RPM-normalized axis.
- The vector is unchanged by MOD2.

Values:

```text
Raw: 10 16 19 1C 1E 24 28 2A 2D 2F 33 37 3A 3E 3E 3E 3E 3E 3E 3E 3E 3E 3E 3E
Deg: 8.0 11.0 12.5 14.0 15.0 18.0 20.0 21.0 22.5 23.5 25.5 27.5 29.0 31.0 ...
```

Strong inference:

- This is likely a wide-open-throttle spark advance vector or a spark fallback vector.
- The online XDF screenshot lists a "spark advance wide open throttle" table, and this code path is the best current match.

## State / Descriptor Logic Around `0x58F2`

Confirmed:

- Many routines call `0x58F2` with:
  - `X` pointing to a small RAM state block.
  - `Y` pointing to a compact descriptor around `0x9131-0x9167`.
- Callers then call `0x5982` with a small numeric ID in `B`.

Example:

```asm
5E3E: CE 00 1B      LDX #$001B
5E41: 18 CE 91 3A   LDY #$913A
5E45: BD 58 F2      JSR $58F2
...
5E4E: C6 03         LDAB #$03
5E50: BD 59 82      JSR $5982
```

Observed descriptor pointers:

```text
0x9131, 0x9134, 0x9137, 0x913A, 0x913D,
0x9143, 0x9146, 0x9149, 0x914C, 0x914F,
0x9152, 0x9155, 0x9158, 0x915B, 0x915E,
0x9161, 0x9164, 0x9167
```

Behavioral interpretation:

- `0x58F2` appears to update a compact state byte and countdown/step byte.
- It tests mode bits in `X[0]`.
- It uses descriptor bytes at `Y+0`, `Y+1`, and `Y+2`.
- It writes back to the RAM state block.
- `0x5982` appears to log, queue, or update event/state output using an ID.

Open:

- Whether this is diagnostic status, limiter state, enrichment state, idle state, or general control-mode bookkeeping.
- The routines using `0x9131-0x9167` need naming before these descriptors should be edited as calibrations.

## Diagnostic / Service Communication Logic

Short answer:

- Yes, the ROM has real diagnostic/service logic.
- It does not yet look like a modern source-level debugger.
- It does look like a factory service/diagnostic protocol with serial framing, state machines, RAM status exposure, and a fault/event queue.

### Fault / Event Queue `0x004B-0x005B`

Confirmed:

- `0x5982` is called by the descriptor/state routines with a small event ID in `B`.
- `0x5982` indexes table `0x55A0`, then either inserts or removes an event byte.
- `0x59A8` inserts/updates an entry in queue RAM `0x004B-0x005B`.
- `0x59CA` removes/compacts an entry from the same queue.
- `0x59F4` scans the queue and updates status bits in `RAM 0x00A4`.
- `0x005B` is the moving end pointer for the queue.

Important queue code shape:

```asm
5982: CE 55 A0      LDX #$55A0
5985: 3A            ABX              ; B selects event descriptor byte
...
5999: BD 59 A8      JSR $59A8        ; insert/update event
599E: A6 00         LDAA $00,X
59A0: BD 59 CA      JSR $59CA        ; remove event
59A3: BD 59 F4      JSR $59F4        ; update queue summary flags
```

```asm
59A8: CE 00 4B      LDX #$004B
...
59C3: DF 5B         STX $5B
59C6: A7 00         STAA $00,X
```

`0x59F4` behavior:

- Clears `0x00A4 bits 0x80` and `0x40`.
- Sets both bits if any queued entry is `>= 0xC0`.
- Sets `0x40` for some entries in the `0x80-0xBF` range depending on the `0x55A0` table.

Strong inference:

- `0x004B-0x005B` is an active fault/status/event queue.
- Entries carry severity/class bits in the upper two bits and an event number in the lower bits.
- The table at `0x55A0` maps internal event IDs to service-visible codes/classes.

Do not edit `0x55A0` as ordinary calibration yet. It is more likely a diagnostic/event code table.

### Diagnostic State Machine `0x650D` / `0x67A3`

Confirmed:

- Main loop calls `0x650D` every cycle.
- Reset/startup calls `0x67A3`.
- State byte `0x21A6` controls major diagnostic/service modes.
- `0x21A9` is the start of a small state/packet descriptor used by the dispatch routines.
- `0x21AF`, `0x21B0`, `0x21B1`, `0x21B2`, `0x21B4`, `0x21B6`, `0x21B9`, `0x21BA`, and `0x21BC` are nearby service state variables.

`0x650D` runtime service:

```asm
650D: B6 21 A6      LDAA $21A6
6510: 81 FF         CMPA #$FF
6514: 81 07         CMPA #$07
6518: 18 CE 21 A9   LDY #$21A9
...
6531: 7C 21 A7      INC $21A7
653D: 13 B0 80 09   BRCLR $B0,#$80,$654A
6541: B6 21 A8      LDAA $21A8
6546: 4A            DECA
6547: B7 21 A8      STAA $21A8
```

This routine mostly maintains timers, flags, and mode counters. Other entry points in the same block initialize or clear the diagnostic/event queue, set `0x21A6 = 0xFE`, and prepare `0x21A9`.

`0x67A3` startup service:

```asm
67A3: 14 B0 80      BSET $B0,#$80
67A6: 86 17         LDAA #$17
67A8: B7 21 A8      STAA $21A8
67AB: CE 10 00      LDX #$1000
67AE: 1C 40 04      BSET $40,X,#$04
67B1: 39            RTS
```

The bytes after `0x67B1` are not straight-line code. They include a compact dispatch/data region. The service dispatcher later uses pointer tables around `0x6830` and `0x68E9`.

Particularly important table-like region:

```text
0x680F-0x682F: 004B 004C 004D 004E 004F 0050 0051 0052
              0053 0054 0055 0056 0057 0058 0094 009A 0099
0x6830-0x6835: 6849 686C 687E
```

Strong inference:

- The diagnostic dispatcher can expose or encode RAM status bytes including queue entries `0x004B-0x0058` and reset/checksum/status flags `0x0094`, `0x009A`, `0x0099`.
- This is diagnostic/status reporting, not normal fuel/ignition calibration.

### SCI Serial Service Protocol

Confirmed:

- The ROM uses the 68HC11 SCI registers at `0x102B-0x102F`.
- `0xA6E5` initializes serial buffers and packet pointers:
  - receive/transmit buffers around `0x2200` and `0x2280`.
  - pointers/counters around `0x23EE-0x240A`.
- `0xA696` initializes the diagnostic mode and writes the SCI baud register.
- `0xA7D8-0xAFxx` is a serial receive/transmit state-machine block.
- `0xD80B` is a special service loop entered after a command handshake.

SCI initialization:

```asm
A6B2: B6 80 0B      LDAA $800B
A6B5: 26 13         BNE $A6CA
A6B7: 86 00         LDAA #$00
A6B9: B7 21 A6      STAA $21A6
A6BC: B6 80 09      LDAA $8009
A6BF: B7 10 2B      STAA $102B       ; BAUD
...
A72D: B7 10 2C      STAA $102C       ; SCCR1 = 0
A730: 86 24
A732: B7 10 2D      STAA $102D       ; SCCR2
...
A73E: 86 33
A740: B7 10 2B      STAA $102B       ; BAUD = 0x33 in this path
```

Serial data access follows the expected SCI pattern:

```asm
A9C6: F6 10 2E      LDAB $102E       ; read SCSR/status
A9C9: B7 10 2F      STAA $102F       ; write SCDR/data
...
A9F5: B6 10 2F      LDAA $102F       ; read received byte
```

Protocol/framing bytes seen in the SCI parser:

| Byte | Observed use |
| ---: | --- |
| `0x05` | Command/control byte checked before jumping to `0xAB5C` |
| `0x0D` | Command/control byte checked before jumping to `0xAB5C` |
| `0x0F` | Framing/state byte in receive path |
| `0x10` | Serial framing/ack byte; also transmitted |
| `0x16` | Serial framing/ack byte; also transmitted |
| `0x41` | Serial framing/ack byte; also transmitted |
| `0x81` | Alternate command byte in the `0xAB5C` path |
| `0xF0` | Command/framing byte with response handling |

Challenge/response-looking decoder at `0xAA3F-0xAA78`:

```asm
AA3F: 81 DD         CMPA #$DD
AA43: 86 33         LDAA #$33
AA47: 81 F0         CMPA #$F0
AA4B: 86 AA         LDAA #$AA
AA4F: 81 36         CMPA #$36
AA53: 86 15         LDAA #$15
AA57: 81 35         CMPA #$35
AA5B: 86 14         LDAA #$14
AA5F: 81 34         CMPA #$34
AA63: 86 16         LDAA #$16
AA67: 81 CC         CMPA #$CC
AA6B: 86 66         LDAA #$66
AA6F: 81 99         CMPA #$99
AA76: 86 55         LDAA #$55
```

This maps received bytes to response bytes:

| RX byte | Response byte |
| ---: | ---: |
| `0xDD` | `0x33` |
| `0xF0` | `0xAA` |
| `0x36` | `0x15` |
| `0x35` | `0x14` |
| `0x34` | `0x16` |
| `0xCC` | `0x66` |
| `0x99` | `0x55` |

Strong inference:

- This is a diagnostic/service serial protocol handshake.
- It may include a session unlock or mode-switch handshake.
- Exact external protocol name is not confirmed yet.

### Special Service Loop `0xD80B`

Confirmed:

`0xAAE0` handles response byte `0x55` by setting `0x21A6 = 0x06`, loading the stack from `0x916A`, and jumping to `0xD80B`.

```asm
AAE0: 86 06         LDAA #$06
AAE2: B7 21 A6      STAA $21A6
AAE5: BE 91 6A      LDS $916A
AAE8: 7E D8 0B      JMP $D80B
```

`0xD80B` disables interrupts, initializes a separate hardware/service context, then loops while servicing the watchdog:

```asm
D80B: 0F            SEI
D80C: 8D 1B         BSR $D829
D80E: 0E            CLI
D80F: B6 21 A6      LDAA $21A6
D812: 81 06         CMPA #$06
D816: 7E B9 4D      JMP $B94D        ; fail-stop if mode changed
D819: 86 55         LDAA #$55
D81B: B7 10 3A      STAA $103A
D81E: 43            COMA
D81F: B7 10 3A      STAA $103A
D822: 8D 72         BSR $D896
D824: BD D9 41      JSR $D941
D827: 20 E6         BRA $D80F
```

`0xD829` sets up hardware and SCI differently:

```asm
D887: B7 10 2B      STAA $102B       ; BAUD = 0x30
D88C: B7 10 2D      STAA $102D       ; SCCR2 = 0xAC
D88F: 7F 10 2C      CLR $102C        ; SCCR1 = 0
D892: FC 10 2E      LDD $102E        ; read SCI status/data window
```

Strong inference:

- `0xD80B` is a special diagnostic/service mode.
- It is entered through the serial handshake path, not through normal runtime.
- It may be a test, programming, or factory diagnostic monitor, but that exact role is still open.

### SPI Communication Block

Confirmed:

- The ROM also uses the 68HC11 SPI registers at `0x1028-0x102A`.
- Routines around `0x9EAF-0xA012` poll `0x1029`, read/write `0x102A`, and configure `0x1028`.

Example:

```asm
9EEC: B6 10 29      LDAA $1029       ; SPSR
9EEF: B6 10 2A      LDAA $102A       ; SPDR
9EF4: B7 10 28      STAA $1028       ; SPCR
...
A016: B6 10 29      LDAA $1029
A019: 86 5C         LDAA #$5C
A01B: B7 10 28      STAA $1028
A01E: B7 10 28      STAA $1028
```

Open:

- The SPI block may be external peripheral communication rather than the user-facing diagnostic interface.
- It should be kept separate from the SCI diagnostic protocol until the external circuit is known.

### Diagnostics Reverse-Engineering Targets

Highest value next steps for this area:

1. Decode the SCI state tables at `0xA778`, `0xA792`, `0xA7A6`, `0xA7C0`, and `0xA7D8`.
2. Trace all reads and writes of `0x102F` to reconstruct packet framing.
3. Decode the meaning of `0x21A6` modes: confirmed values include `0x00`, `0x01`, `0x02`, `0x05`, `0x06`, `0x07`, `0x08`, `0x09`, `0x0A`, `0x0C`, `0x0D`, `0xFE`, and `0xFF`.
4. Decode the queue/event code table at `0x55A0`.
5. Decode the status exposure table around `0x680F-0x682F`.
6. Trace service buffers `0x2200`, `0x2280`, `0x23EE-0x240A`, and the special service context around `0x2640`.

## Output Compare / Actuator Scheduling

Confirmed:

- Routines around `0xBC12` and `0xBC90` interact with timer output compare registers.
- They use:
  - `0x101C` / TOC4-like output compare register.
  - `0x1023` / TFLG1-like timer flag register.
  - RAM words `0x20EB`, `0x20ED`, `0x242B`, `0x242D`.

Example pattern:

```asm
BC60: FC 24 2B      LDD $242B
BC63: F3 20 EB      ADDD $20EB
BC66: FD 10 1C      STD $101C
...
BC7A: 1A B3 20 EB   CPD $20EB
BC7E: 24 07         BCC $BC87
BC80: C6 10         LDAB #$10
BC82: F7 10 23      STAB $1023
```

Strong inference:

- These routines schedule timed output pulses or compare events.
- Because this is an engine ECU, likely candidates are ignition/injection/idle-related outputs, but the exact actuator is not confirmed yet.

Initialization:

- `0xBB98` clears many `0x20xx` output-state variables.
- It copies default values from vectors/scalars into runtime RAM.
- It initializes `0x20EB`, `0x20ED`, `0x2426`, `0x2428`, and the `0x20C*` group.

## Checksum / ROM Integrity Logic

Confirmed:

- Routine at `0x5AD8-0x5B18` sums ROM bytes using `X` and `Y`.
- It skips `0xB600-0xB7FF`.
- It compares the accumulated sum with the word at `0x800E`.
- It sets or clears `RAM 0x0099 bit 0x04`.

Main loop service:

- `0xD40F` calls `0x5AD6`.
- `0x5AD6` checks enable byte `0x916E`, then runs/steps the checksum routine.

Checksum storage:

| Address | Meaning |
| ---: | --- |
| `0x800C-0x800D` | Checksum word |
| `0x800E-0x800F` | Checksum complement / byte-sum target |

Repair formula:

```text
sum_without_checksum_pair = sum(bytes 0x4000-0xFFFF excluding 0x800C-0x800F)
checksum_complement = (sum_without_checksum_pair + 0x01FE) & 0xFFFF
checksum_word       = (~checksum_complement) & 0xFFFF
```

## Free ROM Space / Custom Logic

Measured zero-filled regions in `M27C512_original.BIN`:

| Region | Size | Notes |
| ---: | ---: | --- |
| `0x0000-0x3FFF` | `16384` bytes | Zero-filled lower half. Do not assume this is usable executable ROM; 68HC11 internal RAM/registers and ECU memory decoding make low-address execution risky until hardware mapping is confirmed. |
| `0xF021-0xFFD5` | `4021` bytes | Best current code-cave candidate. It starts immediately after an `RTS` at `0xF020` and ends before the interrupt/vector words at `0xFFD6-0xFFFF`. |
| `0xB600-0xB7FF` | `512` bytes | Zero-filled and deliberately skipped by the checksum routine. Potential patch area, but use carefully because the skip itself is a special checksum behavior. |
| `0xB584-0xB7FF` | `636` bytes | Larger contiguous zero run including the checksum-skipped block. Bytes before `0xB600` are included in checksum. |

There are other zero-looking areas, but several are now known active calibration
tables, for example `0x87B1-0x8888`, `0x9073-0x90D5`, and parts of the
`0x8Fxx` table cluster. Those should not be treated as free space.

Custom logic feasibility:

- The stock image is a fixed `64 KiB` 27C512 address space. It cannot be
  extended past `0xFFFF` without hardware/address-decoder changes.
- Small custom routines can likely be added by placing 68HC11 machine code in a
  real code cave, then patching an existing `JSR`/`JMP` hook into it.
- The safest current cave is `0xF021-0xFFD5`.
- Any patch outside the checksum-skipped `0xB600-0xB7FF` range requires repairing
  the checksum words at `0x800C-0x800F`.
- A compiled C routine is possible only if the compiler can emit plain
  68HC11-compatible code for an absolute address with no runtime assumptions.
  Hand-written assembly is much easier to make safe in this ECU because hooks
  must preserve registers, flags, stack use, RAM variables, and cycle timing.
- Before installing custom logic, decode the chosen hook's live register
  contract and interrupt/timing context. A hook in spark/fuel scheduling code is
  much more timing-sensitive than a slow diagnostic or state-machine hook.

## External Sensor References

External references for the Peugeot 106 I 1.3 Rallye TU2J2/MFZ with Magneti
Marelli 8P list the following ECU-facing sensors/components:

| Sensor / component | Component ID in wiring reference | Reverse-engineering relevance |
| --- | --- | --- |
| Coolant temperature sensor | `B24` | Warmup enrichment, fallback, fan/temperature diagnostics. |
| Inlet air temperature sensor | `B25` | Air-density correction and IAT fallback. |
| Vehicle speed sensor | `B33` | Likely tied to the speed-like `0x00D4 -> 0x2044` path. |
| Knock sensor | `B69` | Marked for the 1.3; supports but does not prove knock/octane spark-bank logic. |
| Heated oxygen sensor | `B72` | Closed-loop mixture and diagnostic adaptation. |
| Crankshaft speed sensor | `B75` | Period/RPM source upstream of `0x00BA -> 0x2036`. |
| MAP sensor | `B83` | Strong clue for the `0x2034` load/MAP axis. |
| Throttle position sensor | `B147` | ADC channel, transient, idle, WOT, and plausibility logic. |

MAP-specific clue:

- A Peugeot 106 1.3 Rallye TU2J2/MFZ listing shows a Magneti Marelli PRT03-family
  MAP sensor (`PRT03E04 3358AA`) removed from this exact vehicle family.
- A Magneti Marelli `PRT03/04` product sheet describes a 1 bar absolute-pressure
  sensor range of `17-105 kPa`.
- The user's `PRT 03E/02 2624AL 100 kPa` marking is consistent with this
  1 bar MAP family.

Implication for maps:

- The likely spark tables use `0x2034` on the x-axis.
- `0x2034` is an 8.8 load-like axis clamped near `0x0800`.
- A 100 kPa MAP sensor makes the provisional `0, 128, 256, 384, 512, 640, 768,
  896, 1024` x-axis labels plausible as mbar-like MAP/load labels.
- This is now the best working label for the XDF, but the exact ADC transfer and
  physical unit conversion remain to be proved from code or live data.

## Current Functional Picture

Best current model:

1. Reset configures 68HC11 hardware, stack, ADC/timer registers, and RAM.
2. Startup copies/validates the calibration window.
3. ADC channels are sampled into RAM `0x2007-0x200E`.
4. Timer input capture builds period-like value `0x00BA`.
5. Period-like `0x00BA` is converted into speed-like axes:
   - `0x2036` via `0xB3B9`.
   - `0x00D4` via inverse-period math.
   - `0x2044` via clamp/divide from `0x00D4`.
6. Load-like axis `0x2034` is built from `0x00CE`.
   - One producer path sets `0x00D0` from the `0x9187` lookup and then stores
     `0x00CE = 0x00D0 << 2`.
7. The main loop runs a fixed sequence of state machines, diagnostics/fault logic, map calculations, and output scheduling.
8. Important maps use common axes:
   - `0x2034` and `0x2036` for several 2D tables.
   - `0x2044` for speed-indexed 1D curves.
9. Output compare routines schedule timed hardware events through `0x101C` and acknowledge flags at `0x1023`.
10. The checksum routine runs as a runtime integrity service and updates `0x0099 bit 0x04`.

## High-Priority Unknowns

1. Fully name the `0x00D0 -> 0x00CE -> 0x2034` path.
   - `0x00CE` is the source of axis `0x2034`.
   - `0x00D0` can come from the `0x9187` lookup or from the alternate
     `0x58F2` state-machine path.
   - This is probably the key to identifying load/throttle/pressure axes.
2. Name `0x20B1`.
   - It selects between the `0x8A69` and `0x8B41` 24x9 banks.
3. Trace `0x2147`.
   - It is the output of the MOD2-touched banked 2D maps.
   - Its downstream consumer may reveal whether those maps are fuel, ignition, or another correction.
4. Continue tracing consumers of `0x00D0`.
   - `0x5E74` proves that `0x9187` can seed `0x00D0`.
   - `0x5E7C` proves that `0x00D0` can seed `0x00CE`, which then becomes
     normalized axis `0x2034`.
   - Remaining consumers of `0x00D0` should reveal whether the path is alpha-N
     load, air-charge, VE, or another correction model.
5. Decode the diagnostic/service protocol.
   - SCI use is confirmed at `0x102B-0x102F`.
   - The handshake path can enter special service loop `0xD80B`.
   - Event/status queue `0x004B-0x005B` and table `0x55A0` need external code naming.
6. Decode `0x58F2` and `0x5982`.
   - They manage many descriptor triples in `0x9131-0x9167`.
   - Understanding them will explain a large part of the control-state logic.
7. Decode the output compare path around `0xBC12/0xBC90`.
   - This is likely where calculated ECU quantities become physical output timing.
8. Identify ADC channels.
   - Map RAM `0x2007-0x200E` to sensors using code behavior and, ideally, bench/live data.

## Editing Caution

At this stage, only table structure and code usage are being confirmed. Physical labels such as fuel, ignition, throttle, RPM, MAP, coolant, air temperature, enrichment, and limiter should not be assigned in the XDF until downstream logic or live behavior confirms them.
