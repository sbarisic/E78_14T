# Marelli IAW 8P.40 Peugeot 106 First-Pass Markup

BIN analyzed:

- `E:\Projects\E78_14T\sample_tunes\peugeot106\M27C512_original.BIN`

High-confidence observations:

- File size is `0x10000` (`65536`) bytes, consistent with a full `27C512`.
- `0x0000-0x3FFF` is entirely zero.
- Real ROM content starts at `0x4000`.
- The last 16 bytes contain valid-looking `68HC11` vectors.
- This strongly suggests the EPROM contains executable firmware plus calibration data.

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
- Conservative descriptions only. No fuel/spark semantics are asserted yet.
- Added compact views for packed structures:
  - `0x86DB` as `8x15`
  - `0x88CA` as `8x19`
  - `0x8880` as `16x5`
- Added better-aligned row-based views:
  - `0x86DB` as `13x9`
  - `0x88CD` as `17x9`
- Added code-confirmed disassembly views:
  - `0x85BA` as `24x5`
  - `0x8A0A` as `5x5`
  - `0x8A69` and `0x8B41` as banked `24x9`
  - `0x9187` as `24x9`
  - the `0x2044`-indexed vector family at `0x89C7`, `0x89DA`, `0x89F3`, `0x8A27`, `0x8A3A`, and `0x8A52`

Recommended next steps:

1. Open the BIN with the new XDF in TunerPro.
2. Inspect `Candidate 17x9 Map @ 0x88CD` first.
3. Inspect `Candidate 13x9 Row Table @ 0x86DB` next.
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

Results:

- `1.3L_8V_IAW8P40_Stok.bin` is byte-identical to `M27C512_original.BIN`.
- `1.3L_8V_IAW8P40_MOD2.bin` differs from stock by `479` bytes across `87` runs.
- `4` of those bytes are checksum bytes at `0x800C-0x800F`.
- The remaining `475` changed bytes are calibration-looking changes.

Checksum offsets:

- `0x800C-0x800D`: checksum word, big-endian.
  - Stock: `0x4A65`
  - MOD2: `0x47BE`
- `0x800E-0x800F`: checksum complement / byte-sum target, big-endian.
  - Stock: `0xB59A`
  - MOD2: `0xB841`
- The two words sum to `0xFFFF`.
- The complement matches the additive byte sum over `0x4000-0xFFFF`; `0xB600-0xB7FF` is zero-filled.

MOD2-backed candidate offsets added to the XDF:

- `0x802E-0x81D4`: candidate `47x9` table.
- `0x802E-0x8105`: split view of the upper `24x9` section of the `47x9` table.
- `0x8106-0x81D4`: split view of the lower `23x9` section of the `47x9` table.
- `0x879C-0x87A3`: scalar block around changed 16-bit words.
- `0x879E`: changed 16-bit threshold scalar, stock `0x07EB`, MOD2 `0x00FA`.
- `0x87A0`: changed 16-bit threshold scalar, stock `0x07EF`, MOD2 `0xFFFF`.
- `0x89ED-0x89F2`: code-referenced control scalars.
- `0x89F3-0x8A05`: code-confirmed `1x19` interpolation vector; part of a larger `0x2044`-indexed vector family.
- `0x8A68`: code-confirmed signed offset byte, stock/MOD2 `0x00`.
- `0x8A69-0x8B40`: code-confirmed `24x9` 2D table bank.
- `0x8B41-0x8C18`: code-confirmed `24x9` 2D table bank.
- `0x8C18`: final cell of the `0x8B41` bank, stock `0x38`, MOD2 `0x3C`.
- `0x9187-0x925E`: code-confirmed `24x9` 2D table. The older `0x91D9-0x925F` `15x9` view is a legacy misaligned slice.

Useful direct-reference hints from byte/opcode context:

- `0x800E` is used by the checksum routine around `0x5AD8-0x5B17`.
- `0x879E` / `0x87A0` are referenced around `0x6F14-0x6F2A`.
- `0x89F3` is used as a 1D interpolation vector around `0xBAA8-0xBAB2`.
- `0x89ED`, `0x89F0`, `0x89F2`, `0x8A06`, and `0x8A08` are scalar/control bytes used around `0xBAA8-0xBB96`.
- `0x8A69` / `0x8B41` are selected as 2D table banks around `0x48EE-0x4941`.
- `0x8A68` is sign-extended as an optional offset around `0x492A-0x493E`.
- `0x9187` is loaded as a 2D table base around `0x6344-0x636A`; stride comes from `0x929A`.
- `0x925F` is referenced around `0x5E6B`.

Important caution:

- The MOD2-touched blocks are stronger candidates than visual-only blocks, but they are still raw reverse-engineering views.
- Do not label fuel, ignition, RPM, load, or temperature until code usage or live behavior confirms the meaning.
