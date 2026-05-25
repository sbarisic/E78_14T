# Marelli IAW 8P.40 Peugeot 106 Stock vs MOD2 Analysis

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
| `0x802B-0x8102` | `75` changed cells inside signed `24x9` view | Code-referenced temp-like/RPM fuel correction A; X raw `0x92CF`, Y `0x929E` RPM, output `$204A` into `$204B -> $00C1` |
| `0x8103-0x81DA` | `72` changed cells inside signed `24x9` view | Code-referenced temp-like/RPM fuel correction B; X raw `0x92CF`, Y `0x929E` RPM, output `$204D` into `$204E/$204F` |
| `0x821C/0x8318/0x83F0` | signed fuel-trim candidate family | Code-referenced main fuel trim/multiplier candidates; `$E38B` selects `$2084`, and `$E715` applies it to `$00C1` |
| `0x802E/0x80EB/0x81A8/0x80F1` | overlapping changed legacy views | Alignment/debug probes only; do not tune as VE or main fuel |
| `0x879E-0x87A1` | `4` | Two changed 16-bit big-endian scalars |
| `0x89F3-0x8A05` | `16` changed cells inside a code-confirmed `1x19` vector | Compact interpolated vector indexed by `RAM 0x2044` |
| `0x8A68-0x8C17` plus `0x8C18` | `245` cells plus one adjacent byte | Large packed row block; likely important |
| `0x9187-0x925E` | `62` changed cells inside a code-confirmed `24x9` table | Load-model / correction-factor candidate; old `0x91D9` view was misaligned |

Repeatable script table stats for the corrected signed correction family:

| Range | Shape | Peugeot stock raw | MOD2 changes | Xantia same-offset raw | Current use |
| --- | --- | --- | --- | --- | --- |
| `0x802B-0x8102` | `24x9` signed | `-121..-8`, avg `-68.6` | `75 / 216`, `+4..+6`, avg `+5.4` | `-112..-28`, avg `-80.0` | Signed temp-like/RPM fuel correction A |
| `0x8103-0x81DA` | `24x9` signed | `-128..127`, avg `-22.8` | `72 / 216`, `+5..+18`, avg `+6.1` | `-54..74`, avg `-4.9` | Signed temp-like/RPM fuel correction B |
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
  `Load Model / Correction Factor Candidate 24x9 @ 0x9187`, but the exact
  strategy role remains unconfirmed.

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
- `MOD2 Compared Scalar Block 1x8 @ 0x879C`
- `Legacy Raw 0x8A68 Banked Block View 48x9`
- `Legacy Raw 1x32 View @ 0x8C18`

After TunerPro visual review, additional split views were added:

- `Signed Fuel Temp-like/RPM Correction A 24x9 @ 0x802B`
- `Signed Fuel Temp-like/RPM Correction B 24x9 @ 0x8103`
- `Main Fuel Trim / Multiplier Candidate A 24x9 @ 0x821C`
- `Main Fuel Trim / Multiplier Candidate B 24x9 @ 0x8318`
- `RPM-only Fuel Trim / Bypass Vector Candidate 1x24 @ 0x83F0`
- legacy alignment probes around `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1`
- `Code-Confirmed Spark Bank High/Default 24x9 @ 0x8A69`
- `Code-Confirmed Spark Bank Low/Alternate 24x9 @ 0x8B41`
- `Code-Referenced Control Scalars 1x6 @ 0x89ED`
- `Provisional RPM Load-Enrichment Gain 1x19 @ 0x89F3`
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
- `Load Model / Correction Factor Candidate 24x9 @ 0x9187`
- `Alternate RPM Thresholds @ 0x87A2/0x87A4`
- `Code-Referenced Axis Vector 1x9 @ 0x9291`
- `Code-Referenced Axis Vector 1x9 @ 0x92CF`
- `Code-Confirmed 2D Table 24x9 @ 0x869A`
- `Code-Confirmed 2D Table 24x9 @ 0x87B1`
- `Code-Confirmed 2D Table 24x9 @ 0x888E`
- `Code-Confirmed 2D Table 11x9 @ 0x9073`
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
  `Provisional RPM Load-Enrichment Gain 1x19 @ 0x89F3`, a code-confirmed
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
| `0x802B-0x8102` | `Signed Fuel Temp-like/RPM Correction A 24x9 @ 0x802B` | Code-referenced | X raw `0x92CF` temp-like labels, Y `0x929E` RPM labels, output `$204A` into `$204B -> $00C1`. |
| `0x8103-0x81DA` | `Signed Fuel Temp-like/RPM Correction B 24x9 @ 0x8103` | Code-referenced | Same axes as `0x802B`; output `$204D` feeds `$204E/$204F` blend path. |
| `0x821C-0x82F3` | `Main Fuel Trim / Multiplier Candidate A 24x9 @ 0x821C` | Code-referenced | Signed load/RPM trim candidate selected by `$E38B`; X=`$2034`, Y=`$2036`, output `$2084` applied to `$00C1` by `$E715`. |
| `0x8318-0x83EF` | `Main Fuel Trim / Multiplier Candidate B 24x9 @ 0x8318` | Code-referenced | Paired signed load/RPM trim candidate selected by `$E38B`; exact selector semantics remain provisional. |
| `0x83F0-0x8407` | `RPM-only Fuel Trim / Bypass Vector Candidate 1x24 @ 0x83F0` | Code-referenced | Signed RPM-only bypass vector that can feed `$2084`; not a standalone VE table. |
| `0x802E/0x80EB/0x81A8/0x80F1` | Legacy alignment probes | Debug only | Overlap the signed correction region; do not tune as VE or main fuel. |
| `0x89ED-0x89F2` | `Code-Referenced Control Scalars 1x6 @ 0x89ED` | Code-referenced | Direct scalar/control bytes. |
| `0x89F3-0x8A05` | `Provisional RPM Load-Enrichment Gain 1x19 @ 0x89F3` | Medium-high structure | Code-confirmed `0x2044`-indexed vector; X sites are `0-7200 rpm` in 400 rpm steps; MOD2 changes `16 / 19` cells. |
| `0x9187-0x925E` | `Load Model / Correction Factor Candidate 24x9 @ 0x9187` | Medium-high structural | Code-confirmed lookup that can feed `0x00D0 -> 0x00CE -> 0x2034`; not proven main fuel. |

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
scaled category. The remaining correction-factor/load-model names are still
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

- `0x802B` and `0x8103` are now the code-referenced signed temp-like/RPM fuel
  correction candidate tables in this region.
- `0x802E` is a `+3` misaligned slice inside `0x802B`; it remains useful only
  as legacy visual context.
- A pure VE/base fuel table is still not proven, but `$821C/$8318` are now the
  strongest main fuel trim/multiplier candidates and `$00C1/$00C3/$00BC` are
  the strongest fuel pulse/event-width path candidates. OC1/OC3 scheduling is
  strong software evidence; exact driver/pin proof remains hardware-level.
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
  like a correction/load-model table than final main fuel.
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
  `IAW8P40_peugeot106_external_evidence.md`.
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
- `0x9187` remains the nearest functional correction/load-model candidate, but
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
