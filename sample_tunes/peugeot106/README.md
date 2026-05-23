# Marelli IAW 8P.40 Peugeot 106 EPROM Notes

This folder contains a readout from a Marelli `IAW 8P.40` ECU used on a Peugeot 106, plus a first-pass TunerPro XDF created to inspect the ROM.

## Files

- `M27C512_original.BIN`
  - Original EPROM read.
  - Size: `65536` bytes / `0x10000`, matching a full `27C512`.

- `IAW8P40_peugeot106_firstpass.xdf`
  - First-pass TunerPro definition.
  - Contains raw table views, candidate table views, and 68HC11 vector markers.
  - This is an inspection XDF, not a fully decoded calibration definition yet.

- `IAW8P40_peugeot106_offsets.md`
  - Short offset summary generated during the first investigation pass.

## Main ROM Observations

- The BIN is exactly `64 KiB`, consistent with a full `27C512` EPROM image.
- `0x0000-0x3FFF` is zero-filled.
- Real content starts at `0x4000`.
- The image contains dense code/data through most of `0x4000-0xEFFF`.
- The end of the file contains valid-looking `68HC11` interrupt/reset vectors.
- This strongly suggests the EPROM contains ECU executable firmware plus calibration data, not just map/calibration bytes.

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

### Candidate 17x9 Map @ `0x88CD`

This is currently the strongest map-like structure found.

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
- The values `0x01` and `0x26`/decimal `38` may be padding, lower/upper clamp values, or meaningful min/max calibration values.
- No fuel/spark/RPM/load meaning has been assigned yet.

### Candidate 13x9 Row Table @ `0x86DB`

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
- At least two packed table-like structures have been identified:
  - `0x88CD` as `17x9`
  - `0x86DB` as `13x9`
- The current XDF is valid XML and was copied next to the BIN.

## Things Not Yet Known

- Exact checksum algorithm and checksum storage address.
- Which maps are fuel, ignition, idle, warmup, transient, limiter, or diagnostic.
- Whether `0x88CD` and `0x86DB` are active engine calibration tables or structured lookup constants.
- Axis locations and axis scaling.
- Byte scaling for physical units.
- Whether any table values are signed.

## Recommended Next Steps

1. Open `M27C512_original.BIN` in TunerPro with `IAW8P40_peugeot106_firstpass.xdf`.
2. Inspect `Candidate 17x9 Map @ 0x88CD` first.
3. Inspect `Candidate 13x9 Row Table @ 0x86DB` next.
4. Compare nearby bytes before each candidate table to look for axis arrays, dimensions, or table descriptors.
5. Search code references to the surrounding address ranges in a 68HC11 disassembler.
6. Identify checksum behavior before editing and burning a modified EPROM.
7. Keep original BIN unchanged and create tuned copies with clear names.

## Practical Caution

This XDF is for reverse engineering and inspection only at this stage. Do not treat any candidate table as confirmed fuel or ignition until there is corroborating evidence from disassembly, known damos/map packs, live behavior, or controlled changes on a bench/test setup.
