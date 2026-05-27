#!/usr/bin/env python3
"""Checksum calculator/repair helper for Marelli IAW 8P.40 64 KiB EPROM images."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path


ROM_SIZE = 0x10000
SUM_START = 0x4000
CHECKSUM_WORD_ADDR = 0x800C
CHECKSUM_COMPLEMENT_ADDR = 0x800E
PROTECTED_FILENAMES = {
    "m27c512_original.bin",
    "1.3l_8v_iaw8p40_stok.bin",
    "1.3l_8v_iaw8p40_mod2.bin",
    "citroen xantia 1.6l 8v iaw 8p.40 (607c).bin",
    "peug.106rally.org.bin",
    "rally13.ori",
}


@dataclass(frozen=True)
class ChecksumInfo:
    checksum_word: int
    checksum_complement: int
    pair_sum: int
    byte_sum: int
    valid: bool


def u16be(data: bytes | bytearray, addr: int) -> int:
    return (data[addr] << 8) | data[addr + 1]


def put_u16be(data: bytearray, addr: int, value: int) -> None:
    data[addr] = (value >> 8) & 0xFF
    data[addr + 1] = value & 0xFF


def fmt(value: int) -> str:
    return f"0x{value:04X}"


def require_rom_size(data: bytes | bytearray) -> None:
    if len(data) != ROM_SIZE:
        raise ValueError(f"data is {len(data)} bytes, expected {ROM_SIZE}")


def read_rom(path: Path) -> bytes:
    data = path.read_bytes()
    if len(data) != ROM_SIZE:
        raise ValueError(f"{path} is {len(data)} bytes, expected {ROM_SIZE}")
    return data


def calculate(data: bytes | bytearray) -> ChecksumInfo:
    require_rom_size(data)
    checksum_word = u16be(data, CHECKSUM_WORD_ADDR)
    checksum_complement = u16be(data, CHECKSUM_COMPLEMENT_ADDR)
    pair_sum = (checksum_word + checksum_complement) & 0xFFFF
    byte_sum = sum(data[SUM_START:]) & 0xFFFF
    valid = pair_sum == 0xFFFF and byte_sum == checksum_complement
    return ChecksumInfo(checksum_word, checksum_complement, pair_sum, byte_sum, valid)


def repaired_words(data: bytes | bytearray) -> tuple[int, int]:
    require_rom_size(data)
    sum_without_pair = (
        sum(data[SUM_START:CHECKSUM_WORD_ADDR])
        + sum(data[CHECKSUM_COMPLEMENT_ADDR + 2 :])
    ) & 0xFFFF
    checksum_complement = (sum_without_pair + 0x01FE) & 0xFFFF
    checksum_word = (~checksum_complement) & 0xFFFF
    return checksum_word, checksum_complement


def repair_bytes(data: bytes | bytearray) -> bytes:
    require_rom_size(data)
    repaired = bytearray(data)
    checksum_word, checksum_complement = repaired_words(repaired)
    put_u16be(repaired, CHECKSUM_WORD_ADDR, checksum_word)
    put_u16be(repaired, CHECKSUM_COMPLEMENT_ADDR, checksum_complement)
    return bytes(repaired)


def is_protected_filename(path: Path) -> bool:
    return path.name.lower() in PROTECTED_FILENAMES


def repair_file(input_path: Path, output_path: Path) -> ChecksumInfo:
    input_resolved = input_path.resolve()
    output_parent = output_path.parent.resolve()
    output_resolved = output_parent / output_path.name

    if output_resolved == input_resolved:
        raise ValueError("refusing to overwrite input file")
    if output_path.exists():
        raise ValueError(f"refusing to overwrite existing output file: {output_path}")
    if is_protected_filename(output_path):
        raise ValueError(f"refusing to write protected source filename: {output_path.name}")

    data = read_rom(input_path)
    repaired = repair_bytes(data)
    output_path.write_bytes(repaired)
    return calculate(repaired)


def print_info(path: Path, info: ChecksumInfo) -> None:
    print(f"file: {path}")
    print(f"checksum_word: {fmt(info.checksum_word)}")
    print(f"checksum_complement: {fmt(info.checksum_complement)}")
    print(f"pair_sum: {fmt(info.pair_sum)}")
    print(f"byte_sum_0x4000_0xffff: {fmt(info.byte_sum)}")
    print(f"valid: {'yes' if info.valid else 'no'}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    calc_parser = subparsers.add_parser("calc", help="Calculate checksum status.")
    calc_parser.add_argument("bin", type=Path)

    repair_parser = subparsers.add_parser("repair", help="Write a repaired copy.")
    repair_parser.add_argument("input_bin", type=Path)
    repair_parser.add_argument("output_bin", type=Path)

    args = parser.parse_args()

    if args.command == "calc":
        data = read_rom(args.bin)
        print_info(args.bin, calculate(data))
    elif args.command == "repair":
        info = repair_file(args.input_bin, args.output_bin)
        print_info(args.output_bin, info)


if __name__ == "__main__":
    main()
