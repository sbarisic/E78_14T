# Marelli IAW 8P.40 Peugeot 106 First-Pass Markup

BIN analyzed:

- `E:\Projects\E78_14T\sample_tunes\peugeot106\M27C512_original.BIN`

High-confidence observations:

- File size is `0x10000` (`65536`) bytes, consistent with a full `27C512`.
- `0x0000-0x3FFF` is entirely zero.
- Real ROM content starts at `0x4000`.
- The last 16 bytes contain valid-looking `68HC11` vectors.
- This strongly suggests the EPROM contains executable firmware plus calibration data.

External evidence note:

- `IAW8P40_peugeot106_external_evidence.md` now records the checked public
  sources from the deep-research report integration. Public material supports
  the Peugeot 106 1.3 Rallye / IAW 8P.40 application, `27C512` media, generic
  8P-family sensor/pin context, OldSkullTuning's public map-family checklist,
  and the 100 kPa MAP clue. It does not publish exact map offsets, so the
  offsets below remain local reverse-engineering findings.

Repeatable analysis note:

- `tools/iaw8p40_analyze.py` is a read-only script that loads all four
  available 64 KiB BINs and emits Markdown-friendly hashes, checksum words,
  reset vectors, diff regions, table stats, helper-call hints, and RAM/register
  references.
- Current script pass confirms:
  - Peugeot stock and folder `Stok` are byte-identical.
  - Peugeot stock checksum pair: `0x4A65/0xB59A`.
  - MOD2 checksum pair: `0x47BE/0xB841`.
  - Xantia 607C checksum pair: `0x9F83/0x607C`.
  - All four available BINs use reset vector `0xB800`.
  - Peugeot stock vs Xantia 607C differs by `42021` bytes, so Xantia remains
    same-family comparative support only.

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
  - `0x879E`, `0x87A0`, `0x87A2`, and `0x87A4` as RPM-scaled period thresholds
  - `0x9291` and `0x92CF` as code-referenced 9-byte axis vectors

Recommended next steps:

1. Open the BIN with the new XDF in TunerPro.
2. Inspect code-confirmed and MOD2-touched views first, especially
   `Likely Fuel/VE/Air-Charge Correction Candidate 21x9 @ 0x802E`,
   `Alternate 24-Row Boundary View for 0x802E Fuel/VE Candidate`,
   `Likely Fuel/Enrichment Lower Adjacent Candidate 23x9 @ 0x8106`,
   the likely spark maps, and
   `Load Model / Correction Factor Candidate 24x9 @ 0x9187`.
3. Inspect `Historical Slice Inside 0x888E Parent 17x9 @ 0x88CD` only as
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

- `0x802E-0x80EA`: `Likely Fuel/VE/Air-Charge Correction Candidate 21x9 @ 0x802E`.
  This is now the preferred working alignment for the visible fuel-side surface.
  MOD2 changes `57 / 189` cells, mostly by `+4`, `+5`, and `+6`.
  Peugeot stock raw range is `135-248`, about `52.9-97.3%` under the
  unconfirmed `raw / 2.55` visualization hypothesis. Xantia 607C at the same
  offset is `144-214`, about `56.5-83.9%`, supporting an engine-specific
  fuel/VE/air-charge interpretation without proving function.
- `0x802E-0x8105`: `Alternate 24-Row Boundary View for 0x802E Fuel/VE Candidate`.
  MOD2 changes `75 / 216` cells. Rows `21-23` may be adjacent calibration or
  tail data until code proves otherwise.
- `0x80EB-0x81A7`: `Public-Index Alignment Probe B 21x9 @ 0x80EB`.
  Script pass reports `60 / 189` MOD2-touched cells, but modulo-byte wraps and
  lack of direct code reference keep it below the primary `0x802E` candidate.
- `0x81A8-0x81D4`: `Public-Index Alignment Probe Tail 5x9 @ 0x81A8`.
  Script pass reports `30 / 45` MOD2-touched cells; keep as tail/alignment
  evidence only.
- `0x8106-0x81D4`: `Likely Fuel/Enrichment Lower Adjacent Candidate 23x9 @ 0x8106`.
  MOD2 changes `72 / 207` cells, mostly parent rows `35-46` and columns `0-5`.
- The old combined `47x9 @ 0x802E` XDF view was removed because the screenshot
  and byte pattern suggest two adjacent structures rather than one table.
- These labels are working names. `0x802E` is the strongest current fuel-side
  candidate, but it is not confirmed main fuel until a consumer path reaches
  injection pulse width, fuel time, lambda correction, air-charge calculation,
  or scheduling.
- `0x800A`: code-referenced spark-bank selector seed byte; stock `0x00` becomes runtime `0x20B1 = 0xFF` after decrement.
- `0x879C-0x87A3`: scalar block around changed 16-bit words.
- `0x879E`: changed 16-bit threshold scalar, stock `0x07EB`, MOD2 `0x00FA`.
- `0x87A0`: changed 16-bit threshold scalar, stock `0x07EF`, MOD2 `0xFFFF`.
- `0x87A2`: alternate period threshold, stock `0x1770`, about `2500 RPM`.
- `0x87A4`: alternate period threshold, stock `0x1979`, about `2300 RPM`.
- `0x869A-0x8771`: code-confirmed `24x9` 2D parent table; the old visual `0x86DB` slice lies inside it.
- `0x87B1-0x8888`: code-confirmed `24x9` 2D table; stock table is all zero.
- `0x888E-0x8965`: code-confirmed `24x9` 2D parent table; the old visual `0x88CD` slice lies inside it.
- `0x8E6F-0x8EC3`: code-confirmed bounded `17x5` 2D table view.
- `0x8EC7-0x8F1B`: code-confirmed bounded `17x5` 2D table view.
- `0x8F1C-0x8F70`: code-confirmed bounded `17x5` 2D table view.
- `0x8F71-0x8FC5`: code-confirmed bounded `17x5` 2D table view.
- `0x9073-0x90D5`: code-confirmed `11x9` 2D table.
- `0x89ED-0x89F2`: code-referenced control scalars.
- `0x89F3-0x8A05`: `Likely Speed/Transient Correction Vector 1x19 @ 0x89F3`;
  code-confirmed `1x19` interpolation vector and part of a larger
  `0x2044`-indexed vector family.
- `0x8A68`: code-confirmed signed offset byte, stock/MOD2 `0x00`.
- `0x8A69-0x8B40`: code-confirmed `24x9` 2D table bank; likely
  high-octane/default spark advance.
- `0x8B41-0x8C18`: code-confirmed `24x9` 2D table bank; likely
  low-octane/alternate spark advance.
- `0x8C18`: final cell of the `0x8B41` bank, stock `0x38`, MOD2 `0x3C`.
- `0x8C19-0x8C30`: code-confirmed RPM-only vector used when `RAM 0x00A9 bit 0x20` bypasses the banked maps.
- `0x9187-0x925E`: `Load Model / Correction Factor Candidate 24x9 @ 0x9187`;
  code-confirmed `24x9` 2D table. The older `0x91D9-0x925F` `15x9` view was a
  legacy misaligned slice and has been removed from the normal XDF tree. The
  retained view uses screenshot-assisted `raw / 230` scaling. Current trace
  shows it can seed `0x00D0`, then `0x00CE`, then the load/MAP-like axis
  `0x2034`, so it is probably correction/load-model related rather than proven
  main fuel.
- `0x929E-0x92CD`: code-confirmed period/RPM axis for `0x2036`; count byte is `0x92CE = 0x18`.
- `0x9291-0x9299`: code-referenced 9-byte axis vector; count byte is `0x929A = 0x09`.
- `0x92CF-0x92D7`: code-referenced 9-byte axis/vector; nearby count byte is `0x92D8 = 0x09`.
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
  sensor, supporting the provisional `0x2034` MAP/load labels `0-1024` used on
  the likely spark maps.
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
- `0x89F3` is used as a 1D interpolation vector around `0xBAA8-0xBAB2`.
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
