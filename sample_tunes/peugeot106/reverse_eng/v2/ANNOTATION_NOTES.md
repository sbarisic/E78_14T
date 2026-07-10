# Annotation pass v2 notes

## Main improvements

The annotated assembly now uses symbolic operands directly for known RAM, MCU I/O, calibration data, routine entries, and local branch targets. Every classified routine receives a generated header containing its range, confidence, subsystem, callers, callees, description, and evidence source.

The symbol database now contains:

- 521 total symbols;
- 356 routine entries;
- 86 RAM symbols;
- 44 ROM/calibration symbols;
- 35 MCU or external-I/O symbols;
- 680 direct-call cross-references;
- 21 vector entries.

Of the routine entries, 144 have semantic names and 212 remain stable `sub_XXXX` placeholders. Placeholder symbols are explicitly marked `generated=true` and `confidence=unclassified` rather than being presented as understood logic.

## Newly classified routines

This pass adds structural annotations for several high-use helpers and previously generic control paths, including:

- `0x43BA update_filtered_o2_and_shared_axis`
- `0x43DC sample_and_filter_o2_candidate`
- `0x43F3 build_shared_axis_2040`
- `0x4C36 sci_prepare_tx_state`
- `0x4C5B sci_command_state_machine`
- `0x4D21 sci_transmit_service`
- `0x58F2 update_descriptor_state`
- `0x5982 dispatch_descriptor_action`
- `0xB3F6 iir_step_u8_to_q8_8`
- `0xB407 iir_step_s16`
- `0xB42F saturating_u8_gain_product`
- `0xBD6E service_transfer_state_machine`
- `0xBDEC reset_service_transfer_state`
- `0xCAC5 clamp_d_to_range_at_x`
- `0xCD6D adaptive_trim_slew_update`
- `0xD00F clamp_word_delta_to_s8_range`
- `0xD03C adaptive_cell_update_setup`
- `0xD04C adaptive_cell_update_worker`
- `0xE6DA scaled_u16_multiply_accumulate`
- `0xEFC0 load_12bit_descriptor_word`
- `0xEFC8 compare_abs_delta_to_limit`

These names describe observed software behavior and avoid claiming unproved actuator or sensor identities.

## Data typing improvements

ROM tables are no longer represented as one-byte symbols. The database records table/vector size, element width, signedness, rows, columns, and subsystem for the known calibration structures. Examples include the 24x9 spark and signed-fuel tables, 17x9 temperature corrections, 1x24 RPM vectors, 1x9 word scheduler vector, and the 24-word RPM period axis.

Important Q8.8 and 16-bit RAM variables now have explicit two-byte ranges, including the RPM/load axes, shared scheduler axis, fuel accumulator, engine period, adaptive trim, and main-loop timer words.

## Remaining high-value work

The next semantic pass should prioritize the unclassified high-fan-in routines rather than merely naming low-use leaf functions. The best targets are the descriptor engine around `0x58F2-0x59F4`, arithmetic helpers near `0xEFB6-0xEFFF`, adaptive update helpers around `0xCD00-0xD0C8`, and ignition/output scheduling around `0x7C00-0x7Fxx` and `0xBC00-0xBE00`.

Hardware-dependent labels must remain provisional until ECU pin tracing, scope captures, or synchronized logs establish exact channel identities and timer scaling.
