# IAW 8P.40 Peugeot 106 annotated assembly and symbol database v3

This package contains the reproducible annotation and symbol-database stage for the Peugeot 106 Marelli IAW 8P.40 reachable-code listing. It uses only Python's standard library. It does not claim to reproduce the BIN-to-instruction decoding phase without an external 68HC11 decoder.

## v3 ownership correction

The v2 generator assigned each instruction to the latest preceding routine start and did not verify the routine's `end_address`. That caused 19 direct-call sites to be attributed to a routine that had already ended.

v3 derives ownership from explicit routine bounds and decoded code blocks:

```text
routine.address <= instruction.address <= routine.end_address
and
instruction.address belongs to one of that routine's decoded blocks
```

Five previously unnamed decoded entry blocks were added to the canonical symbol source so that all 19 call sites have defensible owners instead of being left unowned or attached to the preceding routine.

## Routine spans and code blocks

`address` and `end_address` are **bounding spans**, not an assertion that every byte in the interval is decoded code. The generator derives the authoritative code blocks from the raw listing.

Six routine spans are non-contiguous. They are stored explicitly in:

- the assembly header as `Decoded code blocks`;
- the resolved CSV as `range_kind`, `decoded_bytes`, `gap_bytes`, `block_count`, and `code_blocks`;
- SQLite table `routine_blocks` and view `routine_layout_summary`.

For routine rows, resolved `size_bytes` means decoded instruction bytes. `bounding_span_bytes` is kept separately. For ROM, RAM, and MCU symbols, `size_bytes` retains its normal data-object meaning.

## Files

- `IAW8P40_peugeot106_reachable_raw.asm` — numeric reachable-code listing used as the stable annotation input.
- `IAW8P40_peugeot106_symbols_source_v3.csv` — canonical names, bounding spans, confidence, and descriptions.
- `IAW8P40_peugeot106_reachable_annotated_v3.asm` — generated symbolic assembly with corrected call ownership and explicit block coverage.
- `IAW8P40_peugeot106_symbols_v3.csv` — resolved symbols, block layout, inbound and outbound xrefs.
- `IAW8P40_peugeot106_symbols_v3.sqlite` — symbols, routine blocks, direct calls with `caller_routine`, vectors, and query views.
- `generate_annotations.py` — generator; standard library only.
- `test_generator.py` — regression tests for the 19 ownership failures and six non-contiguous spans.
- `verify_reproducibility.py` — runs tests, regenerates all outputs, and compares SHA-256 hashes.
- `ANNOTATION_NOTES.md` — exact corrections and remaining interpretation limits.

## Reproduce

```text
python generate_annotations.py \
  --raw-asm IAW8P40_peugeot106_reachable_raw.asm \
  --symbols IAW8P40_peugeot106_symbols_source_v3.csv \
  --out-asm IAW8P40_peugeot106_reachable_annotated_v3.asm \
  --out-csv IAW8P40_peugeot106_symbols_v3.csv \
  --out-sqlite IAW8P40_peugeot106_symbols_v3.sqlite
```

Run regression and byte-for-byte reproducibility checks:

```text
python verify_reproducibility.py
```

No third-party Python modules are required for these commands.

## SQLite schema highlights

`xrefs.call_site` is the direct call instruction address. `xrefs.caller_routine` is nullable by design, although the current v3 corpus has zero unowned direct calls. `xrefs.callee` references the routine symbol.

`routine_blocks` contains one row for each contiguous decoded block. `symbols.range_kind` is either `contiguous-code`, `bounding-span`, or `data-object`.

Useful views:

- `routine_call_summary`
- `routine_layout_summary`
- `unowned_call_sites`

## Confidence boundary

Correct code ownership and block boundaries do not prove physical ECU meaning. Labels involving lambda/O2 identity, exact injector or coil channels, timer tick duration, pressure conversion, and temperature conversion remain at their stated confidence levels.
