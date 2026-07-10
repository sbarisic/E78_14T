# Marelli IAW 8P.40 Peugeot 106 EPROM Notes

This directory contains reverse-engineering notes and calibration evidence for the Peugeot 106 1.3 Rallye Marelli IAW 8P.40 27C512 image.

## Documents

- `LOGIC.md` - firmware behavior, disassembly notes, map candidates, offset markup, checksum logic, and XDF implementation notes.
- `EVIDENCE.md` - evidence status, external/public-source references, sensor clues, comparison evidence, XDF crash-bisect notes, and generated analyzer snapshots.
- `reverse_eng/IAW8P40_peugeot106_reverse_engineering_report.md` - latest conservative executable-code pass, pseudocode, code/data boundary findings, and remaining proof items.

## Key Local Files

- `M27C512_original.BIN` - local stock EPROM read.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin` - internet stock duplicate; byte-identical to the local read.
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin` - direct tuned-vs-stock comparison image.
- `IAW8P40_peugeot106_firstpass.xdf` - current broad TunerPro definition.
- `IAW8P40_peugeot106_tunerpro_safe_v014.xdf` - safer TunerPro-focused definition.
- `tools/iaw8p40_analyze.py` - read-only comparison/scanner used to regenerate the analyzer snapshot inside `EVIDENCE.md`.
- `reverse_eng/` - annotated recursive disassembly snapshot, code ranges, direct-call edges, symbols, vectors, and exact stock/MOD2 difference regions.

## Regeneration

```powershell
python tools/iaw8p40_analyze.py --write-analysis
```

The command updates only the generated-analysis block in `EVIDENCE.md`. Console-only section output is still available with `--section`.

## Current Interpretation

- `LOGIC.md` is the source of truth for local code paths, offsets, and XDF naming confidence.
- `EVIDENCE.md` separates confidence, public-source context, same-family comparison evidence, and generated scanner output.
- Public pages and same-family binaries are supporting evidence only. Local disassembly, MOD2 deltas, axes, and controlled behavior remain the authority for Peugeot offsets.

## Safety

This XDF and the notes are for reverse engineering and inspection. Treat spark labels as strong working names, but do not treat fuel/correction candidates as confirmed main-fuel tuning targets without more disassembly, known map-pack evidence, live behavior, or bench/test validation.
