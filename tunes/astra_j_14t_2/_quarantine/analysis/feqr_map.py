import csv
import math
import struct
from collections import Counter
from pathlib import Path


ROOT = Path(r"E:\Projects\E78_14T")
CSV_PATH = ROOT / "sources/Uni78/DamosCSVParser/data/winols_astra.csv"
TARGET_PATH = ROOT / "tunes/astra_j_14t_2/opel_astra_original.bin"
CORSA_ORIGINAL_PATH = (
    ROOT / "tunes/Opel Corsa E 1.4 Turbo 2019/change_everything_bins/Original.bin"
)
CORSA_CHANGED_PATH = (
    ROOT / "tunes/Opel Corsa E 1.4 Turbo 2019/change_everything_bins/Change1.bin"
)


def parse_address(value: str) -> int | None:
    if not value.startswith("$"):
        return None
    try:
        return int(value[1:], 16)
    except ValueError:
        return None


def encode_values(row: dict[str, str]) -> bytes | None:
    text = row["Fieldvalues.Values"].strip()
    if not text:
        return None
    try:
        values = [float(value) for value in text.split()]
        factor = float(row["Fieldvalues.Factor"] or 1)
        offset = float(row["Fieldvalues.Offset"] or 0)
    except ValueError:
        return None

    org = row["DataOrg"]
    signed = row["bSigned"] == "1"
    encoded = bytearray()
    try:
        for value in values:
            if org == "eFloatHiLo":
                encoded.extend(struct.pack(">f", value))
                continue
            raw = round((value - offset) / factor)
            if org == "eByte":
                encoded.extend(struct.pack("b" if signed else "B", raw))
            elif org == "eHiLo":
                encoded.extend(struct.pack(">h" if signed else ">H", raw))
            else:
                return None
    except (OverflowError, struct.error, ZeroDivisionError):
        return None
    return bytes(encoded)


def all_hits(data: bytes, needle: bytes, limit: int = 200) -> list[int]:
    if not needle:
        return []
    hits = []
    start = 0
    while len(hits) < limit:
        found = data.find(needle, start)
        if found < 0:
            break
        hits.append(found)
        start = found + 1
    return hits


def changed_fraction(original: bytes, changed: bytes, address: int, size: int) -> float:
    if address < 0 or address + size > len(original):
        return 0.0
    diffs = sum(
        original[index] != changed[index]
        for index in range(address, address + size)
    )
    return diffs / size if size else 0.0


def main() -> None:
    target = TARGET_PATH.read_bytes()
    corsa_original = CORSA_ORIGINAL_PATH.read_bytes()
    corsa_changed = CORSA_CHANGED_PATH.read_bytes()

    with CSV_PATH.open(newline="", encoding="utf-8-sig") as handle:
        rows = list(csv.DictReader(handle, delimiter=";"))

    by_name = {}
    for row in rows:
        name = row["IdName"]
        if "FEQR" not in name:
            continue
        address = parse_address(row["Fieldvalues.StartAddr.Cpu"])
        if address is None or address >= len(target):
            continue
        by_name.setdefault(name, row)

    records = []
    for name, row in by_name.items():
        source_address = parse_address(row["Fieldvalues.StartAddr.Cpu"])
        encoded = encode_values(row)
        encoded_size = len(encoded) if encoded else 0
        target_hits = all_hits(target, encoded) if encoded and encoded_size >= 4 else []
        corsa_hits = all_hits(corsa_original, encoded) if encoded and encoded_size >= 4 else []
        unique_target = target_hits[0] if len(target_hits) == 1 else None
        unique_corsa = corsa_hits[0] if len(corsa_hits) == 1 else None
        records.append(
            {
                "symbol": name,
                "source_address": f"0x{source_address:06X}",
                "rows": row["Rows"],
                "columns": row["Columns"],
                "data_org": row["DataOrg"],
                "signed": row["bSigned"],
                "unit": row["Fieldvalues.Unit"],
                "factor": row["Fieldvalues.Factor"],
                "offset": row["Fieldvalues.Offset"],
                "encoded_size": encoded_size,
                "exact_target_hits": len(target_hits),
                "unique_target_address": (
                    f"0x{unique_target:06X}" if unique_target is not None else ""
                ),
                "exact_corsa_hits": len(corsa_hits),
                "unique_corsa_address": (
                    f"0x{unique_corsa:06X}" if unique_corsa is not None else ""
                ),
                "corsa_changed_fraction": (
                    f"{changed_fraction(corsa_original, corsa_changed, unique_corsa, encoded_size):.3f}"
                    if unique_corsa is not None
                    else ""
                ),
            }
        )

    records.sort(key=lambda record: int(record["source_address"], 16))
    writer = csv.DictWriter(
        __import__("sys").stdout,
        fieldnames=list(records[0]),
        lineterminator="\n",
    )
    writer.writeheader()
    writer.writerows(records)

    counts = Counter(record["exact_target_hits"] for record in records)
    print(f"# target hit histogram: {dict(sorted(counts.items()))}", file=__import__("sys").stderr)


if __name__ == "__main__":
    main()
