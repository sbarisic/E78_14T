#!/usr/bin/env python3
"""Generate the annotated IAW 8P.40 assembly and symbol database.

This is the reproducible annotation stage. It requires only Python's standard
library and does not depend on Capstone.

Inputs:
  * a numeric/raw assembly listing with addresses and instruction bytes
  * the canonical symbol source CSV

Outputs:
  * annotated assembly
  * resolved symbol CSV with inbound call metadata
  * SQLite symbol/xref/vector database

The separate raw-disassembly stage may use Capstone, but this annotation stage
can be run in a stock Python installation.
"""
from __future__ import annotations

import argparse
import csv
import re
import sqlite3
from collections import defaultdict
from pathlib import Path

ADDR_LINE_RE = re.compile(r'^([0-9A-F]{4}):\s+([0-9A-F ]{2,20})\s+([.a-z0-9]+)\s*(.*)$', re.I)
HEX_RE = re.compile(r'\$([0-9a-fA-F]{1,4})')


def parse_addr(value: str) -> int:
    value = value.strip()
    return int(value, 16) if value.lower().startswith('0x') else int(value, 0)


def read_records(path: Path):
    records = []
    for line in path.read_text(encoding='utf-8').splitlines():
        m = ADDR_LINE_RE.match(line)
        if not m:
            continue
        address = int(m.group(1), 16)
        raw = ' '.join(m.group(2).split()).upper()
        mnemonic = m.group(3).lower()
        operand = m.group(4).split(';', 1)[0].rstrip()
        records.append((address, raw, mnemonic, operand))
    return records


def read_symbols(path: Path):
    rows = []
    with path.open(newline='', encoding='utf-8') as f:
        for r in csv.DictReader(f):
            x = dict(r)
            x['address'] = parse_addr(r['address'])
            x['end_address'] = parse_addr(r['end_address'])
            x['size_bytes'] = int(r['size_bytes']) if r.get('size_bytes','').isdigit() else None
            x['width_bits'] = int(r['width_bits']) if r.get('width_bits','').isdigit() else None
            x['rows'] = int(r['rows']) if r.get('rows','').isdigit() else None
            x['cols'] = int(r['cols']) if r.get('cols','').isdigit() else None
            x['generated'] = r.get('generated','false').lower() in {'1','true','yes'}
            rows.append(x)
    validate_symbols(rows)
    return sorted(rows, key=lambda r: (r['address'], r['kind'], r['name']))


def validate_symbols(rows):
    by_addr = {}
    by_name = {}
    for r in rows:
        if r['address'] in by_addr:
            raise ValueError(f"duplicate symbol address 0x{r['address']:04X}: {r['name']} and {by_addr[r['address']]}")
        if r['name'] in by_name:
            raise ValueError(f"duplicate symbol name {r['name']}: 0x{r['address']:04X} and {by_name[r['name']]:04X}")
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', r['name']):
            raise ValueError(f"invalid assembler symbol name: {r['name']}")
        by_addr[r['address']] = r['name']
        by_name[r['name']] = r['address']


def target_from_operand(operand: str):
    values = HEX_RE.findall(operand)
    return int(values[-1], 16) if values else None


def infer_calls_and_vectors(records):
    calls = []
    vectors = []
    for address, raw, mnemonic, operand in records:
        target = target_from_operand(operand)
        if target is None:
            continue
        if mnemonic in {'jsr', 'bsr'}:
            calls.append((address, target))
        if address >= 0xFFD6 and mnemonic == '.word':
            vectors.append((address, target))
    return calls, vectors


def is_control_transfer(mnemonic: str) -> bool:
    if mnemonic in {'jmp', 'jsr', 'bsr', 'bra'}:
        return True
    return mnemonic.startswith('b') and mnemonic not in {'bita', 'bitb'}


def make_context(records, symbols, calls):
    symbol_by_address = {r['address']: r for r in symbols}
    routines = {a:r for a,r in symbol_by_address.items() if r['kind'] == 'routine'}
    incoming = defaultdict(list)
    outgoing_site = defaultdict(list)
    for site, callee in calls:
        incoming[callee].append(site)
        outgoing_site[site].append(callee)

    routine_starts = sorted(routines)
    owner = {}
    current = None
    index = 0
    for address, *_ in records:
        while index < len(routine_starts) and routine_starts[index] <= address:
            current = routine_starts[index]
            index += 1
        if current is not None:
            owner[address] = current

    routine_calls = defaultdict(list)
    for site, target in calls:
        routine_owner = owner.get(site)
        if routine_owner is not None:
            routine_calls[routine_owner].append((site, target))

    local_targets = set()
    for address, raw, mnemonic, operand in records:
        if not is_control_transfer(mnemonic) or mnemonic in {'jsr', 'bsr'}:
            continue
        target = target_from_operand(operand)
        if target is not None and target not in routines:
            local_targets.add(target)
    local_names = {a: f'loc_{a:04X}' for a in local_targets}
    return symbol_by_address, routines, incoming, outgoing_site, routine_calls, local_names


def render_assembly(records, symbols, calls, vectors, output: Path):
    sym, routines, incoming, outgoing_site, routine_calls, local_names = make_context(records, symbols, calls)

    lines = [
        '; Marelli IAW 8P.40 Peugeot 106 1.3 Rallye',
        '; Reachable Motorola 68HC11 assembly — annotation pass v2',
        ';',
        '; Reproducible inputs:',
        ';   numeric/raw assembly listing',
        ';   canonical symbol source CSV',
        '; Generated by generate_annotations.py using only Python standard library.',
        '; Physical labels marked STRONG/WORKING remain hypotheses; CONFIRMED means direct code-flow support.',
        '',
        '; ============================================================================',
        '; EQUATES: MCU I/O, RAM and ROM data',
        '; ============================================================================',
    ]

    for kind, title in [('mcu_io','MCU / external I/O'), ('ram','RAM'), ('rom_data','ROM / calibration data')]:
        lines.append(f'\n; --- {title} ---')
        for r in symbols:
            if r['kind'] == kind:
                lines.append(f"{r['name']:<42} EQU ${r['address']:04X} ; [{r['confidence'].upper()}] {r['description']}")

    previous_end = None
    for address, raw, mnemonic, operand in records:
        if previous_end is None or address != previous_end:
            lines.append(f'\n        .org ${address:04X}')

        if address in routines:
            r = routines[address]
            callers = incoming.get(address, [])
            callees = []
            for _, target in routine_calls.get(address, []):
                if target not in callees:
                    callees.append(target)
            size = r['size_bytes'] if r['size_bytes'] is not None else r['end_address'] - r['address'] + 1
            lines.extend([
                '',
                '; -----------------------------------------------------------------------------',
                f"; {r['name']} @ ${address:04X} [{r['confidence'].upper()}] / {r['subsystem']}",
                f"; {r['description']}",
                f"; Range: ${address:04X}-${r['end_address']:04X} ({size} bytes)",
                '; Called by: ' + (', '.join(f'${x:04X}' for x in callers[:16]) if callers else 'vector/entry/none found'),
                '; Calls: ' + (', '.join(routines[t]['name'] if t in routines else f'${t:04X}' for t in callees[:16]) if callees else 'none found'),
                '; Evidence: ' + r['evidence'],
                '; -----------------------------------------------------------------------------',
                r['name'] + ':',
            ])
        elif address in local_names:
            lines.append(local_names[address] + ':')

        annotations = []
        original_operand = operand

        def replace_hex(match):
            text = match.group(0)
            digits = match.group(1)
            value = int(digits, 16)
            if len(digits) <= 2 and value in sym:
                annotations.append(text)
                return sym[value]['name']
            if value in routines:
                annotations.append(text)
                return routines[value]['name']
            if value in sym:
                annotations.append(text)
                return sym[value]['name']
            if value in local_names:
                annotations.append(text)
                return local_names[value]
            return text.upper()

        rendered_operand = HEX_RE.sub(replace_hex, operand)
        if mnemonic in {'ldx', 'ldy'}:
            decimal_immediate = re.fullmatch(r'#(-?\d+)', rendered_operand)
            if decimal_immediate:
                value = int(decimal_immediate.group(1)) & 0xFFFF
                if value in sym:
                    annotations.append('#' + decimal_immediate.group(1))
                    rendered_operand = '#' + sym[value]['name']

        comments = []
        if annotations:
            comments.append('orig ' + ', '.join(dict.fromkeys(annotations)))
        if address in outgoing_site:
            comments.append('call ' + ', '.join(routines[t]['name'] if t in routines else f'${t:04X}' for t in outgoing_site[address]))
        for digits in HEX_RE.findall(original_operand):
            value = int(digits, 16)
            if len(digits) <= 2:
                value &= 0xFF
            if value in sym and sym[value]['name'] not in rendered_operand:
                comments.append(f"${value:04X}={sym[value]['name']}")

        comment_text = ' ; ' + ' | '.join(dict.fromkeys(comments)) if comments else ''
        lines.append(f'{address:04X}:  {raw:<20} {mnemonic:<8} {rendered_operand}{comment_text}'.rstrip())
        previous_end = address + len(raw.split())

    lines.extend(['', '; ============================================================================', '; VECTOR SUMMARY', '; ============================================================================'])
    for slot, target in vectors:
        target_name = routines[target]['name'] if target in routines else f'${target:04X}'
        lines.append(f'; ${slot:04X} -> ${target:04X} {target_name}')

    output.write_text('\n'.join(lines) + '\n', encoding='utf-8')


def write_resolved_csv(symbols, calls, output: Path):
    incoming = defaultdict(list)
    for site, target in calls:
        incoming[target].append(site)
    columns = [
        'address','end_address','name','kind','subtype','size_bytes','width_bits','signed','rows','cols',
        'subsystem','confidence','inbound_xrefs','callers','description','evidence','aliases','generated'
    ]
    with output.open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=columns)
        writer.writeheader()
        for r in symbols:
            x = dict(r)
            x['address'] = f"0x{r['address']:04X}"
            x['end_address'] = f"0x{r['end_address']:04X}"
            x['size_bytes'] = '' if r['size_bytes'] is None else r['size_bytes']
            x['width_bits'] = '' if r['width_bits'] is None else r['width_bits']
            x['rows'] = '' if r['rows'] is None else r['rows']
            x['cols'] = '' if r['cols'] is None else r['cols']
            x['generated'] = 'true' if r['generated'] else 'false'
            x['inbound_xrefs'] = len(incoming.get(r['address'], []))
            x['callers'] = '|'.join(f'0x{x:04X}' for x in incoming.get(r['address'], []))
            writer.writerow({key: x.get(key, '') for key in columns})


def write_sqlite(symbols, calls, vectors, output: Path):
    if output.exists():
        output.unlink()
    con = sqlite3.connect(output)
    con.executescript('''
    PRAGMA foreign_keys=ON;
    CREATE TABLE symbols(
      address INTEGER PRIMARY KEY,
      end_address INTEGER NOT NULL,
      name TEXT NOT NULL UNIQUE,
      kind TEXT NOT NULL,
      subtype TEXT,
      size_bytes INTEGER,
      width_bits INTEGER,
      signed TEXT,
      rows INTEGER,
      cols INTEGER,
      subsystem TEXT,
      confidence TEXT NOT NULL,
      description TEXT,
      evidence TEXT,
      aliases TEXT,
      generated INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE xrefs(
      call_site INTEGER NOT NULL,
      callee INTEGER NOT NULL,
      FOREIGN KEY(callee) REFERENCES symbols(address)
    );
    CREATE INDEX idx_xrefs_callee ON xrefs(callee);
    CREATE TABLE vectors(
      vector_address INTEGER PRIMARY KEY,
      target INTEGER NOT NULL,
      FOREIGN KEY(target) REFERENCES symbols(address)
    );
    CREATE VIEW routine_call_summary AS
      SELECT s.address, s.name, COUNT(x.call_site) AS inbound_calls,
             GROUP_CONCAT(printf('0x%04X', x.call_site), '|') AS callers
      FROM symbols s
      LEFT JOIN xrefs x ON x.callee=s.address
      WHERE s.kind='routine'
      GROUP BY s.address, s.name;
    ''')
    for r in symbols:
        con.execute('INSERT INTO symbols VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', (
            r['address'], r['end_address'], r['name'], r['kind'], r['subtype'], r['size_bytes'],
            r['width_bits'], r.get('signed') or None, r['rows'], r['cols'], r['subsystem'],
            r['confidence'], r['description'], r['evidence'], r.get('aliases') or None,
            1 if r['generated'] else 0
        ))
    con.executemany('INSERT INTO xrefs VALUES(?,?)', calls)
    con.executemany('INSERT INTO vectors VALUES(?,?)', vectors)
    con.commit()
    con.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--raw-asm', type=Path, required=True)
    parser.add_argument('--symbols', type=Path, required=True)
    parser.add_argument('--out-asm', type=Path, required=True)
    parser.add_argument('--out-csv', type=Path, required=True)
    parser.add_argument('--out-sqlite', type=Path, required=True)
    args = parser.parse_args()

    records = read_records(args.raw_asm)
    symbols = read_symbols(args.symbols)
    calls, vectors = infer_calls_and_vectors(records)
    render_assembly(records, symbols, calls, vectors, args.out_asm)
    write_resolved_csv(symbols, calls, args.out_csv)
    write_sqlite(symbols, calls, vectors, args.out_sqlite)
    print(f'Generated {args.out_asm} ({len(records)} records)')
    print(f'Generated {args.out_csv} ({len(symbols)} symbols)')
    print(f'Generated {args.out_sqlite} ({len(calls)} calls, {len(vectors)} vectors)')


if __name__ == '__main__':
    main()
