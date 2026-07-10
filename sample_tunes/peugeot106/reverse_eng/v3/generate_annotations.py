#!/usr/bin/env python3
"""Generate annotated IAW 8P.40 assembly and symbol/xref databases.

This is the reproducible annotation stage. It uses only Python's standard
library. The raw binary-to-instruction decoding stage is deliberately outside
this script.

Routine address/end_address values are treated as *bounding spans*. Actual
instruction ownership and decoded size are derived from the raw listing and
stored as one or more explicit routine code blocks.
"""
from __future__ import annotations

import argparse
import csv
import re
import sqlite3
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

ADDR_LINE_RE = re.compile(r'^([0-9A-F]{4}):\s+([0-9A-F ]{2,20})\s+([.a-z0-9]+)\s*(.*)$', re.I)
HEX_RE = re.compile(r'\$([0-9a-fA-F]{1,4})')


@dataclass(frozen=True)
class Record:
    address: int
    raw: str
    mnemonic: str
    operand: str

    @property
    def size(self) -> int:
        return len(self.raw.split())

    @property
    def end_address(self) -> int:
        return self.address + self.size - 1


@dataclass(frozen=True)
class CodeBlock:
    start_address: int
    end_address: int

    @property
    def size_bytes(self) -> int:
        return self.end_address - self.start_address + 1


@dataclass(frozen=True)
class RoutineLayout:
    address: int
    end_address: int
    blocks: tuple[CodeBlock, ...]

    @property
    def bounding_span_bytes(self) -> int:
        return self.end_address - self.address + 1

    @property
    def decoded_bytes(self) -> int:
        return sum(block.size_bytes for block in self.blocks)

    @property
    def gap_bytes(self) -> int:
        return self.bounding_span_bytes - self.decoded_bytes

    @property
    def block_count(self) -> int:
        return len(self.blocks)

    @property
    def coverage_percent(self) -> float:
        return 100.0 * self.decoded_bytes / self.bounding_span_bytes

    @property
    def range_kind(self) -> str:
        if (
            len(self.blocks) == 1
            and self.blocks[0].start_address == self.address
            and self.blocks[0].end_address == self.end_address
        ):
            return 'contiguous-code'
        return 'bounding-span'

    def contains_decoded_address(self, address: int) -> bool:
        return any(block.start_address <= address <= block.end_address for block in self.blocks)

    def blocks_text(self) -> str:
        return '|'.join(f'0x{b.start_address:04X}-0x{b.end_address:04X}' for b in self.blocks)


def parse_addr(value: str) -> int:
    value = value.strip()
    if value.lower().startswith('0x'):
        return int(value, 16)
    return int(value, 0)


def parse_optional_int(value: str | None) -> int | None:
    value = (value or '').strip()
    return int(value, 10) if value else None


def read_records(path: Path) -> list[Record]:
    records: list[Record] = []
    for line in path.read_text(encoding='utf-8').splitlines():
        match = ADDR_LINE_RE.match(line)
        if not match:
            continue
        records.append(Record(
            address=int(match.group(1), 16),
            raw=' '.join(match.group(2).split()).upper(),
            mnemonic=match.group(3).lower(),
            operand=match.group(4).split(';', 1)[0].rstrip(),
        ))
    if not records:
        raise ValueError(f'no assembly records parsed from {path}')
    addresses = [record.address for record in records]
    if len(addresses) != len(set(addresses)):
        raise ValueError('duplicate instruction addresses in raw assembly')
    return records


def read_symbols(path: Path) -> list[dict]:
    rows: list[dict] = []
    with path.open(newline='', encoding='utf-8') as handle:
        for source_row in csv.DictReader(handle):
            row = dict(source_row)
            row['address'] = parse_addr(source_row['address'])
            row['end_address'] = parse_addr(source_row['end_address'])
            row['size_bytes'] = parse_optional_int(source_row.get('size_bytes'))
            row['width_bits'] = parse_optional_int(source_row.get('width_bits'))
            row['rows'] = parse_optional_int(source_row.get('rows'))
            row['cols'] = parse_optional_int(source_row.get('cols'))
            row['generated'] = source_row.get('generated', 'false').lower() in {'1', 'true', 'yes'}
            rows.append(row)
    validate_symbols(rows)
    return sorted(rows, key=lambda row: (row['address'], row['kind'], row['name']))


def validate_symbols(rows: Iterable[dict]) -> None:
    by_address: dict[int, str] = {}
    by_name: dict[str, int] = {}
    routines: list[tuple[int, int, str]] = []
    for row in rows:
        address = row['address']
        end_address = row['end_address']
        name = row['name']
        if end_address < address:
            raise ValueError(f'inverted range for {name}: 0x{address:04X}-0x{end_address:04X}')
        if address in by_address:
            raise ValueError(f'duplicate symbol address 0x{address:04X}: {name} and {by_address[address]}')
        if name in by_name:
            raise ValueError(f'duplicate symbol name {name}: 0x{address:04X} and 0x{by_name[name]:04X}')
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', name):
            raise ValueError(f'invalid assembler symbol name: {name}')
        by_address[address] = name
        by_name[name] = address
        if row['kind'] == 'routine':
            routines.append((address, end_address, name))

    routines.sort()
    for previous, current in zip(routines, routines[1:]):
        if current[0] <= previous[1]:
            raise ValueError(
                'overlapping routine bounding spans: '
                f'{previous[2]} 0x{previous[0]:04X}-0x{previous[1]:04X} and '
                f'{current[2]} 0x{current[0]:04X}-0x{current[1]:04X}'
            )


def target_from_operand(operand: str) -> int | None:
    values = HEX_RE.findall(operand)
    return int(values[-1], 16) if values else None


def infer_calls_and_vectors(records: Iterable[Record]) -> tuple[list[tuple[int, int]], list[tuple[int, int]]]:
    calls: list[tuple[int, int]] = []
    vectors: list[tuple[int, int]] = []
    for record in records:
        target = target_from_operand(record.operand)
        if target is None:
            continue
        if record.mnemonic in {'jsr', 'bsr'}:
            calls.append((record.address, target))
        if record.address >= 0xFFD6 and record.mnemonic == '.word':
            vectors.append((record.address, target))
    return calls, vectors


def is_control_transfer(mnemonic: str) -> bool:
    if mnemonic in {'jmp', 'jsr', 'bsr', 'bra'}:
        return True
    return mnemonic.startswith('b') and mnemonic not in {'bita', 'bitb'}


def merge_record_blocks(records: list[Record]) -> tuple[CodeBlock, ...]:
    if not records:
        return ()
    sorted_records = sorted(records, key=lambda record: record.address)
    blocks: list[CodeBlock] = []
    start = sorted_records[0].address
    end = sorted_records[0].end_address
    for record in sorted_records[1:]:
        if record.address <= end:
            raise ValueError(f'overlapping decoded records at 0x{record.address:04X}')
        if record.address == end + 1:
            end = record.end_address
        else:
            blocks.append(CodeBlock(start, end))
            start = record.address
            end = record.end_address
    blocks.append(CodeBlock(start, end))
    return tuple(blocks)


def build_routine_layouts(
    records: list[Record], symbols: list[dict]
) -> tuple[dict[int, RoutineLayout], dict[int, int]]:
    routines = sorted(
        (row for row in symbols if row['kind'] == 'routine'),
        key=lambda row: row['address'],
    )
    records_by_routine: dict[int, list[Record]] = defaultdict(list)
    owner_by_record_address: dict[int, int] = {}

    routine_index = 0
    for record in sorted(records, key=lambda item: item.address):
        while routine_index < len(routines) and routines[routine_index]['end_address'] < record.address:
            routine_index += 1
        owner: dict | None = None
        if routine_index < len(routines):
            candidate = routines[routine_index]
            if candidate['address'] <= record.address <= candidate['end_address']:
                owner = candidate
        if owner is None:
            continue
        if record.end_address > owner['end_address']:
            raise ValueError(
                f'instruction 0x{record.address:04X}-0x{record.end_address:04X} crosses '
                f'routine bound for {owner["name"]} ending at 0x{owner["end_address"]:04X}'
            )
        owner_by_record_address[record.address] = owner['address']
        records_by_routine[owner['address']].append(record)

    layouts: dict[int, RoutineLayout] = {}
    for routine in routines:
        blocks = merge_record_blocks(records_by_routine.get(routine['address'], []))
        if not blocks:
            raise ValueError(
                f'routine {routine["name"]} at 0x{routine["address"]:04X} contains no decoded records'
            )
        layouts[routine['address']] = RoutineLayout(
            address=routine['address'],
            end_address=routine['end_address'],
            blocks=blocks,
        )
    return layouts, owner_by_record_address


def make_context(records: list[Record], symbols: list[dict], calls: list[tuple[int, int]]):
    symbol_by_address = {row['address']: row for row in symbols}
    routines = {address: row for address, row in symbol_by_address.items() if row['kind'] == 'routine'}
    layouts, owner_by_address = build_routine_layouts(records, symbols)

    incoming: dict[int, list[int]] = defaultdict(list)
    outgoing_site: dict[int, list[int]] = defaultdict(list)
    routine_calls: dict[int, list[tuple[int, int]]] = defaultdict(list)
    unowned_calls: list[tuple[int, int]] = []
    for site, callee in calls:
        incoming[callee].append(site)
        outgoing_site[site].append(callee)
        owner = owner_by_address.get(site)
        if owner is None:
            unowned_calls.append((site, callee))
        else:
            routine_calls[owner].append((site, callee))

    local_targets: set[int] = set()
    for record in records:
        if not is_control_transfer(record.mnemonic) or record.mnemonic in {'jsr', 'bsr'}:
            continue
        target = target_from_operand(record.operand)
        if target is not None and target not in routines:
            local_targets.add(target)
    local_names = {address: f'loc_{address:04X}' for address in local_targets}
    return (
        symbol_by_address,
        routines,
        layouts,
        owner_by_address,
        incoming,
        outgoing_site,
        routine_calls,
        unowned_calls,
        local_names,
    )


def routine_callee_list(routine_calls: list[tuple[int, int]]) -> list[int]:
    result: list[int] = []
    for _, target in routine_calls:
        if target not in result:
            result.append(target)
    return result


def format_blocks(layout: RoutineLayout) -> str:
    return ', '.join(
        f'${block.start_address:04X}-${block.end_address:04X} ({block.size_bytes} bytes)'
        for block in layout.blocks
    )


def render_assembly(
    records: list[Record], symbols: list[dict], calls: list[tuple[int, int]],
    vectors: list[tuple[int, int]], output: Path
) -> None:
    (
        symbol_by_address,
        routines,
        layouts,
        _owner_by_address,
        incoming,
        outgoing_site,
        routine_calls,
        unowned_calls,
        local_names,
    ) = make_context(records, symbols, calls)

    lines = [
        '; Marelli IAW 8P.40 Peugeot 106 1.3 Rallye',
        '; Reachable Motorola 68HC11 assembly — annotation pass v3',
        ';',
        '; Reproducible inputs:',
        ';   numeric/raw assembly listing',
        ';   canonical symbol source CSV',
        '; Generated by generate_annotations.py using only Python standard library.',
        '; Routine address ranges are bounding spans; explicit decoded code blocks are authoritative.',
        '; Physical labels marked STRONG/WORKING remain hypotheses; CONFIRMED means direct code-flow support.',
        '',
        '; ============================================================================',
        '; EQUATES: MCU I/O, RAM and ROM data',
        '; ============================================================================',
    ]

    for kind, title in [('mcu_io', 'MCU / external I/O'), ('ram', 'RAM'), ('rom_data', 'ROM / calibration data')]:
        lines.append(f'\n; --- {title} ---')
        for row in symbols:
            if row['kind'] == kind:
                lines.append(
                    f"{row['name']:<42} EQU ${row['address']:04X} ; "
                    f"[{row['confidence'].upper()}] {row['description']}"
                )

    previous_end: int | None = None
    for record in records:
        address, raw, mnemonic, operand = record.address, record.raw, record.mnemonic, record.operand
        if previous_end is None or address != previous_end:
            lines.append(f'\n        .org ${address:04X}')

        if address in routines:
            routine = routines[address]
            layout = layouts[address]
            callers = incoming.get(address, [])
            callees = routine_callee_list(routine_calls.get(address, []))
            lines.extend([
                '',
                '; -----------------------------------------------------------------------------',
                f"; {routine['name']} @ ${address:04X} [{routine['confidence'].upper()}] / {routine['subsystem']}",
                f"; {routine['description']}",
                f"; Range kind: {layout.range_kind}",
                f"; Bounding span: ${address:04X}-${routine['end_address']:04X} ({layout.bounding_span_bytes} bytes)",
                f"; Decoded code blocks: {format_blocks(layout)}",
                f"; Decoded coverage: {layout.decoded_bytes}/{layout.bounding_span_bytes} bytes "
                f"({layout.coverage_percent:.1f}%; {layout.gap_bytes} undecoded bytes inside span)",
                '; Called by: ' + (', '.join(f'${site:04X}' for site in callers[:16]) if callers else 'vector/entry/none found'),
                '; Calls: ' + (
                    ', '.join(routines[target]['name'] if target in routines else f'${target:04X}' for target in callees[:16])
                    if callees else 'none found'
                ),
                '; Evidence: ' + routine['evidence'],
                '; -----------------------------------------------------------------------------',
                routine['name'] + ':',
            ])
        elif address in local_names:
            lines.append(local_names[address] + ':')

        annotations: list[str] = []
        original_operand = operand

        def replace_hex(match: re.Match[str]) -> str:
            text = match.group(0)
            digits = match.group(1)
            value = int(digits, 16)
            if len(digits) <= 2 and value in symbol_by_address:
                annotations.append(text)
                return symbol_by_address[value]['name']
            if value in routines:
                annotations.append(text)
                return routines[value]['name']
            if value in symbol_by_address:
                annotations.append(text)
                return symbol_by_address[value]['name']
            if value in local_names:
                annotations.append(text)
                return local_names[value]
            return text.upper()

        rendered_operand = HEX_RE.sub(replace_hex, operand)
        if mnemonic in {'ldx', 'ldy'}:
            decimal_immediate = re.fullmatch(r'#(-?\d+)', rendered_operand)
            if decimal_immediate:
                value = int(decimal_immediate.group(1)) & 0xFFFF
                if value in symbol_by_address:
                    annotations.append('#' + decimal_immediate.group(1))
                    rendered_operand = '#' + symbol_by_address[value]['name']

        comments: list[str] = []
        if annotations:
            comments.append('orig ' + ', '.join(dict.fromkeys(annotations)))
        if address in outgoing_site:
            comments.append(
                'call ' + ', '.join(
                    routines[target]['name'] if target in routines else f'${target:04X}'
                    for target in outgoing_site[address]
                )
            )
        for digits in HEX_RE.findall(original_operand):
            value = int(digits, 16)
            if len(digits) <= 2:
                value &= 0xFF
            if value in symbol_by_address and symbol_by_address[value]['name'] not in rendered_operand:
                comments.append(f'${value:04X}={symbol_by_address[value]["name"]}')

        comment_text = ' ; ' + ' | '.join(dict.fromkeys(comments)) if comments else ''
        lines.append(f'{address:04X}:  {raw:<20} {mnemonic:<8} {rendered_operand}{comment_text}'.rstrip())
        previous_end = record.address + record.size

    lines.extend([
        '',
        '; ============================================================================',
        '; VECTOR SUMMARY',
        '; ============================================================================',
    ])
    for slot, target in vectors:
        target_name = routines[target]['name'] if target in routines else f'${target:04X}'
        lines.append(f'; ${slot:04X} -> ${target:04X} {target_name}')

    lines.extend([
        '',
        '; ============================================================================',
        '; UNOWNED DIRECT CALL SITES',
        '; ============================================================================',
    ])
    if unowned_calls:
        for site, callee in unowned_calls:
            lines.append(f'; ${site:04X} -> ${callee:04X}')
    else:
        lines.append('; none')

    output.write_text('\n'.join(lines) + '\n', encoding='utf-8')


def build_call_metadata(
    calls: list[tuple[int, int]], owner_by_address: dict[int, int]
) -> tuple[dict[int, list[int]], dict[int, list[tuple[int, int]]], list[tuple[int, int]]]:
    incoming: dict[int, list[int]] = defaultdict(list)
    outgoing: dict[int, list[tuple[int, int]]] = defaultdict(list)
    unowned: list[tuple[int, int]] = []
    for site, target in calls:
        incoming[target].append(site)
        owner = owner_by_address.get(site)
        if owner is None:
            unowned.append((site, target))
        else:
            outgoing[owner].append((site, target))
    return incoming, outgoing, unowned


def write_resolved_csv(
    records: list[Record], symbols: list[dict], calls: list[tuple[int, int]], output: Path
) -> None:
    layouts, owner_by_address = build_routine_layouts(records, symbols)
    incoming, outgoing, _unowned = build_call_metadata(calls, owner_by_address)
    symbol_by_address = {row['address']: row for row in symbols}
    columns = [
        'address', 'end_address', 'name', 'kind', 'subtype', 'size_bytes', 'width_bits', 'signed', 'rows', 'cols',
        'subsystem', 'confidence', 'range_kind', 'bounding_span_bytes', 'decoded_bytes', 'gap_bytes',
        'block_count', 'code_blocks', 'coverage_percent', 'inbound_xrefs', 'callers', 'caller_routines',
        'outbound_xrefs', 'outbound_call_sites', 'callees', 'description', 'evidence', 'aliases', 'generated',
    ]
    with output.open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=columns)
        writer.writeheader()
        for row in symbols:
            resolved = dict(row)
            address = row['address']
            resolved['address'] = f'0x{address:04X}'
            resolved['end_address'] = f"0x{row['end_address']:04X}"
            resolved['width_bits'] = '' if row['width_bits'] is None else row['width_bits']
            resolved['rows'] = '' if row['rows'] is None else row['rows']
            resolved['cols'] = '' if row['cols'] is None else row['cols']
            resolved['generated'] = 'true' if row['generated'] else 'false'

            inbound_sites = incoming.get(address, [])
            caller_routine_addresses: list[int] = []
            for site in inbound_sites:
                owner = owner_by_address.get(site)
                if owner is not None and owner not in caller_routine_addresses:
                    caller_routine_addresses.append(owner)
            outbound_calls = outgoing.get(address, []) if row['kind'] == 'routine' else []
            callee_addresses: list[int] = []
            for _, target in outbound_calls:
                if target not in callee_addresses:
                    callee_addresses.append(target)

            if row['kind'] == 'routine':
                layout = layouts[address]
                resolved.update({
                    'size_bytes': layout.decoded_bytes,
                    'range_kind': layout.range_kind,
                    'bounding_span_bytes': layout.bounding_span_bytes,
                    'decoded_bytes': layout.decoded_bytes,
                    'gap_bytes': layout.gap_bytes,
                    'block_count': layout.block_count,
                    'code_blocks': layout.blocks_text(),
                    'coverage_percent': f'{layout.coverage_percent:.3f}',
                    'outbound_xrefs': len(outbound_calls),
                    'outbound_call_sites': '|'.join(f'0x{site:04X}' for site, _ in outbound_calls),
                    'callees': '|'.join(
                        symbol_by_address[target]['name'] if target in symbol_by_address else f'0x{target:04X}'
                        for target in callee_addresses
                    ),
                })
            else:
                resolved.update({
                    'size_bytes': '' if row['size_bytes'] is None else row['size_bytes'],
                    'range_kind': 'data-object',
                    'bounding_span_bytes': row['end_address'] - row['address'] + 1,
                    'decoded_bytes': '',
                    'gap_bytes': '',
                    'block_count': '',
                    'code_blocks': '',
                    'coverage_percent': '',
                    'outbound_xrefs': '',
                    'outbound_call_sites': '',
                    'callees': '',
                })

            resolved['inbound_xrefs'] = len(inbound_sites)
            resolved['callers'] = '|'.join(f'0x{site:04X}' for site in inbound_sites)
            resolved['caller_routines'] = '|'.join(
                symbol_by_address[owner]['name'] if owner in symbol_by_address else f'0x{owner:04X}'
                for owner in caller_routine_addresses
            )
            writer.writerow({column: resolved.get(column, '') for column in columns})


def write_sqlite(
    records: list[Record], symbols: list[dict], calls: list[tuple[int, int]],
    vectors: list[tuple[int, int]], output: Path
) -> None:
    layouts, owner_by_address = build_routine_layouts(records, symbols)
    if output.exists():
        output.unlink()
    connection = sqlite3.connect(output)
    connection.executescript('''
    PRAGMA page_size=4096;
    PRAGMA journal_mode=OFF;
    PRAGMA synchronous=OFF;
    PRAGMA auto_vacuum=NONE;
    PRAGMA foreign_keys=ON;
    PRAGMA user_version=3;

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
      range_kind TEXT NOT NULL,
      bounding_span_bytes INTEGER NOT NULL,
      decoded_bytes INTEGER,
      gap_bytes INTEGER,
      block_count INTEGER,
      description TEXT,
      evidence TEXT,
      aliases TEXT,
      generated INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE routine_blocks(
      routine_address INTEGER NOT NULL,
      block_index INTEGER NOT NULL,
      start_address INTEGER NOT NULL,
      end_address INTEGER NOT NULL,
      size_bytes INTEGER NOT NULL,
      PRIMARY KEY(routine_address, block_index),
      FOREIGN KEY(routine_address) REFERENCES symbols(address)
    );
    CREATE INDEX idx_routine_blocks_range ON routine_blocks(start_address, end_address);

    CREATE TABLE xrefs(
      call_site INTEGER PRIMARY KEY,
      caller_routine INTEGER,
      callee INTEGER NOT NULL,
      FOREIGN KEY(caller_routine) REFERENCES symbols(address),
      FOREIGN KEY(callee) REFERENCES symbols(address)
    );
    CREATE INDEX idx_xrefs_caller ON xrefs(caller_routine);
    CREATE INDEX idx_xrefs_callee ON xrefs(callee);

    CREATE TABLE vectors(
      vector_address INTEGER PRIMARY KEY,
      target INTEGER NOT NULL,
      FOREIGN KEY(target) REFERENCES symbols(address)
    );

    CREATE VIEW routine_call_summary AS
      SELECT s.address, s.name,
             COUNT(DISTINCT inbound.call_site) AS inbound_calls,
             GROUP_CONCAT(DISTINCT printf('0x%04X', inbound.call_site)) AS caller_sites,
             COUNT(DISTINCT outbound.call_site) AS outbound_calls,
             GROUP_CONCAT(DISTINCT printf('0x%04X', outbound.call_site)) AS outbound_sites
      FROM symbols s
      LEFT JOIN xrefs inbound ON inbound.callee=s.address
      LEFT JOIN xrefs outbound ON outbound.caller_routine=s.address
      WHERE s.kind='routine'
      GROUP BY s.address, s.name;

    CREATE VIEW routine_layout_summary AS
      SELECT s.address, s.name, s.range_kind, s.bounding_span_bytes,
             s.decoded_bytes, s.gap_bytes, s.block_count,
             GROUP_CONCAT(
               printf('0x%04X-0x%04X', b.start_address, b.end_address), '|'
             ) AS code_blocks
      FROM symbols s
      LEFT JOIN routine_blocks b ON b.routine_address=s.address
      WHERE s.kind='routine'
      GROUP BY s.address, s.name, s.range_kind, s.bounding_span_bytes,
               s.decoded_bytes, s.gap_bytes, s.block_count;

    CREATE VIEW unowned_call_sites AS
      SELECT call_site, callee FROM xrefs WHERE caller_routine IS NULL;
    ''')

    for row in symbols:
        if row['kind'] == 'routine':
            layout = layouts[row['address']]
            size_bytes = layout.decoded_bytes
            range_kind = layout.range_kind
            bounding_span_bytes = layout.bounding_span_bytes
            decoded_bytes = layout.decoded_bytes
            gap_bytes = layout.gap_bytes
            block_count = layout.block_count
        else:
            size_bytes = row['size_bytes']
            range_kind = 'data-object'
            bounding_span_bytes = row['end_address'] - row['address'] + 1
            decoded_bytes = None
            gap_bytes = None
            block_count = None
        connection.execute(
            'INSERT INTO symbols VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
            (
                row['address'], row['end_address'], row['name'], row['kind'], row['subtype'], size_bytes,
                row['width_bits'], row.get('signed') or None, row['rows'], row['cols'], row['subsystem'],
                row['confidence'], range_kind, bounding_span_bytes, decoded_bytes, gap_bytes, block_count,
                row['description'], row['evidence'], row.get('aliases') or None,
                1 if row['generated'] else 0,
            ),
        )

    for routine_address in sorted(layouts):
        for block_index, block in enumerate(layouts[routine_address].blocks):
            connection.execute(
                'INSERT INTO routine_blocks VALUES(?,?,?,?,?)',
                (routine_address, block_index, block.start_address, block.end_address, block.size_bytes),
            )

    symbol_addresses = {row['address'] for row in symbols}
    missing_callees = sorted({target for _, target in calls if target not in symbol_addresses})
    if missing_callees:
        raise ValueError('direct callees missing symbols: ' + ', '.join(f'0x{x:04X}' for x in missing_callees))
    connection.executemany(
        'INSERT INTO xrefs VALUES(?,?,?)',
        [(site, owner_by_address.get(site), target) for site, target in calls],
    )
    connection.executemany('INSERT INTO vectors VALUES(?,?)', vectors)
    connection.commit()
    connection.execute('VACUUM')
    connection.close()


def main() -> None:
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
    layouts, owner_by_address = build_routine_layouts(records, symbols)
    unowned = [(site, target) for site, target in calls if site not in owner_by_address]

    render_assembly(records, symbols, calls, vectors, args.out_asm)
    write_resolved_csv(records, symbols, calls, args.out_csv)
    write_sqlite(records, symbols, calls, vectors, args.out_sqlite)

    bounding_spans = sum(layout.range_kind == 'bounding-span' for layout in layouts.values())
    print(f'Generated {args.out_asm} ({len(records)} records)')
    print(f'Generated {args.out_csv} ({len(symbols)} symbols, {len(layouts)} routines)')
    print(
        f'Generated {args.out_sqlite} ({len(calls)} calls, {len(vectors)} vectors, '
        f'{bounding_spans} non-contiguous routine spans, {len(unowned)} unowned calls)'
    )


if __name__ == '__main__':
    main()
