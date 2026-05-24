#!/usr/bin/env python3
"""Read-only comparison/scanner for Peugeot/Citroen Magneti Marelli IAW 8P.40 bins.

The script intentionally does not write ROM files. It prints Markdown-friendly
tables that can be pasted into the reverse-engineering notes.
"""

from __future__ import annotations

import argparse
import hashlib
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class RomSpec:
    key: str
    label: str
    path: Path


ROMS = [
    RomSpec("peugeot_stock", "Peugeot stock M27C512_original", ROOT / "M27C512_original.BIN"),
    RomSpec(
        "peugeot_stok",
        "Peugeot Stok folder duplicate",
        ROOT / "1_3L_8V_IAW8P40" / "1.3L_8V_IAW8P40_Stok.bin",
    ),
    RomSpec(
        "peugeot_mod2",
        "Peugeot MOD2",
        ROOT / "1_3L_8V_IAW8P40" / "1.3L_8V_IAW8P40_MOD2.bin",
    ),
    RomSpec(
        "xantia_607c",
        "Citroen Xantia 1.6 8v IAW 8P.40 607C",
        ROOT / "Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin",
    ),
]


KNOWN_TABLES = [
    ("fuel_ve_aircharge_candidate_21x9", 0x802E, 21, 9, "raw"),
    ("fuel_ve_boundary_24x9", 0x802E, 24, 9, "raw"),
    ("public_probe_b_21x9", 0x80EB, 21, 9, "raw"),
    ("public_probe_tail_5x9", 0x81A8, 5, 9, "raw"),
    ("spark_high_default_24x9", 0x8A69, 24, 9, "raw/2 deg"),
    ("spark_low_alternate_24x9", 0x8B41, 24, 9, "raw/2 deg"),
    ("wot_spark_vector_1x24", 0x8C19, 1, 24, "raw/2 deg"),
    ("load_model_correction_24x9", 0x9187, 24, 9, "raw/230 hypothesis"),
    ("rpm_axis_period_1x24", 0x929E, 1, 24, "period axis"),
    ("control_scalars_1x6", 0x89ED, 1, 6, "raw"),
    ("speed_transient_vector_1x19", 0x89F3, 1, 19, "raw"),
]

TABLE_BASES = [
    0x802E,
    0x80EB,
    0x8106,
    0x81A8,
    0x869A,
    0x879E,
    0x87A0,
    0x89ED,
    0x89F3,
    0x8A69,
    0x8B41,
    0x8C19,
    0x9187,
    0x9291,
    0x929E,
]

PEUGEOT_HELPERS = [0xB2D6, 0xB2AB, 0xB383, 0xB3B9]
XANTIA_HELPERS = [0xB2CB, 0xB349]
RAM_TARGETS = [
    0x00CE,
    0x00D0,
    0x1030,
    0x1031,
    0x1032,
    0x1033,
    0x1034,
    0x2007,
    0x2008,
    0x2009,
    0x200A,
    0x200B,
    0x200C,
    0x200D,
    0x200E,
    0x2013,
    0x2034,
    0x2036,
    0x20B1,
    0x20BC,
    0x20BD,
    0x20BE,
    0x20BF,
    0x20C0,
    0x20C1,
    0x20C2,
    0x20C3,
    0x20C4,
    0x20C5,
    0x20EB,
    0x20ED,
    0x2147,
    0x2148,
    0x2149,
    0x214C,
    0x242B,
    0x242D,
    0x242F,
    0x2431,
]

EXTENDED_OPS = {
    0xB6: "LDAA ext",
    0xB7: "STAA ext",
    0xF6: "LDAB ext",
    0xF7: "STAB ext",
    0xFC: "LDD ext",
    0xFD: "STD ext",
    0xFE: "LDX ext",
    0xFF: "STX ext",
    0x7C: "INC ext",
    0x7A: "DEC ext",
    0x7D: "TST ext",
    0x7F: "CLR ext",
    0xBD: "JSR ext",
    0xBC: "CPX ext",
    0xB1: "CMPA ext",
    0xF1: "CMPB ext",
    0xB3: "SUBD ext",
    0xF3: "ADDD ext",
}

PREFIX18_EXTENDED_OPS = {
    0xCE: "LDY imm",
    0xFE: "LDY ext",
    0xFF: "STY ext",
    0xBC: "CPY ext",
    0xB3: "CPD? ext",
    0x83: "CPD imm",
}

DIRECT_OPS = {
    0x96: "LDAA dir",
    0x97: "STAA dir",
    0xD6: "LDAB dir",
    0xD7: "STAB dir",
    0xDC: "LDD dir",
    0xDD: "STD dir",
    0xDE: "LDX dir",
    0xDF: "STX dir",
    0x9C: "CPX dir",
    0x91: "CMPA dir",
    0xD1: "CMPB dir",
    0x93: "SUBD dir",
    0xD3: "ADDD dir",
}

PREFIX18_DIRECT_OPS = {
    0xDE: "LDY dir",
    0xDF: "STY dir",
    0x9C: "CPY dir",
}


def read_roms() -> dict[str, bytes]:
    roms: dict[str, bytes] = {}
    missing = []
    for spec in ROMS:
        if not spec.path.exists():
            missing.append(str(spec.path))
            continue
        data = spec.path.read_bytes()
        roms[spec.key] = data
    if missing:
        raise FileNotFoundError("Missing ROM files:\n" + "\n".join(missing))
    return roms


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def u16be(data: bytes, addr: int) -> int:
    if addr < 0 or addr + 1 >= len(data):
        return -1
    return (data[addr] << 8) | data[addr + 1]


def fmt_addr(addr: int) -> str:
    return f"0x{addr:04X}"


def find_diff_regions(a: bytes, b: bytes) -> list[tuple[int, int, int]]:
    regions = []
    start = None
    count = 0
    for i, (aa, bb) in enumerate(zip(a, b)):
        if aa != bb:
            if start is None:
                start = i
                count = 0
            count += 1
        elif start is not None:
            regions.append((start, i - 1, count))
            start = None
    if start is not None:
        regions.append((start, len(a) - 1, count))
    return regions


def table_bytes(data: bytes, addr: int, rows: int, cols: int) -> bytes:
    return data[addr : addr + rows * cols]


def byte_stats(values: bytes) -> dict[str, float]:
    if not values:
        return {"min": 0, "max": 0, "avg": 0.0, "zeros": 0, "ff": 0}
    return {
        "min": min(values),
        "max": max(values),
        "avg": sum(values) / len(values),
        "zeros": values.count(0),
        "ff": values.count(0xFF),
    }


def same_offset_table_delta(a: bytes, b: bytes, addr: int, length: int) -> tuple[int, int, int, float]:
    av = a[addr : addr + length]
    bv = b[addr : addr + length]
    diffs = [bb - aa for aa, bb in zip(av, bv) if aa != bb]
    if not diffs:
        return 0, 0, 0, 0.0
    return len(diffs), min(diffs), max(diffs), sum(diffs) / len(diffs)


def find_word_refs(data: bytes, value: int) -> list[tuple[int, str]]:
    hi, lo = value >> 8, value & 0xFF
    hits: list[tuple[int, str]] = []
    for i in range(0, len(data) - 1):
        if data[i] != hi or data[i + 1] != lo:
            continue
        context = "literal"
        if i >= 1:
            op = data[i - 1]
            if op == 0xCE:
                context = "LDX imm"
            elif op == 0xCC:
                context = "LDD imm"
            elif op in EXTENDED_OPS:
                context = EXTENDED_OPS[op]
        if i >= 2 and data[i - 2] == 0x18:
            context = PREFIX18_EXTENDED_OPS.get(data[i - 1], "prefix18 operand")
        hits.append((i, context))
    return hits


def scan_jsr_targets(data: bytes) -> Counter[int]:
    c: Counter[int] = Counter()
    for i in range(0, len(data) - 2):
        if data[i] == 0xBD:
            c[u16be(data, i + 1)] += 1
    return c


def call_sites(data: bytes, target: int) -> list[int]:
    hi, lo = target >> 8, target & 0xFF
    return [i for i in range(0, len(data) - 2) if data[i] == 0xBD and data[i + 1] == hi and data[i + 2] == lo]


def scan_ram_refs(data: bytes, targets: Iterable[int]) -> dict[int, list[tuple[int, str]]]:
    target_set = set(targets)
    refs: dict[int, list[tuple[int, str]]] = defaultdict(list)

    for i in range(0, len(data) - 2):
        op = data[i]
        addr = u16be(data, i + 1)
        if addr in target_set and op in EXTENDED_OPS:
            refs[addr].append((i, EXTENDED_OPS[op]))

    for i in range(0, len(data) - 3):
        if data[i] == 0x18:
            op = data[i + 1]
            addr = u16be(data, i + 2)
            if addr in target_set and op in PREFIX18_EXTENDED_OPS:
                refs[addr].append((i, PREFIX18_EXTENDED_OPS[op]))

    direct_targets = {t for t in target_set if t <= 0x00FF}
    for i in range(0, len(data) - 1):
        op = data[i]
        addr = data[i + 1]
        if addr in direct_targets and op in DIRECT_OPS:
            refs[addr].append((i, DIRECT_OPS[op]))

    for i in range(0, len(data) - 2):
        if data[i] == 0x18:
            op = data[i + 1]
            addr = data[i + 2]
            if addr in direct_targets and op in PREFIX18_DIRECT_OPS:
                refs[addr].append((i, PREFIX18_DIRECT_OPS[op]))
    return refs


def nearby_table_literals(data: bytes, site: int, radius: int = 24) -> list[str]:
    start = max(0, site - radius)
    end = min(len(data) - 2, site + radius)
    found = []
    for base in TABLE_BASES:
        hi, lo = base >> 8, base & 0xFF
        for i in range(start, end):
            if data[i] == hi and data[i + 1] == lo:
                found.append(f"{fmt_addr(base)} at {fmt_addr(i)}")
                break
    return found


def print_rom_overview(roms: dict[str, bytes]) -> None:
    print("## ROM Overview")
    print()
    print("| Key | Label | Size | SHA256 | Checksum words | Pair sum | Byte sum 0x4000-0xFFFF | Reset vector |")
    print("| --- | --- | ---: | --- | --- | --- | --- | --- |")
    for spec in ROMS:
        data = roms[spec.key]
        w1 = u16be(data, 0x800C)
        w2 = u16be(data, 0x800E)
        byte_sum = sum(data[0x4000:]) & 0xFFFF
        reset = u16be(data, 0xFFFE)
        print(
            f"| `{spec.key}` | {spec.label} | {len(data)} | `{sha256(data)}` | "
            f"`{fmt_addr(w1)}/{fmt_addr(w2)}` | `{fmt_addr((w1 + w2) & 0xFFFF)}` | "
            f"`{fmt_addr(byte_sum)}` | `{fmt_addr(reset)}` |"
        )
    print()


def print_diff_summary(roms: dict[str, bytes]) -> None:
    pairs = [
        ("peugeot_stock", "peugeot_stok"),
        ("peugeot_stock", "peugeot_mod2"),
        ("peugeot_stock", "xantia_607c"),
    ]
    print("## Diff Regions")
    print()
    for left, right in pairs:
        regions = find_diff_regions(roms[left], roms[right])
        total = sum(c for _, _, c in regions)
        print(f"### `{left}` vs `{right}`")
        print()
        print(f"Total differing bytes: `{total}` in `{len(regions)}` contiguous regions.")
        print()
        print("| Start | End | Changed bytes |")
        print("| --- | --- | ---: |")
        display = regions[:40]
        for start, end, count in display:
            print(f"| `{fmt_addr(start)}` | `{fmt_addr(end)}` | {count} |")
        if len(regions) > len(display):
            print(f"| ... | ... | {len(regions) - len(display)} more regions omitted |")
        print()


def print_known_table_stats(roms: dict[str, bytes]) -> None:
    stock = roms["peugeot_stock"]
    mod2 = roms["peugeot_mod2"]
    xantia = roms["xantia_607c"]
    print("## Known Table / Candidate Stats")
    print()
    print("| Name | Range | Shape | Peugeot raw min-max avg | MOD2 changed cells/delta | Xantia raw min-max avg | Peugeot vs Xantia changed cells/delta | Notes |")
    print("| --- | --- | --- | --- | --- | --- | --- | --- |")
    for name, addr, rows, cols, notes in KNOWN_TABLES:
        length = rows * cols
        s = byte_stats(table_bytes(stock, addr, rows, cols))
        x = byte_stats(table_bytes(xantia, addr, rows, cols))
        md_count, md_min, md_max, md_avg = same_offset_table_delta(stock, mod2, addr, length)
        xd_count, xd_min, xd_max, xd_avg = same_offset_table_delta(stock, xantia, addr, length)
        print(
            f"| `{name}` | `{fmt_addr(addr)}-{fmt_addr(addr + length - 1)}` | `{rows}x{cols}` | "
            f"`{s['min']:.0f}-{s['max']:.0f} avg {s['avg']:.1f}` | "
            f"`{md_count}; {md_min:+d}..{md_max:+d} avg {md_avg:+.1f}` | "
            f"`{x['min']:.0f}-{x['max']:.0f} avg {x['avg']:.1f}` | "
            f"`{xd_count}; {xd_min:+d}..{xd_max:+d} avg {xd_avg:+.1f}` | {notes} |"
        )
    print()


def print_table_refs(roms: dict[str, bytes]) -> None:
    print("## Immediate Table-Base Reference Scan")
    print()
    for key in ("peugeot_stock", "xantia_607c"):
        data = roms[key]
        print(f"### `{key}`")
        print()
        print("| Base | Hits | Contexts | First sites |")
        print("| --- | ---: | --- | --- |")
        for base in TABLE_BASES:
            hits = find_word_refs(data, base)
            contexts = Counter(ctx for _, ctx in hits)
            ctx_text = ", ".join(f"{name}:{count}" for name, count in contexts.most_common())
            first = ", ".join(fmt_addr(pos) for pos, _ in hits[:8])
            print(f"| `{fmt_addr(base)}` | {len(hits)} | {ctx_text or '-'} | {first or '-'} |")
        print()


def print_helper_calls(roms: dict[str, bytes]) -> None:
    print("## Helper / JSR Scan")
    print()
    for key, helpers in (("peugeot_stock", PEUGEOT_HELPERS), ("xantia_607c", XANTIA_HELPERS)):
        data = roms[key]
        targets = scan_jsr_targets(data)
        print(f"### `{key}`")
        print()
        print("Most common extended JSR targets:")
        print()
        print("| Target | Count |")
        print("| --- | ---: |")
        for target, count in targets.most_common(20):
            print(f"| `{fmt_addr(target)}` | {count} |")
        print()
        print("Focused helper calls:")
        print()
        print("| Helper | Count | First call sites | Nearby known table literals |")
        print("| --- | ---: | --- | --- |")
        for helper in helpers:
            sites = call_sites(data, helper)
            nearby = []
            for site in sites[:12]:
                for item in nearby_table_literals(data, site):
                    if item not in nearby:
                        nearby.append(item)
            print(
                f"| `{fmt_addr(helper)}` | {len(sites)} | "
                f"{', '.join(fmt_addr(s) for s in sites[:12]) or '-'} | "
                f"{', '.join(nearby[:12]) or '-'} |"
            )
        print()


def print_ram_refs(roms: dict[str, bytes]) -> None:
    print("## RAM / Register Reference Scan")
    print()
    for key in ("peugeot_stock", "xantia_607c"):
        refs = scan_ram_refs(roms[key], RAM_TARGETS)
        print(f"### `{key}`")
        print()
        print("| Address | Count | Operations | First sites |")
        print("| --- | ---: | --- | --- |")
        for addr in RAM_TARGETS:
            hits = sorted(refs.get(addr, []))
            operations = Counter(op for _, op in hits)
            ops = ", ".join(f"{op}:{count}" for op, count in operations.most_common())
            first = ", ".join(fmt_addr(pos) for pos, _ in hits[:10])
            print(f"| `{fmt_addr(addr)}` | {len(hits)} | {ops or '-'} | {first or '-'} |")
        print()


def print_targeted_trace_notes(roms: dict[str, bytes]) -> None:
    stock = roms["peugeot_stock"]
    mod2 = roms["peugeot_mod2"]
    xantia = roms["xantia_607c"]
    print("## Targeted Trace Notes")
    print()

    for addr, rows, cols in ((0x802E, 21, 9), (0x802E, 24, 9), (0x80EB, 21, 9), (0x81A8, 5, 9)):
        length = rows * cols
        md_count, md_min, md_max, md_avg = same_offset_table_delta(stock, mod2, addr, length)
        xd_count, xd_min, xd_max, xd_avg = same_offset_table_delta(stock, xantia, addr, length)
        refs = find_word_refs(stock, addr)
        print(
            f"- `{fmt_addr(addr)}` `{rows}x{cols}`: MOD2 changed `{md_count}/{length}` cells "
            f"(`{md_min:+d}..{md_max:+d}`, avg `{md_avg:+.1f}`); Xantia same-offset differs "
            f"`{xd_count}/{length}` cells (`{xd_min:+d}..{xd_max:+d}`, avg `{xd_avg:+.1f}`); "
            f"Peugeot immediate word-reference hits `{len(refs)}`."
        )

    ram_refs = scan_ram_refs(stock, RAM_TARGETS)
    print()
    for addr in (0x20EB, 0x20ED, 0x242B, 0x242D, 0x20BC, 0x242F, 0x2431):
        hits = sorted(ram_refs.get(addr, []))
        stores = [h for h in hits if h[1].startswith("ST") or h[1].startswith("CLR")]
        loads = [h for h in hits if h[1].startswith("LD") or h[1].startswith("CP") or h[1].startswith("ADD") or h[1].startswith("SUB")]
        print(
            f"- `{fmt_addr(addr)}`: `{len(hits)}` scanned refs; stores/clears at "
            f"{', '.join(fmt_addr(p) for p, _ in stores[:10]) or '-'}; loads/math at "
            f"{', '.join(fmt_addr(p) for p, _ in loads[:10]) or '-'}."
        )
    print()
    for addr in (0x1030, 0x1031, 0x1032, 0x1033, 0x1034, 0x2007, 0x2008, 0x2009, 0x200A, 0x200B, 0x200C, 0x200D, 0x200E, 0x2013, 0x00CE, 0x00D0, 0x2034):
        hits = sorted(ram_refs.get(addr, []))
        print(
            f"- `{fmt_addr(addr)}` ADC/load path: `{len(hits)}` scanned refs; first sites "
            f"{', '.join(fmt_addr(p) for p, _ in hits[:12]) or '-'}."
        )
    print()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--section",
        choices=["all", "overview", "diffs", "tables", "refs", "helpers", "ram", "trace"],
        default="all",
        help="Limit output to one section.",
    )
    args = parser.parse_args()

    roms = read_roms()
    for key, data in roms.items():
        if len(data) != 0x10000:
            raise ValueError(f"{key} is {len(data)} bytes, expected 65536")

    if args.section in ("all", "overview"):
        print_rom_overview(roms)
    if args.section in ("all", "diffs"):
        print_diff_summary(roms)
    if args.section in ("all", "tables"):
        print_known_table_stats(roms)
    if args.section in ("all", "refs"):
        print_table_refs(roms)
    if args.section in ("all", "helpers"):
        print_helper_calls(roms)
    if args.section in ("all", "ram"):
        print_ram_refs(roms)
    if args.section in ("all", "trace"):
        print_targeted_trace_notes(roms)


if __name__ == "__main__":
    main()
