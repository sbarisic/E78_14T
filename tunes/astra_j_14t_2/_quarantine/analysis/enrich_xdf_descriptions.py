import csv
import html
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.sax.saxutils import escape


ROOT = Path(r"E:\Projects\E78_14T")
BASE = ROOT / "tunes/astra_j_14t_2"
CSV_PATH = ROOT / "sources/Uni78/DamosCSVParser/data/winols_astra.csv"
XDF_PATH = BASE / "E78_Astra_047922_TableSearch.xdf"
LEDGER_PATH = BASE / "feqr_mapping.csv"

LOCAL_NOTES_LABEL = "Astra mapping/local notes:"


def parse_address(value: str) -> int | None:
    if not value.startswith("$"):
        return None
    try:
        return int(value[1:], 16)
    except ValueError:
        return None


def clean_comment_sections(comment: str) -> tuple[str, str, str]:
    text = html.unescape(comment or "")
    text = re.sub(r"(?i)<br\s*/?>", "\n", text)
    text = re.sub(r"<[^>]+>", "", text)
    sections = {"main": [], "x": [], "y": []}
    current = "main"
    for raw_line in text.replace("\r", "").split("\n"):
        line = " ".join(raw_line.split())
        if not line:
            continue
        label = line.lower().rstrip(":")
        if label == "x axis":
            current = "x"
            continue
        if label == "y axis":
            current = "y"
            continue
        if label in {"map", "curve", "value", "scalar", "calibration note"}:
            continue
        sections[current].append(line)
    return tuple(" ".join(sections[key]).strip() for key in ("main", "x", "y"))


def storage_description(row: dict[str, str]) -> str:
    organization = row["DataOrg"]
    signedness = "signed" if row["bSigned"] == "1" else "unsigned"
    descriptions = {
        "eByte": f"8-bit {signedness} integer",
        "eHiLo": f"16-bit big-endian {signedness} integer",
        "eLoHi": f"16-bit little-endian {signedness} integer",
        "eFloatHiLo": "32-bit big-endian IEEE-754 float",
        "eFloatLoHi": "32-bit little-endian IEEE-754 float",
    }
    return descriptions.get(organization, f"{organization} {signedness} storage")


def equation_description(row: dict[str, str]) -> str:
    if row["DataOrg"] in {"eFloatHiLo", "eFloatLoHi"}:
        return "Y = X"
    factor = row["Fieldvalues.Factor"] or "1"
    offset = row["Fieldvalues.Offset"] or "0"
    if float(offset) == 0:
        return "Y = X" if float(factor) == 1 else f"Y = X * {factor}"
    return f"Y = (X * {factor}) + {offset}"


def local_notes_from_description(description: str) -> str:
    if LOCAL_NOTES_LABEL in description and description.startswith("Purpose:"):
        return description.split(LOCAL_NOTES_LABEL, 1)[1].strip()
    return description.strip()


def build_description(row: dict[str, str], local_notes: str) -> str:
    purpose, x_note, y_note = clean_comment_sections(row.get("Comment", ""))
    if not purpose:
        raise ValueError(f"CSV calibration note is empty for {row['IdName']}")

    rows = int(row["Rows"])
    columns = int(row["Columns"])
    unit = (row["Fieldvalues.Unit"] or "").strip()
    unit_text = "unitless" if unit in {"", "-"} else unit
    source = parse_address(row["Fieldvalues.StartAddr.Cpu"])
    if source is None:
        raise ValueError(f"Invalid source address for {row['IdName']}")

    parts = [f"Purpose: {purpose}"]
    axis_parts = []
    if x_note:
        axis_parts.append(f"X - {x_note}")
    if y_note:
        axis_parts.append(f"Y - {y_note}")
    if axis_parts:
        parts.append("Axes: " + " ".join(axis_parts))
    parts.append(
        f"Format: {rows}x{columns}; {storage_description(row)}; "
        f"{equation_description(row)}; units {unit_text}."
    )
    parts.append(
        f"Source: {row['IdName']} at 0x{source:06X} in winols_astra.csv."
    )
    if local_notes.strip():
        parts.append(f"{LOCAL_NOTES_LABEL} {local_notes.strip()}")
    return " ".join(parts)


def safe_symbol(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]+", "_", name).strip("_")


def map_symbol(
    title: str,
    description: str,
    rows_by_name: dict[str, dict[str, str]],
    ledger_by_title: dict[str, dict[str, str]],
) -> tuple[str | None, str | None]:
    if title in ledger_by_title:
        return ledger_by_title[title]["symbol"], "ledger"

    mapping_description = local_notes_from_description(description)
    candidates = {
        token
        for token in re.findall(
            r"\bK[a-zA-Z0-9]*_[A-Za-z0-9_\[\]]+", mapping_description
        )
        if token in rows_by_name
    }
    if len(candidates) == 1:
        return next(iter(candidates)), "description"
    return None, None


def main() -> None:
    with CSV_PATH.open(newline="", encoding="utf-8-sig") as handle:
        source_rows = list(csv.DictReader(handle, delimiter=";"))
    rows_by_name = {}
    for row in source_rows:
        rows_by_name.setdefault(row["IdName"], row)

    with LEDGER_PATH.open(newline="", encoding="utf-8") as handle:
        ledger = list(csv.DictReader(handle))
    ledger_by_title = {
        title: row
        for row in ledger
        for title in row["xdf_title"].split(" | ")
        if title
    }

    xdf_text = XDF_PATH.read_text(encoding="utf-8")
    root = ET.fromstring(xdf_text)
    replacements = {}
    mapping_counts = {"ledger": 0, "description": 0}
    unmatched_titles = []

    for table in root.findall("XDFTABLE"):
        title = table.findtext("title", default="")
        description = table.findtext("description", default="")
        symbol, mapping_path = map_symbol(
            title, description, rows_by_name, ledger_by_title
        )
        if symbol is None:
            unmatched_titles.append(title)
            continue
        row = rows_by_name[symbol]
        replacements[title] = build_description(
            row, local_notes_from_description(description)
        )
        mapping_counts[mapping_path] += 1

    if len(replacements) != 131:
        raise RuntimeError(
            f"Expected 131 uniquely mapped descriptions, found {len(replacements)}"
        )
    if len(unmatched_titles) != 27:
        raise RuntimeError(
            f"Expected 27 unmatched XDF entries, found {len(unmatched_titles)}"
        )

    table_pattern = re.compile(
        r"(?P<prefix><XDFTABLE\b.*?<title>(?P<title>.*?)</title>.*?<description>)"
        r"(?P<description>.*?)"
        r"(?P<suffix></description>)",
        re.DOTALL,
    )
    replaced_titles = set()

    def replace_description(match: re.Match[str]) -> str:
        title = html.unescape(match.group("title"))
        if title not in replacements:
            return match.group(0)
        replaced_titles.add(title)
        return (
            match.group("prefix")
            + escape(replacements[title])
            + match.group("suffix")
        )

    updated_text = table_pattern.sub(replace_description, xdf_text)
    if replaced_titles != set(replacements):
        missing = sorted(set(replacements) - replaced_titles)
        raise RuntimeError(f"Could not replace descriptions for: {missing}")
    ET.fromstring(updated_text)
    XDF_PATH.write_text(updated_text, encoding="utf-8", newline="\n")

    print(f"Updated descriptions: {len(replacements)}")
    print(f"Ledger mappings: {mapping_counts['ledger']}")
    print(f"Description-symbol mappings: {mapping_counts['description']}")
    print(f"Unmatched entries left unchanged: {len(unmatched_titles)}")


if __name__ == "__main__":
    main()
