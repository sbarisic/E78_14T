# Generated IAW8P40 Analysis Snapshots

This directory stores committed Markdown snapshots generated from the current
six local 64 KiB binaries:

- `M27C512_original.BIN`
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin`
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin`
- `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin`
- `Peug.106Rally.org.bin`
- `RALLY13.ORI`

Regenerate the snapshots after changing `tools/iaw8p40_analyze.py` or adding a
new same-family binary:

```powershell
python tools/iaw8p40_analyze.py --write-analysis
```

These files are generated evidence, not hand-authored conclusions. Use them for
Git diffs and review, then keep final interpretation in `LOGIC.md`,
`IAW8P40_peugeot106_disassembly_notes.md`, and `evidence_status.md`.
