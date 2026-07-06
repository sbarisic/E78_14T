# Opel Astra E78 OS 12644082 Relocation Report

Target file: `C:\Projects\E78_14T\tunes\astra_j_14t_2\opel_astra_original.bin`
Target SHA256: `2E562B30BB48A72205F9DD4756E152BC44EEF6B07D2F76F3FE25E222952824CD`

No bytes were changed in the target binary. This report records table-location work for using the existing E78 XDFs against this OS.

## Segment IDs

| Bin | Boot/OS | Calibration segment IDs |
|---|---:|---|
| `astra_j_14t_2/opel_astra_original.bin` | boot `12639237`, OS `12644082` | `55581104`, `55581157`, `55581159`, `55581098`, `55581092` |
| `astra_j_14t/Astra J A14NET- ECU Orig.bin` | boot `12647136`, OS `12654130` | `55593471`, `55593462`, `55593475`, `55593457`, `55593447` |
| `AcDelco E78 Full/Corsa E 1.4T 2016 150hp_exported.bin` | boot `12647136`, OS `12669508` | exported/trimmed layout; comparable tables are often shifted by about `-0x158` from full-flash Corsa 2019 addresses |

## High/Medium Confidence Relocations

See [`relocations_high_confidence.csv`](relocations_high_confidence.csv) for machine-readable rows.

| Source XDF | Item | Source | Target | Confidence | Notes |
|---|---|---:|---:|---|---|
| `E78_Adam.xdf` | KeIMOC_t_AutoLearnDly `const` | `0x021838` | `0x02158C` | medium | Target direct address is zero-filled; anchor relocation plausible but verify before editing. |
| `E78_Adam.xdf` | KeIMOC_t_ToolLearnDly `const` | `0x02183C` | `0x021590` | medium | Target direct address is zero-filled; anchor relocation plausible but verify before editing. |
| `E78_Adam.xdf` | KfTCSC_Pct_TorqRdctThrsh `const` | `0x0363A4` | `0x033C8C` | medium | Relocated from nearby unique 128-byte anchor. |
| `E78_Adam.xdf` | KfTCSC_n_TCR_EngSpdStallHi `const` | `0x0363A6` | `0x033C8E` | medium | Relocated from nearby unique 128-byte anchor. |
| `E78_Adam.xdf` | KfTCSC_n_TCR_EngSpdStallLo `const` | `0x0363A8` | `0x033C90` | medium | Relocated from nearby unique 128-byte anchor. |
| `E78_Adam.xdf` | KfTCSC_t_MinTC_EngRunTime `const` | `0x0363AA` | `0x033C92` | medium | Relocated from nearby unique 128-byte anchor. |
| `E78_Adam.xdf` | Scavenging scalar cluster `mixed` | `0x04815C-0x0481B0` | `0x04E64C-0x04E690` | medium | Target matches Astra-ref cluster shape, not the Corsa2019 E78_Adam layout exactly; do not blindly apply every scalar name. |
| `E78_Adam.xdf` | t_ShortPulseAdjust2 `z` | `0x056EE4` | `0x05CE0E` | medium | Target values differ, but table shape and adjacent structure match. |
| `E78_Adam.xdf` | t_PulseWidthShortLimit `const` | `0x056F34` | `0x05CE5E` | medium | Target values differ, but table shape and adjacent structure match. |
| `E78_Adam.xdf` | t_PulseWidthShortLimit2 `const` | `0x056F38` | `0x05CE62` | medium | Target values differ, but table shape and adjacent structure match. |
| `E78_Adam.xdf` | t_ShortPulseAdjust `z` | `0x056F3C` | `0x05CE66` | medium | Target values differ, but table shape and adjacent structure match. |
| `E78_Adam.xdf` | KaTHMC_T_EngCool `z` | `0x078200` | `0x077B9E` | high | Exact 128-byte context match. |
| `E78_Adam.xdf` | KaTHMC_T_EngCool axis/labels `x/z` | `0x078238` | `0x077BD6` | high | Exact 128-byte context match. |
| `E78_Adam.xdf` | KtTCSI_Scl_TorqueReserve `z` | `0x07A864` | `0x079974` | high | Exact table/context match. |

## Unsafe / Not Relocated

- `?? Intake Cam Idle` and `?? Exhaust Cam Idle` from `E78_Adam.xdf`/`E78_Test.xdf` were not considered safe to relocate. The nearest structural anchor suggested `0x06FACC`/`0x06FAF0`, but the target bytes there are not the same 8-bit table format.
- `KeSTRC_b_StarterInDevelopment` was not considered safe to relocate. Anchor inference landed around erased `0xFF` space.
- The scavenging scalar cluster is present around `0x04E64C-0x04E690`, but it matches the Astra reference layout more closely than the Corsa 2019 `E78_Adam.xdf` layout. Treat individual names after the first few scalars as requiring manual validation.

## Binary Edit Status

The target bin was left unchanged. Before patching it, specify the actual requested calibration changes, for example donor table/value, desired scalar value, or whether a target table should be copied from the Astra reference or Corsa 150hp file. Any binary patch will also need segment checksum/CVN handling before flashing.
