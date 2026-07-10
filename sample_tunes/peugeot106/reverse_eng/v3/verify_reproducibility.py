#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
EXPECTED = {
    'asm': ROOT / 'IAW8P40_peugeot106_reachable_annotated_v3.asm',
    'csv': ROOT / 'IAW8P40_peugeot106_symbols_v3.csv',
    'sqlite': ROOT / 'IAW8P40_peugeot106_symbols_v3.sqlite',
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    subprocess.run([sys.executable, str(ROOT / 'test_generator.py')], cwd=ROOT, check=True)
    with tempfile.TemporaryDirectory() as temp_dir:
        temp = Path(temp_dir)
        generated = {
            'asm': temp / 'annotated.asm',
            'csv': temp / 'symbols.csv',
            'sqlite': temp / 'symbols.sqlite',
        }
        subprocess.run([
            sys.executable, str(ROOT / 'generate_annotations.py'),
            '--raw-asm', str(ROOT / 'IAW8P40_peugeot106_reachable_raw.asm'),
            '--symbols', str(ROOT / 'IAW8P40_peugeot106_symbols_source_v3.csv'),
            '--out-asm', str(generated['asm']),
            '--out-csv', str(generated['csv']),
            '--out-sqlite', str(generated['sqlite']),
        ], check=True)

        failed = False
        for key in ('asm', 'csv', 'sqlite'):
            expected_hash = digest(EXPECTED[key])
            generated_hash = digest(generated[key])
            status = 'OK' if expected_hash == generated_hash else 'MISMATCH'
            print(f'{key}: {status} expected={expected_hash} generated={generated_hash}')
            failed |= expected_hash != generated_hash
        return 1 if failed else 0


if __name__ == '__main__':
    raise SystemExit(main())
