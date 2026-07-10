# Marelli IAW 8P.40 Peugeot 106 executable-code reverse engineering

Analysis target: repository commit `1270f0cc444eb16ce1987d60eba304a3e06b4af4`.

## Result summary

The Peugeot stock image, the `Stok` duplicate, and the MOD2 image share all bytes outside the established calibration/data window. Stock and MOD2 differ in **479 bytes across 87 contiguous regions**, all within `0x800C-0x925E`, and every changed byte maps to a known calibration/support region or checksum word. None overlap the conservative executable-code graph. This is strong evidence that MOD2 is a **calibration-only modification plus checksum update**, rather than an executable-code patch.

The expanded recursive pass decoded **13,734 instructions** covering **33,663 instruction bytes** in **192 contiguous ranges**. It starts from all 21 ROM vectors, evidence-backed functional entries, and the RTS-delimited hardware-I/O cluster at `0x4F10-0x5510`. It follows direct calls and branches and deliberately excludes the established calibration window. Therefore, absence of decoded instructions inside `0x8000-0x9314` is partly a configured boundary, not an independent proof that no indirect or overlay-executed code could ever exist there. Indirect-dispatch-only, dead, or not-yet-seeded code can also be absent.

Stock SHA-256: `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681`  
MOD2 SHA-256: `D3E4A451EDD236104C79190372FA1BE1E45AAD09398EABE6F7B7E1479D810855`

## Firmware lineages in the folder

| Image | Relationship | Deep annotation status |
| --- | --- | --- |
| `M27C512_original.BIN` | Peugeot stock authority | Fully used for this pass |
| `1.3L_8V_IAW8P40_Stok.bin` | Byte-identical stock duplicate | Same annotations apply exactly |
| `1.3L_8V_IAW8P40_MOD2.bin` | Same program; calibration/checksum changes only | Same code annotations apply exactly |
| `Peug.106Rally.org.bin` | Public/tuned comparison with invalid full-image checksum and nonzero lower prefix | Do not treat as an authoritative executable build |
| Xantia 607C | Different 8P.40 firmware build; tens of thousands of byte differences | Requires independent address mapping |
| `RALLY13.ORI` | Different checksum-valid same-family build; tables/routines may be shifted | Requires independent address mapping |

Do not transplant Peugeot addresses into Xantia or RALLY13 without function-signature matching.

## Memory map

| Range | Interpretation | Executable bytes found |
| --- | --- | ---: |
| `0x0000-0x3FFF` | Zero-filled in authoritative Peugeot images | 0 |
| `0x4000-0x7FFF` | Mixed executable code and constants/data | 15,321 |
| `0x8000-0x9314` | Calibration/data logical window | 0 |
| `0x9315-0xB5FF` | Mixed executable code and constants/data | 6,666 |
| `0xB600-0xB7FF` | Blank/excluded checksum hole | 0 |
| `0xB800-0xFFD5` | Reset, scheduler, services, helpers, mixed constants | 11,676 |
| `0xFFD6-0xFFFF` | 21 big-endian vector words | 0 |

The old apparent 16x16 “tables” at `0x5100`, `0x5200`, `0x5300`, and `0xB500` are executable bytes. The new listing resolves `0x5100` inside routine `0x50F4`, `0x5200` inside routine `0x51FB`, `0x5300` inside routine `0x52DD`, and `0xB500` inside a reachable high-memory routine.

## CPU and reset

The code is Motorola 68HC11-family machine code using the internal register block at `0x1000`. The reset vector is `0xFFFE -> 0xB800`.

```text
reset_entry:
    clear reset/fault bookkeeping
    SP = word[0x916A]              ; stock 0x27FF
    configure 68HC11 ports/timer/SPI/SCI/ADC/register mapping
    write 0x55 then 0xAA to COPRST ; watchdog service
    for address 0x8000..0x9314:
        copy byte through the logical calibration window
    call subsystem initializers
    enable runtime operation
    jump main_runtime_loop          ; 0xD2D9
```

The source and destination of the `0x8000-0x9314` copy use the same logical addresses, implying a board-specific RAM overlay or memory-mapping transition.

## Vector table

| Vector word | Target | Working annotation |
| --- | --- | --- |
| `0xFFD6` | `0xA7DE` | `sub_A7DE` |
| `0xFFD8` | `0xB94D` | `fault_stop_bit08` |
| `0xFFDA` | `0xB94D` | `fault_stop_bit08` |
| `0xFFDC` | `0x7392` | `timer_capture_handler` |
| `0xFFDE` | `0x72CB` | `sub_72CB` |
| `0xFFE0` | `0x583A` | `sub_583A` |
| `0xFFE2` | `0xBC91` | `sub_BC91` |
| `0xFFE4` | `0x5565` | `sub_5565` |
| `0xFFE6` | `0x7F33` | `sub_7F33` |
| `0xFFE8` | `0x6FE4` | `sub_6FE4` |
| `0xFFEA` | `0xE0E7` | `sub_E0E7` |
| `0xFFEC` | `0x9315` | `sub_9315` |
| `0xFFEE` | `0xEB37` | `sub_EB37` |
| `0xFFF0` | `0x95F3` | `interrupt_handler_95f3` |
| `0xFFF2` | `0x6405` | `interrupt_handler_6405` |
| `0xFFF4` | `0xB94D` | `fault_stop_bit08` |
| `0xFFF6` | `0xB94D` | `fault_stop_bit08` |
| `0xFFF8` | `0xB948` | `fault_fatal_bit04` |
| `0xFFFA` | `0xB93D` | `fault_soft_restart_bit01` |
| `0xFFFC` | `0xB942` | `fault_soft_restart_bit02` |
| `0xFFFE` | `0xB800` | `reset_entry` |

The exact peripheral name for each lower vector slot depends on the exact 68HC11 mask/variant. The upper fault handlers are behaviorally clear: `0xB93D` and `0xB942` record a cause and soft-restart; `0xB948` and `0xB94D` enter fatal/fail-safe handling.

## Main scheduler

`0xD2D9` is the main loop guard. The exact decode places `STS $24EA` at **0xD2EE** and `CPX $916A` at **0xD2F4**; older prose that placed those instructions one byte earlier should be corrected.

```text
main_runtime_loop:
    elapsed = TCNT - previous_timer
    update elapsed/budget records
    previous_timer = TCNT

    saved_sp = SP
    if saved_sp != word[0x916A]:
        record stack/runtime fault
        select recovery path

    validate timer/interrupt state
    service watchdog with 0x55, 0xAA
    run fixed periodic call sequence
    jump main_runtime_loop
```

The fixed body calls input processing, state timers, checksum service, operating-mode handlers, closed-loop/adaptive logic, axis construction, fuel/spark calculations, and output scheduling.

## Hardware-I/O service cluster at 0x4F10-0x5510

This dense section configures and polls extended I/O registers around `0x1040`, `0x1050`, `0x1060`, and `0x1080`, then mirrors selected bits into low RAM. It consists of many short RTS-delimited functions and shared bit-update helpers at `0x54C8`, `0x54EB`, and `0x54FE`.

This resolves the three false calibration candidates:

```text
0x5100 = operand bytes inside hardware_io_scan_group_50f4
0x5200 = operand bytes inside hardware_io_scan_group_51fb
0x5300 = instruction bytes inside hardware_io_scan_group_52dd
```

The exact external ASIC/driver represented by the extended register addresses still requires PCB identification.

## Incremental ROM checksum at 0x5AD6

The routine processes one ROM byte on each service call rather than blocking for a full scan.

```text
if checksum_service_enabled:
    disable interrupts
    X = checksum_cursor             ; RAM 0x2188
    Y = checksum_accumulator        ; RAM 0x218A

    if X lies in 0xB600..0xB7FF:
        skip excluded blank window
    else:
        Y += ROM[X]

    decrement X
    save X and Y

    if X fell below 0x4000:
        compare Y with word[0x800E]
        set/clear runtime checksum-fault bit
        reset cursor to 0xFFFF and accumulator to zero

    restore interrupt state
```

The stored words are complementary: stock `0x4A65/0xB59A`, MOD2 `0x47BE/0xB841`.

## Engine period and RPM axis

`0x7392` reads input-capture register `0x1014` into RAM `0x00D9`. The period path calculates:

```text
engine_period_delta (0x00BA) = current_capture - previous_capture
```

Smaller period means higher speed. `0xD46D` maps this period through the 24-point word axis at `0x929E` and helper `0xB3B9`, producing normalized RPM axis `0x2036`.

The locally supported limiter display conversion is `rpm ≈ 15,000,000 / period`.

## RPM limiter at 0x6F01

```text
alternate = (RAM[0x214F] != 0)

if RAM[0x00A4] bit 0x10 is set:
    clear_period = alternate ? word[0x87A4] : word[0x87A0]
    if engine_period > clear_period:
        clear RAM[0x00A4] bit 0x10
else:
    set_period = alternate ? word[0x87A2] : word[0x879E]
    if engine_period < set_period:
        set RAM[0x00A4] bit 0x10
```

Stock primary thresholds are approximately 7400/7386 RPM. MOD2 changes the primary set threshold to about 60,000 RPM and the clear threshold to about 229 RPM. This effectively prevents normal activation and also makes clearing abnormal if the bit is ever set.

## Base spark lookup at 0x48EE

```text
if operating_mode_flags bit 0x20:
    spark = interp1d(table=0x8C19, axis=RPM 0x2036)
else:
    table = 0x8A69
    if bank_selector_0x20B1 == 0:
        table = 0x8B41

    spark = interp2d(
        table=table,
        x=normalized_load 0x2034,
        y=normalized_RPM 0x2036,
        columns=9
    )

    if spark_mode_flags bit 0x02:
        spark += sign_extend(byte[0x8A68])

RAM[0x2147] += spark
```

The table boundaries and `raw / 2` degree scaling are strong. “High/default,” “low/alternate,” and “WOT/bypass” remain working physical names until the knock/fallback selector is fully traced and validated on hardware.

## Spark temperature corrections at 0x4943/0x494F

The same signed 2D helper `0xB32B` is used with:

- `0x8D15`, indexed by CTS-like axis `0x203E` and load `0x2034`.
- `0x8C7C`, indexed by IAT-like axis `0x203A` and load `0x2034`.

The signed result is added to the spark accumulator at `0x2147`.

## Signed fuel trim lookup at 0xE38B

```text
if operating_mode_flags bit 0x20:
    correction = signed_interp1d(table=0x83F0, axis=RPM 0x2036)
else:
    if bank_selector_0x20B1 != 0:
        main_table = 0x821C
        low_rpm_table = 0x81F8
    else:
        main_table = 0x8318
        low_rpm_table = 0x82F4

    if RPM axis <= 0x0300 and mode guards allow:
        select low_rpm_table
    else:
        select main_table

    correction = signed_interp2d(
        table=selected_table,
        x=normalized_load 0x2034,
        y=normalized_RPM 0x2036
    )

RAM[0x2084] = correction
```

`0xE715` later applies signed values approximately as `value += value * raw / 256`. These are quantity trims/corrections, not proven base VE maps.

## Fuel calculation chain

```text
ADC/input preprocessing
    -> load/air-charge word 0x00CE
    -> normalized load axis 0x2034

0xE84B:
    signed IAT-like/RPM corrections from 0x802B and 0x8103

0xE38B:
    signed quantity trim from 0x821C/0x8318 or guarded low-RPM slices

0xE927:
    sum corrections into 0x204B

0xE5E8:
    base accumulator 0x00C1 = max(0, load/charge + corrections)

0xE748:
    apply adaptive trim 0x20B9 centered at 0x8000

0xE652 / 0x6E96:
    final duration stack -> 0x00C3

0x6EEE:
    scheduler translates duration/phase support into output-compare timing
```

`0x87B1` affects event phase (`0x00BE -> 0x21C6`), not fuel quantity. Scheduler tables such as `0x8789` remain authoritative in raw timer ticks; milliseconds or crank degrees are not proven.

## Closed-loop and adaptive fuel

`0xC000-0xC90E` contains a closed-loop/adaptive state machine. `0xC94B` interpolates learned cells and `0xCC00` gates/updates adaptive trim. Runtime trim `0x20B9` is centered at `0x8000`; learned cells around `0x0060/0x0069` use neutral byte `0x80`.

The oxygen-sensor electrical polarity, cell conditions, and physical percent scaling still require live logging or bench stimulation.

## ADC and temperature paths

The firmware alternates ADC result groups rather than maintaining a simple permanent ADRn-to-sensor mapping. Confirmed processing paths include:

- `0x4340/0x434F`: calibration `0x92CF` -> `0x203C/0x203E`, currently CTS-like.
- `0x4390/0x439F`: calibration `0x92D9` -> `0x2038/0x203A`, currently IAT-like.
- `0x41A1`: normalized load/MAP-like axis `0x2034`.
- `0x41D6`: transient/helper axis `0x2042`.

The lookup paths and inversion behavior are code-confirmed. Exact sensor pins and physical transfer equations are not.

## MOD2 calibration changes

| Region | Range | Changed bytes | Interpretation |
| --- | --- | ---: | --- |
| Checksum words | `0x800C-0x800F` | 4 | 0x4A65/0xB59A -> 0x47BE/0xB841 |
| Signed IAT/RPM correction A | `0x802B-0x8102` | 75 | +4..+6 signed raw counts |
| Signed IAT/RPM correction B | `0x8103-0x81DA` | 72 | +5..+18 signed raw counts |
| Primary limiter set/clear words | `0x879E-0x87A1` | 4 | 0x07EB/0x07EF -> 0x00FA/0xFFFF |
| Ignition retard/gain vector | `0x89F3-0x8A05` | 16 | +2..+18 raw counts |
| Likely high/default spark | `0x8A69-0x8B40` | 101 | +2..+20 raw = +1..+10 degrees |
| Likely low/alternate spark | `0x8B41-0x8C18` | 145 | +2..+18 raw = +1..+9 degrees |
| Load/air-charge factor | `0x9187-0x925E` | 62 | mixed raw changes; physical scaling remains provisional |

No MOD2 difference overlaps any of the 33,663 bytes in the configured executable graph. Combined with the reset-time calibration-window copy, the vector target at `0x9315`, and the fact that all changed bytes fall in known calibration/checksum regions, this strongly supports calibration-only modification without claiming an absolute proof from recursive disassembly alone.

## Corrections to the current repository notes

1. The main-loop stack-check instruction addresses are `D2EE: STS $24EA`, `D2F1: LDX $24EA`, and `D2F4: CPX $916A`; the loop-back jump is `D6A9: JMP $D2D9`.
2. The `0x5100/0x5200/0x5300` candidates are now tied to exact RTS-delimited hardware-I/O routines, not only broadly classified as executable.
3. All 479 MOD2 changes are calibration/support data or checksum words, and no byte outside the established calibration/data window changes.
4. The checksum verifier is incremental, processing one byte per periodic call.
5. The XDF should continue to keep `0x8000-0x9314` as data and must not expose discovered executable ranges as tune tables.
6. Firmware-support metadata should expose the complete 21-word vector table, expected stack-top word `0x916A = 0x27FF`, and checksum-service enable byte `0x916E = 0xFF` as non-tuning items.

## Confidence and remaining work

Confirmed means the instruction flow, data width, table base, or producer/consumer relationship is directly visible. “Strong” means the software role is constrained but the physical name or unit is not fully proven. “Open” means only a structural role is assigned.

Highest-priority unresolved items:

1. Identify the exact 68HC11 mask/variant and ECU PCB pin-to-peripheral wiring.
2. Prove the timer E-clock and prescaler before converting scheduler ticks to milliseconds or crank degrees.
3. Trace the complete knock/fallback path controlling `0x20B1`.
4. Prove the exact MAP ADC transfer behind `0x2034`.
5. Trace final injector and ignition driver pins with schematics or oscilloscope measurements.
6. Independently signature-map Xantia 607C and `RALLY13.ORI`; they are different firmware builds.
7. Validate limiter, spark-bank, and fuel-trim behavior on a bench or instrumented engine.

Static analysis is sufficient to reject false table boundaries and identify core algorithms, but not to make every raw support table safe to tune.
