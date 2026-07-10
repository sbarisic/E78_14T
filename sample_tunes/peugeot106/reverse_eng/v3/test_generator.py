#!/usr/bin/env python3
from __future__ import annotations

import csv
import sqlite3
import tempfile
import unittest
from pathlib import Path

import generate_annotations as gen

ROOT = Path(__file__).resolve().parent
RAW = ROOT / 'IAW8P40_peugeot106_reachable_raw.asm'
SOURCE = ROOT / 'IAW8P40_peugeot106_symbols_source_v3.csv'


class GeneratorRegressionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.records = gen.read_records(RAW)
        cls.symbols = gen.read_symbols(SOURCE)
        cls.calls, cls.vectors = gen.infer_calls_and_vectors(cls.records)
        cls.layouts, cls.owner = gen.build_routine_layouts(cls.records, cls.symbols)
        cls.symbol_by_name = {row['name']: row for row in cls.symbols}

    def test_no_call_owner_outside_explicit_decoded_block(self):
        for site, _target in self.calls:
            owner = self.owner.get(site)
            self.assertIsNotNone(owner, f'unowned call at 0x{site:04X}')
            layout = self.layouts[owner]
            self.assertTrue(layout.address <= site <= layout.end_address)
            self.assertTrue(layout.contains_decoded_address(site))

    def test_previous_19_misattributions_have_correct_owners(self):
        expected = {
            0x6C6A: 0x6C6A, 0x6C78: 0x6C6A,
            0x6CFB: 0x6CFB, 0x6CFE: 0x6CFB, 0x6D2F: 0x6CFB,
            0x750E: 0x74CA, 0x753E: 0x74CA, 0x7541: 0x74CA,
            0x7555: 0x74CA, 0x7558: 0x74CA,
            0xD80C: 0xD80B, 0xD822: 0xD80B, 0xD824: 0xD80B,
            0xE096: 0xE080, 0xE09F: 0xE080, 0xE0A8: 0xE080,
            0xE0AF: 0xE080, 0xE0B3: 0xE080, 0xE0BA: 0xE080,
        }
        self.assertEqual(len(expected), 19)
        for site, owner in expected.items():
            self.assertEqual(self.owner.get(site), owner, f'wrong owner for 0x{site:04X}')

    def test_sub_6c56_does_not_claim_later_calls(self):
        owner = self.symbol_by_name['sub_6C56']['address']
        owned_sites = [site for site, _ in self.calls if self.owner.get(site) == owner]
        self.assertEqual(owned_sites, [0x6C56])

    def test_noncontiguous_spans_are_explicit_blocks(self):
        expected = {
            'mode_handler_68f3': (81, 46, 35, [(0x68F3, 0x691F), (0x6943, 0x6943)]),
            'sub_6A2C': (60, 45, 15, [(0x6A2C, 0x6A57), (0x6A67, 0x6A67)]),
            'sub_A7DE': (525, 126, 399, [(0xA7DE, 0xA854), (0xA9E4, 0xA9EA)]),
            'sci_service_55_entry': (919, 61, 858, [(0xAAE0, 0xAAEB), (0xAB52, 0xAB7B), (0xAE70, 0xAE76)]),
            'closed_loop_adaptive_state_machine': (2319, 2042, 277, [(0xC000, 0xC441), (0xC44C, 0xC46C), (0xC578, 0xC90E)]),
            'fuel_signed_trim_lookup': (605, 603, 2, [(0xE38B, 0xE57D), (0xE580, 0xE5E7)]),
        }
        actual_noncontiguous = {
            row['name']
            for row in self.symbols
            if row['kind'] == 'routine' and self.layouts[row['address']].range_kind == 'bounding-span'
        }
        self.assertEqual(actual_noncontiguous, set(expected))
        for name, (span, decoded, gap, blocks) in expected.items():
            layout = self.layouts[self.symbol_by_name[name]['address']]
            self.assertEqual(layout.bounding_span_bytes, span)
            self.assertEqual(layout.decoded_bytes, decoded)
            self.assertEqual(layout.gap_bytes, gap)
            self.assertEqual([(b.start_address, b.end_address) for b in layout.blocks], blocks)

    def test_generated_sqlite_has_no_unowned_xrefs(self):
        with tempfile.TemporaryDirectory() as temp:
            db = Path(temp) / 'symbols.sqlite'
            gen.write_sqlite(self.records, self.symbols, self.calls, self.vectors, db)
            con = sqlite3.connect(db)
            try:
                self.assertEqual(con.execute('SELECT COUNT(*) FROM unowned_call_sites').fetchone()[0], 0)
                row = con.execute(
                    "SELECT range_kind, bounding_span_bytes, decoded_bytes, gap_bytes, block_count "
                    "FROM symbols WHERE name='sci_service_55_entry'"
                ).fetchone()
                self.assertEqual(row, ('bounding-span', 919, 61, 858, 3))
            finally:
                con.close()


if __name__ == '__main__':
    unittest.main(verbosity=2)
