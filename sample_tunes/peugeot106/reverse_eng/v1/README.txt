IAW 8P.40 Peugeot 106 reverse-engineering artifacts
Commit: 1270f0cc444eb16ce1987d60eba304a3e06b4af4
Decoded: 13734 instructions, 33663 instruction bytes, 192 code ranges

Files:
- IAW8P40_peugeot106_reverse_engineering_report.md: analysis and pseudocode
- IAW8P40_peugeot106_reachable_annotated.asm: recursive annotated listing
- IAW8P40_peugeot106_code_ranges.csv: conservative code-byte map
- IAW8P40_peugeot106_direct_calls.csv: direct call edges
- IAW8P40_peugeot106_symbols.csv: routine/RAM/ROM/I/O symbol database
- IAW8P40_peugeot106_vectors.csv: exact vector words and targets
- IAW8P40_stock_vs_MOD2_diff_regions.csv: exact stock/MOD2 calibration diffs
- iaw8p40_recursive_disassemble.py: reproducible core Capstone decode that writes a generic assembly listing and basic code ranges

The script requires `capstone>=5` and reproduces the core recursive decode only.
The checked-in annotated listing, symbols, call edges, vectors, difference
regions, and prose report are reviewed snapshot artifacts; their annotation and
report-generation pipeline is not included in this folder.

Firmware BIN files are intentionally not included.
