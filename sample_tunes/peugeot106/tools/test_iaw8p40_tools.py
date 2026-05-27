#!/usr/bin/env python3
"""Unit tests for local IAW8P40 support tools."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import iaw8p40_checksum as checksum


ROOT = Path(__file__).resolve().parents[1]


class ChecksumToolTests(unittest.TestCase):
    def assert_checksum_pair(self, relative_path: str, word: int, complement: int) -> None:
        data = checksum.read_rom(ROOT / relative_path)
        info = checksum.calculate(data)
        self.assertEqual(info.checksum_word, word)
        self.assertEqual(info.checksum_complement, complement)
        self.assertEqual(info.pair_sum, 0xFFFF)
        self.assertEqual(info.byte_sum, complement)
        self.assertTrue(info.valid)

    def test_known_checksum_pairs(self) -> None:
        self.assert_checksum_pair("M27C512_original.BIN", 0x4A65, 0xB59A)
        self.assert_checksum_pair(
            "1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin",
            0x4A65,
            0xB59A,
        )
        self.assert_checksum_pair(
            "1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin",
            0x47BE,
            0xB841,
        )
        self.assert_checksum_pair(
            "Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin",
            0x9F83,
            0x607C,
        )
        self.assert_checksum_pair("RALLY13.ORI", 0x7A41, 0x85BE)

    def test_public_peug_106rally_file_is_checksum_invalid(self) -> None:
        data = checksum.read_rom(ROOT / "Peug.106Rally.org.bin")
        info = checksum.calculate(data)
        self.assertEqual(info.checksum_word, 0x4A65)
        self.assertEqual(info.checksum_complement, 0xB59A)
        self.assertEqual(info.pair_sum, 0xFFFF)
        self.assertEqual(info.byte_sum, 0xE160)
        self.assertFalse(info.valid)

    def test_direct_byte_helpers_reject_wrong_size_data(self) -> None:
        wrong_size_inputs = (
            b"",
            bytearray(checksum.ROM_SIZE - 1),
            bytes(checksum.ROM_SIZE + 1),
        )
        helpers = (
            checksum.calculate,
            checksum.repaired_words,
            checksum.repair_bytes,
        )
        for helper in helpers:
            for data in wrong_size_inputs:
                with self.subTest(helper=helper.__name__, size=len(data)):
                    with self.assertRaisesRegex(ValueError, "expected 65536"):
                        helper(data)

    def test_repair_writes_only_new_output(self) -> None:
        source = ROOT / "M27C512_original.BIN"
        original = source.read_bytes()
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            input_path = tmpdir / "scratch_corrupt.bin"
            output_path = tmpdir / "scratch_repaired.bin"
            corrupt = bytearray(original)
            corrupt[0x802E] ^= 0x01
            input_path.write_bytes(corrupt)

            before = input_path.read_bytes()
            info = checksum.repair_file(input_path, output_path)

            self.assertEqual(input_path.read_bytes(), before)
            self.assertTrue(output_path.exists())
            self.assertTrue(info.valid)
            self.assertEqual(checksum.calculate(output_path.read_bytes()).byte_sum, info.checksum_complement)

    def test_repair_refuses_overwrite_and_protected_output_name(self) -> None:
        source = ROOT / "M27C512_original.BIN"
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            input_path = tmpdir / "scratch.bin"
            input_path.write_bytes(source.read_bytes())

            with self.assertRaises(ValueError):
                checksum.repair_file(input_path, input_path)

            protected_output = tmpdir / "M27C512_original.BIN"
            with self.assertRaises(ValueError):
                checksum.repair_file(input_path, protected_output)

            protected_ori_output = tmpdir / "RALLY13.ORI"
            with self.assertRaises(ValueError):
                checksum.repair_file(input_path, protected_ori_output)

            protected_public_output = tmpdir / "Peug.106Rally.org.bin"
            with self.assertRaises(ValueError):
                checksum.repair_file(input_path, protected_public_output)

            existing_output = tmpdir / "already_exists.bin"
            existing_output.write_bytes(b"existing")
            with self.assertRaises(ValueError):
                checksum.repair_file(input_path, existing_output)


if __name__ == "__main__":
    unittest.main()
