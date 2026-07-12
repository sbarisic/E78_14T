import csv
import re
import shutil
import struct
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.sax.saxutils import escape


ROOT = Path(r"E:\Projects\E78_14T")
BASE = ROOT / "tunes/astra_j_14t_2"
CSV_PATH = ROOT / "sources/Uni78/DamosCSVParser/data/winols_astra.csv"
BIN_PATH = BASE / "opel_astra_original.bin"
XDF_PATH = BASE / "E78_Astra_047922_TableSearch.xdf"
LEDGER_PATH = BASE / "feqr_mapping.csv"
BACKUP_PATH = BASE / "_quarantine/load_tests/28_before_full_feqr_expansion_20260712.xdf"

CATEGORIES = {
    "Fuel->Power Enrich": (0x5, 6),
    "Fuel->Knock Enrichment": (0x6, 7),
    "Fuel->Cranking": (0xE, 15),
    "Fuel->Open Loop": (0xF, 16),
    "Fuel->Protection": (0x10, 17),
    "Fuel->AIR": (0x11, 18),
    "Fuel->General": (0x12, 19),
}

PREIGN_RPM = [1600, 1700, 1800, 1950, 2050, 2200, 2400, 2600, 3000]
PREIGN_AIR = [0.47, 0.50, 0.53, 0.56, 0.59, 0.62, 0.65, 0.68, 0.71]


def parse_address(value: str) -> int | None:
    if not value.startswith("$"):
        return None
    try:
        return int(value[1:], 16)
    except ValueError:
        return None


def map_target(source: int) -> tuple[int | None, str, str, str]:
    if 0x59330 <= source <= 0x59704:
        return source + 0x631C, "high", "+0x631C", "crank/green block"
    if 0x59706 <= source <= 0x598B8:
        return source + 0x6340, "high", "+0x6340", "hot/piston/pre-ignition block"
    if source == 0x5995E:
        return None, "absent", "n/a", "E80 pre-ignition table omitted in target layout"
    if source == 0x59A00:
        return 0x5FC9A, "high", "+0x629A", "pre-ignition ramp scalar"
    if source == 0x59A02:
        return 0x5FC9C, "high", "+0x629A", "pre-ignition ramp scalar"
    if source == 0x59A04:
        return None, "absent", "n/a", "open-to-closed blend table omitted in target layout"
    if 0x59AB0 <= source <= 0x59B98:
        return source + 0x61F4, "high", "+0x61F4", "stoich/general block"
    if source == 0x59B9A:
        return None, "absent", "n/a", "driveability blend scalar omitted before AIR table"
    if 0x59B9E <= source <= 0x5BE97:
        return source + 0x61F0, "high", "+0x61F0", "AIR/open-loop block"
    if 0x5BE98 <= source <= 0x5C3DC:
        return source + 0x61FC, "high", "+0x61FC", "power-enrichment block"
    if source == 0x5C800:
        return None, "unresolved", "n/a", "no unique target fingerprint or coherent local anchor"
    return None, "unresolved", "n/a", "outside established FEQR relocation blocks"


def category_for(name: str) -> str:
    if "_PE_" in name or name.endswith("PowerEnrichment"):
        return "Fuel->Power Enrich"
    if "PreIgn" in name:
        return "Fuel->Knock Enrichment"
    if "AIR" in name:
        return "Fuel->AIR"
    if any(token in name for token in ("HotCoolant", "PistonProtect", "CoolLoss", "Misfire")):
        return "Fuel->Protection"
    if any(token in name for token in ("ClearFlood", "Crank")):
        return "Fuel->Cranking"
    if "GreenEng" in name and "_OL_" not in name:
        return "Fuel->Cranking"
    if any(
        token in name
        for token in (
            "OpenLoop",
            "_OL_",
            "IVT_OL",
            "FITT",
            "TorqueEnlean",
            "MaxAPC",
            "LimFactForMaxAPC",
        )
    ):
        return "Fuel->Open Loop"
    return "Fuel->General"


def dimensions(row: dict[str, str]) -> tuple[int, int, int, int]:
    rows = int(row["Rows"])
    columns = int(row["Columns"])
    org = row["DataOrg"]
    bits = 8 if org == "eByte" else 32 if org == "eFloatHiLo" else 16
    return rows, columns, bits, rows * columns * (bits // 8)


def decode_target(row: dict[str, str], data: bytes, address: int) -> tuple[list[float], bytes]:
    rows, columns, bits, size = dimensions(row)
    raw = data[address : address + size]
    factor = float(row["Fieldvalues.Factor"] or 1)
    offset = float(row["Fieldvalues.Offset"] or 0)
    signed = row["bSigned"] == "1"
    values = []
    for index in range(rows * columns):
        start = index * (bits // 8)
        cell = raw[start : start + (bits // 8)]
        if bits == 32:
            value = struct.unpack(">f", cell)[0]
        else:
            raw_value = int.from_bytes(cell, "big", signed=signed)
            value = raw_value * factor + offset
        values.append(value)
    return values, raw


def preview(values: list[float], count: int = 6) -> str:
    shown = ", ".join(f"{value:.6g}" for value in values[:count])
    return shown + (", ..." if len(values) > count else "")


def labels_from_text(text: str, count: int) -> list[str] | None:
    text = (text or "").strip()
    if not text:
        return None
    values = text.split(";") if ";" in text else text.split()
    values = [value.strip() for value in values if value.strip()]
    return values if len(values) == count else None


def fallback_labels(name: str, axis_name: str, count: int, axis: str) -> list[str]:
    if "PreIgn" in name and count == 9:
        values = PREIGN_RPM if axis == "x" else PREIGN_AIR
        return [f"{value:g}" for value in values]
    if "Engine" in axis_name and count == 33:
        return [str(index * 256) for index in range(count)]
    if "Engine" in axis_name and count == 17:
        return [str(index * 512) for index in range(count)]
    if "Accel" in axis_name and count == 17:
        return [f"{index * 6.25:g}" for index in range(count)]
    return [str(index) for index in range(count)]


def axis_labels(row: dict[str, str], axis: str, count: int) -> tuple[list[str], str]:
    prefix = "AxisX" if axis == "x" else "AxisY"
    labels = labels_from_text(row[f"{prefix}.Values"], count)
    if labels is None:
        labels = fallback_labels(row["IdName"], row[f"{prefix}.IdName"], count, axis)
    unit = row[f"{prefix}.Unit"]
    if unit == "-":
        unit = ""
    return labels, unit


def scalar_format(unit: str, factor: float, org: str) -> tuple[int, float, float]:
    normalized = unit.lower()
    if org == "eFloatHiLo":
        return 3, -100000.0, 100000.0
    if normalized == "rpm":
        return 0, 0.0, 8192.0
    if normalized == "%":
        return 1, 0.0, 100.0
    if normalized == "deg c":
        return 1, -256.0, 256.0
    if normalized in {"kpa", "kph"}:
        return 1, 0.0, 512.0
    if normalized == "s":
        return 2, 0.0, 3276.75
    if normalized == "mg":
        return 1, 0.0, 8192.0
    if normalized == "count":
        return 0, 0.0, 65535.0
    if normalized in {"ratio", "eq ratio"}:
        return 3, 0.0, 64.0
    if factor >= 1:
        return 0, 0.0, 65535.0
    return (6 if factor < 0.0001 else 4), 0.0, 4.0


def math_equation(row: dict[str, str]) -> str:
    if row["DataOrg"] == "eFloatHiLo":
        return "X"
    factor = float(row["Fieldvalues.Factor"] or 1)
    offset = float(row["Fieldvalues.Offset"] or 0)
    if factor == 1 and offset == 0:
        return "X"
    factor_text = row["Fieldvalues.Factor"] or "1"
    if offset == 0:
        return f"X * {factor_text}"
    return f"(X * {factor_text}) + {offset:g}"


def safe_title(name: str, address: int) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_]+", "_", name).strip("_")
    return f"{cleaned}_{address:06X}"


def make_axis(row: dict[str, str], axis: str, count: int) -> str:
    labels, unit = axis_labels(row, axis, count)
    decimal = 3 if any("." in label for label in labels) else 0
    lines = [f'    <XDFAXIS id="{axis}" uniqueid="0x0">']
    lines.append('      <EMBEDDEDDATA mmedelementsizebits="16" mmedmajorstridebits="0" mmedminorstridebits="0" />')
    if unit:
        lines.append(f"      <units>{escape(unit)}</units>")
    lines.extend(
        [
            f"      <indexcount>{count}</indexcount>",
            f"      <decimalpl>{decimal}</decimalpl>",
            "      <datatype>0</datatype>",
            "      <unittype>0</unittype>",
            '      <DALINK index="0" />',
        ]
    )
    for index, label in enumerate(labels):
        lines.append(f'      <LABEL index="{index}" value="{escape(label)}" />')
    lines.extend(['      <MATH equation="X">', '        <VAR id="X" />', "      </MATH>", "    </XDFAXIS>"])
    return "\n".join(lines)


def make_table(row: dict[str, str], target: int, unique_id: int, category: str, evidence: str) -> str:
    rows, columns, bits, _ = dimensions(row)
    name = row["IdName"]
    unit = row["Fieldvalues.Unit"] or "factor"
    factor = float(row["Fieldvalues.Factor"] or 1)
    decimals, minimum, maximum = scalar_format(unit, factor, row["DataOrg"])
    type_flags = ""
    if row["DataOrg"] == "eFloatHiLo":
        type_flags = ' mmedtypeflags="0x10000"'
    elif row["bSigned"] == "1":
        type_flags = ' mmedtypeflags="0x01"'
    source = parse_address(row["Fieldvalues.StartAddr.Cpu"])
    description = (
        f"DAMOS {name}; source 0x{source:06X} -> Astra 0x{target:06X}. "
        f"High-confidence {evidence}. Static/index axes are used unless separately proven."
    )
    if name == "KwFEQR_t_PE_DelayMax":
        description += " Stock raw FFFF displays 3276.75 s and may be a disabled/sentinel value."
    membership = CATEGORIES[category][1]
    lines = [
        f'  <XDFTABLE uniqueid="0x{unique_id:X}" flags="0x0">',
        f"    <title>{escape(safe_title(name, target))}</title>",
        f"    <description>{escape(description)}</description>",
        f'    <CATEGORYMEM index="0" category="{membership}" />',
        make_axis(row, "x", columns),
        make_axis(row, "y", rows),
        '    <XDFAXIS id="z">',
        (
            f'      <EMBEDDEDDATA{type_flags} mmedaddress="0x{target:X}" '
            f'mmedelementsizebits="{bits}" mmedrowcount="{rows}" mmedcolcount="{columns}" '
            'mmedmajorstridebits="0" mmedminorstridebits="0" />'
        ),
        f"      <units>{escape(unit)}</units>",
        f"      <decimalpl>{decimals}</decimalpl>",
        f"      <min>{minimum:.6f}</min>",
        f"      <max>{maximum:.6f}</max>",
        "      <outputtype>1</outputtype>",
        f'      <MATH equation="{escape(math_equation(row))}">',
        '        <VAR id="X" />',
        "      </MATH>",
        "    </XDFAXIS>",
        "  </XDFTABLE>",
    ]
    return "\n".join(lines)


def main() -> None:
    target_data = BIN_PATH.read_bytes()
    with CSV_PATH.open(newline="", encoding="utf-8-sig") as handle:
        source_rows = list(csv.DictReader(handle, delimiter=";"))

    by_name = {}
    for row in source_rows:
        name = row["IdName"]
        if "FEQR" not in name:
            continue
        source = parse_address(row["Fieldvalues.StartAddr.Cpu"])
        if source is None or source >= len(target_data):
            continue
        by_name.setdefault(name, row)

    xdf_text = XDF_PATH.read_text(encoding="utf-8")
    root = ET.fromstring(xdf_text)
    existing_ids = {
        int(element.attrib["uniqueid"], 16)
        for element in root.findall("XDFTABLE")
        if element.attrib.get("uniqueid")
    }
    existing_by_address = {}
    for table in root.findall("XDFTABLE"):
        title = table.findtext("title", default="")
        z_axis = next((axis for axis in table.findall("XDFAXIS") if axis.attrib.get("id") == "z"), None)
        if z_axis is None:
            continue
        embedded = z_axis.find("EMBEDDEDDATA")
        if embedded is None or "mmedaddress" not in embedded.attrib:
            continue
        address = int(embedded.attrib["mmedaddress"], 16)
        existing_by_address.setdefault(address, []).append(title)

    next_id = 0x7282
    while next_id in existing_ids:
        next_id += 1

    additions = []
    ledger = []
    for row in sorted(by_name.values(), key=lambda item: parse_address(item["Fieldvalues.StartAddr.Cpu"])):
        source = parse_address(row["Fieldvalues.StartAddr.Cpu"])
        target, confidence, delta, evidence = map_target(source)
        category = category_for(row["IdName"])
        values = []
        raw = b""
        if target is not None:
            values, raw = decode_target(row, target_data, target)
        existing_titles = existing_by_address.get(target, []) if target is not None else []
        if confidence == "high" and target is not None and not existing_titles:
            while next_id in existing_ids:
                next_id += 1
            title = safe_title(row["IdName"], target)
            additions.append(make_table(row, target, next_id, category, evidence))
            existing_ids.add(next_id)
            existing_by_address[target] = [title]
            xdf_status = "added"
            xdf_title = title
            next_id += 1
        elif existing_titles:
            xdf_status = "existing"
            xdf_title = " | ".join(existing_titles)
        else:
            xdf_status = confidence
            xdf_title = ""
        rows, columns, bits, size = dimensions(row)
        ledger.append(
            {
                "symbol": row["IdName"],
                "function_group": category,
                "source_address": f"0x{source:06X}",
                "target_address": f"0x{target:06X}" if target is not None else "",
                "relocation_delta": delta,
                "rows": rows,
                "columns": columns,
                "storage": row["DataOrg"],
                "signed": row["bSigned"],
                "unit": row["Fieldvalues.Unit"],
                "factor": row["Fieldvalues.Factor"],
                "offset": row["Fieldvalues.Offset"],
                "target_value_preview": preview(values) if values else "",
                "target_min": f"{min(values):.6g}" if values else "",
                "target_max": f"{max(values):.6g}" if values else "",
                "confidence": confidence,
                "evidence": evidence,
                "xdf_status": xdf_status,
                "xdf_title": xdf_title,
                "notes": "Static/index axes where target axis storage is not independently proven.",
            }
        )

    BACKUP_PATH.parent.mkdir(parents=True, exist_ok=True)
    if not BACKUP_PATH.exists():
        shutil.copy2(XDF_PATH, BACKUP_PATH)

    category_lines = []
    for name, (index, _) in CATEGORIES.items():
        if f'name="{name}"' not in xdf_text:
            category_lines.append(f'    <CATEGORY index="0x{index:X}" name="{name}" />')
    if category_lines:
        xdf_text = xdf_text.replace(
            "  </XDFHEADER>", "\n".join(category_lines) + "\n  </XDFHEADER>", 1
        )

    marker = "  <!-- Expanded FEQR mappings added 2026-07-12 -->"
    if marker not in xdf_text and additions:
        fragment = marker + "\n" + "\n".join(additions) + "\n"
        xdf_text = xdf_text.replace("</XDFFORMAT>", fragment + "</XDFFORMAT>", 1)
    XDF_PATH.write_text(xdf_text, encoding="utf-8", newline="\n")

    with LEDGER_PATH.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(ledger[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(ledger)

    print(f"FEQR flash calibrations: {len(ledger)}")
    print(f"New XDF entries: {len(additions)}")
    print(f"Final unique ID: 0x{next_id - 1:X}")
    for status in ("existing", "added", "absent", "unresolved"):
        print(f"{status}: {sum(row['xdf_status'] == status for row in ledger)}")


if __name__ == "__main__":
    main()
