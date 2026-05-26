# Marelli IAW 8P.40 Firmware Logic Notes
This is the consolidated source for local firmware behavior, disassembly findings, map candidates, offsets, checksum logic, and XDF implementation notes. External/public-source evidence and generated scanner snapshots live in `EVIDENCE.md`.
## Functional Logic
Analysis date: 2026-05-24

This file is a living description of the ECU firmware behavior while the Peugeot 106 1.3 Rallye Marelli `IAW 8P.40` ROM is being reverse engineered.

External public research is summarized in
`EVIDENCE.md`. That file is useful for vehicle,
EPROM, sensor, and public map-family context, but this `LOGIC.md` remains the
source of truth for local code paths, offsets, and XDF naming confidence.

Confidence labels used below:

- Confirmed: directly supported by decoded instruction flow.
- Strong inference: supported by code shape and 68HC11 register usage, but physical meaning is not fully named.
- Open: visible in code, but not understood enough to name.

## XDF Category Display

XDF v0.44 intentionally writes `CATEGORYMEM category` as a 1-based TunerPro
display position, while the category definitions remain indexed from `0x0`.
For example, a table intended for the `Fuel Warmup / Transient` category uses
membership value `21`, which TunerPro displays as the 21st category definition.

## DHC11 Verification Pass

The generated DHC11 listing at `analysis/dhc11/M27C512_original_dhc11.asm`
now agrees with the active XDF on the main runtime axis families:

- Reset vector `0xFFFE -> 0xB800` and the vector table at `0xFFF0-0xFFFC`
  match the existing 68HC11 model.
- The temperature conversion paths are code-visible:
  `0x4340/0x434F` uses `0x92CF -> 0x400E -> $203C/$203E`, and
  `0x4390/0x439F` uses `0x92D9 -> 0x400E -> $2038/$203A`.
- The generated listing confirms the firmware inversion rule before runtime
  map indexing, so consumer maps stay cold-to-hot while raw ADC helpers stay
  hot-to-cold.
- DHC11 corrected two active XDF details: `0x8DD9` is a 1x9 `$203C` lookup
  at `0x44AD/0x44B1`, while `0x8558` is a `$2042` helper-axis lookup at
  `0xE4FF/0xE502`, not a `$203C` temperature vector.
- XDF version `0.44` corrects `$2040` scheduler-support table boundaries:
  `0x92FA` is a separate unsigned `1x9` table multiplied by `40` into
  `$2388`, `0x9303` is a separate signed `1x10` subvector feeding `$2048`,
  and `0x8789` is a `1x9` word table feeding `$2086`.
- Seeding `0xE9A8` as an entry point exposes the afterstart state handler and
  confirms `$203E` lookups for `0x845B/0x846C`, `0x847D/0x848E`,
  `0x849F/0x84B0`, and `0x84C1/0x84D2`.
- XDF version `0.41` promotes the remaining DHC11 helper-referenced lookup
  bases that lacked exact named views. This includes transient fuel support
  vectors at `0x81E0`, `0x8508`, `0x8511`, `0x8529`, `0x8561`, and `0x8579`;
  warmup/startup support at `0x841B`, `0x843D`, `0x8452`, and `0x84ED`;
  idle/state support at `0x8636`, `0x863F`, `0x8648`, `0x8652`, `0x8671`,
  `0x8689`, and `0x899A`; spark transition/state support at `0x87A6`,
  `0x87AB`, `0x8E04`, `0x8E0D`, and `0x8E18`; adaptive entry support at
  `0x8E36`, `0x8E3D`, `0x8E46`, and `0x8E57`; and the scheduler subvector
  `0x9303`.
- The special SCI response `0x55` service entry begins with `SEV` at `0xAAE0`,
  then `LDAA #0x06` at `0xAAE1`, `STAA $21A6`, `LDS $916A`, and
  `JMP $D80B`.

These confirmations improve table boundaries and axes only. Fuel, warmup,
transient, idle, closed-loop, and timer table values remain raw unless a
separate producer/consumer trace proves physical units.

### Remaining DHC11 Lookup Pass

The `0.41` XDF pass uses only helper call evidence from the generated DHC11
listing. Width follows helper behavior: `0xB2AB/0xB2BA` byte interpolation,
`0xB26E` word interpolation, and heterogeneous threshold records stay raw byte
records. These are exact inspection views, not final physical-unit claims.

| Cluster | Exact bases | Runtime index / output evidence |
| --- | --- | --- |
| Transient fuel support | `0x81E0`, `0x8508`, `0x8511`, `0x8529`, `0x8561`, `0x8579` | `$2036` RPM feeds `0x81E0/0x8511/0x8561`; `$2042` feeds `0x8508/0x8529/0x8579`; outputs include `$24D9`, `$206D`, `$206C`, `$206E/$2070`, `$207A`, and `$207E/$207C`. |
| Warmup/startup support | `0x841B`, `0x843D`, `0x8452`, `0x84ED` | `$203E` feeds the 17-point afterstart vectors; `$203C` feeds startup/scheduler vectors; outputs/uses include `$205D` compare, `$205B`, `$21CA`, and `$00BF` compare. |
| Idle/state support | `0x8636`, `0x863F`, `0x8648`, `0x8652`, `0x8671`, `0x8689`, `0x899A` | `$203C` feeds the CTS state vectors; `$2042` feeds threshold/minimum vectors; `$2036` feeds the closed-loop entry offset. Outputs include `$20A8`, `$210E`, `$2110`, `$20F6`, and `$20F5`. |
| Spark transition/state support | `0x87A6`, `0x87AB`, `0x8E04`, `0x8E0D`, `0x8E18` | `$2046` feeds compact transition vectors stored at `$214F`; capped `$2065` feeds spark-state decay vectors that contribute to `$2146`. |
| Adaptive entry support | `0x8E36`, `0x8E3D`, `0x8E46`, `0x8E57` | `0x8E36/0x8E3D` are mixed threshold records read by the `0xCC00` gate; `$2044` feeds `0x8E46/0x8E57`, whose result is added to `$00C9`. |
| Scheduler support | `0x9303` | `$2040` feeds signed helper `0xB2BA`; output `$2048`. This begins immediately after the separate `0x92FA` 1x9 scheduler vector and is a real exact code base. |

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
- `0x2034` is later derived from the processed RAM word `0x00CE`.
- The physical meanings are still not fully named from static code alone, but
  the copy and consumer paths now separate the raw channel groups.

Current ADC channel matrix:

| RAM | Source ADR path | Key consumers / transforms | Current status |
| ---: | --- | --- | --- |
| `0x2007` | `$1033` in the `0x4034/0x4146` group | Read by the `0x5E97/0x5EEC` load-model/state paths and by `0x96D3` | likely load/TPS/MAP-adjacent input, exact sensor unknown |
| `0x2008` | `$1031` in the `0x4017/0x4113` group | Filter/processing around `0x40CE/0x4322`, consumers at `0x5C19` and `0x96E9` | raw sensor channel, likely analog ECU sensor |
| `0x2009` | processed from the `0x2008` path | Used around `0x5BA0`, `0x5BC4`, and `0x5CE9` | filtered/derived copy of `0x2008` path |
| `0x200A` | `$1034` in the `0x4017/0x411F` group | Filter/processing around `0x40B0/0x4372`, consumers at `0x5D1F`, `0x6D25`, `0x96F3` | raw sensor channel, likely correction-related |
| `0x200B` | processed from the `0x200A` path | Consumers around `0x47F1` and `0x5D5D` | filtered/derived copy of `0x200A` path |
| `0x200C` | `$1032` in the `0x4034/0x4140` group | Consumers around `0x5B1B` and `0x5B8E`; threshold checks near `0x52A8/0x53D9` | raw sensor channel |
| `0x200D` | `$1033` in the `0x4017/0x4119` group | Helper around `0x415D`; threshold checks near `0x52B5/0x53E6` | raw sensor channel |
| `0x200E` | `$1034` in the `0x4034/0x414C` group | Consumers around `0x4173`, `0x418E`, `0x42F7`, `0x5DA8`, `0x96DA` | raw sensor channel |
| `0x2013` | helper result from `0x5E82` after `$1033` sample | Many later comparisons and mode checks | processed sensor/status value |

Repeatable scan counts:

| Address | Peugeot refs | First Peugeot sites | Xantia refs | Interpretation |
| --- | ---: | --- | ---: | --- |
| `0x1030` | `16` | `0x40E8`, `0x4133`, `0x51EF`, `0x52D1` | `14` | ADC control writes are a shared family pattern. |
| `0x1031` | `8` | `0x401E`, `0x4113`, `0x53CC` | `6` | ADC result byte source. |
| `0x1032` | `5` | `0x403B`, `0x4140`, `0x52A8` | `5` | ADC result byte source. |
| `0x1033` | `7` | `0x4024`, `0x4041`, `0x4119` | `7` | ADC result byte source; feeds several Peugeot `0x2007/0x200D/0x2013` paths. |
| `0x1034` | `7` | `0x402D`, `0x405A`, `0x411F` | `7` | ADC result byte source. |
| `0x00CE` | `19` | `0x4073`, `0x409C`, `0x412B` | `10` | load/air-charge word path; exact physical units still open. |
| `0x00D0` | `22` | `0x574A`, `0x57BD`, `0x5E5C` | `26` | load-model byte / air-charge byte family. |
| `0x2034` | `8` | `0x41AD`, `0x4913`, `0x495F` | `3` | normalized load/MAP-like axis consumer. |

Interpretation:

- The code alternates ADC result groups rather than keeping a simple one-to-one
  permanent `ADRn -> sensor` assignment.
- MAP is still the best physical candidate behind the normalized `0x2034`
  load axis because of the vehicle's 100 kPa PRT03-family MAP sensor and the
  `0x2034` clamp/range, but the exact ADC byte that enters the pressure
  transfer path is not yet proven.
- TPS, IAT, CTS, lambda, and battery/other analog channels are all expected in
  this matrix, but assigning those names now would be premature without tracing
  the fallback thresholds and diagnostic event IDs to each channel.

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
- It is the main RPM-normalized axis; exact timer-clock basis can still be
  checked against live RPM logging.

### Inverse RPM-Like Value `0x00D4`

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

- `0x00D4` is RPM-like because it is derived from engine period. The
  `0xE4E2 * 256` constant is effectively `15000000`, matching the local
  RPM-axis math.
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
- Because `$2044 = (rpm / 25) << 4`, the integer table sites are 400 rpm
  apart: `0, 400, 800, ... 7200 rpm`.
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

- `0x2034` is a MAP/load-like 8.8 axis.
- It is best displayed as a rounded integer `0-100 kPa` MAP/load estimate for
  the spark maps, while the exact ADC channel and transfer function remain
  open.
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

Producer/consumer split:

| RAM | Producers now identified | Consumers now identified | Working name |
| ---: | --- | --- | --- |
| `0x00D0` | `0x5E77` from `0x9187` lookup or fallback byte `0x917C`; `0x5E5C` from the `0x58F2` state path | Direct users around `0x574A`, `0x57BD`, `0x5F07`, `0x5FAA`, `0x96DE`, `0x96F7`, `0x9953`, `0x99CC`, `0xBAB8`, `0xBE0E`, `0xD10F`, `0xD169`, `0xE5C1`; table cluster `0xD105-0xD15D` derives a `0x00D0 - 0x60` axis | load_model_byte / air-charge byte |
| `0x00CE` | `0x5E7C` as `0x00D0 << 2`; `0x5E5E` from the `0x58F2` state path; earlier preload/update paths around `0x4073`, `0x409C`, `0x412B`, `0x42E1` | `0x41A1-0x41AD` builds `0x2034`; consumers around `0x45F3`, `0x97E7`, `0x992C`, `0x99DC`, `0x9CB0`, `0xE411`, `0xE5EB`, `0xE975` | raw_load_or_aircharge_word |
| `0x2034` | `0x41A1-0x41AD` from clamped `0x00CE * 2` | First axis for banked spark maps `0x8A69/0x8B41`, `0x85BA`, `0x87B1`, `0x888E`, `0x8A0A`, and other B2D6 users | load/MAP-like_axis_8p8 |

Resolved part:

- `0x9187` is not the same subsystem as the `0x58F2` descriptors. It is a
  normal B2D6 table lookup whose result can seed `0x00D0`.
- `0x58F2` is a state/descriptor routine that can substitute or update the
  same load-model RAM, but its descriptor data at `0x9131-0x9167` should not be
  treated as fuel or spark maps.
- `0x2034` is now strong enough to label as load/MAP-like in the XDF. The exact
  pressure transfer and ADC source remain open.

### Axis Inventory

This is the current consolidated naming table for runtime axes and EPROM
breakpoint vectors. "Confirmed" here means the lookup structure or RAM axis is
confirmed from code; the physical name can still be provisional.

| Axis/source | Current name | Producer / calibration | Confirmed consumers | Physical confidence |
| --- | --- | --- | --- | --- |
| `0x2036` | `rpm_axis_8p8` | Built by `0xB3B9` from period-like `0x00BA` using `0x929E-0x92CD`, count `0x92CE = 0x18` | `0x8A69`, `0x8B41`, `0x8C19`, `0x9187`, `0x85BA`, `0x869A` | High; `15000000 / period` gives the displayed RPM labels. |
| `0x2034` | `MAP/load_kPa_estimate_axis_8p8` | `0x41A1-0x41AD` from clamped/doubled `0x00CE`, fed by `0x00D0` and load-model/state paths | `0x8A69`, `0x8B41`, `0x85BA`, `0x87B1`, `0x888E`, `0x8A0A` | Medium-high MAP/load; XDF displays spark labels as rounded integer `0-100 kPa`, exact ADC transfer unproven. |
| `0x2044` | `rpm_400rpm_site_axis_8p8` | Derived from RPM-like `0x00D4`, clamped to `0x1200` | `0x89C7-0x8A67` vector family, `0x9073`, `0x8E6F/0x8EC7/0x8F1C/0x8F71` | High structure; integer sites are `0-7200 rpm` in 400 rpm steps. Not a vehicle-speed axis. |
| `0x2046` | `secondary_transient_state_axis_8p8` | Built in the same normalized-axis runtime block as `0x2036` and `0x2044` | `0x8A0A` | Low-medium; exact source still needs tracing. |
| `0x9291-0x9299` | `9_point_helper_breakpoint_vector_A` | EPROM vector used by `0xB383`, count/stride byte `0x929A = 0x09` | `0x9187`, `0x9073`, helper calls around `0x41E0` | High structural, physical units provisional. |
| `0x92CF-0x92D7` | `likely_CTS_ADC_breakpoints_B` | NTC-matching ADC vector `12,20,34,57,93,142,191,227,246`, count `0x92D8 = 0x09`; shared output vector `0x400E` is `deg C + 40` | `0x2008 -> 0x2122 -> 0x203C/0x203E`; best current CTS/coolant path by consumers. | High NTC structure; exact pin/bench proof still pending. |
| `0x92D9-0x92E1` | `likely_IAT_ADC_breakpoints_A` | Same NTC-matching ADC vector, count `0x92E2 = 0x09`; shared output vector `0x400E` is `deg C + 40` | `0x200A -> 0x2124 -> 0x2038/0x203A`; X axis for `0x802B/0x8103`. | High NTC structure; best current IAT/air-temperature path by consumers. |
| `0x2014` | `candidate_sensor_or_state_axis` | Producer not fully named | `0x869A` first axis | Low; keep provisional. |

### Confirmed Axis Consumers

| Table/vector | Axes | Current role |
| --- | --- | --- |
| `0x8A69` | `0x2034` MAP/load kPa estimate by `0x2036` RPM | Likely high-octane/default spark bank; in XDF `Confirmed` category with rounded integer MAP/load labels. |
| `0x8B41` | `0x2034` MAP/load kPa estimate by `0x2036` RPM | Likely low-octane/alternate spark bank; in XDF `Confirmed` category with rounded integer MAP/load labels. |
| `0x8C19` | `0x2036` RPM only | Likely WOT/fallback spark vector; in XDF `Confirmed` category. |
| `0x802B` | likely IAT axis `0x92D9 -> 0x2038` by `0x2036` RPM | Signed `24x9` fuel correction table; XDF consumer labels display the inverted `-40..120 C` order; output `0x204A`, exact sensor pin still provisional. |
| `0x8103` | likely IAT axis `0x92D9 -> 0x2038` by `0x2036` RPM | Paired signed `24x9` fuel correction table; XDF consumer labels display the inverted `-40..120 C` order; output `0x204D`, exact sensor pin still provisional. |
| `0x9187` | `0x9291`-derived axis by `0x2036` RPM | Load / air-charge model factor that can seed `0x00D0 -> 0x00CE -> 0x2034`. |
| `0x85BA` | high-load transform / load by `0x2036` RPM | High-load pulse extension / duration-support candidate; output `0x2063` is doubled into the `0x00C3` path. |
| `0x87B1` | `0x2034` MAP/load by `0x2036` RPM | Injector/event phase offset; stock-zero output updates `0x00BE -> 0x21C6` before OC1 schedules `TOC1 = $00B8 + $21C6`; changes timing/phase, not fuel quantity. |
| `0x888E` | `0x2034` MAP/load by `0x2036` RPM | Idle-air / idle-bypass target candidate stored to `0x2484`, then combined with likely CTS vector `0x8970` and shaped toward `0x202B`. |
| `0x8970` | likely CTS axis `0x203E` | Idle target/cap vector stored to `0x2486`, part of the `0x888E -> 0x202B` idle actuator path. |
| `0x84E3` | lambda/dynamic axis `0x2040` | Likely lambda / closed-loop fuel correction vector; output `0x2049` is applied to `0x00C1`. |
| `0x8A0A` | `0x2034` MAP/load by `0x2046` secondary transient/state axis | Code-confirmed `5x5` table. |
| `0x869A` | `0x2014` candidate sensor/state axis by `0x2036` RPM | Code-confirmed `24x9` parent table stored to `0x2391`. |
| `0x9073` | `0x9291`-derived axis by transformed `0x2044` | Closed-loop ramp/target `11x9` table compared with `$243C`.  |
| `0x8E6F/0x8EC7/0x8F1C/0x8F71` | `0x00D0`-derived axis by `0x2044` | Adaptive trim dynamics cluster feeding `$24AB/$24AF/$24AC/$24AD` into the closed-loop/adaptive state machine. |

## Interpolation / Calibration Helpers

### NTC Temperature Breakpoint Tables

The two temperature-axis helper vectors at `0x92CF` and `0x92D9` are now best
understood as 8-bit ADC breakpoint curves for NTC sensors, not resistance
tables. Both carry the same breakpoints:

| Path | Breakpoint vector | Count byte | Runtime output | Best current physical role |
| --- | --- | --- | --- | --- |
| `$2008 -> $2122` | `0x92CF`: `12,20,34,57,93,142,191,227,246` | `0x92D8 = 0x09` | `$203C/$203E` | likely CTS/coolant |
| `$200A -> $2124` | `0x92D9`: `12,20,34,57,93,142,191,227,246` | `0x92E2 = 0x09` | `$2038/$203A` | likely IAT/air temperature |

The shared transfer vector at `0x400E` is
`160,140,120,100,80,60,40,20,0`, which fits a `deg C + 40` representation.
That maps the raw ADC helper breakpoints to hot-to-cold labels
`120,100,80,60,40,20,0,-20,-40 C`.

Using coolant-sensor midpoint references of roughly `6400 ohm` at `0 C`,
`2500 ohm` at `20 C`, and `315 ohm` at `80 C`, the breakpoints imply a pull-up
near `2 kOhm`:

| Point | ROM ADC | Implied pull-up |
| ---: | ---: | ---: |
| `0 C` | `191` | `2145 ohm` |
| `20 C` | `142` | `1989 ohm` |
| `80 C` | `34` | `2048 ohm` |

This raises confidence that these are real temperature-sensor conversion
curves. The hardware document's coolant temperature pin 13 and air temperature
pin 31 support the physical interpretation, but the IAT/CTS side assignment
still remains provisional until confirmed by pinout, PCB trace, or coherent live
diagnostic behavior.

The firmware does not use the hot-to-cold helper order directly for consumer
maps. After converting the ADC byte through the breakpoint helper, it inverts the
8.8 index as `axis = ((count - 1) << 8) - breakpoint_index`; consumers of
`$2038/$203A/$203C/$203E` therefore display cold-to-hot labels.

### Temperature Axis Consumer Matrix

The active XDF uses the NTC proof to display dependent table axes in degrees C.
This is an axis-label upgrade only: table cells remain raw or signed raw unless
their output units are independently proven.

| Axis family | Tables/vectors | Display axis |
| --- | --- | --- |
| raw ADC helper vectors | `0x92CF`, `0x92D9` | 9-point hot-to-cold `120,100,80,60,40,20,0,-20,-40 C`; Z remains raw ADC counts |
| likely IAT `$2038` | `0x802B`, `0x8103` | 9-point cold-to-hot `-40,-20,0,20,40,60,80,100,120 C` by RPM |
| likely IAT doubled `$203A` | `0x8C7C` | 17-point cold-to-hot `-40..120 C` in 10 C steps, by load |
| likely CTS `$203C` | `0x8452`, `0x84ED`, `0x84F6`, `0x853B`, `0x8546`, `0x858B`, `0x859F`, `0x8636`, `0x863F`, `0x8648`, `0x8689`, `0x8DD9`, `0x90D6` | 9-point cold-to-hot `-40,-20,0,20,40,60,80,100,120 C` |
| likely CTS doubled `$203E` | `0x8D15`, `0x8408`, `0x841B`, `0x843D`, `0x845B`, `0x846C`, `0x847D`, `0x848E`, `0x849F`, `0x84B0`, `0x84C1`, `0x84D2`, `0x8970`, `0x8DAE`, `0x9000`, `0x9011`, `0x9022`, `0x9033`, `0x9044`, `0x90EF` | 17-point cold-to-hot `-40..120 C` in 10 C steps |
| `$2042` helper axis from `0x9291` | `0x8508`, `0x8529`, `0x8558`, `0x8579`, `0x8652`, `0x8671` | 9-point raw helper labels `0,3,11,22,37,54,89,132,201`; physical units still unnamed |

The exact IAT/CTS channel assignment still needs pin, PCB, or live diagnostic
proof. The active XDF exposes the CTS transient leads `0x84F6`, `0x853B`,
`0x8546`, `0x858B`, and `0x859F` as raw/word views, plus the DHC11-promoted
CTS startup/state leads listed above. The DHC11 listing keeps `0x8558` and the
new `0x8508/0x8529/0x8579/0x8652/0x8671` views in the `$2042` helper-axis
family instead of `$203C`. Output units remain unscaled.

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

- If `spark_bank_selector_state` (`RAM 0x20B1`) is nonzero, use `24x9 @ 0x8A69`.
- If `spark_bank_selector_state` (`RAM 0x20B1`) is zero, use `24x9 @ 0x8B41`.
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

- Calibration byte `0x800A` seeds runtime `spark_bank_selector_state`
  (`0x20B1`).
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
- Working octane-bank naming:
  - `0x8A69` is now labelled as likely high-octane/default spark advance.
  - `0x8B41` is now labelled as likely low-octane/alternate spark advance.
  - This is still a likely label, not a final proof from knock-control code.
- Same-family offset warning:
  - The Peugeot stock/MOD2 code-confirmed offsets remain `0x8A69`,
    `0x8B41`, and `0x8C19`.
  - `RALLY13.ORI` carries an exact copy of the Peugeot stock spark bundle
    shifted by `+0x1B`: high bank `0x8A84`, low bank `0x8B5C`, WOT vector
    `0x8C34`.
  - `Peug.106Rally.org.bin` keeps the same Peugeot offsets, but its two
    banked spark tables are heavily altered while the `0x8C19` WOT vector is
    unchanged. Its low-RPM high values are therefore tune/data content at the
    same offset, not an offset proof by themselves.

Numeric support for the octane-bank naming:

- Stock and MOD2 both store `0x800A = 0x00`.
- The initialization path decrements that to runtime `0x20B1 = 0xFF`.
- The spark routine therefore selects `0x8A69` in normal/default stock operation.
- Comparing stock `0x8B41 - 0x8A69` in displayed degrees:
  - All cells: mean `-1.46 deg`, min `-12.0 deg`, max `+17.0 deg`.
  - Low-load columns `0-2`: mean `-0.62 deg`.
  - Mid-load columns `3-4`: mean `+2.14 deg`.
  - High-load columns `5-8`: mean `-3.89 deg`, with `87` lower cells and
    only `9` higher cells.
  - Highest columns `6-8`: mean `-3.78 deg`.
- Therefore `0x8B41` is not a simple globally-retarded copy. It has a
  mid-load advance ridge, but it is usually more conservative where load is
  highest. That pattern is more consistent with `0x8A69` as the
  high-octane/default table and `0x8B41` as the low-octane/alternate table.

Downstream trace:

- Direct references to `0x2147` cluster in `0x44xx-0x49xx`.
- `0x4481` seeds `0x2147` from a byte at `0x8C79` with `A = 0`.
- `0x48F1` clears `0x2147` before the banked spark/WOT selection path.
- `0x493B-0x493E` adds the banked-map or WOT-vector result into `0x2147`.
- `0x454E`, `0x4602`, `0x462C`, `0x489A`, and `0x4978` add further
  correction terms to `0x2147`.
- `0x45C4`, `0x45E2`, `0x4684`, and `0x49B5` write post-processed values back
  to `0x2147`.
- `0x460A-0x463E` applies an additional correction dependent on
  `spark_bank_selector_state` (`0x20B1`).
- `0x4642-0x468F` clamps/converts the `0x2147` word and writes related byte
  outputs including `0x2001` and `0x2148`.
- `0x2149` is written at `0x46E5`, tested at `0x4702`, and read at `0x4772`.
- `0x214C` is read at `0x48DD/0x48E6` and written at `0x496D`.

Interpretation:

- `0x2147` is now best named a spark-angle accumulator/intermediate command.
- The banked `0x8A69/0x8B41` tables and the `0x8C19` bypass vector feed this
  accumulator, then later corrections and clamps produce byte-sized outputs.
- `0x2001` and `0x2148` look like final or near-final spark-angle command bytes,
  but the code path from those bytes to timer/output-compare hardware is not
  fully closed yet.
- No direct `0x2147 -> 0xBC12/0xBC90` path has been proven. The spark-map
  interpretation is strong from values, scaling, selector behavior, and this
  accumulator path, but the exact timer conversion routine still needs tracing.

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
- This is now exposed in the XDF as
  `Load / Air-Charge Model Factor 24x9 @ 0x9187`.
  The code confirms the lookup, axes, and consumers, but not yet whether the
  factor is air density, VE, fuel, or another compensation path.
- Current best interpretation is load/air-charge modelling rather than final main
  fuel, because one confirmed path stores the lookup result to `0x00D0`, then
  stores `0x00CE = 0x00D0 << 2`, and `0x00CE` is later normalized into the
  load/MAP-like axis `0x2034`.
- The old `15x9 @ 0x91D9` view is misaligned and has been removed from the
  normal XDF candidate tree. Use the code-correct `0x9187` parent table instead.

### MOD2 Fuel/Corr Candidate Pass

Using `1_3L_8V_IAW8P40_MOD2.bin` against `M27C512_original.BIN`, the current
fuel-search priority is now expressed as confidence-tier working labels:

| Range | XDF working label | Confidence | Current interpretation |
| --- | --- | --- | --- |
| `0x802B-0x8102` | `Signed Fuel IAT/RPM Correction A 24x9 @ 0x802B` | Code-referenced | Signed likely IAT/RPM fuel correction candidate. X uses the likely IAT `0x92D9 -> $2038` path and displays firmware-inverted `-40..120 C` sites; Y uses `0x929E` RPM labels into `$2036`; output `$204A` feeds `$204B -> $00C1`. |
| `0x8103-0x81DA` | `Signed Fuel IAT/RPM Correction B 24x9 @ 0x8103` | Code-referenced | Paired signed likely IAT/RPM correction candidate using the same axes; output `$204D` feeds the `$204E/$204F` blend path. |
| `0x81F8-0x821B` | `Low-RPM Fuel Trim A 4x9 @ 0x81F8` | Code-referenced alternate base | Guarded low-RPM/submode signed trim slice selected by `$E38B`; not exposed as a normal tuning table yet. |
| `0x821C-0x82F3` | `Signed Fuel Quantity Trim A Raw 24x9 @ 0x821C` | Code-referenced | Signed load/RPM trim candidate selected by `$E38B` when `$20B1 != 0`; `$E715` applies roughly `fuel += fuel * signed_trim / 256`. |
| `0x82F4-0x8317` | `Low-RPM Fuel Trim B 4x9 @ 0x82F4` | Code-referenced alternate base | Guarded low-RPM/submode signed trim slice selected by `$E38B`; not exposed as a normal tuning table yet. |
| `0x8318-0x83EF` | `Signed Fuel Quantity Trim B Raw 24x9 @ 0x8318` | Code-referenced | Paired signed load/RPM trim candidate selected by `$E38B` when `$20B1 == 0`; `$20B1` is fuel-bank selector too, not spark-only. |
| `0x83F0-0x8407` | `RPM-only Fuel Trim / Bypass Vector Candidate 1x24 @ 0x83F0` | Code-referenced | Signed RPM-only bypass vector selected by `$E38B` in a special mode and stored to `$2084`; not a standalone VE table. |
| `0x802E/0x80EB/0x81A8/0x80F1` | Retired signed/misaligned probes | Historical evidence only | Removed from the active XDF in v0.42 after exact `0x802B/0x8103` views superseded them. `0x80EB` is a signed boundary slice at `0x802B+0xC0`; do not tune these as VE or main fuel. |
| `0x89ED-0x89F2` | `Per-event Correction Scalars 1x6 @ 0x89ED` | Code-referenced | Direct scalar/control bytes around the `0x2044` vector family. |
| `0x84E3-0x84F5` | `Lambda / Closed-Loop Fuel Correction Vector 1x19 @ 0x84E3` | Candidate | `0x2040`-indexed likely lambda fuel correction; output `$2049` is applied to `$00C1`. `$200C` lambda/O2 identity still needs hardware proof. |
| `0x888E-0x8965` | `Idle Air / Idle Bypass Target 24x9 @ 0x888E` | Code-referenced | Load/RPM idle-air target candidate; output `$2484` combines with `0x8970` and shapes `$202B`. |
| `0x8970-0x8980` | `CTS Idle Target / Cap Vector 1x17 @ 0x8970` | Candidate | Likely CTS-axis idle vector stored to `$2486`; exact actuator hardware unproven. |
| `0x8010-0x8027` | `SPI Output Pointer Frame 1x12 @ 0x8010` | Code-referenced non-tune | Pointer frame streamed by `0x9F02-0xA001` through SPI register `$102A`; not calibration. |
| `0x8E6F/0x8EC7/0x8F1C/0x8F71` | Adaptive trim dynamics cluster | Code-referenced | `17x5` cluster feeding `$24AB/$24AF/$24AC/$24AD` for the `$CC00-$CE38` adaptive/closed-loop state machine; not direct fuel quantity. |
| `0x89C7/0x89DA/0x8A52` | Ignition output / per-event retard vectors | Code-referenced | `$89C7 -> $20E7 -> $20EB` phase, `$89DA -> $20E8 -> $20ED` width/dwell, `$8A52 -> $20E6` retard cap. |
| `0x89F3-0x8A05` | `Per-event Retard/Gain Candidate 1x19 @ 0x89F3` | Medium-high structure | Code-confirmed `0x2044`-indexed vector; X sites are `0-7200 rpm` in 400 rpm steps; MOD2 changes `16 / 19` cells; kept with ignition output/retard strategy. |
| `0x9187-0x925E` | `Load / Air-Charge Model Factor 24x9 @ 0x9187` | Medium-high structural | Code-confirmed lookup that can feed `0x00D0 -> 0x00CE -> 0x2034`; likely load-model, air, fuel, or correction factor. |

The old `0x802E-0x81D4` fuel-side interpretation has been demoted. Targeted
disassembly points to the real signed table base at `0x802B`, with `0x802E`
starting three bytes into that table. `0x80EB` starts at `0x802B+0xC0`,
is not row-aligned, and crosses into the paired signed table at `0x8103`.
Keep the old `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1` views only as
legacy alignment/debug probes.
  - `0x80F1-0x8102` is exactly two full changed 9-cell rows in MOD2.
  - Later MOD2 regions align as repeated row chunks when this table starts at
    `0x80F1`.
  - Most MOD2 deltas are signed-value increases of `+5`, with one row group at
    `+18`.
  - The XDF uses TunerPro native signed 8-bit storage with plain `X` math for
    compatibility; the analyzer uses the equivalent two's-complement
    conversion internally.
- The lower shape keeps raw row labels in the XDF because it does not fit the
  24-point RPM axis cleanly.
- No direct code reference to table base `0x802E` has been confirmed. The only
  raw address-byte occurrence in stock is around `0xC621`, and current 68HC11
  decoding treats it as an immediate compare sequence rather than a table base.
- A pure VE/base fuel table is still not proven, but `$821C/$8318` are now the
  strongest signed fuel quantity trim candidates. `$00C1 -> $00C3 -> $00BC` is
  the strongest pulse-width/event-width path, while `$87B1 -> $00BE -> $21C6`
  is event phase. The old `0x802E` and `0x80EB` visual views are overlapping
  slices of the signed correction region, not standalone fuel maps; OC1
  schedules `TOC1 = $00B8 + $21C6` and OC3/PA5 behaves like the timed
  pulse-output path, but exact driver/pin and tick-to-ms/degree proof remain
  hardware-level.
- Screenshot continuity alone is no longer enough to keep a normal XDF view
  active when later code proves misalignment. The misleading `0x89F2` and
  `0x91D9` legacy views were removed; use the corrected scalar/vector and
  `0x9187` parent-table entries instead.

Repeatable script pass:

- `tools/iaw8p40_analyze.py` now loads the Peugeot stock, Peugeot folder
  `Stok`, Peugeot MOD2, Xantia 607C, `Peug.106Rally.org.bin`, and
  `RALLY13.ORI` images and prints Markdown-friendly hash/checksum/diff/reference
  tables without modifying ROMs.
- The script confirms Peugeot stock and folder `Stok` are byte-identical.
- Checksum pairs:
  - Peugeot stock and `Stok`: `0x4A65/0xB59A`, sum `0xFFFF`.
  - Peugeot MOD2: `0x47BE/0xB841`, sum `0xFFFF`.
  - Xantia 607C: `0x9F83/0x607C`, sum `0xFFFF`.
  - `RALLY13.ORI`: `0x7A41/0x85BE`, sum `0xFFFF`.
  - `Peug.106Rally.org.bin`: stored `0x4A65/0xB59A`, but byte sum `0xE160`;
    checksum validation fails.
- All six available 64 KiB images use reset vector `0xB800`.
- `Peug.106Rally.org.bin` is suspicious: the normally blank `0x0000-0x3FFF`
  prefix is not zero-filled, though the `0xB600-0xB7FF` hole is zero.
- `RALLY13.ORI` has a valid checksum, zero prefix, zero `0xB600-0xB7FF` hole,
  and same-family reset vector.
- Peugeot stock vs MOD2: `479` differing bytes in `87` contiguous regions.
  The changes remain concentrated in checksum/calibration-looking regions.
- Peugeot stock vs Xantia 607C: `42021` differing bytes in `1038`
  contiguous regions. Xantia is therefore useful as same-family comparative
  evidence, but not as proof that a same offset has the same Peugeot function.
- Peugeot stock vs `Peug.106Rally.org.bin`: `16513` differing bytes, mostly in
  the normally zero prefix plus spark/correction calibration areas. The legacy
  `0x802E` slice is unchanged versus stock.
- Peugeot stock vs `RALLY13.ORI`: `43767` differing bytes in `954` contiguous
  regions. Treat it like Xantia: useful same-family comparison, not offset proof.

Script-reported candidate stats:

| Range | Peugeot stock | MOD2 | Xantia | Peug.106Rally.org | RALLY13 | Interpretation impact |
| --- | --- | --- | --- | --- | --- | --- |
| `0x802B-0x8102` | signed `-121..-8`, avg `-68.6` | `75 / 216`, `+4..+6` | signed `-112..-28`, avg `-80.0` | `0 / 216` changed | `133 / 216` changed | Signed likely IAT/RPM fuel correction A; code-referenced. |
| `0x8103-0x81DA` | signed `-128..127`, avg `-22.8` | `72 / 216`, `+5..+18` | signed `-54..74`, avg `-4.9` | `0 / 216` changed | `145 / 216` changed | Signed likely IAT/RPM fuel correction B; code-referenced. |
| `0x802E/0x80EB/0x81A8/0x80F1` | retired overlapping raw/signed views | MOD2-touched only because they overlap the signed region | same-offset comparison only | same-offset comparison only | same-offset comparison only | Historical alignment probes only, removed from active XDF v0.42; `0x80EB` is signed boundary slice `0x802B+0xC0`. |

Immediate-reference scan:

- Peugeot has code-confirmed helper references for the spark/correction maps:
  `0x8A69`, `0x8B41`, `0x8C19`, `0x9187`, `0x9291`, and `0x929E`.
- The script's only raw `0x802E` byte-pattern hit is still the already decoded
  false positive near `0xC620`; keep treating it as a byte-pattern hint, not a
  table consumer.
- No direct Peugeot code reference to `0x80EB` or `0x81A8` was found by the
  immediate-base scan. `0x80EB` is retained only as a signed boundary slice
  spanning the end of `0x802B` and the start of `0x8103`.
- Xantia does not use the same Peugeot helper addresses or table-base literals
  for the known Peugeot tables. Its helper targets need to be traced separately.

Helper-call separation:

| ROM | Helper / target | Script count | First call sites | Notes |
| --- | --- | ---: | --- | --- |
| Peugeot | `0xB2D6` | `12` | `0x4927`, `0x6366`, `0x6ECA`, `0x7270` | 2D helper family; nearby known literals include `0x9187`, `0x9291`, `0x869A`. |
| Peugeot | `0xB2AB` | `53` | `0x4353`, `0x43A3`, `0x44B4`, `0x4599` | 1D/vector helper family; nearby known literals include spark/WOT bases. |
| Peugeot | `0xB383` | `7` | `0x41E9`, `0x4349`, `0x4399`, `0x5CFC` | Axis/descriptor setup family. |
| Peugeot | `0xB3B9` | `1` | `0xD47C` | RPM-axis path with `0x929E`. |
| Xantia | `0xB2CB` | `7` | `0x5028`, `0x50F2`, `0x5283`, `0x5365` | Same-family helper candidate, but not same address/function proof. |
| Xantia | `0xB349` | `4` | `0x4FF6`, `0x96B0`, `0xB88D`, `0xD973` | Likely helper candidate; needs separate tracing before comparison use. |

`0x9187` is code-confirmed and MOD2-touched, but is probably upstream of load:

- MOD2 changes `62 / 216` cells.
- It is called by the `0x6344` lookup routine and returns a byte.
- Known callers store that byte to `0x210F` or `0x00D0`.
- The `0x00D0 -> 0x00CE -> 0x2034` path means this table can affect later
  spark/fuel tables by changing the load/MAP-like axis.
- Until a direct pulse-width or fueling consumer is found, label it as a
  load/air-charge model candidate, not main fuel.

`0x89F3` is code-confirmed and MOD2-touched:

- Shape: `1x19`, indexed by `RAM 0x2044` through helper `0xB2AB`.
- X axis: `0, 400, 800, ... 7200 rpm`.
- MOD2 changes `16 / 19` cells, with mostly positive deltas from `+2` to `+18`.
- It is now best treated as a per-event retard/gain candidate. It is not
  confirmed main fuel or checksum data.

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
| `0x9073` | `11x9` | `0xC282-0xC2BE` | `0x9291`-derived axis by transformed `0x2044` | closed-loop ramp/target compared with `0x243C` |
| `0x8E6F` | `17x5` | `0xD105-0xD134` | `0x00D0`-derived axis by `0x2044` | stores `0x24AB` |
| `0x8F1C` | `17x5` | `0xD137-0xD140` | same descriptor as `0x8E6F` | stores `0x24AC` |
| `0x8F71` | `17x5` | `0xD143-0xD151` | same descriptor as `0x8E6F` | shifted down four bits into `0x24AD` |
| `0x8EC7` | `17x5` | `0xD154-0xD15D` | same descriptor as `0x8E6F` | stores `0x24AF` |

Important alignment corrections:

- The visually interesting old `0x86DB` candidate sits inside the larger
  code-confirmed `0x869A` parent table, not as a standalone proven table.
- The visually interesting old `0x88CD` candidate sits inside the larger
  code-confirmed `0x888E` parent table.
- The older `0x88CA` `8x19` triangular XDF view was a misleading off-axis slice
  and has been removed from the normal XDF tree.
- The `0x8E6F/0x8EC7/0x8F1C/0x8F71` cluster is exposed as bounded `17x5`
  views because those boundaries line up cleanly with adjacent table starts.
  The code's `0x2044` source axis is RPM-derived; live logging would still be
  useful to verify the exact runtime values.

### RPM-Indexed `0x2044` Vector Family

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

- Open physical roles. Because `0x2044` is RPM-derived, these are RPM-indexed
  correction curves or limits.
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

Observed call table:

| Call site | RAM state block in `X` | Descriptor in `Y` | Event ID passed to `0x5982` |
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

Behavioral interpretation:

- `0x58F2` appears to update a compact state byte and countdown/step byte.
- It tests mode bits in `X[0]`.
- It uses descriptor bytes at `Y+0`, `Y+1`, and `Y+2`.
- It writes back to the RAM state block.
- `0x5982` appears to log, queue, or update event/state output using an ID.
- Descriptor entries are 3 bytes wide. The raw range `0x9131-0x9169` therefore
  covers the observed entries and one apparent unused/reserved 3-byte slot at
  `0x9140`.
- These descriptors belong to a state/event subsystem. They are code-confirmed
  ROM data, but they are not normal fuel, spark, or axis maps.

Open:

- The external meaning of each event ID.
- Which state blocks correspond to MAP, TPS, temperature, lambda, idle, limiter,
  or other diagnostics.

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

XDF handling:

- `0x55A0-0x55B1` is now useful as an 18-byte raw diagnostic/event-code view
  because observed event IDs run from `0x00` through `0x11`.
- Stock bytes at `0x55A0-0x55B1`:
  `6C 0C 0B 1B 11 21 17 62 65 6F 12 6A 19 13 24 2B 0D 1C`.
- `0x9131-0x9169` is useful as a raw `19x3` state descriptor view. The observed
  callers use 18 descriptor triples; the extra slot keeps the display aligned
  across the gap at `0x9140`.
- Notable descriptor bytes:
  - `0x9131`: `01 01 01`.
  - `0x9134/0x9137/0x913A`: `01 19 0A`.
  - `0x913D`: `01 19 01`.
  - `0x9143`: `20 61 40`.
  - `0x9149`: `01 01 FE`.
  - `0x914C/0x914F`: `01 05 02`.
  - `0x9152`: `04 05 02`.
- Both should live under a diagnostics/service category in the XDF, not under
  normal calibration or likely-tune categories.

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

IES2 / IAW-8F.68 comparison:

- IES2 uses a simpler passive diagnostic sequence for related FIAT IAW ECUs:
  `1200` baud init bytes `0x0F`, `0xAA`, `0xCC`, then `7680` baud one-byte
  request/response queries with the echo discarded.
- The local 8P.40 ROM already shows a richer SCI parser with framing/control
  bytes, challenge/response bytes, service mode `0x21A6`, and the special
  service loop at `0xD80B`. Treat local 8P.40 SCI evidence as authoritative.
- IES2 request bytes are therefore trace and bench-test candidates, not proven
  8P.40 commands.

High-value IES2 request IDs to search in the 8P.40 dispatcher:

| Request byte(s) | IES2 / IAW-8F.68 meaning | 8P.40 tracing target |
| --- | --- | --- |
| `0x01, 0x02` | RPM period, `15000000 / raw16` | Confirm whether diagnostic output exposes `0x00BA`, `0x2036`, or an adjacent RPM value. |
| `0x03, 0x04` | injection duration, `raw16 / 500 ms` | Find a service-visible bridge to fuel pulse-width candidates such as `$00C3/$00BC` or `$2051`. |
| `0x05` | ignition advance, `raw / 2 degrees` | Map any response RAM to the spark command chain around `$2147/$2001/$20E2-$20E5`. |
| `0x06` | MAP, `raw * 4 hPa` | Map any response RAM to the `0x2034` MAP/load-like path. |
| `0x07` | air temperature, `raw - 40 C` | Map any response RAM to likely IAT path `0x200A -> 0x2124 -> 0x2038/0x203A`. |
| `0x08` | coolant temperature, `raw - 40 C` | Map any response RAM to likely CTS path `0x2008 -> 0x2122 -> 0x203C/0x203E`. |
| `0x09` | throttle angle | Search for TPS-related diagnostic output from raw ADC channels. |
| `0x0A` | battery voltage | Search for voltage correction or supply-voltage RAM exposure. |
| `0x0B` | lambda correction | Compare with the `0x200C -> 0x2040 -> 0x2049 -> 0x00C1` candidate path. |
| `0x0C` | idle stepper position | Compare with idle-air / idle-bypass variables around `$2484/$2486/$202B`. |
| `0x0D, 0x0E` | idle integral/proportional terms | Search idle-control state RAM near the current idle actuator path. |
| `0x0F` | trim position, `raw - 128` | Compare with signed/centered trim conventions and adaptive fuel state. |
| `0x17-0x20` | CODRIC bytes | Check whether 8P.40 exposes a compatible spare-part-code request range. |
| `0x2A-0x2F` | ISO bytes | Check whether 8P.40 exposes compatible ISO identification bytes. |
| `0x80-0x91` | active tests / resets | Search carefully near active-test or special-service dispatch, not normal calibration. |

If any request byte maps to a 8P.40 response RAM location, trace that RAM's
producer before applying the IES2 label. The label remains provisional until
the 8P.40 code path, bench behavior, or live data confirms it.

### Special Service Loop `0xD80B`

Confirmed:

`0xAAE0` handles response byte `0x55` by setting `0x21A6 = 0x06`, loading the stack from `0x916A`, and jumping to `0xD80B`.

```asm
AAE0: 0B            SEV
AAE1: 86 06         LDAA #$06
AAE3: B7 21 A6      STAA $21A6
AAE6: BE 91 6A      LDS $916A
AAE9: 7E D8 0B      JMP $D80B
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
6. Search the diagnostic dispatch path for IES2-like request bytes `0x01-0x0F`,
   `0x17-0x20`, `0x2A-0x2F`, and active-test bytes around `0x80-0x91`.
7. Trace service-visible RAM for spark, MAP/load, injection duration, IAT, CTS,
   lambda correction, and idle stepper values back to their producer routines.
8. Trace service buffers `0x2200`, `0x2280`, `0x23EE-0x240A`, and the special service context around `0x2640`.

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
- The code is using the 68HC11 timer/output-compare hardware directly, not
  merely writing an abstract software flag.
- `0xBC12` has a direct reset/setup call at `0xB8F2`. `0xBC90` behaves like a
  second entry or continuation in the same timed-output family rather than a
  widely direct-called public routine.
- `0xBC64` schedules a compare as `TOC4 = 0x242B + 0x20EB`.
- `0xBCAB` reads current `TOC4`, stores it to `0x242D`, adds `0x20ED`, and
  writes the next compare to `TOC4`.
- `0x1023` is written with `0x10` in this block, matching a TFLG1-style
  output-compare flag acknowledge.
- Current evidence identifies this as a timed actuator scheduler. It does not
  yet prove whether the specific channel is ignition, injection, or another
  output without tracing the upstream producers of `0x20EB/0x20ED`.

The repeatable RAM scan gives the current producer/consumer boundary:

| RAM | Script refs | Stores / setup | Loads / math | Meaning so far |
| --- | ---: | --- | --- | --- |
| `0x20EB` | `4` | `0xBB9A`, `0xBD39` | `0xBC67`, `0xBC7A` | scheduled offset word used by `TOC4 = 0x242B + 0x20EB` |
| `0x20ED` | `4` | `0xBB9D`, `0xBD4F` | `0xBCB1`, `0xBCC1` | next scheduled offset word used after reading current TOC4 |
| `0x242B` | `3` | `0xBD1B` | `0xBC64`, `0xBC76` | previous/base compare time |
| `0x242D` | `2` | `0xBCAE` | `0xBCBD` | captured/current compare time |
| `0x20BC` | `2` | `0xBAB1`, `0xBBEC` | none in simple scan | output-state byte, exact actuator unknown |
| `0x242F` | `5` | `0xBAB5`, `0xBAC6` | `0xBABE`, `0xBB49`, `0xBB53` | adjacent scheduler/state word |
| `0x2431` | `2` | `0xBB68`, `0xBB79` | none in simple scan | adjacent state byte/flag |

This still points at a timed actuator family rather than a final fuel proof.
The next proof step is to trace the values written at `0xBB9A/0xBB9D` and
`0xBD39/0xBD4F` back to any fuel-time or spark-angle calculations.

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
| Vehicle speed sensor | `B33` | Listed in some generic references, but current firmware evidence does not tie it to `0x00D4 -> 0x2044`. |
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

## External Research Checklist

The integrated deep-research report is now treated as a secondary lead list,
with verified public URLs recorded in
`EVIDENCE.md`.

That external note also records a safe BTDig/public-index search. BTDig did not
produce a usable public XDF, but it did expose filenames and identifiers such as
`106 Rallye 1.3 100hp Magneti Marelli IAW 8P.40.ORI.BIN`, `Citroen Xantia 1.6L
8v iaw 8p.40 (607C).std`, `PEUGEOT 106 1.6 IAW 8P.40 total.zip`, and forum
terms `106RALL2`, `16143.124`, and `9620697280`. These are search leads only,
not local offset evidence.

The active XDF labels the signed `24x9 @ 0x802B` and `24x9 @ 0x8103` tables as
likely IAT/RPM fuel correction candidates with the `0x92D9 -> $2038` X path and
confirmed `0x929E` RPM Y labels. Later scaling displays the firmware-inverted
`-40..120 C` temperature sites. It also adds raw, percent, and multiplier
views for signed fuel quantity trims at `0x821C`, `0x8318`, `0x81F8`, `0x82F4`,
and `0x83F0`; adds warmup/transient fuel views; expands lambda/closed-loop
calibration views around `0x9000-0x90EF`; separates ignition main/special/
correction and ignition output/retard categories. XDF v0.42 removes the old
`0x802E`, `0x80EB`, `0x81A8`, `0x80F1`, and broad raw duplicate probe views
from the active table tree; they remain historical evidence only. The 2D
spark-bank load labels remain rounded display-only `0-100 kPa` values.

Current cross-check status:

| Public map family | Current local status |
| --- | --- |
| Main fuel multiplier | No pure VE/base table proven yet. `$821C/$8318` are the strongest signed fuel quantity trim views, with `$81F8/$82F4` as guarded low-RPM 4x9 slices and `$83F0` as RPM-only bypass; `$00C1 -> $00C3 -> $00BC` is pulse width/duration, while `$87B1 -> $00BE -> $21C6` is event phase. |
| Spark high/low octane | `0x8A69` and `0x8B41` are code-confirmed banked spark lookups and likely high/default vs low/alternate. |
| WOT spark | `0x8C19` is a code-confirmed RPM-only spark bypass vector and likely WOT/RPM-only spark. |
| Spark correction/minimum/idle | Not yet matched to exact local offsets. |
| Dwell | Not yet matched to an exact local offset. |
| Air density / VE correction | `0x802B/0x8103` are signed likely IAT/RPM fuel correction candidates; `0x9187` is code-confirmed upstream load-model related. A pure VE/base table is still not proven. |
| RPM axis | `0x929E` is code-confirmed. |
| Load/MAP axis | `0x2034` is code-confirmed as a load/MAP-like axis. The XDF spark views display it as rounded integer `0-100 kPa`, but exact ADC transfer remains provisional. |
| RPM limiter | `0x879E` / `0x87A0` remain likely limiter thresholds from code reference and MOD2 deltas. |

No XDF labels should be promoted from external-source names alone. Public
sources can guide search priority, but exact map naming still needs local code,
MOD2 delta, axis, or live-behavior proof.

## Static Fuel-Path Proof Pass 2026-05-25

This pass added analyzer snapshots in the generated-analysis block of
`EVIDENCE.md`, checksum tooling under `tools/iaw8p40_checksum.py`, and the
confidence matrix in `EVIDENCE.md`. The important firmware result is still conservative:
main fuel table is still not found, but `$00C1/$00C3` are now the strongest
fuel/charge time-path candidates. The old `0x802E` fuel-side candidate is now a
legacy misaligned slice inside the signed `0x802B` table.

Direct and indirect `0x802E` evidence:

- Literal table-base search is insufficient. The only Peugeot `0x802E`
  word-pattern hit is still the known false positive near `0xC620`, where
  aligned decoding is an immediate clamp sequence, not a table-base load.
- The focused helper-call scan still finds no `B2D6`/`B2AB` helper call with a
  nearby `0x802E`, `0x80EB`, or `0x81A8` table literal.
- The known Peugeot helper calls remain tied to other proven structures:
  `0x8A69`, `0x8B41`, `0x8C19`, `0x9187`, `0x9291`, `0x929E`, and `0x869A`.
- No current startup-copy, calibration-overlay, descriptor-table, or constructed
  base path has been proven for a main fuel table.
- `0x80EB` and `0x81A8` remain legacy/debug views because their MOD2 deltas
  are overlap evidence only and the immediate-base scan finds no standalone
  Peugeot code reference.

Injection/output scheduling trace:

- Backward tracing from the timer/output-compare block identifies scheduler
  state, not a fuel-table consumer.
- `0x20EB` stores at `0xBB9A` and `0xBD39`; loads/math at `0xBC67` and
  `0xBC7A`.
- `0x20ED` stores at `0xBB9D` and `0xBD4F`; loads/math at `0xBCB1` and
  `0xBCC1`.
- `0x242B` is stored at `0xBD1B` and consumed at `0xBC64/0xBC76`.
- `0x242D` is captured at `0xBCAE` and consumed at `0xBCBD`.
- `0x20BC`, `0x20BD-0x20C5`, `0x242F`, and `0x2431` are adjacent timed-output
  state bytes/words, but this pass does not connect them to `0x802E`.

ADC/load trace:

- `0x1030-0x1034` remain the ADC control/result register family.
- `0x2007-0x200E` and `0x2013` remain raw or lightly processed sensor RAM.
- `0x00D0 -> 0x00CE -> 0x2034` remains the best load/air-charge chain.
- `0x2034` is strong enough to label as load/MAP-like, but exact pressure
  scaling and sensor channel assignment remain unproven.

Conclusion:

- Keep XDF `0.21` labels conservative: the `Confirmed` category is active, but
  spark MAP/load labels remain rounded integers rather than fractional kPa.
- Do not add `raw / 2.55` as normal tuning scaling.
- Do not rename `0x802E` to main fuel until a Peugeot-local consumer reaches
  injection pulse width, fuel time, lambda correction, air-charge math, or fuel
  scheduling.

## Current Functional Picture

Best current model:

1. Reset configures 68HC11 hardware, stack, ADC/timer registers, and RAM.
2. Startup copies/validates the calibration window.
3. ADC channels are sampled into RAM `0x2007-0x200E`.
4. Timer input capture builds period-like value `0x00BA`.
5. Period-like `0x00BA` is converted into RPM-derived axes:
   - `0x2036` via `0xB3B9`.
   - `0x00D4` via inverse-period math.
   - `0x2044` via clamp/divide from `0x00D4`.
6. Load-like axis `0x2034` is built from `0x00CE`.
   - One producer path sets `0x00D0` from the `0x9187` lookup and then stores
     `0x00CE = 0x00D0 << 2`.
7. The main loop runs a fixed sequence of state machines, diagnostics/fault logic, map calculations, and output scheduling.
8. Important maps use common axes:
   - `0x2034` and `0x2036` for several 2D tables.
   - `0x2044` for RPM-indexed 1D curves.
9. Output compare routines schedule timed hardware events through `0x101C` and acknowledge flags at `0x1023`.
10. The checksum routine runs as a runtime integrity service and updates `0x0099 bit 0x04`.

## High-Priority Unknowns

Resolved or downgraded in this pass:

1. `0x20B1` is now named `spark_bank_selector_state`.
   - `nonzero -> 0x8A69` likely high-octane/default spark.
   - `zero -> 0x8B41` likely low-octane/alternate spark.
   - It is still worth tracing knock/fallback code, but it is no longer an
     unnamed high-priority variable.
2. `0x00D0 -> 0x00CE -> 0x2034` is now partly named.
   - `0x00D0`: `load_model_byte / air-charge byte`.
   - `0x00CE`: `raw_load_or_aircharge_word`.
   - `0x2034`: `load/MAP-like_axis_8p8`.
   - Remaining unknown: exact physical transfer from ADC/TPS/MAP and live units.
3. `0x2147` is now a spark-angle accumulator/intermediate command.
   - It receives the banked spark-map/WOT-vector result plus corrections.
   - It feeds byte outputs including `0x2001` and `0x2148`.
   - Remaining unknown: exact conversion from these command bytes into the
     timer/output-compare scheduler.
4. `0x58F2` / `0x5982` are now separated from fuel/spark maps.
   - `0x58F2` consumes 3-byte descriptor triples at `0x9131-0x9167`.
   - `0x5982` maps event IDs through `0x55A0` and manages queue
     `0x004B-0x005B`.
   - Remaining unknown: external meaning of each event ID and state block.
5. Diagnostics are confirmed as a real SCI service protocol.
   - SCI registers `0x102B-0x102F`, service mode `0x21A6`, handshake responses,
     and special loop `0xD80B` are documented.
   - Remaining unknown: full command table and external protocol naming.
6. Output compare is confirmed as a 68HC11 timed-output scheduler.
   - `0x101C` and `0x1023` are timer compare/flag registers.
   - `0x20EB/0x20ED` and `0x242B/0x242D` are schedule words.
   - Remaining unknown: actuator assignment and upstream producers for the
     compare offsets.
7. ADC channels are matrixed but not fully identified.
   - `0x2007-0x200E` and `0x2013` have source/result and consumer notes.
   - Remaining unknown: exact sensor-to-channel mapping for MAP, TPS, IAT,
     CTS, lambda, battery, and any other analog inputs.

## Air-Density Screenshot Search

A public TunerPro screenshot labelled `Air density correction factor by
temperature` was tested as a local map lead. The visible table is `24x9`, with
RPM-like rows from about `750` to `9004` and temperature columns
`-5, 10, 20, 30, 40, 50, 60, 70, 80`. Displayed values are factor-like, roughly
`0.10-1.11`.

Search result:

- No exact match was found in `M27C512_original.BIN`,
  `1.3L_8V_IAW8P40_Stok.bin`, or `1.3L_8V_IAW8P40_MOD2.bin`.
- The search tried normal, reversed-row, reversed-column, row/column-reversed,
  and transposed orientations.
- Candidate equations tried included `raw / 230`, `raw / 100`, `raw / 128`, and
  `raw / 200`.
- With `raw / 230`, the screenshot's first row would encode approximately
  `115 104 83 62 48 51 46 46 44`; local `0x9187` begins
  `186 199 220 227 247 252 254 254 254`, so it is not the same data.
- The best loose numeric matches are misaligned offsets inside the
  code-confirmed spark-bank region around `0x8A9C`; those are false positives,
  not air-density tables.

Current conclusion:

- The screenshot is useful external evidence that a public IAW8P40 XDF family
  may contain an RPM-by-temperature air-density correction table.
- It does not confirm a local offset in this Peugeot 106 1.3 Rallye dump.
- `0x9187` remains the nearest functional local load/air-charge model candidate,
  but it must not be renamed as air density until the IAT/CTS ADC path reaches
  a table consumer.

Next best high-priority work:

1. Trace writes and consumers of `0x20EB/0x20ED` back from `0xBC12/0xBC90`.
2. Trace `0x2001` and `0x2148` forward to the timer conversion path.
3. Decode the SCI command dispatch around `0xA7D8-0xAFxx` and status pointer
   tables around `0x680F-0x6835`.
4. Decode event IDs `0x00-0x11` by following each `0x58F2` caller's sensor
   thresholds and fallback behavior.
5. Continue fuel proof by finding a code consumer for the MOD2-touched
   `0x802E-0x81D4` candidate and tying it to pulse-width or injection timing.
6. Trace IAT and CTS ADC consumers into correction logic, looking specifically
   for a `24x9` RPM-by-temperature table or a temperature axis/vector that could
   explain the public air-density screenshot.

## Editing Caution

At this stage, only table structure and code usage are being confirmed. The spark labels are strong working names because values, selector behavior, and the `0x2147` accumulator path all line up, but most other physical labels such as fuel, throttle, exact MAP scaling, coolant, air temperature, enrichment, and actuator assignment should not be finalized in the XDF until downstream logic or live behavior confirms them.
## Detailed Disassembly Notes
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
- Same-family alignment warning: these are Peugeot stock/MOD2 offsets.
  `RALLY13.ORI` carries the same stock spark bundle shifted by `+0x1B`
  (`0x8A84`, `0x8B5C`, `0x8C34`). `Peug.106Rally.org.bin` keeps the Peugeot
  offsets but heavily alters the two 2D spark banks while leaving the WOT
  vector unchanged.

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
- It is best named a MAP/load-style normalized axis. The XDF spark views
  display it as rounded integer `0-100 kPa`; exact ADC channel and transfer
  remain open.

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
- It is derived from RPM-like `RAM 0x00D4`.
- It is clamped at `0x1200`, giving integer index `18`.
- The code path maps integer sites to 400 rpm steps: `0, 400, 800, ... 7200`.
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

## Axis Inventory and Current Names

This table keeps the XDF labels, code notes, and physical guesses aligned.
Confirmed means the axis or table lookup is confirmed from instruction flow;
physical units remain qualified where the transfer path is still incomplete.

| Axis/source | Current name | Producer / calibration | Confirmed consumers | Physical confidence |
| --- | --- | --- | --- | --- |
| `0x2036` | `rpm_axis_8p8` | Built by `0xB3B9` from period-like `0x00BA` using `0x929E-0x92CD`, count `0x92CE = 0x18` | `0x8A69`, `0x8B41`, `0x8C19`, `0x9187`, `0x85BA`, `0x869A` | High; `15000000 / period` gives the displayed RPM labels. |
| `0x2034` | `MAP/load_kPa_estimate_axis_8p8` | `0x41A1-0x41AD` from clamped/doubled `0x00CE`, fed by `0x00D0` and load-model/state paths | `0x8A69`, `0x8B41`, `0x85BA`, `0x87B1`, `0x888E`, `0x8A0A` | Medium-high MAP/load; XDF displays spark labels as rounded integer `0-100 kPa`, exact ADC transfer unproven. |
| `0x2044` | `rpm_400rpm_site_axis_8p8` | Derived from RPM-like `0x00D4`, clamped to `0x1200` | `0x89C7-0x8A67` vector family, `0x9073`, `0x8E6F/0x8EC7/0x8F1C/0x8F71` | High structure; sites are `0-7200 rpm` in 400 rpm steps. Not a vehicle-speed axis. |
| `0x2046` | `secondary_transient_state_axis_8p8` | Built in the same normalized-axis runtime block as `0x2036` and `0x2044` | `0x8A0A` | Low-medium; exact source still needs tracing. |
| `0x9291-0x9299` | `9_point_helper_breakpoint_vector_A` | EPROM vector used by `0xB383`, count/stride byte `0x929A = 0x09` | `0x9187`, `0x9073`, helper calls around `0x41E0` | High structural, physical units provisional. |
| `0x92CF-0x92D7` | `likely_CTS_ADC_breakpoints_B` | NTC-matching ADC vector `12,20,34,57,93,142,191,227,246`, count `0x92D8 = 0x09`; shared output vector `0x400E` is `deg C + 40` | `0x2008 -> 0x2122 -> 0x203C/0x203E`; best current CTS/coolant path by consumers. | High NTC structure; exact pin/bench proof still pending. |
| `0x92D9-0x92E1` | `likely_IAT_ADC_breakpoints_A` | Same NTC-matching ADC vector, count `0x92E2 = 0x09`; shared output vector `0x400E` is `deg C + 40` | `0x200A -> 0x2124 -> 0x2038/0x203A`; X axis for `0x802B/0x8103`. | High NTC structure; best current IAT/air-temperature path by consumers. |
| `0x2014` | `candidate_sensor_or_state_axis` | Producer not fully named | `0x869A` first axis | Low; keep provisional. |

Current confirmed consumer map:

| Table/vector | Axes | Current role |
| --- | --- | --- |
| `0x8A69` | `0x2034` MAP/load kPa estimate by `0x2036` RPM | Likely high-octane/default spark bank; in XDF `Confirmed` category with rounded integer MAP/load labels. |
| `0x8B41` | `0x2034` MAP/load kPa estimate by `0x2036` RPM | Likely low-octane/alternate spark bank; in XDF `Confirmed` category with rounded integer MAP/load labels. |
| `0x8C19` | `0x2036` RPM only | Likely WOT/fallback spark vector; in XDF `Confirmed` category. |
| `0x802B` | likely IAT axis `0x92D9 -> 0x2038` by `0x2036` RPM | Signed `24x9` fuel correction table; XDF labels display firmware-inverted `-40..120 C`; output `0x204A`, exact sensor pin still provisional. |
| `0x8103` | likely IAT axis `0x92D9 -> 0x2038` by `0x2036` RPM | Paired signed `24x9` fuel correction table; XDF labels display firmware-inverted `-40..120 C`; output `0x204D`, exact sensor pin still provisional. |
| `0x9187` | `0x9291`-derived axis by `0x2036` RPM | Load / air-charge model factor that can seed `0x00D0 -> 0x00CE -> 0x2034`. |
| `0x85BA` | high-load transform / load by `0x2036` RPM | High-load pulse extension / duration-support candidate; output `0x2063` is doubled into the `0x00C3` path. |
| `0x87B1` | `0x2034` MAP/load by `0x2036` RPM | Injector/event phase offset; stock-zero output updates `0x00BE -> 0x21C6` before OC1 schedules `TOC1 = $00B8 + $21C6`; changes timing/phase, not fuel quantity. |
| `0x888E` | `0x2034` MAP/load by `0x2036` RPM | Idle-air / idle-bypass target candidate stored to `0x2484`, later combined with likely CTS vector `0x8970` and shaped toward `0x202B`. |
| `0x8A0A` | `0x2034` MAP/load by `0x2046` secondary transient/state axis | Code-confirmed `5x5` table. |
| `0x869A` | `0x2014` candidate sensor/state axis by `0x2036` RPM | Code-confirmed `24x9` parent table stored to `0x2391`. |
| `0x9073` | `0x9291`-derived axis by transformed `0x2044` | Closed-loop ramp/target `11x9` table compared with `$243C`.  |
| `0x8E6F/0x8EC7/0x8F1C/0x8F71` | `0x00D0`-derived axis by `0x2044` | Adaptive trim dynamics cluster feeding `$24AB/$24AF/$24AC/$24AD` into the closed-loop/adaptive state machine. |

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
This gives a 400 rpm X axis: `0, 400, 800, ... 7200 rpm`.

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
- Physical role remains provisional, but the axis is RPM-derived. The current
  best label is per-event retard/gain candidate, not vehicle speed or fuel quantity.

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
| `0x89C7` | `1x19` | `0x20E7 -> 0x20EB` | no | Ignition phase / first-edge factor candidate |
| `0x89DA` | `1x19` | `0x20E8 -> 0x20ED` | no | Ignition width / dwell-window factor candidate |
| `0x89F3` | `1x19` | `0x20BC` | yes | Per-event retard/gain candidate |
| `0x8A27` | `1x19` | `0x20DD` | no | Constant `0x06` curve |
| `0x8A3A` | `1x19` | `0x20D4` | no | Followed by scalar/sentinel bytes `0x8A4D-0x8A51` |
| `0x8A52` | `1x19` | `0x20E6` | no | Per-event retard/correction bucket cap |

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
`0.00-1.10`, similar in range to the screenshot's factor maps. The
XDF now includes this as `Load / Air-Charge Model Factor 24x9 @ 0x9187`. This is
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
engineering pass. It loads the six available 64 KiB images:

- `M27C512_original.BIN`.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin`.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin`.
- `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin`.
- `Peug.106Rally.org.bin`.
- `RALLY13.ORI`.

The script reports hashes, checksum words, reset vectors, diff regions,
candidate-table statistics, same-offset comparisons, immediate table-base
byte-pattern hints, helper-call sites, and RAM/register references. It does not
modify BIN or ORI files.

Confirmed by the script:

| BIN | SHA256 | Checksum pair | Byte sum | Valid | Prefix zero | Hole zero | Reset |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Peugeot stock | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xB59A` | Yes | Yes | Yes | `0xB800` |
| Peugeot `Stok` | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xB59A` | Yes | Yes | Yes | `0xB800` |
| Peugeot MOD2 | `D3E4A451EDD236104C79190372FA1BE1E45AAD09398EABE6F7B7E1479D810855` | `0x47BE/0xB841` | `0xB841` | Yes | Yes | Yes | `0xB800` |
| Xantia 607C | `05470171F86B8525F962F13370846E6D4A1A6FBABC0107D90E1497F88A5DFE89` | `0x9F83/0x607C` | `0x607C` | Yes | Yes | Yes | `0xB800` |
| `Peug.106Rally.org.bin` | `FE7D7953298C575BC08E4C301CE7E911BCE082D1515E1FCA68509A2C980E0141` | `0x4A65/0xB59A` | `0xE160` | No | No | Yes | `0xB800` |
| `RALLY13.ORI` | `5F4EF679F6D262502D0023CF9F441111BC5C694CD4E281394AD0FCBA810854CF` | `0x7A41/0x85BE` | `0x85BE` | Yes | Yes | Yes | `0xB800` |

Diff summary:

- Peugeot stock vs folder `Stok`: `0` differing bytes.
- Peugeot stock vs MOD2: `479` differing bytes in `87` contiguous regions.
- Peugeot stock vs Xantia 607C: `42021` differing bytes in `1038`
  contiguous regions.
- Peugeot stock vs `Peug.106Rally.org.bin`: `16513` differing bytes in `27`
  contiguous regions. This file keeps the Peugeot checksum words but has byte
  sum `0xE160`, so it is checksum-invalid and should be treated as suspicious
  comparison evidence.
- Peugeot stock vs `RALLY13.ORI`: `43767` differing bytes in `954`
  contiguous regions. It is checksum-valid and reset-compatible, so it is a
  useful same-family comparison image, not a Peugeot offset authority.

For the corrected signed `0x802B` and `0x8103` fuel/charge correction candidates, MOD2
changes `75 / 216` and `72 / 216` cells respectively. These tables use the
likely IAT `0x92D9 -> $2038` path with firmware-inverted temperature labels
`-40..120 C`, the `0x929E` RPM axis into `$2036`, and output `$204A/$204D`.
`$204A` feeds the `$204B -> $00C1` fuel/charge accumulator candidate, while
`$204D` feeds the `$204E/$204F` blend path. The old `0x802E` view is a
misaligned slice, not a primary fuel/VE candidate.

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

## `0x802B-0x81DA` Region

The corrected code-referenced view of this MOD2-touched region is two signed
fuel/charge correction candidates: `24x9 @ 0x802B` and `24x9 @ 0x8103`. Their
exact sensor pin identity and final injector output channel remain
provisional.

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

- `0x802B`: signed `24x9`; X uses the likely IAT
  `0x92D9 -> $2038` path and displays `-40,-20,0,20,40,60,80,100,120 C`;
  Y uses `0x929E` RPM labels; output `$204A` feeds `$204B -> $00C1`.
- `0x8103`: paired signed `24x9` with the same axes; output `$204D` feeds the
  `$204E/$204F` blend path.
- `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1` are retained as legacy alignment
  probes only. Do not tune them as VE or main fuel.
- A pure VE/base fuel table is still not proven, but `$821C/$8318` are now the
  strongest signed fuel quantity trim candidates. `$00C1 -> $00C3 -> $00BC` is
  the strongest fuel pulse-width/event-width path, while `$87B1 -> $00BE ->
  $21C6` is event phase. OC1 schedules `TOC1 = $00B8 + $21C6`, OC3/PA5 behaves
  like the timed pulse-output path, and exact driver/pin plus tick-to-ms/degree
  proof remains hardware-level.

## Static Fuel-Path Proof Pass 2026-05-25

New support artifacts:

- The generated-analysis section in `EVIDENCE.md` now stores analyzer snapshots for overview, diff
  regions, table stats, helper calls, RAM/register refs, and trace notes.
- `EVIDENCE.md` summarizes confidence and next proof requirements for
  the important offsets.
- `tools/iaw8p40_checksum.py` adds safe checksum calculation and repair-copy
  tooling. It does not modify source BIN files.

Static proof result:

- No Peugeot-local code path has yet proven a main fuel base table. The newest
  trace does identify `$00C1/$00C3` as strong fuel/charge time-path candidates,
  but final injector hardware assignment remains open.
- The only immediate `0x802E` word-pattern hit is still the false positive at
  the aligned `0xC61A-0xC623` clamp sequence.
- The helper-call scan does not find `0x802E`, `0x80EB`, or `0x81A8` near the
  known Peugeot interpolation helpers.
- `0x802E` is now understood as a misaligned slice inside `0x802B`, not a real
  table base.

Output/injection path boundary:

| RAM | Current trace result | Meaning |
| --- | --- | --- |
| `0x20EB` | stores `0xBB9A`, `0xBD39`; math/loads `0xBC67`, `0xBC7A` | scheduled output offset |
| `0x20ED` | stores `0xBB9D`, `0xBD4F`; math/loads `0xBCB1`, `0xBCC1` | next scheduled output offset |
| `0x242B` | store `0xBD1B`; loads `0xBC64`, `0xBC76` | base/previous compare time |
| `0x242D` | capture `0xBCAE`; load `0xBCBD` | captured/current compare time |
| `0x20BC` | stores `0xBAB1`, `0xBBEC` | timed-output state byte |
| `0x242F` | stores `0xBAB5`, `0xBAC6`; math/loads `0xBABE`, `0xBB49`, `0xBB53` | adjacent scheduler/state word |
| `0x2431` | stores `0xBB68`, `0xBB79` | adjacent state byte/flag |

This identifies the scheduler boundary and now has a stronger bridge from
`$00C3 -> $00BC -> $1016`, but it does not yet identify the actuator as
injection or make any legacy `0x802E` view a standalone table.

ADC/load boundary:

- ADC control/result register refs are concentrated around `0x1030-0x1034`.
- Raw/processed sensor RAM remains `0x2007-0x200E` plus `0x2013`.
- The load chain remains `0x00D0 -> 0x00CE -> 0x2034`.
- Exact MAP/TPS/CTS/IAT/lambda/battery channel names remain unproven.

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
AAE0: 0B            SEV
AAE1: 86 06         LDAA #$06
AAE3: B7 21 A6      STAA $21A6
AAE6: BE 91 6A      LDS $916A
AAE9: 7E D8 0B      JMP $D80B
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

`IAW8P40_peugeot106_firstpass.xdf` version `0.21` restores the `Confirmed` category/category 10 memberships for the code-confirmed spark maps and supporting axes after TunerPro RT loaded the rounded integer labels successfully. The 2D spark banks keep rounded display-only `0-100 kPa` MAP/load x-axis labels, raw diagnostic/service views for code-confirmed descriptor data, confidence-tier labels for likely fuel/correction candidates, public-index alignment probes, TunerPro-native signed display for the `0x80F1` adjacent candidate, same-family spark alignment caveats, and a deduplicated table tree where each major structure has one best inspection entry.

Previously added in `0.4`:

- `Code-Confirmed Signed Offset Byte @ 0x8A68`
- code-confirmed spark-bank raw views at `0x8A69` and `0x8B41`, later
  condensed into the retained scaled likely spark entries
- `Per-event Correction Scalars 1x6 @ 0x89ED`
- `Per-event Retard/Gain Candidate 1x19 @ 0x89F3`

New in `0.5`:

- code-confirmed raw `24x9 @ 0x9187`, later condensed into the retained
  `Load / Air-Charge Model Factor 24x9 @ 0x9187`
- `Ignition Phase Factor Candidate 1x19 @ 0x89C7`
- `Ignition Width/Dwell Factor Candidate 1x19 @ 0x89DA`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A27`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A3A`
- `Per-event Retard Cap Vector 1x19 @ 0x8A52`
- `Code-Referenced Scalar Block 1x5 @ 0x8A4D`
- `Code-Referenced Scalar Block 1x3 @ 0x8A65`
- `High-Load Fuel Pulse Extension / Duration Support 24x5 @ 0x85BA`
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
- `AXIS_TEMP_B / Likely CTS ADC Breakpoints 1x9 @ 0x92CF`.
- `AXIS_TEMP_A / Likely IAT ADC Breakpoints 1x9 @ 0x92D9`.
- `VEC_TEMP_RAW_OUTPUT_C_PLUS_40_9 @ 0x400E`.
- `Load / Air-Charge Model Factor 24x9 @ 0x9187`, displayed as `raw / 230`.

New in `0.7`:

- `Code-Confirmed 2D Table 24x9 @ 0x869A`.
- `Injector/Event Phase Offset 24x9 @ 0x87B1`.
- `Idle Air / Idle Bypass Target 24x9 @ 0x888E`.
- `Closed-Loop Ramp / Target Table 11x9 @ 0x9073`.
- `Adaptive Trim Dynamics A 17x5 @ 0x8E6F`.
- `Adaptive Trim Dynamics B 17x5 @ 0x8EC7`.
- `Adaptive Trim Timer 17x5 @ 0x8F1C`.
- `Adaptive Trim Hold 17x5 @ 0x8F71`.

Alignment notes for `0.7`:

- The old visual `0x86DB` candidate is inside the code-confirmed `0x869A`
  parent table.
- The old visual `0x88CD` candidate is inside the code-confirmed `0x888E`
  parent table.
- The `0x8E6F/0x8EC7/0x8F1C/0x8F71` cluster is exposed as bounded `17x5`
  views because the table starts and ends line up cleanly at those boundaries.

New in `0.8`:

- likely spark advance high/default `24x9 @ 0x8A69` x-axis labels changed from
  placeholder `0-8` to provisional load/MAP-like labels. In XDF `0.21`, these
  are displayed as rounded integers `0, 13, 25, 38, 50, 63, 75, 88, 100 kPa`.
- likely spark advance low/alternate `24x9 @ 0x8B41` received the same x-axis labels.
- This is based on the code-confirmed `0x2034` 8.8 axis range clamped near
  `0x0800`. The exact ADC transfer is still not proven.

New in `0.9`:

- Added external sensor-reference documentation in
  `EVIDENCE.md`.
- Updated the likely spark-bank descriptions to tie the `0x2034` x-axis labels
  to Peugeot 106 TU2J2/MFZ 100 kPa MAP-sensor evidence.
- The best current interpretation for spark-map x-axis labels is provisional
  MAP/load displayed as rounded integer `0-100 kPa`, pending ADC transfer
  confirmation.

New in `0.10`:

- Renamed the scaled spark views as:
  - `Likely Spark Advance High Octane / Default 24x9 @ 0x8A69`.
  - `Likely Spark Advance Low Octane / Alternate 24x9 @ 0x8B41`.
- Kept the `raw / 2` degree scaling. XDF `0.21` now displays the provisional
  MAP/load axis as rounded integer `0-100 kPa`.
- Added the MOD2-backed `0x9187` load/air-charge model factor view.

New in `0.21`:

- Restored the `Confirmed` category/category 10 memberships after TunerPro RT
  loaded XDF `0.20` successfully with rounded integer labels.
- Moved the code-confirmed spark tables `0x8A69`, `0x8B41`, and `0x8C19`, plus
  supporting axes `0x929E`, `0x9291`, and the temperature breakpoint family
  at `0x92CF/0x92D9/0x400E`, into `Confirmed`.
- Kept the two 2D spark-bank x-axis labels as rounded display-only
  `0-100 kPa` MAP/load labels. Runtime axis source remains `0x2034`; exact ADC
  transfer remains open.

New in `0.11`:

- Added category `Diagnostics / Service Data`.
- Added raw diagnostic/event view `0x55A0-0x55B1` for the `0x5982` event-code
  table used by IDs `0x00-0x11`.
- Added raw state descriptor view `0x9131-0x9169` as `19x3` triples for the
  `0x58F2` descriptor subsystem.
- No `.bin` files were edited.

New in `0.12`:

- Removed the combined `47x9 @ 0x802E` view.
- Historical note: `0x802E-0x8105` was once promoted as an upper `24x9` tune
  candidate, but later targeted disassembly superseded this with the signed
  `0x802B/0x8103` correction model.
- Replaced the bad `0x8106-0x81D4` lower adjacent slice with
  `0x80F1-0x81D1` as a signed `25x9` tune/correction candidate.
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
  - historical `0x802E` and `0x80F1` fuel-side hypotheses, now superseded by
    the signed `0x802B/0x8103` correction model
  - `Per-event Retard/Gain Candidate 1x19 @ 0x89F3`
  - `Load / Air-Charge Model Factor 24x9 @ 0x9187`
- Removed the misleading legacy `0x89F2` and `0x91D9` views from the normal XDF
  tree. Screenshots alone are no longer enough to keep an active view when later
  code proves that it mixes structures or starts on a misaligned row.
- Historically added a public-index lead category; that category was retired
  when XDF v0.42 moved the active tree to subsystem categories.
- Added raw BTDig/Digital-Kaos-derived alignment probe views:
  - `21x9 @ 0x802E`
  - `21x9 @ 0x80EB`
  - `5x9 tail @ 0x81A8`
- These probes tested the public claim of two 9-load-site, about-21-speed-site
  fuel/correction maps. They are now legacy alignment context only.
- Updated the `0x879E/0x87A0` limiter descriptions to mention the public
  `21000000 / value` formula as a lead only; the retained scaling remains the
  locally supported `15000000 / period`.

New in `0.26`:

- Added the likely IAT `0x92D9 -> $2038` X axis and `0x929E` RPM Y labels to
  signed `24x9 @ 0x802B` and `24x9 @ 0x8103`; later scaling displays the
  firmware-inverted `-40..120 C` temperature sites.
- Marked `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1` as legacy alignment probes.
- Main fuel base table remains unconfirmed. `$00C1/$00C3` are the strongest
  fuel/charge time-path candidates until the final injector output is proven.

External evidence integration:

- Added `EVIDENCE.md` as a public-source and
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
- `0x9187` remains the closest functional load/air-charge model candidate, but
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
   - trace `$00C3/$00BC` through the output scheduler and prove which actuator
     channel is driven.
   - keep searching backward from the fuel/charge path for the still-unfound
     main fuel base table.
5. Keep tracing table outputs:
   - `0x20BC`, `0x20BD-0x20C5`, `0x242F`, `0x2431`.
   - `0x2063`, `0x2391`, `0x00BE`, `0x2484`, `0x243C`, `0x24AB`,
     `0x24AC`, `0x24AD`, and `0x24AF`.
## First-Pass Offset Markup
BIN analyzed:

- `E:\Projects\E78_14T\sample_tunes\peugeot106\M27C512_original.BIN`

High-confidence observations:

- File size is `0x10000` (`65536`) bytes, consistent with a full `27C512`.
- `0x0000-0x3FFF` is entirely zero.
- Real ROM content starts at `0x4000`.
- The last 16 bytes contain valid-looking `68HC11` vectors.
- This strongly suggests the EPROM contains executable firmware plus calibration data.

External evidence note:

- `EVIDENCE.md` now records the checked public
  sources from the deep-research report integration. Public material supports
  the Peugeot 106 1.3 Rallye / IAW 8P.40 application, `27C512` media, generic
  8P-family sensor/pin context, OldSkullTuning's public map-family checklist,
  and the 100 kPa MAP clue. It does not publish exact map offsets, so the
  offsets below remain local reverse-engineering findings.

Repeatable analysis note:

- `tools/iaw8p40_analyze.py` is a read-only script that loads all six
  available 64 KiB images and emits Markdown-friendly hashes, checksum words,
  reset vectors, diff regions, table stats, helper-call hints, and RAM/register
  references.
- Current script pass confirms:
  - Peugeot stock and folder `Stok` are byte-identical.
  - Peugeot stock checksum pair: `0x4A65/0xB59A`.
  - MOD2 checksum pair: `0x47BE/0xB841`.
  - Xantia 607C checksum pair: `0x9F83/0x607C`.
  - `RALLY13.ORI` checksum pair: `0x7A41/0x85BE`.
  - `Peug.106Rally.org.bin` stores `0x4A65/0xB59A`, but its byte sum is
    `0xE160`, so checksum validation fails.
  - All six available images use reset vector `0xB800`.
  - Peugeot stock vs Xantia 607C differs by `42021` bytes, so Xantia remains
    same-family comparative support only.
  - Peugeot stock vs `Peug.106Rally.org.bin` differs by `16513` bytes and the
    public file has a nonzero `0x0000-0x3FFF` prefix, so it is suspicious
    comparative evidence only.
  - Peugeot stock vs `RALLY13.ORI` differs by `43767` bytes; it is
    checksum-valid same-family comparison evidence, not Peugeot offset proof.

Important vector values:

- `0xFFF8 = 0xB948`
- `0xFFFA = 0xB93D`
- `0xFFFC = 0xB942`
- `0xFFFE = 0xB800` likely reset vector

Priority candidate calibration areas:

- `0x5100-0x53FF`
- `0x8200-0x83FF`
- `0x8600-0x8900`
- `0x8E00-0x90FF`
- `0xB500-0xB5FF`

Why these were chosen:

- They are markedly lower-entropy than surrounding code-like regions.
- Several contain smooth low-value gradients, repeated constants, or compact structured byte patterns.
- `0x8800` is especially interesting and should be one of the first areas to inspect for small maps or correction tables.

What the XDF contains:

- Raw 16x16 byte views for the most promising regions.
- Scalar views for the 68HC11 vectors.
- Conservative descriptions remain the default. The spark bank pair now has
  likely octane/default labels because the selector path and high-load timing
  comparison both support that interpretation; fuel/correction candidates remain
  explicitly unconfirmed.
- Diagnostic/service data is now separated from tune maps. The `0x55A0`
  event-code table and `0x9131` state descriptor triples are exposed as raw
  inspection views only.
- Added compact views for packed structures:
  - the old `0x88CA` as `8x19` view has now been removed because it was a
    misleading off-axis slice inside the code-confirmed `0x888E` parent table
  - `0x8880` as `16x5`
- Added better-aligned row-based views:
  - `0x88CD` as a historical `17x9` slice only
- Added code-confirmed disassembly views:
  - `0x85BA` as `24x5`
  - `0x8A0A` as `5x5`
  - `0x8A69` and `0x8B41` as banked `24x9`
  - `0x9187` as `24x9`
  - the `0x2044`-indexed vector family at `0x89C7`, `0x89DA`, `0x89F3`, `0x8A27`, `0x8A3A`, and `0x8A52`
- Added screenshot-assisted scaled views:
  - `0x929E` as the code-confirmed `24` point RPM axis, displayed as `15000000 / period`
  - `0x8A69` as likely high-octane/default spark advance, displayed as `raw / 2` degrees
  - `0x8B41` as likely low-octane/alternate spark advance, displayed as `raw / 2` degrees
  - `0x8C19` as a likely RPM-only/WOT spark advance vector, displayed as `raw / 2` degrees
  - XDF `0.21` restores the `Confirmed` category/category 10 memberships for code-confirmed spark entries plus `0x929E`, `0x9291`, and the temperature-axis family at `0x92CF/0x92D9/0x400E`; rounded integer kPa labels are retained because TunerPro RT loaded them successfully.
  - The 2D spark-bank X labels now display runtime `0x2034` as rounded integer `0-100 kPa` MAP/load estimates rather than raw `0-1024`; this is display-only until the ADC transfer is fully proven.
  - Same-family comparison caveat: `RALLY13.ORI` carries this stock spark
    bundle shifted by `+0x1B` (`0x8A84`, `0x8B5C`, `0x8C34`), while
    `Peug.106Rally.org.bin` keeps these Peugeot offsets but has heavily
    altered bank values.
  - `0x879E`, `0x87A0`, `0x87A2`, and `0x87A4` as RPM-scaled period thresholds
- `0x9291` as a code-referenced 9-byte helper axis vector, plus the paired
  NTC-matching ADC breakpoint vectors at `0x92CF` and `0x92D9`

Recommended next steps:

1. Open the BIN with the new XDF in TunerPro.
2. Inspect code-confirmed and MOD2-touched views first, especially
signed IAT/RPM fuel correction candidates `24x9 @ 0x802B` and `24x9 @ 0x8103`,
   signed fuel quantity trim views `24x9 @ 0x821C`, `24x9 @ 0x8318`,
   and the RPM-only bypass vector `1x24 @ 0x83F0`,
   legacy alignment probes around `0x802E`, `0x80EB`, `0x80F1`, and `0x81A8`,
   the likely spark maps, and
   `Load / Air-Charge Model Factor 24x9 @ 0x9187`.
3. Inspect the retired `0x88CD` slice inside the `0x888E` parent only as
   historical visual context, because the later code-confirmed parent table
   starts at `0x888E`. Do not use the removed `0x88CA` triangular alignment.
4. Use `Candidate Flag/Scalar Block 16x5 @ 0x8880` to understand the header/setup bytes before the 0x88CD map.
5. Then review `0x8E00` and `0x8300`.
6. Look for recognizable axes:
   - monotonic increasing rows or columns
   - temperature-like curves
   - RPM/load breakpoints
7. Once one or two tables are confirmed, convert those raw blocks into named maps with real scaling.

## Stock vs MOD2 Comparison Pass

Additional files analyzed:

- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin`
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin`
- `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin`

Results:

- `1.3L_8V_IAW8P40_Stok.bin` is byte-identical to `M27C512_original.BIN`.
- `1.3L_8V_IAW8P40_MOD2.bin` differs from stock by `479` bytes across `87` runs.
- `4` of those bytes are checksum bytes at `0x800C-0x800F`.
- The remaining `475` changed bytes are calibration-looking changes.
- Xantia 607C differs from Peugeot stock by `42021` bytes across `1038` runs;
  it is useful for same-family comparison, not direct Peugeot offset proof.

Checksum offsets:

- `0x800C-0x800D`: checksum word, big-endian.
  - Stock: `0x4A65`
  - MOD2: `0x47BE`
- `0x800E-0x800F`: checksum complement / byte-sum target, big-endian.
  - Stock: `0xB59A`
  - MOD2: `0xB841`
- The two words sum to `0xFFFF`.
- The complement matches the additive byte sum over `0x4000-0xFFFF`; `0xB600-0xB7FF` is zero-filled.

Candidate and code-confirmed offsets added to the XDF:

- `0x802B-0x8102`: `Signed Fuel IAT/RPM Correction A 24x9 @ 0x802B`.
  Code-referenced signed correction table. X labels follow the likely IAT
  `0x200A -> 0x2124 -> 0x92D9 -> $2038` path and display the firmware-inverted
  temperature sites `-40..120 C`; Y labels are the confirmed `0x929E` RPM
  sites. Output is `$204A`.
- `0x8103-0x81DA`: `Signed Fuel IAT/RPM Correction B 24x9 @ 0x8103`.
  Paired signed correction table using the same likely IAT and RPM axes.
  Output is `$204D`.
- `0x821C-0x82F3`: `Signed Fuel Quantity Trim A 24x9 @ 0x821C`.
  Signed load/RPM trim selected by `$E38B`; X is runtime `$2034`,
  Y is runtime `$2036`, and output `$2084` is applied to `$00C1` by `$E715`
  as roughly `fuel += fuel * signed_trim / 256`.
- `0x8318-0x83EF`: `Signed Fuel Quantity Trim B 24x9 @ 0x8318`.
  Paired signed load/RPM trim selected by `$E38B`; exact selector semantics
  remain provisional.
- `0x83F0-0x8407`: `RPM-only Fuel Trim / Bypass Vector Candidate 1x24 @ 0x83F0`.
  Signed RPM-only bypass vector that can also feed `$2084`.
- `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1` are retained only as legacy
  visual/alignment probes around the signed correction region. `0x80EB` is a
  signed boundary slice at `0x802B+0xC0` crossing into `0x8103`. Do not tune
  them as VE or main fuel.
- A pure VE/base fuel table is still not proven, but `$821C/$8318` are now the
  strongest signed fuel quantity trim candidates. `$00C1 -> $00C3 -> $00BC` is
  the strongest pulse-width/event-width path, while `$87B1 -> $00BE -> $21C6` is
  event phase. OC1 schedules `TOC1 = $00B8 + $21C6`, OC3 handles the pulse edge,
  and exact driver/pin plus tick-to-ms/degree proof remains hardware-level.
- `0x800A`: code-referenced spark-bank selector seed byte; stock `0x00` becomes runtime `0x20B1 = 0xFF` after decrement.
- `0x879C-0x87A3`: scalar block around changed 16-bit words.
- `0x879E`: changed 16-bit threshold scalar, stock `0x07EB`, MOD2 `0x00FA`.
- `0x87A0`: changed 16-bit threshold scalar, stock `0x07EF`, MOD2 `0xFFFF`.
- `0x87A2`: alternate period threshold, stock `0x1770`, about `2500 RPM`.
- `0x87A4`: alternate period threshold, stock `0x1979`, about `2300 RPM`.
- `0x869A-0x8771`: code-confirmed `24x9` 2D parent table; the old visual `0x86DB` slice lies inside it.
- `0x87B1-0x8888`: injector/event phase offset `24x9`; stock table is all
  zero, output updates `$00BE -> $21C6`, and changes affect phase/timing rather
  than fuel quantity.
- `0x888E-0x8965`: code-confirmed `24x9` 2D parent table; the old visual `0x88CD` slice lies inside it.
- `0x8E6F-0x8EC3`: code-confirmed bounded `17x5` 2D table view.
- `0x8EC7-0x8F1B`: code-confirmed bounded `17x5` 2D table view.
- `0x8F1C-0x8F70`: code-confirmed bounded `17x5` 2D table view.
- `0x8F71-0x8FC5`: code-confirmed bounded `17x5` 2D table view.
- `0x9073-0x90D5`: closed-loop/adaptive ramp/target `11x9` 2D table.
- `0x89ED-0x89F2`: code-referenced control scalars.
- `0x89F3-0x8A05`: `Per-event Retard / Gain Candidate 1x19 @ 0x89F3`;
  code-confirmed `1x19` interpolation vector and part of a larger
  RPM-derived `0x2044`-indexed vector family.
- `0x8A68`: code-confirmed signed offset byte, stock/MOD2 `0x00`.
- `0x8A69-0x8B40`: code-confirmed `24x9` 2D table bank; likely
  high-octane/default spark advance. XDF displays the `0x2034` load axis as
  rounded integer `0-100 kPa` MAP/load estimate and Z values as `raw / 2`
  degrees.
- `0x8B41-0x8C18`: code-confirmed `24x9` 2D table bank; likely
  low-octane/alternate spark advance. XDF displays the `0x2034` load axis as
  rounded integer `0-100 kPa` MAP/load estimate and Z values as `raw / 2`
  degrees.
- `0x8C18`: final cell of the `0x8B41` bank, stock `0x38`, MOD2 `0x3C`.
- `0x8C19-0x8C30`: code-confirmed RPM-only vector used when `RAM 0x00A9 bit 0x20` bypasses the banked maps.
- `0x9187-0x925E`: `Load / Air-Charge Model Factor 24x9 @ 0x9187`;
  code-confirmed `24x9` 2D table. The older `0x91D9-0x925F` `15x9` view was a
  legacy misaligned slice and has been removed from the normal XDF tree. The
  retained view uses screenshot-assisted `raw / 230` scaling. Current trace
  shows it can seed `0x00D0`, then `0x00CE`, then the load/MAP-like axis
  `0x2034`, so it is probably load/air-charge model related rather than proven
  main fuel.
- `0x929E-0x92CD`: code-confirmed period/RPM axis for runtime `0x2036`; count byte is `0x92CE = 0x18`; in the XDF `Confirmed` category.
- `0x9291-0x9299`: code-referenced 9-byte helper breakpoint vector; count byte is `0x929A = 0x09`; in the XDF `Confirmed` category with physical units provisional.
- `0x92CF-0x92D7`: NTC-matching likely CTS ADC breakpoint vector; nearby count byte is `0x92D8 = 0x09`; paired with `0x92D9` and shared `0x400E` `deg C + 40` output vector.
- `0x55A0-0x55B1`: raw diagnostic/event-code table indexed by `0x5982` for
  observed event IDs `0x00-0x11`.
- `0x9131-0x9169`: raw `19x3` state descriptor triples consumed by `0x58F2`.
  Observed callers use 18 descriptors from `0x9131` through `0x9167`; the
  extra row keeps the apparent `0x9140` reserved slot aligned.

Free-space / cave candidates:

- `0xF021-0xFFD5`: `4021` zero bytes; best current code-cave candidate before vectors at `0xFFD6-0xFFFF`.
- `0xB600-0xB7FF`: `512` zero bytes skipped by the checksum routine.
- `0x0000-0x3FFF`: `16384` zero bytes in the file, but not assumed usable without ECU memory-map confirmation.
- Do not treat zero-looking active tables such as `0x87B1`, `0x9073`, or the `0x8Fxx` cluster as free space.

External sensor clue:

- Peugeot 106 TU2J2/MFZ references list a MAP sensor, coolant temp, inlet air
  temp, TPS, VSS, crank sensor, knock sensor, and heated oxygen sensor.
- MAP sensor evidence points to a Magneti Marelli PRT03-family 100 kPa / 1 bar
  sensor, supporting the rounded display-only `0x2034` MAP/load labels
  `0-100 kPa` used on the likely spark maps.
- A public air-density screenshot shows a `24x9` RPM-by-temperature factor map,
  but the displayed matrix was not found in the local stock or MOD2 dumps. This
  is a map-family lead only, not an offset.

Useful direct-reference hints from byte/opcode context:

- `0x800E` is used by the checksum routine around `0x5AD8-0x5B17`.
- `0x879E` / `0x87A0` are referenced around `0x6F14-0x6F2A`.
- `0x87A2` / `0x87A4` are alternate thresholds in the same limiter-looking routine when `RAM 0x214F` is nonzero.
- `0x869A` is loaded as a B2D6 table base around `0x9B79-0x9BAE`; result stores to `0x2391`.
- `0x87B1` is loaded as a B2D6 table base around `0x7254-0x7270`; result updates `0x00BE`.
- `0x888E` is loaded as a B2D6 table base around `0xBE74-0xBE90`; result stores to `0x2484`.
- `0x9073` is loaded as a B2D6 table base around `0xC282-0xC2BE`; result is compared with `0x243C`.
- `0x8E6F`, `0x8F1C`, `0x8F71`, and `0x8EC7` are loaded as B2D6 table bases around `0xD105-0xD15D`.
- `0x89F3` is used as a 1D RPM-indexed interpolation vector around `0xBAA8-0xBAB2`.
- `0x89ED`, `0x89F0`, `0x89F2`, `0x8A06`, and `0x8A08` are scalar/control bytes used around `0xBAA8-0xBB96`.
- `0x8A69` / `0x8B41` are selected as 2D table banks around `0x48EE-0x4941`.
- `0x800A` is loaded around `0xCBEF` and decremented before being stored to `0x20B1`.
- Stock and MOD2 both have `0x800A = 0x00`, which underflows to runtime
  `0x20B1 = 0xFF` and selects `0x8A69`. High-load numeric comparison also
  points to `0x8A69` as likely high-octane/default and `0x8B41` as likely
  low-octane/alternate.
- `0x20B1` is now best named `spark_bank_selector_state`.
- `0x8A68` is sign-extended as an optional offset around `0x492A-0x493E`.
- `0x8C19` is used by the `0x48F4` bypass path as an RPM-only vector.
- `0x9187` is loaded as a 2D table base around `0x6344-0x636A`; stride comes from `0x929A`.
- The `0x9187` raw values become factor-like with `raw / 230`, but the exact correction type is still unconfirmed.
- The public air-density screenshot does not match `0x9187` byte-for-byte. Its
  first row under `raw / 230` would be approximately
  `115 104 83 62 48 51 46 46 44`, while local `0x9187` begins
  `186 199 220 227 247 252 254 254 254`.
- `0x5E74-0x5E7C` can store the `0x9187` lookup into `0x00D0`, then store `0x00CE = 0x00D0 << 2`.
- `0x41A1-0x41AD` turns `0x00CE` into normalized axis `0x2034`.
- `0x00D0` is now best treated as a load-model/air-charge byte, `0x00CE` as a
  raw load/aircharge word, and `0x2034` as a load/MAP-like 8.8 axis until live
  data or ADC transfer code proves exact pressure units.
- `0x2147` is now best treated as a spark-angle accumulator/intermediate
  command. It receives the banked-map or WOT-vector result plus corrections and
  feeds byte outputs including `0x2001` and `0x2148`.
- `0x5982` maps event IDs through `0x55A0` and manages queue `0x004B-0x005B`;
  `0x58F2` consumes 3-byte state descriptors around `0x9131-0x9167`.
- `0x925F` is referenced around `0x5E6B`.
- `0x929E` is loaded by the `0x2036` axis builder at `0xD46D-0xD47F`.

Important caution:

- The MOD2-touched blocks are stronger candidates than visual-only blocks, but they are still raw reverse-engineering views.
- Do not label fuel, RPM, temperature, or the exact correction type until code
  usage or live behavior confirms the meaning. Spark timing is now a strong
  working label for `0x8A69`, `0x8B41`, and `0x8C19`, but octane-bank names
  should remain "likely" until knock/fallback logic is fully traced.
- The air-density screenshot should stay on the checklist, but no local offset
  should be named from it until IAT/CTS ADC paths reach a confirmed table.
## Stock vs MOD2 Comparison Analysis
Analysis date: 2026-05-23

## Input Files

Compared files:

| File | Size | SHA-256 | Notes |
| --- | ---: | --- | --- |
| `M27C512_original.BIN` | `65536` | `09e5d927bd6951ecf7b57f351ccd5d396dc95c191d12164f71671725b751a681` | Original local read |
| `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin` | `65536` | `09e5d927bd6951ecf7b57f351ccd5d396dc95c191d12164f71671725b751a681` | Byte-identical to `M27C512_original.BIN` |
| `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin` | `65536` | `d3e4a451edd236104c79190372fa1be1e45aad09398eabe6f7b7e1479d810855` | Same ROM family, modified calibration/checksum bytes |
| `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin` | `65536` | `05470171f86b8525f962f13370846e6d4a1a6fbabc0107d90e1497f88a5dfe89` | Same-family comparison binary, not Peugeot offset proof |
| `Peug.106Rally.org.bin` | `65536` | `fe7d7953298c575bc08e4c301ce7e911bce082d1515e1fca68509a2c980e0141` | Suspicious public/tuned comparison: reset vector is `0xB800`, but checksum validation fails and prefix is not zero-filled |
| `RALLY13.ORI` | `65536` | `5f4ef679f6d262502d0023cf9f441111bc5c694cd4e281394ad0fcba810854cf` | Checksum-valid same-family comparison image, not Peugeot offset proof |

Important result: the internet `Stok` BIN is exactly the same as the local original read. The `MOD2` file is therefore useful as a direct tuned-vs-stock comparison.

The repeatable script `tools/iaw8p40_analyze.py` now reproduces these hashes,
checksum words, diff counts, known table stats, same-offset comparison data,
helper-call scans, and RAM/register reference scans for all six images.

## Shared ROM Structure

All clean stock/MOD2/Xantia/RALLY13-style images:

- Are exactly `0x10000` bytes / `64 KiB`.
- Have a zero-filled prefix from `0x0000-0x3FFF`.
- Have real content from `0x4000`.
- Have a zero-filled internal hole at `0xB600-0xB7FF`.
- Share reset vector `0xB800` and a similar 68HC11 vector layout.

`Peug.106Rally.org.bin` is also `64 KiB` and has reset vector `0xB800`, but it
has a nonzero `0x0000-0x3FFF` prefix and checksum byte sum `0xE160` against the
stored `0x4A65/0xB59A` pair. Keep it in comparisons, but do not treat it as a
clean stock duplicate.

Peugeot vector values:

| Address | Value |
| --- | --- |
| `0xFFF0` | `0x95F3` |
| `0xFFF2` | `0x6405` |
| `0xFFF4` | `0xB94D` |
| `0xFFF6` | `0xB94D` |
| `0xFFF8` | `0xB948` |
| `0xFFFA` | `0xB93D` |
| `0xFFFC` | `0xB942` |
| `0xFFFE` | `0xB800` |

`0xFFFE = 0xB800` remains the likely reset vector.

The Xantia 607C comparison file also uses reset vector `0xB800`, but differs
from the Peugeot stock file in `42021` bytes across `1038` contiguous regions.
It is therefore useful same-family evidence, not a direct map-offset authority.

## Checksum Discovery

`MOD2` changes four bytes at `0x800C-0x800F`:

| Address | Stock | MOD2 | Meaning |
| --- | --- | --- | --- |
| `0x800C-0x800D` | `0x4A65` | `0x47BE` | Checksum word |
| `0x800E-0x800F` | `0xB59A` | `0xB841` | Checksum complement / byte-sum target |

Both files keep the relationship:

```text
checksum_word + checksum_complement = 0xFFFF
```

Observed byte sums:

| File | Byte sum over `0x4000-0xFFFF` | Stored complement @ `0x800E` | Stored word @ `0x800C` |
| --- | --- | --- | --- |
| Stock | `0xB59A` | `0xB59A` | `0x4A65` |
| MOD2 | `0xB841` | `0xB841` | `0x47BE` |
| Xantia 607C | `0x607C` | `0x607C` | `0x9F83` |
| `RALLY13.ORI` | `0x85BE` | `0x85BE` | `0x7A41` |
| `Peug.106Rally.org.bin` | `0xE160` | `0xB59A` | `0x4A65` |

The checksum routine appears to sum bytes down through the ROM while skipping `0xB600-0xB7FF`; that skipped range is zero-filled, so the practical sum is the same as summing `0x4000-0xFFFF`.

Useful repair formula:

```text
sum_without_checksum_pair = sum(bytes 0x4000-0xFFFF excluding 0x800C-0x800F)
checksum_complement = (sum_without_checksum_pair + 0x01FE) & 0xFFFF
checksum_word       = (~checksum_complement) & 0xFFFF

store checksum_word       big-endian at 0x800C
store checksum_complement big-endian at 0x800E
```

`0x01FE` is the constant byte-sum contribution of any valid 16-bit word plus its one's-complement word.

Relevant code area:

```text
0x5AD8-0x5B17
```

The routine loads a rolling pointer/sum from RAM, accumulates bytes, skips the zero hole, and compares the accumulated value against the 16-bit value at `0x800E`.

## MOD2 Difference Summary

`M27C512_original.BIN` vs `1.3L_8V_IAW8P40_MOD2.bin`:

- Total differing bytes: `479`.
- Difference runs: `87`.
- Checksum bytes: `4` bytes at `0x800C-0x800F`.
- Non-checksum changed bytes: `475`.
- All non-checksum changes are in the calibration-looking half of the ROM.

Top-level changed regions:

| Region | Changed bytes | Current interpretation |
| --- | ---: | --- |
| `0x800C-0x800F` | `4` | Checksum word and complement |
| `0x802B-0x8102` | `75` changed cells inside signed `24x9` view | Code-referenced IAT/RPM fuel correction A; X likely IAT `0x92D9 -> $2038` displayed as firmware-inverted `-40..120 C`, Y `0x929E` RPM, output `$204A` into `$204B -> $00C1` |
| `0x8103-0x81DA` | `72` changed cells inside signed `24x9` view | Code-referenced IAT/RPM fuel correction B; X likely IAT `0x92D9 -> $2038` displayed as firmware-inverted `-40..120 C`, Y `0x929E` RPM, output `$204D` into `$204E/$204F` |
| `0x821C/0x8318/0x83F0` | signed fuel quantity trim family | Code-referenced proportional trim candidates; `$E38B` selects `$2084`, and `$E715` applies it to `$00C1` as roughly `fuel += fuel * signed_trim / 256` |
| `0x802E/0x80EB/0x81A8/0x80F1` | overlapping changed legacy views | Alignment/debug probes only; do not tune as VE or main fuel |
| `0x879E-0x87A1` | `4` | Two changed 16-bit big-endian scalars |
| `0x89F3-0x8A05` | `16` changed cells inside a code-confirmed `1x19` vector | Compact interpolated vector indexed by `RAM 0x2044` |
| `0x8A68-0x8C17` plus `0x8C18` | `245` cells plus one adjacent byte | Large packed row block; likely important |
| `0x9187-0x925E` | `62` changed cells inside a code-confirmed `24x9` table | Load / air-charge model factor; old `0x91D9` view was misaligned |

Repeatable script table stats for the corrected signed correction family:

| Range | Shape | Peugeot stock raw | MOD2 changes | Xantia same-offset raw | Current use |
| --- | --- | --- | --- | --- | --- |
| `0x802B-0x8102` | `24x9` signed | `-121..-8`, avg `-68.6` | `75 / 216`, `+4..+6`, avg `+5.4` | `-112..-28`, avg `-80.0` | Signed IAT/RPM fuel correction A |
| `0x8103-0x81DA` | `24x9` signed | `-128..127`, avg `-22.8` | `72 / 216`, `+5..+18`, avg `+6.1` | `-54..74`, avg `-4.9` | Signed IAT/RPM fuel correction B |
| `0x802E/0x80EB/0x81A8/0x80F1` | legacy probes | overlapping raw/signed views | MOD2-touched because they overlap the signed region | same-offset comparison only | Debug/alignment only; `0x80EB` is signed boundary slice `0x802B+0xC0` |

## MOD2-Touched Split Region @ `0x802E-0x81D4`

The earlier combined view was:

```text
start: 0x802E
shape: 47 rows x 9 columns
end:   0x81D4
```

That alignment was useful for discovery, but it is no longer the active XDF
view. The current preferred alignment is the code-referenced signed `24x9`
base at `0x802B`, with the older public-index views retained only as
boundary/debug views:

- Legacy misaligned slice: `21x9 @ 0x802E-0x80EA`.
- Alternate boundary view: `24x9 @ 0x802E-0x8105`.
- Signed boundary slice: `21x9 @ 0x80EB-0x81A7`, starting at `0x802B+0xC0`
  and crossing into `0x8103`.
- Adjacent signed candidate: `25x9 @ 0x80F1-0x81D1`.

Changed parent row indexes:

```text
10, 11, 13, 14, 15, 16, 17, 18,
21, 22, 23,
35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46
```

Notable pattern:

- Upper rows `14-17` are changed across all 9 columns by `+6`.
- Lower parent rows `35-44` mostly change columns `0-5` by `+5`.
- Lower parent row `45` changes columns `0-5` by `+18`.

The lower structure wraps through `0xFF`, so signed or modulo interpretation may
matter. The upper `24x9` shape is a plausible RPM/load-style table, but direct
code usage is not confirmed. Do not assign physical units or confirmed fuel
meaning yet.

## MOD2-Touched Scalars @ `0x879E` and `0x87A0`

Surrounding stock bytes:

```text
0x879C stock: 01 A0 07 EB 07 EF 17 70
0x879C MOD2:  01 A0 00 FA FF FF 17 70
```

Interpreted as big-endian 16-bit words:

| Address | Stock | MOD2 |
| --- | --- | --- |
| `0x879E` | `0x07EB` | `0x00FA` |
| `0x87A0` | `0x07EF` | `0xFFFF` |

These words are directly referenced in code around `0x6F14-0x6F2A`. They may be thresholds, limits, or switch values. The stock values are close to each other, which suggests a paired low/high threshold or hysteresis pair, but the MOD2 values are unusual enough that the exact purpose should be confirmed by disassembly.

## Legacy Raw MOD2-Touched Vector View @ `0x89F2`

Proposed view:

```text
start: 0x89F2
shape: 1 row x 20 columns
end:   0x8A05
```

Stock vs MOD2:

```text
stock: 40 40 46 4B 50 55 5A 5F 78 90 90 96 96 90 A5 AA A0 9B 96 82
MOD2:  40 40 46 4D 52 5B 64 6F 7E 90 96 9A 9E A2 A7 AC AA A3 98 8C
```

Evidence:

- `16` bytes change in the corrected `0x89F3-0x8A05` vector.
- A direct code reference to `0x89F2` was observed around `0xBB81` as part of an extended load sequence.
- The values look like a compact breakpoint/vector/table region rather than executable code.

## MOD2-Touched Banked 2D Candidate @ `0x8A68-0x8C18`

Original raw view:

```text
start: 0x8A68
shape: 48 rows x 9 columns
end:   0x8C17
```

Disassembly-corrected structure:

```text
0x8A68: signed offset byte, used conditionally
0x8A69-0x8B40: code-confirmed 24x9 bank
0x8B41-0x8C18: code-confirmed 24x9 bank
```

Important correction:

- `0x8C18` is not an adjacent vector start.
- It is row `23`, column `8` of the `0x8B41` bank.
- `0x8C18` changes from stock `0x38` to MOD2 `0x3C`.
- The routine at `0x48EE-0x4941` sets column count to `9` and calls the 2D interpolation helper at `0xB2D6`.

Bank select:

```text
RAM[0x20B1] != 0 -> bank at 0x8A69
RAM[0x20B1] == 0 -> bank at 0x8B41
```

Inputs:

```text
RAM[0x2034] -> descriptor bytes 0/1
RAM[0x2036] -> descriptor bytes 2/3
```

This is currently one of the strongest code-confirmed MOD2-backed map candidates, although the physical meaning of the axes is not yet known.

## MOD2-Touched Code-Confirmed 24x9 @ `0x9187`

Disassembly corrected the earlier `15x9 @ 0x91D9` view. The confirmed structure is:

```text
start: 0x9187
shape: 24 rows x 9 columns
end:   0x925E
```

The proving routine is at `0x6344-0x636A`:

```asm
634B: F6 92 9A      LDAB $929A       ; stride = 9
6351: CE 92 91      LDX #$9291       ; axis vector/helper input
6354: BD B3 83      JSR $B383
635A: FC 20 36      LDD $2036
6360: CC 91 87      LDD #$9187       ; table base
6366: BD B2 D6      JSR $B2D6
```

Notes:

- `0x929A` is `0x09`, confirming a 9-column stride.
- `0x9291-0x9299` is the supporting axis vector used by helper `0xB383`.
- `RAM 0x2036` supplies the second interpolation axis.
- MOD2 changes `62` bytes inside this confirmed table.
- The old `0x91D9` view starts one byte after row 9 begins and has been removed
  from the normal XDF tree.
- `0x91EC: 0xCD -> 0x6F` is row 11, column 2 of this confirmed table, not a separate anomaly outside the map.
- Row `13`: column `5` increases by `+32`, much larger than surrounding changes.
- Row `14`: columns `2-7` increase by `+3`.
- Screenshot-assisted scaling: `raw / 230` turns this into a factor-like surface of
  roughly `0.00-1.10`. The XDF now includes
  `Load / Air-Charge Model Factor 24x9 @ 0x9187`; it is not treated as main
  fuel.

## Earlier Candidates Revisited

The first-pass candidates are still valid inspection regions, but MOD2 did not touch the two previously strongest visual candidates:

| Candidate | MOD2 touched? | Current status |
| --- | --- | --- |
| `0x86DB` as `13x9` | No | Still table-like, but not changed by MOD2 |
| `0x88CD` as `17x9` | No | Still visually strong, but not changed by MOD2 |
| `0x8880` flag/scalar block | No direct MOD2 change | Still likely setup/header/scalar data |

This does not prove those blocks are unimportant. It only means the MOD2 tune did not alter them.

## Code Reference Notes

Current code-reference summary:

| Target | Observed reference area | Notes |
| --- | --- | --- |
| `0x800E` | `0x5B00` | Checksum routine compares accumulated sum to stored complement |
| `0x879E` | `0x6F28` | Threshold/hysteresis flag-set compare |
| `0x87A0` | `0x6F12` | Threshold/hysteresis flag-clear compare |
| `0x89ED-0x89F2` | `0xBADA-0xBB92` | Control/scalar bytes |
| `0x89C7`, `0x89DA`, `0x89F3`, `0x8A27`, `0x8A3A`, `0x8A52` | `0xBA5D-0xBAB2` | Code-confirmed `0x2044`-indexed 1D vector family |
| `0x8A68` | `0x492E` | Optional signed offset byte |
| `0x8A69` / `0x8B41` | `0x4904-0x4927` | Code-confirmed banked 24x9 tables |
| `0x9187` | `0x6344-0x636A` | Code-confirmed 24x9 table using stride byte `0x929A` |
| `0x925F-0x9261` | `0x5E6A-0x5E9F` | Scalar/threshold bytes near 0x91xx descriptor region |

Some earlier naive byte-reference hits were false positives. For example, the apparent `0x802E` hit around `0xC620` decodes as `CPD #$FF80` followed by a branch and is not a real table reference.

## XDF Updates Made

`IAW8P40_peugeot106_firstpass.xdf` was updated to version `0.5` in this pass and later to `0.6` after comparing against an online Peugeot 106 Rallye XDF screenshot.

Historical categories in that early pass:

- `Checksum`
- comparison-candidate bucket, later retired in favor of subsystem categories

New checksum constants:

- `Checksum Word @ 0x800C`
- `Checksum Complement @ 0x800E`

New MOD2-backed entries:

- `MOD2 Changed 16-bit Scalar A @ 0x879E`
- `MOD2 Changed 16-bit Scalar B @ 0x87A0`
- `MOD2 Changed Last Cell of 0x8B41 Bank @ 0x8C18`
- `Code-Confirmed Signed Offset Byte @ 0x8A68`
- historical `0x879C` comparison scalar block, retired from active XDF v0.42
- historical raw `0x8A68` banked block view, retired from active XDF v0.42
- historical raw `0x8C18` view, retired from active XDF v0.42

After TunerPro visual review, additional split views were added:

- `Signed Fuel IAT/RPM Correction A 24x9 @ 0x802B`
- `Signed Fuel IAT/RPM Correction B 24x9 @ 0x8103`
- `Signed Fuel Quantity Trim A 24x9 @ 0x821C`
- `Signed Fuel Quantity Trim B 24x9 @ 0x8318`
- `RPM-only Fuel Trim / Bypass Vector Candidate 1x24 @ 0x83F0`
- legacy alignment probes around `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1`
- `Code-Confirmed Spark Bank High/Default 24x9 @ 0x8A69`
- `Code-Confirmed Spark Bank Low/Alternate 24x9 @ 0x8B41`
- `Code-Referenced Control Scalars 1x6 @ 0x89ED`
- `Per-event Retard / Gain Candidate 1x19 @ 0x89F3`
- `Code-Confirmed 1D Vector 1x19 @ 0x89C7`
- `Code-Confirmed 1D Vector 1x19 @ 0x89DA`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A27`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A3A`
- `Code-Confirmed 1D Vector 1x19 @ 0x8A52`
- `Code-Referenced Scalar Block 1x5 @ 0x8A4D`
- `Code-Referenced Scalar Block 1x3 @ 0x8A65`
- `Code-Confirmed 2D Table 24x5 @ 0x85BA`
- `Code-Confirmed 2D Table 5x5 @ 0x8A0A`
- `Code-Confirmed RPM Axis 1x24 @ 0x929E`
- `Likely Spark Advance High Octane / Default 24x9 @ 0x8A69`
- `Likely Spark Advance Low Octane / Alternate 24x9 @ 0x8B41`
- `Likely WOT Spark Advance Vector 1x24 @ 0x8C19`
- `Likely RPM Limiter Set/Clear Thresholds @ 0x879E/0x87A0`
- `Load / Air-Charge Model Factor 24x9 @ 0x9187`
- `Alternate RPM Thresholds @ 0x87A2/0x87A4`
- `Code-Referenced Axis Vector 1x9 @ 0x9291`
- `AXIS_TEMP_B / Likely CTS ADC Breakpoints 1x9 @ 0x92CF`
- `AXIS_TEMP_A / Likely IAT ADC Breakpoints 1x9 @ 0x92D9`
- `VEC_TEMP_RAW_OUTPUT_C_PLUS_40_9 @ 0x400E`
- `Code-Confirmed 2D Table 24x9 @ 0x869A`
- `Code-Confirmed 2D Table 24x9 @ 0x87B1`
- `Code-Confirmed 2D Table 24x9 @ 0x888E`
- `Closed-Loop Ramp / Target Table 11x9 @ 0x9073`
- `Code-Confirmed 2D Table 17x5 @ 0x8E6F`
- `Code-Confirmed 2D Table 17x5 @ 0x8EC7`
- `Code-Confirmed 2D Table 17x5 @ 0x8F1C`
- `Code-Confirmed 2D Table 17x5 @ 0x8F71`
- likely spark advance x-axis labels changed from placeholder
  `0-8` to provisional load/MAP-like `0, 128, 256, 384, 512, 640, 768,
  896, 1024`.
- `Spark Bank Selector Config @ 0x800A`
- `Diagnostic Event Code Table 1x18 @ 0x55A0`
- `State Descriptor Triples 19x3 @ 0x9131`

Rationale:

- The old combined `47x9 @ 0x802E` view changes character after row `23`; it
  has been removed from the XDF. Later disassembly shows `0x802E` is a
  misaligned slice inside the signed `0x802B` table, so it is retained only as
  legacy visual context.
- The `48x9 @ 0x8A68` view has a clear visual break at row `24`, making two `24x9` subviews easier to inspect.
- The original large views remain in the XDF for context, even where later disassembly refined the true boundaries.

After 68HC11 disassembly, the `0x8A68` split was corrected:

- `0x8A68` is a signed offset byte used conditionally by the routine at `0x48EE`.
- `0x8A69-0x8B40` is a code-confirmed `24x9` 2D table bank.
- `0x8B41-0x8C18` is a code-confirmed `24x9` 2D table bank.
- `0x8C18` is the last cell of the second bank, not an adjacent vector.

The `0x89F2` raw view was also refined:

- `0x89ED-0x89F2` are code-referenced control/scalar bytes.
- The old raw `1x20 @ 0x89F2` view has been removed from the normal XDF tree
  because it mixed scalars and vector data in one misleading row.
- `0x89F3-0x8A05` is now exposed as
  `Per-event Retard / Gain Candidate 1x19 @ 0x89F3`, a code-confirmed
  `1x19` vector used by the 1D interpolation helper at `0xB2AB`.
- The continuation pass confirmed the surrounding `0x2044`-indexed vector family at `0x89C7`, `0x89DA`, `0x8A27`, `0x8A3A`, and `0x8A52`.

The `0x91D9` raw view was corrected:

- The code-confirmed table starts at `0x9187`, not `0x91D9`.
- It is a `24x9` B2D6 table with stride `9`.
- The `0x91D9` view has been removed from the normal XDF tree. It was a
  misaligned screenshot-continuity slice, not a standalone map.

Current confidence-tier candidate labels:

| Range | Retained XDF label | Confidence | Notes |
| --- | --- | --- | --- |
| `0x802B-0x8102` | `Signed Fuel IAT/RPM Correction A 24x9 @ 0x802B` | Code-referenced | X likely IAT `0x92D9 -> $2038` displayed as firmware-inverted `-40..120 C`, Y `0x929E` RPM labels, output `$204A` into `$204B -> $00C1`. |
| `0x8103-0x81DA` | `Signed Fuel IAT/RPM Correction B 24x9 @ 0x8103` | Code-referenced | Same likely IAT/RPM axes as `0x802B`; output `$204D` feeds `$204E/$204F` blend path. |
| `0x821C-0x82F3` | `Signed Fuel Quantity Trim A 24x9 @ 0x821C` | Code-referenced | Signed load/RPM trim selected by `$E38B`; X=`$2034`, Y=`$2036`, output `$2084` applied to `$00C1` by `$E715` as roughly `fuel += fuel * signed_trim / 256`. |
| `0x8318-0x83EF` | `Signed Fuel Quantity Trim B 24x9 @ 0x8318` | Code-referenced | Paired signed load/RPM trim selected by `$E38B`; exact selector semantics remain provisional. |
| `0x83F0-0x8407` | `RPM-only Fuel Trim / Bypass Vector Candidate 1x24 @ 0x83F0` | Code-referenced | Signed RPM-only bypass vector that can feed `$2084`; not a standalone VE table. |
| `0x802E/0x80EB/0x81A8/0x80F1` | Legacy alignment probes | Debug only | Overlap the signed correction region; do not tune as VE or main fuel. |
| `0x89ED-0x89F2` | `Code-Referenced Control Scalars 1x6 @ 0x89ED` | Code-referenced | Direct scalar/control bytes. |
| `0x89F3-0x8A05` | `Per-event Retard / Gain Candidate 1x19 @ 0x89F3` | Medium-high structure | Code-confirmed `0x2044`-indexed vector; X sites are `0-7200 rpm` in 400 rpm steps; MOD2 changes `16 / 19` cells. |
| `0x9187-0x925E` | `Load / Air-Charge Model Factor 24x9 @ 0x9187` | Medium-high structural | Code-confirmed lookup that can feed `0x00D0 -> 0x00CE -> 0x2034`; not proven main fuel. |

Screenshots alone are no longer enough to keep a normal candidate view active
when later code proves misalignment. Historical visual leads should now be folded
into the corrected parent structures or documented outside the active XDF tree.

Two older visual candidates were also corrected by the full B2D6 call scan:

- The old `0x86DB` visual candidate is inside the code-confirmed `24x9`
  parent table at `0x869A`.
- The old `0x88CD` visual candidate is inside the code-confirmed `24x9`
  parent table at `0x888E`.
- Neither parent table is changed by MOD2, but both are active code-referenced
  calibration lookups.

The `0x879E/0x87A0` pair was confirmed as threshold/hysteresis data, not a map:

- `0x879E` is used in the flag-set compare.
- `0x87A0` is used in the flag-clear compare.
- Both affect `RAM 0x00A4 bit 0x10`.

Additional `0x9187` flow found:

- `0x5E74` calls the `0x9187` lookup routine at `0x6344`.
- `0x5E77` stores the returned byte to `0x00D0`.
- `0x5E79-0x5E7C` stores `0x00CE = 0x00D0 << 2`.
- `0x41A1-0x41AD` converts `0x00CE` into normalized axis `0x2034`.

The likely spark views and limiter constants now have working names in the
scaled category. The remaining load/air-charge model names are still
hypotheses until more consumer paths are traced.

Spark-bank selector trace:

- `0xCBEF` loads calibration byte `0x800A`.
- `0xCBFB-0xCBFC` decrements the value and stores it to runtime `0x20B1`.
- `0x4907-0x490C` selects `0x8A69` when `0x20B1` is nonzero, otherwise `0x8B41`.
- Stock and MOD2 both have `0x800A = 0x00`, so the stored selector underflows
  to `0xFF`; stock runtime behavior should use the `0x8A69` spark bank.

Spark-bank octane/default naming pass:

- The XDF now labels `0x8A69` as `Likely Spark Advance High Octane / Default`
  and `0x8B41` as `Likely Spark Advance Low Octane / Alternate`.
- This is based on selector behavior and numeric comparison, not just the order
  of the tables in ROM.
- Stock `0x8B41 - 0x8A69` comparison in displayed degrees:
  - Overall mean: `-1.46 deg`.
  - Low-load columns `0-2`: mean `-0.62 deg`.
  - Mid-load columns `3-4`: mean `+2.14 deg`.
  - High-load columns `5-8`: mean `-3.89 deg`.
  - Highest columns `6-8`: mean `-3.78 deg`.
- Bank B has a mid-load advance ridge, so it is not simply a uniformly lower
  copy. At high load, however, it is mostly more conservative, which fits the
  low-octane/alternate interpretation.

Spark offset sanity pass across comparison ROMs:

- Peugeot stock, `1.3L_8V_IAW8P40_Stok.bin`, and MOD2 use the local
  code-confirmed bundle at `0x8A69`, `0x8B41`, and `0x8C19`.
- `RALLY13.ORI` carries an exact byte-for-byte copy of the Peugeot stock spark
  bundle shifted by `+0x1B`: high bank `0x8A84`, low bank `0x8B5C`, WOT vector
  `0x8C34`. Loading it with the stock XDF at `0x8A69` produces apparent
  row-boundary garbage before the true bank.
- `Peug.106Rally.org.bin` keeps the same Peugeot spark offsets. Its WOT vector
  at `0x8C19` is unchanged, but the two 2D spark banks are heavily altered; the
  high low-RPM cells visible in TunerPro are data content, not by themselves an
  offset proof.

Fuel/correction candidate pass:

- `0x802B` and `0x8103` are now the code-referenced signed IAT/RPM fuel
  correction candidate tables in this region.
- `0x802E` is a `+3` misaligned slice inside `0x802B`; it remains useful only
  as legacy visual context.
- A pure VE/base fuel table is still not proven, but `$821C/$8318` are now the
  strongest signed fuel quantity trim candidates. `$00C1 -> $00C3 -> $00BC` is
  the strongest pulse-width/event-width path, while `$87B1 -> $00BE -> $21C6` is
  event phase. OC1 schedules `TOC1 = $00B8 + $21C6`, OC3 handles the pulse edge,
  and exact driver/pin plus tick-to-ms/degree proof remains hardware-level.
  calibration or tail data until code proves otherwise.
- The adjacent signed candidate `25x9 @ 0x80F1` changes `90 / 225` cells.
  The previous `0x8106` view started three bytes into a row. At `0x80F1`, the
  first MOD2 change block is exactly two full 9-cell rows and later changes
  align as repeated row chunks. It displays as signed 8-bit with TunerPro
  native signed data flags; most MOD2 deltas become signed `+5`, with one `+18`
  group.
- Direct code usage for `0x802E` is still not confirmed. The only raw address
  byte occurrence currently seen is the earlier false hit around `0xC621`.
- Fuel/enrichment remains a hypothesis only; `0x802E` is not code-confirmed
  main fuel.
- `0x9187-0x925E` is code-confirmed and MOD2 changes `62 / 216` cells, but the
  traced path can feed `0x00D0 -> 0x00CE -> 0x2034`, so it currently looks more
  like a load/air-charge model table than final main fuel.
- `0x89F3-0x8A05` is a code-confirmed `1x19` vector indexed by RPM-derived
  `0x2044`; MOD2 changes `16 / 19` cells. It remains a plausible
  load-model/transient/enrichment vector, not a vehicle-speed map.

Free-space scan:

- `0xF021-0xFFD5`: `4021` zero bytes and the best current code-cave candidate.
- `0xB600-0xB7FF`: `512` zero bytes skipped by the checksum routine.
- `0x0000-0x3FFF`: `16384` zero bytes in the file, but not assumed usable
  without hardware memory-map confirmation.
- Zero-filled active maps such as `0x87B1` and `0x9073` are not free space.

External sensor scan:

- TU2J2/MFZ wiring references list coolant temp, inlet air temp, VSS, knock,
  heated oxygen, crank, MAP, and TPS sensors.
- A Peugeot 106 1.3 Rallye donor listing identifies a PRT03-family MAP sensor,
  and a PRT03/04 product sheet gives a `17-105 kPa` absolute range.
- This supports interpreting the spark-table x-axis `0x2034` as MAP/load-like.
  XDF `0.21` displays that runtime axis as a rounded provisional `0-100 kPa`
  MAP/load estimate; exact ADC transfer remains open.

External evidence integration:

- The checked public-source summary now lives in
  `EVIDENCE.md`.
- Public sources support the vehicle/ECU match, `27C512` EPROM workflow,
  generic 8P-family sensors/pins, the public OldSkullTuning map-family list,
  and the 100 kPa MAP clue.
- Public sources still do not disclose exact IAW 8P.40 map addresses. The
  MOD2 comparison and disassembly remain the authority for local offsets.

Air-density screenshot lead:

- A public TunerPro screenshot labelled `Air density correction factor by
  temperature` shows a `24x9` RPM-by-temperature factor table.
- The visible cells were converted back into likely byte values and searched
  against stock, Stok, and MOD2 dumps.
- Tried equations/orientations: `raw / 230`, `raw / 100`, `raw / 128`,
  `raw / 200`; normal, reversed rows/columns, both reversed, and transposed.
- No exact local match was found.
- `0x9187` remains the nearest functional load/air-charge model candidate, but
  its bytes do not match the screenshot.
- Loose numeric matches near `0x8A9C` sit inside the code-confirmed spark bank
  and are false positives.
- Do not promote an air-density XDF name until IAT/CTS ADC consumers prove a
  table path.

## Best Next Steps

1. Continue naming source variables for the confirmed axes:
   - `0x00D0 -> 0x00CE -> 0x2034`
   - `0x00BA -> 0x2036`
   - `0x00D4 -> 0x2044`
2. Trace the outputs from the confirmed maps:
    - `0x2147` for the `0x8A69/0x8B41` banked table result
    - `0x2063` for the `0x85BA` table
    - return value from the `0x9187` table routine at `0x6344`
    - `0x2391`, `0x00BE`, `0x2484`, `0x243C`, `0x24AB`, `0x24AC`, `0x24AD`, and `0x24AF` for the new B2D6 inventory
3. Decode the state/descriptor routine at `0x58F2`; it explains the nearby descriptor triples at `0x9131-0x9167`.
4. In TunerPro, inspect the code-confirmed MOD2-touched maps first: `0x8A69`, `0x8B41`, `0x9187`, and `0x89F3`.
5. Trace IAT/CTS ADC consumers for the public air-density map family before
   adding any air-density XDF name.
6. Before burning any edited EPROM, recompute the checksum pair at `0x800C-0x800F`.
