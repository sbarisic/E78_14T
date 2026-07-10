#!/usr/bin/env python3
"""Unit tests for local IAW8P40 support tools."""

from __future__ import annotations

import csv
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
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


class XdfMetadataTests(unittest.TestCase):
    def test_active_xdf_cleanup_and_names(self) -> None:
        root = ET.parse(ROOT / "IAW8P40_peugeot106_firstpass.xdf").getroot()
        nodes = root.findall("XDFCONSTANT") + root.findall("XDFTABLE")
        by_id = {node.get("uniqueid"): node for node in nodes}

        retired_ids = {"0x112", "0x113", "0x114", "0x24E", "0x250", "0x252", "0x255", "0x257"}
        self.assertTrue(retired_ids.isdisjoint(by_id))

        expected_titles = {
            "0x116": "Primary RPM Limiter Set Threshold @ 0x879E",
            "0x117": "Primary RPM Limiter Clear Threshold @ 0x87A0",
            "0x118": "Alternate RPM Limiter Set Threshold @ 0x87A2",
            "0x119": "Alternate RPM Limiter Clear Threshold @ 0x87A4",
            "0x228": "Main Spark Bank A / Default 24x9 @ 0x8A69",
            "0x229": "Main Spark Bank B / Alternate 24x9 @ 0x8B41",
            "0x22C": "RPM-only Bypass Spark Vector 1x24 @ 0x8C19",
            "0x248": "Fast Closed-Loop Fuel Correction vs $2040 1x9 @ 0x84E3",
        }
        for unique_id, expected_title in expected_titles.items():
            with self.subTest(unique_id=unique_id):
                self.assertEqual(by_id[unique_id].findtext("title"), expected_title)

        expected_fuel_views = {
            0x81F8: {"0x24C", "0x24F"},
            0x821C: {"0x23F", "0x24D"},
            0x82F4: {"0x253", "0x254"},
            0x8318: {"0x240", "0x251"},
            0x83F0: {"0x241", "0x256"},
        }
        tables_by_address: dict[int, set[str]] = {}
        for table in root.findall("XDFTABLE"):
            embedded = table.find("XDFAXIS[@id='z']/EMBEDDEDDATA")
            if embedded is None or not embedded.get("mmedaddress"):
                continue
            address = int(embedded.get("mmedaddress"), 16)
            tables_by_address.setdefault(address, set()).add(table.get("uniqueid"))
        for address, expected_ids in expected_fuel_views.items():
            with self.subTest(fuel_address=f"0x{address:04X}"):
                self.assertEqual(tables_by_address[address], expected_ids)

    def test_vectors_and_firmware_support_constants(self) -> None:
        root = ET.parse(ROOT / "IAW8P40_peugeot106_firstpass.xdf").getroot()
        self.assertEqual(root.findtext("XDFHEADER/fileversion"), "0.54")

        nodes = root.findall("XDFCONSTANT") + root.findall("XDFTABLE")
        unique_ids = [node.get("uniqueid") for node in nodes]
        self.assertEqual(len(unique_ids), len(set(unique_ids)))

        constants: dict[int, list[ET.Element]] = {}
        for constant in root.findall("XDFCONSTANT"):
            embedded = constant.find("EMBEDDEDDATA")
            if embedded is None or not embedded.get("mmedaddress"):
                continue
            address = int(embedded.get("mmedaddress"), 16)
            constants.setdefault(address, []).append(constant)

        with (ROOT / "reverse_eng/v1/IAW8P40_peugeot106_vectors.csv").open(
            newline="", encoding="utf-8-sig"
        ) as source:
            vectors = {
                int(row["vector_address"], 16): int(row["target"], 16)
                for row in csv.DictReader(source)
            }

        rom = (ROOT / "M27C512_original.BIN").read_bytes()
        self.assertEqual(len(vectors), 21)
        for address, target in vectors.items():
            with self.subTest(vector=f"0x{address:04X}"):
                self.assertEqual(len(constants.get(address, [])), 1)
                embedded = constants[address][0].find("EMBEDDEDDATA")
                self.assertIsNotNone(embedded)
                self.assertEqual(embedded.get("mmedelementsizebits"), "16")
                self.assertEqual(int.from_bytes(rom[address : address + 2], "big"), target)

        support = ((0x916A, "16", 0x27FF), (0x916E, "8", 0xFF))
        for address, bits, expected in support:
            with self.subTest(support=f"0x{address:04X}"):
                self.assertEqual(len(constants.get(address, [])), 1)
                embedded = constants[address][0].find("EMBEDDEDDATA")
                self.assertIsNotNone(embedded)
                self.assertEqual(embedded.get("mmedelementsizebits"), bits)
                size = int(bits) // 8
                self.assertEqual(
                    int.from_bytes(rom[address : address + size], "big"), expected
                )


if __name__ == "__main__":
    unittest.main()
