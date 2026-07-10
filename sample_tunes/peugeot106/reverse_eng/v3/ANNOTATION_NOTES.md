# v3 annotation and symbol-database corrections

## Fixed ownership bug

The old ownership loop retained the most recent routine start indefinitely. It did not clear ownership after `end_address`, so later instructions inherited the wrong caller routine.

The corrected implementation assigns ownership only while the instruction lies within the explicit routine bounding span. It then verifies that the call site lies in a decoded code block belonging to that span.

The 19 affected direct calls are now owned by five explicit entry blocks:

| Owner | Bounding span | Direct call sites corrected |
| --- | --- | --- |
| `output_compare_scheduler_isr_6c6a` | `0x6C6A-0x6CFA` | `0x6C6A`, `0x6C78` |
| `periodic_service_isr_6cfb` | `0x6CFB-0x6D32` | `0x6CFB`, `0x6CFE`, `0x6D2F` |
| `timer_capture_isr_preamble_74ca` | `0x74CA-0x765F` | `0x750E`, `0x753E`, `0x7541`, `0x7555`, `0x7558` |
| `sci_service_runtime_loop_d80b` | `0xD80B-0xD828` | `0xD80C`, `0xD822`, `0xD824` |
| `timer_compare_isr_e080` | `0xE080-0xE0CB` | `0xE096`, `0xE09F`, `0xE0A8`, `0xE0AF`, `0xE0B3`, `0xE0BA` |

`sub_6C56` now owns only its real call at `0x6C56 -> 0x69B8`; it no longer claims calls after its `0x6C64` return.

## Non-contiguous routine spans

The following routine symbols are bounding spans with undecoded gaps. Their actual code extents are represented as blocks:

| Routine | Bounding span | Decoded bytes | Gap bytes | Code blocks |
| --- | ---: | ---: | ---: | --- |
| `mode_handler_68f3` | 81 | 46 | 35 | `0x68F3-0x691F`, `0x6943` |
| `sub_6A2C` | 60 | 45 | 15 | `0x6A2C-0x6A57`, `0x6A67` |
| `sub_A7DE` | 525 | 126 | 399 | `0xA7DE-0xA854`, `0xA9E4-0xA9EA` |
| `sci_service_55_entry` | 919 | 61 | 858 | `0xAAE0-0xAAEB`, `0xAB52-0xAB7B`, `0xAE70-0xAE76` |
| `closed_loop_adaptive_state_machine` | 2319 | 2042 | 277 | `0xC000-0xC441`, `0xC44C-0xC46C`, `0xC578-0xC90E` |
| `fuel_signed_trim_lookup` | 605 | 603 | 2 | `0xE38B-0xE57D`, `0xE580-0xE5E7` |

The assembly no longer prints a single ambiguous `Range:` line. It prints `Range kind`, `Bounding span`, `Decoded code blocks`, and coverage.

## Database changes

The SQLite `xrefs` table now includes `caller_routine`. Ownership is not inferred by consumers from ordering.

The `routine_blocks` table contains exact contiguous decoded extents. `symbols` now separates:

- `bounding_span_bytes`
- `decoded_bytes`
- `gap_bytes`
- `block_count`
- `range_kind`

The CSV exports the same layout fields and also includes outbound call sites and callee names.

## Regression checks

`test_generator.py` verifies:

1. every direct call owner contains the site within both the bounding span and a decoded code block;
2. all 19 formerly misattributed sites have the expected owner;
3. `sub_6C56` owns no later calls;
4. the six non-contiguous spans have the exact expected block layout;
5. the generated SQLite database has zero unowned direct calls.

## Remaining limitation

A bounding span can group code blocks connected by branches, jump tables, or manually established subsystem ownership. Block representation removes the false implication that gap bytes are code, but it does not by itself prove that every non-contiguous block belongs to one high-level source-language function. That distinction still requires deeper control-flow and jump-table reconstruction.
