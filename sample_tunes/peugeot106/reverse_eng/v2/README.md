# IAW 8P.40 Peugeot 106 annotated assembly and symbol database v2

This package focuses on the two artifacts requested after the reproducibility review:

1. the annotated Motorola 68HC11 assembly;
2. the symbol database.

It does **not** claim to reproduce the binary-to-disassembly phase without an external decoder. Instead, it makes the annotation phase completely reproducible with Python's standard library.

## Files

- `IAW8P40_peugeot106_reachable_raw.asm` — numeric/raw reachable-code listing used as the stable annotation input.
- `IAW8P40_peugeot106_symbols_source_v2.csv` — canonical symbol source. Human-reviewed names and generated placeholder routine names are distinguished by the `generated` column.
- `IAW8P40_peugeot106_reachable_annotated_v2.asm` — generated symbolic assembly.
- `IAW8P40_peugeot106_symbols_v2.csv` — generated resolved symbols with inbound-call counts and caller addresses.
- `IAW8P40_peugeot106_symbols_v2.sqlite` — queryable symbols, direct-call xrefs, vectors, and `routine_call_summary` view.
- `generate_annotations.py` — standard-library annotation/database generator.
- `verify_reproducibility.py` — regenerates all three outputs in a temporary directory and checks SHA-256 equality.
- `ANNOTATION_NOTES.md` — changes, confidence boundaries, and remaining work.

## Reproduce

From this directory:

```text
python generate_annotations.py \
  --raw-asm IAW8P40_peugeot106_reachable_raw.asm \
  --symbols IAW8P40_peugeot106_symbols_source_v2.csv \
  --out-asm IAW8P40_peugeot106_reachable_annotated_v2.asm \
  --out-csv IAW8P40_peugeot106_symbols_v2.csv \
  --out-sqlite IAW8P40_peugeot106_symbols_v2.sqlite
```

Verification:

```text
python verify_reproducibility.py
```

No third-party Python modules are required for these commands.

## Symbol confidence

- `confirmed` — direct instruction-flow or standard 68HC11-register evidence.
- `strong` — strong producer/consumer or call-context evidence, but physical hardware meaning is not completely proven.
- `working` — useful working name with unresolved physical interpretation.
- `open` — subsystem or state-machine role is still unresolved.
- `unclassified` — stable symbol automatically created for a reachable direct-call or vector target.

The database deliberately keeps provisional names provisional. In particular, O2/lambda, exact injector/coil pins, timer tick duration, and exact pressure/temperature engineering units still need hardware or live-data proof.
