# Marelli IAW 8P.40 Peugeot 106 Stock vs MOD2 Analysis

Analysis date: 2026-05-23

## Input Files

Compared files:

| File | Size | SHA-256 | Notes |
| --- | ---: | --- | --- |
| `M27C512_original.BIN` | `65536` | `09e5d927bd6951ecf7b57f351ccd5d396dc95c191d12164f71671725b751a681` | Original local read |
| `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin` | `65536` | `09e5d927bd6951ecf7b57f351ccd5d396dc95c191d12164f71671725b751a681` | Byte-identical to `M27C512_original.BIN` |
| `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin` | `65536` | `d3e4a451edd236104c79190372fa1be1e45aad09398eabe6f7b7e1479d810855` | Same ROM family, modified calibration/checksum bytes |

Important result: the internet `Stok` BIN is exactly the same as the local original read. The `MOD2` file is therefore useful as a direct tuned-vs-stock comparison.

## Shared ROM Structure

All three files:

- Are exactly `0x10000` bytes / `64 KiB`.
- Have a zero-filled prefix from `0x0000-0x3FFF`.
- Have real content from `0x4000`.
- Have a zero-filled internal hole at `0xB600-0xB7FF`.
- Share the same 68HC11 vector values.

Vector values:

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
| `0x802E-0x81D4` | `147` changed cells inside a `47x9` view | Large MOD2-touched table candidate |
| `0x879E-0x87A1` | `4` | Two changed 16-bit big-endian scalars |
| `0x89F2-0x8A05` | `17` changed cells inside a `1x20` vector view | Compact vector or mini table |
| `0x8A68-0x8C17` plus `0x8C18` | `245` cells plus one adjacent byte | Large packed row block; likely important |
| `0x91D9-0x925F` | `62` changed cells inside a `15x9` view | Clean table-like block |

## MOD2-Touched Candidate: 47x9 @ `0x802E`

Proposed view:

```text
start: 0x802E
shape: 47 rows x 9 columns
end:   0x81D4
```

Why this alignment is useful:

- `0x802E + 47*9 - 1 = 0x81D4`.
- `0x81D5` begins a different-looking block.
- MOD2 changes selected cells in coherent row/column groups.
- Deltas are mostly `+4`, `+5`, `+6`, with one row group at `+18` if interpreted modulo 8-bit.

Changed row indexes in this view:

```text
10, 11, 13, 14, 15, 16, 17, 18,
21, 22, 23,
35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46
```

Notable pattern:

- Rows `14-17` are changed across all 9 columns by `+6`.
- Rows `35-44` mostly change columns `0-5` by `+5`.
- Row `45` changes columns `0-5` by `+18`.

The raw values wrap through `0xFF` in this region, so signed or modulo interpretation may matter. Do not assign physical units yet.

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

## MOD2-Touched Vector @ `0x89F2`

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

- `17` of the `20` bytes change.
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

## MOD2-Touched Candidate: 15x9 @ `0x91D9`

Proposed view:

```text
start: 0x91D9
shape: 15 rows x 9 columns
end:   0x925F
```

Why this alignment is useful:

- `0x91D9-0x925F` is exactly `135` bytes, or `15*9`.
- Rows are visually smooth table-like data.
- MOD2 changes `62` cells.
- A direct reference to the last byte/area `0x925F` was observed around `0x5E6B`.

Notable anomaly:

```text
0x91EC stock: 0xCD
0x91EC MOD2:  0x6F
```

In the `15x9` view this is row `2`, column `1`, and it is a `-94` raw-count change. It may be a deliberate smoothing correction, a copied tune artifact, or a suspicious outlier in the stock dump. It should not be assumed to be wrong until code usage and neighboring table meaning are known.

Regular delta patterns:

- Rows `4-8`: columns `1-4` increase by `+4`.
- Rows `9-12`: columns `1-4` increase by `+4/+7`, columns `5-7` increase by `+3`.
- Row `13`: column `5` increases by `+32`, much larger than surrounding changes.
- Row `14`: columns `2-7` increase by `+3`.

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
| `0x89F3` | `0xBAAB` | Code-confirmed 1D interpolation vector |
| `0x8A68` | `0x492E` | Optional signed offset byte |
| `0x8A69` / `0x8B41` | `0x4904-0x4927` | Code-confirmed banked 24x9 tables |
| `0x925F-0x9261` | `0x5E6A-0x5E9F` | Scalar/threshold bytes near 0x91xx descriptor region |

Some earlier naive byte-reference hits were false positives. For example, the apparent `0x802E` hit around `0xC620` decodes as `CPD #$FF80` followed by a branch and is not a real table reference.

## XDF Updates Made

`IAW8P40_peugeot106_firstpass.xdf` was updated to version `0.4`.

New categories:

- `Checksum`
- `MOD2 Compared Candidates`

New checksum constants:

- `Checksum Word @ 0x800C`
- `Checksum Complement @ 0x800E`

New MOD2-backed entries:

- `MOD2 Changed 16-bit Scalar A @ 0x879E`
- `MOD2 Changed 16-bit Scalar B @ 0x87A0`
- `MOD2 Changed Last Cell of 0x8B41 Bank @ 0x8C18`
- `Code-Confirmed Signed Offset Byte @ 0x8A68`
- `MOD2 Compared Candidate 47x9 Table @ 0x802E`
- `MOD2 Compared Scalar Block 1x8 @ 0x879C`
- `Legacy Raw 1x20 View @ 0x89F2`
- `Legacy Raw 0x8A68 Banked Block View 48x9`
- `Legacy Raw 1x32 View @ 0x8C18`
- `MOD2 Compared Candidate 15x9 Table @ 0x91D9`

After TunerPro visual review, additional split views were added:

- `MOD2 Compared 47x9 Upper Split 24x9 @ 0x802E`
- `MOD2 Compared 47x9 Lower Split 23x9 @ 0x8106`
- `Code-Confirmed Bank A 24x9 @ 0x8A69`
- `Code-Confirmed Bank B 24x9 @ 0x8B41`
- `Code-Referenced Control Scalars 1x6 @ 0x89ED`
- `Code-Confirmed 1D Vector 1x19 @ 0x89F3`

Rationale:

- The `47x9 @ 0x802E` view changes character after row `23`; the lower section contains wraparound-looking values when viewed unsigned.
- The `48x9 @ 0x8A68` view has a clear visual break at row `24`, making two `24x9` subviews easier to inspect.
- The original large views remain in the XDF for context, even where later disassembly refined the true boundaries.

After 68HC11 disassembly, the `0x8A68` split was corrected:

- `0x8A68` is a signed offset byte used conditionally by the routine at `0x48EE`.
- `0x8A69-0x8B40` is a code-confirmed `24x9` 2D table bank.
- `0x8B41-0x8C18` is a code-confirmed `24x9` 2D table bank.
- `0x8C18` is the last cell of the second bank, not an adjacent vector.

The `0x89F2` raw view was also refined:

- `0x89ED-0x89F2` are code-referenced control/scalar bytes.
- `0x89F3-0x8A05` is a code-confirmed `1x19` vector used by the 1D interpolation helper at `0xB2AB`.

The `0x879E/0x87A0` pair was confirmed as threshold/hysteresis data, not a map:

- `0x879E` is used in the flag-set compare.
- `0x87A0` is used in the flag-clear compare.
- Both affect `RAM 0x00A4 bit 0x10`.

All new table entries are raw byte views. No fuel, ignition, RPM, load, or temperature names have been asserted yet.

## Best Next Steps

1. Disassemble the checksum routine around `0x5AD8-0x5B17` and confirm the exact loop initialization.
2. Disassemble code around the direct references:
   - `0x492F` for `0x8A68`
   - `0xBB81` for `0x89F2`
   - `0x6F14-0x6F2A` for `0x879E/0x87A0`
   - `0x5E6B` for `0x925F`
3. In TunerPro, inspect the new `MOD2 Compared Candidates` category first.
4. Use the MOD2 deltas to infer which tables behave like fuel, spark, limiter, enrichment, or correction tables.
5. Before burning any edited EPROM, recompute the checksum pair at `0x800C-0x800F`.
