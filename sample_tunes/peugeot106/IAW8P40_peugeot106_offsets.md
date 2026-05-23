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
