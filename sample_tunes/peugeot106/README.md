# Marelli IAW 8P.40 Peugeot 106 EPROM Notes

This folder contains a readout from a Marelli `IAW 8P.40` ECU used on a Peugeot 106, plus a first-pass TunerPro XDF created to inspect the ROM.

## Files

- `M27C512_original.BIN`
  - Original EPROM read.
  - Size: `65536` bytes / `0x10000`, matching a full `27C512`.

- `IAW8P40_peugeot106_firstpass.xdf`
  - TunerPro definition, now updated to comparison markup version `0.21`.
  - Contains raw table views, candidate table views, checksum constants, MOD2-touched candidate views, a `Confirmed` category for code-confirmed spark/supporting axis views, axis views, and 68HC11 vector markers.
  - This is an inspection XDF, not a fully decoded calibration definition yet.

- `IAW8P40_peugeot106_offsets.md`
  - Short offset summary generated during the first investigation pass.

- `IAW8P40_peugeot106_comparison_analysis.md`
  - Stock-vs-MOD2 comparison notes.
  - Documents duplicate stock file confirmation, checksum behavior, changed regions, code-reference hints, and new XDF entries.

- `IAW8P40_peugeot106_disassembly_notes.md`
  - 68HC11 disassembly findings.
  - Documents reset flow, checksum routine, interpolation helpers, code-confirmed map/vector structures, and corrected XDF interpretations.

- `LOGIC.md`
  - Living firmware-logic map.
  - Describes boot flow, main loop, timer/ADC preprocessing, normalized axes, interpolation helpers, confirmed table usage, output scheduling, and open reverse-engineering targets.

- `evidence_status.md`
  - Compact confidence table for important offsets and map candidates.
  - Separates code-confirmed, MOD2-touched, Xantia-comparable, and diagnostic-only structures.

- `IAW8P40_peugeot106_external_evidence.md`
  - Verified public-source notes from the deep-research report integration.
  - Separates public evidence, report-only leads, local code confirmation, and
    still-unconfirmed map-family targets.

- `analysis/`
  - Generated analyzer snapshots that are safe to review in Git diffs.
  - Regenerate with `python tools/iaw8p40_analyze.py --write-analysis`.

- `1_3L_8V_IAW8P40/`
  - Internet comparison files.
  - `1.3L_8V_IAW8P40_Stok.bin` is byte-identical to `M27C512_original.BIN`.
  - `1.3L_8V_IAW8P40_MOD2.bin` is the same ROM family with modified calibration/checksum bytes.

- `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin`
  - Same-family IAW 8P.40 comparison binary.
  - Used only as comparative support; it does not confirm Peugeot offsets by itself.

- `Peug.106Rally.org.bin`
  - Public/tuned-looking Peugeot comparison image.
  - Size and reset vector look compatible, but checksum validation fails and
    `0x0000-0x3FFF` is not zero-filled, so treat it as suspicious evidence.

- `RALLY13.ORI`
  - Valid same-family 64 KiB comparison image.
  - Checksum pair is valid and reset vector is `0xB800`; use as comparative
    evidence only, not as Peugeot offset authority.

- `tools/iaw8p40_analyze.py`
  - Read-only repeatable analysis script for all six available 64 KiB images.
  - Emits Markdown-friendly hashes, checksum words, reset vectors, diff regions,
    known-table stats, same-offset comparison data, immediate
    reference hints, helper-call scans, and RAM/register reference scans.
  - Can also write committed snapshots under `analysis/`.

- `tools/iaw8p40_checksum.py`
  - Calculates or repairs the IAW8P40 checksum pair.
  - Repair mode writes only a new output file and refuses protected source filenames.

## Main ROM Observations

- The BIN is exactly `64 KiB`, consistent with a full `27C512` EPROM image.
- `0x0000-0x3FFF` is zero-filled.
- Real content starts at `0x4000`.
- The image contains dense code/data through most of `0x4000-0xEFFF`.
- The end of the file contains valid-looking `68HC11` interrupt/reset vectors.
- This strongly suggests the EPROM contains ECU executable firmware plus calibration data, not just map/calibration bytes.
- `tools/iaw8p40_analyze.py` confirms:
  - Peugeot stock and folder `Stok` are byte-identical.
  - Peugeot stock checksum words are `0x4A65/0xB59A`, summing to `0xFFFF`.
  - MOD2 checksum words are `0x47BE/0xB841`, also summing to `0xFFFF`.
  - Xantia 607C checksum words are `0x9F83/0x607C`, also summing to `0xFFFF`.
  - `RALLY13.ORI` checksum words are `0x7A41/0x85BE`, also summing to `0xFFFF`.
  - `Peug.106Rally.org.bin` stores `0x4A65/0xB59A`, but its byte sum is
    `0xE160`, so checksum validation fails.
  - All six available 64 KiB images use reset vector `0xB800`.

## 68HC11 Vector Area

The final vector values observed were:

- `0xFFF0 = 0x95F3`
- `0xFFF2 = 0x6405`
- `0xFFF4 = 0xB94D`
- `0xFFF6 = 0xB94D`
- `0xFFF8 = 0xB948`
- `0xFFFA = 0xB93D`
- `0xFFFC = 0xB942`
- `0xFFFE = 0xB800`

`0xFFFE = 0xB800` is likely the reset vector.

## Generated XDF Work

The first XDF pass started with broad raw `16x16` byte views over lower-entropy regions:

- `0x5100`
- `0x5200`
- `0x5300`
- `0x8200`
- `0x8300`
- `0x8600`
- `0x8700`
- `0x8800`
- `0x8E00`
- `0x9000`
- `0xB500`
- `0xFF00`

After inspecting TunerPro screenshots, `0x8600` and `0x8800` were clearly not normal `16x16` maps. They look like packed small tables, scalar/header bytes, and padding/clamp values.

## Current Strongest Candidates

The corrected view of the old `0x802E` region is now the signed temp-like/RPM
fuel correction pair at `0x802B` and `0x8103`. Both are code-referenced `24x9`
signed correction candidates.
Their X axis uses raw `0x92D9` helper labels into runtime `$2038`, their Y axis
uses the confirmed `0x929E` RPM labels into `$2036`, and their outputs are
`$204A` and `$204D`. These outputs feed the `$204B -> $00C1 -> $2051/$00C3`
fuel/charge time-path candidate. The exact temperature sensor identity and
final injector output channel remain provisional.

The strongest main fuel trim/multiplier candidates are now the signed load/RPM
tables at `0x821C` and `0x8318`, plus the RPM-only bypass vector at `0x83F0`.
Routine `$E38B` stores their selected signed result in `$2084`, and `$E715`
applies it to `$00C1`. A pure VE/base fuel table is still not proven.

`0x802E` is retained only as a legacy misaligned slice inside `0x802B`. The
smooth unsigned surface was a useful visual clue, but it should not be tuned as
VE or main fuel. `$00C1/$00C3/$00BC` are now the strongest fuel pulse/event-width
path candidates. OC1 schedules the interrupt, then OC3/PA5 is used as the timed
pulse-output channel; the exact driver transistor/connector pin remains
hardware-level proof.

### Candidate 17x9 Map @ `0x88CD`

Historical note: this was an early strong visual candidate, but later
disassembly showed it is a slice inside the code-confirmed `0x888E` parent
table. It is no longer the strongest candidate.

The region aligns well as `17` rows by `9` columns:

```text
0x88CD:   1   1   1   1   1   4   8  13  18
0x88D6:   1   1   1   2   3   7  11  18  28
0x88DF:   1   1   1   3   6  10  15  23  38
0x88E8:   1   1   1   5  10  19  29  35  38
0x88F1:   1   1   1   6  18  29  36  38  38
0x88FA:   1   1   1  11  23  32  38  38  38
0x8903:   1   1   1  13  23  32  38  38  38
0x890C:   1   1   1  10  24  35  38  38  38
0x8915:   1   1   1  14  27  36  38  38  38
0x891E:   1   1   1  13  25  35  38  38  38
0x8927:   1   1   1  12  26  35  38  38  38
0x8930:   1   1   1  24  38  38  38  38  38
0x8939:   1   1   1  38  38  38  38  38  38
0x8942:   1   1   1  38  38  38  38  38  38
0x894B:   1   1   1  38  38  38  38  38  38
0x8954:   1   1   1  38  38  38  38  38  38
0x895D:   1   6  21  38  38  38  38  38  38
```

Notes:

- This was first viewed incorrectly as `8x19 @ 0x88CA`.
- Re-aligning to `9` columns starting at `0x88CD` produced much cleaner row boundaries.
- The pattern changes at `0x8966`, which supports `0x88CD-0x8965` as a likely table boundary.
- Later disassembly superseded both early visual interpretations: the
  code-confirmed parent table starts at `0x888E` and is `24x9`. The bad `8x19 @
  0x88CA` XDF view has been removed, and the `17x9 @ 0x88CD` view is retained
  only as a historical slice.
- The values `0x01` and `0x26`/decimal `38` may be padding, lower/upper clamp values, or meaningful min/max calibration values.
- No fuel/spark/RPM/load meaning has been assigned yet.

### Legacy Visual Slice @ `0x86DB`

This region also aligns better as `9` columns.

```text
0x86DB:  48  48  48  48  48  48  48   0   0
0x86E4:  48  48  48  48  48  48  48   0   0
0x86ED:  48  48  48  48  48  48  48   0   0
0x86F6:  40  40  40  40  40  40  40   0   0
0x86FF:  32  32  32  32  32  32  32   0   0
0x8708:  26  26  26  26  26  26  26   0   0
0x8711:  24  24  24  24  24  24  24   0   0
0x871A:  22  22  22  22  22  22  22   0   0
0x8723:  22  22  22  22  22  22  22  17  17
0x872C:  24  24  24  24  24  24  24  16  16
0x8735:  24  24  24  24  24  24  24  19  19
0x873E:  26  26  26  26  26  26  26  26  26
0x8747:  26  26  26  26  26  26  26   0   0
```

Notes:

- This was first viewed as `8x15 @ 0x86DB`.
- The `13x9` view lines up better and ends before the zero-filled area at `0x8750`.
- This is no longer an active XDF entry because later disassembly confirmed it
  sits inside the larger `24x9 @ 0x869A` parent table.
- It may be a correction table, limiter table, or structured constant block.
- No physical units are known yet.

### Candidate Flag/Scalar Block @ `0x8880`

The region before `0x88CD` looks like setup/header/scalar data rather than a main map.

Important bytes:

```text
0x8880:   0   0   0   0   0   0   0   0   0   3   0 100  87  39   1   1
0x8890:   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
0x88A0:   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
0x88B0:   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
0x88C0:   1   1   1   1   1   1   1   1   1   1   4   7  12   1   1   1
```

Notes:

- The long run of `0x01` values suggests padding, masks, flags, or low-value calibration defaults.
- `0x88CA-0x88CC` holds `4, 7, 12`; these were originally included in the triangular table, but the cleaner table start appears to be `0x88CD`.
- The old `0x88CA` triangular XDF view was removed because it is a misleading
  off-axis slice inside the later code-confirmed `0x888E` parent table.

## Other Candidate Areas

These regions were flagged by entropy and visual structure but have not yet been broken down:

- `0x5100-0x53FF`
- `0x8200-0x83FF`
- `0x8E00-0x90FF`
- `0xB500-0xB5FF`

They remain worth inspecting in TunerPro.

## Things Confirmed So Far

- The EPROM is a full `27C512` image.
- The EPROM appears to contain executable ECU firmware.
- The reset vector points into the dense code region.
- `1.3L_8V_IAW8P40_Stok.bin` is byte-identical to `M27C512_original.BIN`.
- `1.3L_8V_IAW8P40_MOD2.bin` differs from stock in `479` bytes across `87` runs.
- `0x800C-0x800F` stores a checksum word and one's-complement word:
  - Stock: `0x800C = 0x4A65`, `0x800E = 0xB59A`
  - MOD2: `0x800C = 0x47BE`, `0x800E = 0xB841`
- The checksum complement matches the additive byte sum over `0x4000-0xFFFF`; the internal `0xB600-0xB7FF` hole is zero-filled.
- Early visual table-like structures were identified at `0x88CD` and `0x86DB`,
  but later disassembly showed those are inside larger code-confirmed parent
  tables. The duplicate `0x86DB` visual XDF views have been removed.
- MOD2 comparison adds stronger tune-touched candidates:
  - `0x802E` as upper `24x9` tune candidate and `0x80F1` as an adjacent
    signed `25x9` tune/correction candidate
  - `0x879E` / `0x87A0` as a code-confirmed threshold/hysteresis pair
  - `0x89ED-0x89F2` as code-referenced control scalars
  - `0x89C7`, `0x89DA`, `0x89F3`, `0x8A27`, `0x8A3A`, and `0x8A52` as a code-confirmed `0x2044`-indexed vector family
  - `0x8A68` as a code-confirmed signed offset byte
  - `0x8A69` and `0x8B41` as single retained code-confirmed/scaled likely
    spark advance entries with `raw / 2` degrees
  - `0x8A69` as likely high-octane/default spark and `0x8B41` as likely low-octane/alternate spark, based on stock selector behavior and high-load timing comparison
  - same-family spark alignment caveat: `RALLY13.ORI` carries the stock spark bundle shifted by `+0x1B` (`0x8A84`, `0x8B5C`, `0x8C34`), while `Peug.106Rally.org.bin` keeps the Peugeot stock offsets but heavily alters the two 2D spark banks
  - likely spark advance x-axis labels changed from placeholder `0-8` to rounded display-only MAP/load `0-100 kPa` labels
  - `0x800A` as the calibration byte that seeds runtime spark-bank selector `0x20B1`; stock `0x00` underflows to `0xFF`, selecting the `0x8A69` bank
  - `0x8C19` as a likely RPM-only/WOT spark advance vector with `raw / 2` degrees
  - `0x879E/0x87A0` as likely RPM limiter set/clear thresholds, stock about `7400/7386 RPM`
  - legacy raw `0x8A68` as `48x9`, now known to be off by one byte for true bank starts
  - `0x9187` as a single retained code-confirmed correction/load candidate with `raw / 230`; the older `0x91D9` view is only a legacy misaligned slice
- New disassembly also confirms:
  - `0x85BA` as a code-confirmed `24x5` 2D table
  - `0x8A0A` as a code-confirmed `5x5` 2D table
  - `0x869A` as a code-confirmed `24x9` parent table; the old visual `0x86DB` candidate is inside this parent
  - `0x87B1` as a code-confirmed `24x9` table
  - `0x888E` as a code-confirmed `24x9` parent table; the old visual `0x88CD` candidate is inside this parent
  - `0x9073` as a code-confirmed `11x9` table
  - `0x8E6F`, `0x8EC7`, `0x8F1C`, and `0x8F71` as a code-confirmed `17x5` table cluster
- External sensor references are collected in `IAW8P40_peugeot106_sensor_references.md`:
  - TU2J2/MFZ references list coolant temp, inlet air temp, knock, oxygen, crank, MAP, and throttle position sensors. Some generic sources mention vehicle speed, but the current `0x00D4 -> 0x2044` path is crank/RPM-derived.
  - Peugeot 106 1.3 Rallye MAP listings point to the Magneti Marelli PRT03 family; a PRT03/04 sheet gives `17-105 kPa`, supporting 100 kPa / 1 bar MAP-axis assumptions.
- The ROM contains diagnostic/service communication code:
  - SCI serial registers `0x102B-0x102F` are used for a packet/state-machine protocol.
  - `0x004B-0x005B` is an event/status queue managed by `0x5982`, `0x59A8`, `0x59CA`, and `0x59F4`.
  - `0xAA3F-0xAA78` maps command bytes such as `0xDD`, `0xF0`, `0x36`, `0x35`, `0x34`, `0xCC`, and `0x99` to response bytes.
  - The `0x55` response path enters special service mode `0xD80B` with `0x21A6 = 0x06`.
- Current high-priority logic conclusions:
  - `0x20B1` is now best named `spark_bank_selector_state`: nonzero selects likely high/default spark `0x8A69`, zero selects likely low/alternate spark `0x8B41`.
  - `0x00D0 -> 0x00CE -> 0x2034` is now documented as a load-model path: `0x00D0` is a load/air-charge byte, `0x00CE` is a raw load/aircharge word, and `0x2034` is the load/MAP-like 8.8 axis.
  - `0x2147` is now documented as a spark-angle accumulator/intermediate command that feeds byte outputs including `0x2001` and `0x2148`.
  - `0x58F2` and `0x5982` are documented as state/descriptor and diagnostic/event queue routines, not fuel/spark maps.
  - `0xBC12/0xBC90` are documented as 68HC11 timer output-compare scheduling, with actuator assignment still open.
- New XDF diagnostic/service raw views:
  - `0x55A0-0x55B1` as an 18-byte event-code table for observed event IDs `0x00-0x11`.
  - `0x9131-0x9169` as `19x3` state descriptor triples consumed by `0x58F2`.
- XDF deduplication:
  - Removed the old combined `47x9 @ 0x802E` view.
  - Removed duplicate raw spark entries at `0x8A69` and `0x8B41`.
  - Removed duplicate raw `0x9187` and old duplicate `0x86DB` visual views.
- Current axis/source tracing:
  - `0x2034` is derived from `RAM 0x00CE`, doubled, clamped to `0x07FF`, and best named `MAP/load kPa estimate`; the spark XDF labels display it as rounded integer `0-100 kPa` while exact ADC transfer remains open
  - `0x2036` is derived from period-like `RAM 0x00BA` through helper `0xB3B9` and best named the RPM-normalized axis
  - `0x929E-0x92CD` is the code-confirmed 24-entry period/RPM axis table for `0x2036`; `15000000 / period` gives about `550-7500 RPM`
  - `0x2044` is derived from RPM-like `RAM 0x00D4` and clamped to `0x1200`; it indexes 19-cell curves at 400 rpm sites from `0-7200 rpm`
  - `0x2046` is a secondary transient/state axis currently confirmed as an `0x8A0A` table axis
  - `0x92D9` raw labels `12, 20, 34, 57, 93, 142, 191, 227, 246` are used for the temperature-like `$2038` X axis on signed `0x802B/0x8103`
  - `0x92D9` and `0x92CF` are paired temperature-like helper breakpoint vectors; exact sensor assignments remain provisional
  - `0x00BA` appears to be a timer delta, `0x00D9 - 0x00B8`
  - `0x00CE` can be produced from `0x00D0 << 2`, where `0x00D0` can come from the `0x9187` lookup
- Current fuel/correction search status:
  - `0x802B` and `0x8103` are code-referenced signed `24x9` temp-like/RPM fuel correction candidates with X=`0x92D9` raw temp-like labels, Y=`0x929E` RPM labels, and outputs `$204A/$204D`
  - `0x802E` is retained only as a legacy misaligned slice inside the signed `0x802B` table; do not tune it as VE or main fuel
  - `0x80EB` is now treated as a signed boundary slice starting at `0x802B+0xC0` and crossing into `0x8103`; `0x81A8` and `0x80F1` remain legacy/alignment probes
  - `0x821C` and `0x8318` are the strongest signed load/RPM main fuel trim/multiplier candidates; `0x83F0` is the RPM-only bypass candidate
  - `$00C1/$00C3/$00BC` are the strongest fuel pulse/event-width path candidates; OC1 schedules the ISR and OC3/PA5 behaves like the timed pulse output, but exact driver/pin proof is still hardware-level
  - `0x9187-0x925E` is `Load Model / Correction Factor Candidate 24x9 @ 0x9187`; it is code-confirmed and MOD2-touched, but currently traces into `0x00D0 -> 0x00CE -> 0x2034`, so it looks more like a correction/load-model table than proven main fuel
  - `0x89F3-0x8A05` is `Provisional RPM Load-Enrichment Gain 1x19 @ 0x89F3`; MOD2 changes `16 / 19` cells and it remains a plausible load-model/transient/enrichment vector
  - screenshots alone are no longer enough to keep a view active when later code proves misalignment, so the misleading legacy `0x89F2` and `0x91D9` views were removed from the normal XDF tree
- Free-space scan:
  - `0xF021-0xFFD5` is the best current code-cave candidate, `4021` zero bytes before the vector table
  - `0xB600-0xB7FF` is `512` zero bytes and is skipped by the checksum routine
  - `0x0000-0x3FFF` is zero-filled but should not be assumed usable without ECU memory-map confirmation
- The current XDF is valid XML and was copied next to the BIN.

## Things Not Yet Known

- Which maps are fuel, idle, warmup, transient, or diagnostic. The main spark maps are now strong likely labels, but octane-bank naming remains provisional until knock/fallback logic is fully traced.
- Exact names for the larger parent tables that contain old visual slices such
  as `0x88CD` and `0x86DB`.
- Axis locations and axis scaling.
- Byte scaling for physical units.
- Whether any table values are signed.
- Whether MOD2's `0x91EC: 0xCD -> 0x6F` change is intentional; it is now known to be row 11, column 2 of the confirmed `0x9187` table.

## Recommended Next Steps

1. Run `python tools/iaw8p40_analyze.py --section all` after adding any new
   same-family BIN, then compare the emitted table/reference stats with these
   notes.
2. Open `M27C512_original.BIN` in TunerPro with `IAW8P40_peugeot106_firstpass.xdf`.
3. Inspect the `MOD2 Compared Candidates` category first:
   - code-confirmed `24x9 @ 0x8A69`
   - code-confirmed `24x9 @ 0x8B41`
   - code-confirmed `24x9 @ 0x9187`
   - code-confirmed `1x19 @ 0x89F3`
   - surrounding `0x2044` vector family entries
   - control scalars `1x6 @ 0x89ED`
   - legacy signed/misaligned probes around `0x802E`, `0x80EB`, `0x80F1`, and `0x81A8`
4. Inspect the `Confirmed` category next:
   - likely spark advance high-octane/default `24x9 @ 0x8A69`
   - likely spark advance low-octane/alternate `24x9 @ 0x8B41`
   - these now use rounded display-only MAP/load x labels `0, 13, 25, 38, 50, 63, 75, 88, 100 kPa`
   - likely WOT spark advance vector `1x24 @ 0x8C19`
   - signed temp-like/RPM fuel correction candidates `24x9 @ 0x802B` and `24x9 @ 0x8103`
   - signed main fuel trim/multiplier candidates `24x9 @ 0x821C`, `24x9 @ 0x8318`, and RPM-only bypass vector `1x24 @ 0x83F0`
   - code-confirmed RPM axis `1x24 @ 0x929E`
   - code-referenced helper axes `1x9 @ 0x9291` and `1x9 @ 0x92CF`
5. Inspect the `Scaled / Likely Named Views` category for remaining non-confirmed named views:
   - spark bank selector config `0x800A`
   - likely RPM limiter thresholds `0x879E/0x87A0`
   - load model / correction factor candidate `24x9 @ 0x9187`
6. Inspect the `Code-Confirmed Additional Tables` category:
   - `24x9 @ 0x869A`
   - `24x9 @ 0x87B1`
   - `24x9 @ 0x888E`
   - `11x9 @ 0x9073`
   - `17x5 @ 0x8E6F`, `0x8EC7`, `0x8F1C`, and `0x8F71`
7. Inspect the `Diagnostics / Service Data` category:
   - `0x55A0-0x55B1` event-code table
   - `0x9131-0x9169` state descriptor triples
8. Continue disassembling code around confirmed reference areas:
   - `0x48EE-0x4941` handles the banked `0x8A69/0x8B41` 2D table
   - `0x6344-0x636A` handles the code-confirmed `0x9187` 2D table
   - `0xBAA8-0xBB96` handles the `0x89ED-0x8A08` scalar/vector area
   - `0x6F14-0x6F2A` references `0x879E/0x87A0`
   - `0x5E33-0x5EA0` references descriptors around `0x913A` and scalars `0x925F-0x9261`
   - `0xA7D8-0xAFxx` handles SCI diagnostic/service protocol state
   - `0xD80B-D941` handles a special service loop entered by the serial handshake
   - `0x5D8D-0x5E80` ties the `0x9187` lookup to `0x00D0 -> 0x00CE -> 0x2034`
9. Confirm table axes, units, and signedness before assigning fuel names or removing the "likely" qualifier from spark/octane labels.
10. Recompute the checksum pair at `0x800C-0x800F` before burning or testing any edited EPROM.
11. Keep original BIN unchanged and create tuned copies with clear names.

## Custom Code Cave Notes

The stock EPROM image is fixed at `64 KiB`; it cannot be extended past `0xFFFF`
without hardware/address-decoder changes. Small custom logic is feasible only by
placing 68HC11 code into a verified cave, then patching an existing `JSR`/`JMP`
hook. The current best cave is `0xF021-0xFFD5`. Any patch outside
`0xB600-0xB7FF` requires checksum repair.

## Sensor Reference Notes

See `IAW8P40_peugeot106_sensor_references.md` for the current external sensor
inventory and source links. The most important current takeaway is that the
1.3 Rallye MAP sensor evidence supports treating `0x2034` as a MAP/load-like
axis, so the confirmed spark-map views now display it as a provisional
rounded integer `0-100 kPa` MAP/load estimate. The raw `0x2034` ADC transfer
is still open.

## External Evidence Notes

See `IAW8P40_peugeot106_external_evidence.md` for the integrated
deep-research-report follow-up. The checked public sources support the Peugeot
106 1.3 Rallye / IAW 8P.40 application, `27C512` EPROM workflow, generic
8P-family sensor/pin context, the public OldSkullTuning map-family checklist,
and the 100 kPa MAP-sensor clue. They do not publish exact map offsets, so
local code references and MOD2 deltas remain the authority for XDF naming.
The same file now also records BTDig/public-index filename leads such as
`106RALL2`, `16143.124`, and `9620697280`; those are research search terms only,
not downloadable evidence or offset proof.

XDF `0.31` labels the signed `0x802B` and `0x8103` tables as temp-like/RPM fuel
correction candidates with raw `0x92D9` temperature-like X labels and confirmed
`0x929E` RPM Y labels. It also adds signed main fuel trim/multiplier candidates
at `0x821C`, `0x8318`, the RPM-only bypass vector at `0x83F0`, sensor-axis views
for `0x92D9/0x92CF/0x400E`, and RPM-only mode spark vectors. Legacy and
historical probe tables now sit in the `Legacy` category so they can be filtered
out of normal tuning workflow. The old `0x802E`, `0x80EB`, `0x81A8`, and
`0x80F1` views remain legacy/alignment probes rather than primary fuel/VE
candidates; `0x80EB` is displayed signed because it starts at `0x802B+0xC0` and
crosses into `0x8103`. The misleading legacy `0x89F2` and `0x91D9` views are
intentionally removed from normal tuning workflow.

XDF `0.21` keeps the `0x802E` fuel-side interpretation unchanged, keeps the
`0.16` replacement of the bad lower `23x9 @ 0x8106` mid-row slice with a
smoother signed `25x9 @ 0x80F1` view, and documents the same-family spark
alignment caveat, and changes the signed `0x80F1` view to TunerPro native
signed storage flags instead of modulo math. It restores the `Confirmed`
category for code-confirmed spark/supporting axis entries after TunerPro RT
loaded the rounded integer labels successfully. The spark load-axis display
remains a rounded integer `0-100 kPa` view of runtime `0x2034`. The `0x8106`
start was three bytes into the row.

## Air-Density Screenshot Lead

The public TunerPro screenshot labelled `Air density correction factor by
temperature` was checked against the local Peugeot dumps as a `24x9` table.
The visible axes are RPM-like rows from about `750` to `9004` and temperature
columns from `-5` to `80` deg C, with factor-like cells from about `0.10` to
`1.11`.

No exact table match was found in `M27C512_original.BIN`,
`1.3L_8V_IAW8P40_Stok.bin`, or `1.3L_8V_IAW8P40_MOD2.bin`. The scan tried
normal, reversed, and transposed orientations with likely display equations
including `raw / 230`, `raw / 100`, `raw / 128`, and `raw / 200`.

The nearest functional local candidate remains
`Load Model / Correction Factor Candidate 24x9 @ 0x9187`, but its bytes do not
match the screenshot. Loose numeric matches around `0x8A9C` fall inside the
code-confirmed spark bank and are false positives. Do not rename any local table
as air-density correction until the IAT/CTS ADC path reaches a confirmed table
consumer.

## Practical Caution

This XDF is for reverse engineering and inspection only at this stage. Treat the spark labels as strong working names, but do not treat any fuel/correction candidate as confirmed main fuel until there is corroborating evidence from disassembly, known damos/map packs, live behavior, or controlled changes on a bench/test setup.
