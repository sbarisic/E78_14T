# Marelli IAW 8P.40 External Evidence Notes

This file integrates the downloaded deep-research report as a set of leads and
cross-checks. It is intentionally separate from `LOGIC.md`: the firmware notes
remain the source of truth for code paths and offsets, while this file records
what public material appears to support, weaken, or leave open.

## Evidence Classes

| Class | Meaning | How to use it |
| --- | --- | --- |
| Verified public source | A public URL was checked during this pass and supports the statement. | Useful as context and corroboration, but not enough to name a ROM offset by itself. |
| Deep-research lead only | The downloaded report says it, but no usable public URL was verified here. | Treat as a lead for future research only. |
| Locally code-confirmed | The local 27C512 image or disassembly proves it. | Strongest evidence for XDF naming and logic notes. |
| Still unconfirmed | Neither public sources nor local code fully prove it yet. | Keep "likely", "candidate", or "provisional" labels. |

## Verified Public Sources

| Topic | Source | Checked fact | Local interpretation |
| --- | --- | --- | --- |
| Peugeot 106 1.3 Rallye application | Magneti Marelli identification catalogue: https://prepa205gti.wordpress.com/wp-content/uploads/2014/01/magneti_marelli_-identification_calculateur.pdf | Lists Peugeot 106 1.3 i Rallye, 1294 cc TU2J2, IAW 8P.40, reference `230016143457`. | Supports the project vehicle/ECU match. It does not expose map offsets. |
| Peugeot 106 1.3 Rallye application | V-Tuning file listing: https://www.v-tuning.eu/shop/product/ecu-original-file-peugeot-106-1300-rallye-100hp-ecu-magneti-marelli-iaw-8p-40%2C247349 | Lists an original file for Peugeot 106 1300 Rallye 100 hp with Magneti Marelli IAW 8P.40. | Corroborates the application, but is a commercial file listing rather than OEM proof. |
| 27C512 EPROM media | Cartelematics Peugeot ECU database: https://cartelematics.fr/ecu/fullecu/search-PEUGEOT.html | Lists Peugeot 106 1.3/1.3 Rallye IAW 8P.40 entries with `27C512` in PLCC or DIL form. | Matches the local `65536` byte EPROM image and off-board chip workflow. |
| 27C512 EPROM media | Eprom auto listing: https://immooff.net/download/ecu-pinout-diagram/listing_des_eprom_auto_par_marques.pdf | Lists Peugeot 106 Rally / IAW_8P40 entries with `27C512 DIL`. | Secondary support for 27C512 package variants. |
| Public map-family checklist | OldSkullTuning IAW 8P.40 XDF page: https://oldskulltuning.com/citroen-peugeot-marelli-iaw-8p-40-tunerpro-xdf/ | Lists example 106 Rally 1.3 maps: main fuel multiplier, spark high/low/WOT/correction/minimum/idle, dwell, air-density correction, VE correction, RPM axis, load/mbar axis, and RPM limiter. | Use as a target checklist only. The page does not disclose exact addresses. |
| TunerPro role | OldSkullTuning IAW 8P.40 XDF page: https://oldskulltuning.com/citroen-peugeot-marelli-iaw-8p-40-tunerpro-xdf/ | States that TunerPro is a binary editor and does not read/write the ECU directly. | Supports the off-board/EPROM workflow for this project. |
| Generic 8P sensors and pins | Magneti Marelli 8P/8F/6F/6R diagnostic guide mirror: https://www.scribd.com/document/954743628/33145789-Magnetti-Marelli-IAW-8P-20 | Describes 35-pin 8P-family connector, MAP, TPS, air temp, coolant temp, crank, lambda on some systems, diagnostic pins, main relay, fuel pump relay, and grounds. | Useful family cross-check only. Do not use as an exact 8P.40 bench-power recipe without vehicle harness confirmation. |
| 100 kPa MAP sensor clue | EuroFrance PRT03E/02 listing: https://eurofrance.ie/map-manifold-pressure-sensor-prt03e-02-1920p2-citroen-peugeot-fiat.html | Lists Magneti Marelli `PRT03E/02` / `1920P2` / `100kPa`, 3-pin, Citroen/Fiat/Peugeot MAP sensor. | Supports treating the spark x-axis as MAP/load-like. It does not prove the exact ROM transfer function. |

## Deep-Research Leads Kept Unverified

The downloaded report included several useful leads that were not promoted to
verified facts in this pass:

- Board/PCB revision meanings for labels such as `16143.xxx`.
- Primary-source confirmation of the exact MCU mask/part number for IAW 8P.40.
- Exact public checksum algorithm, window, and storage documentation.
- Exact public map addresses for IAW 8P.40 fuel, spark, dwell, idle, or air
  correction maps.
- Any public bootloader or in-car flashing method for this exact ECU subtype.

These remain research leads. The local ROM currently provides stronger evidence
for the 68HC11 execution model than the public material does.

## BTDig / Public Index Search Leads

BTDig was used only as a public filename/reference index. No torrent payloads,
magnet links, commercial XDFs, or archive contents were downloaded.

Checked query:

- `https://btdig.com/search?q=%22IAW%208P.40%22`

Observed BTDig filename leads:

| Indexed title | Visible matching files | Usefulness | Evidence state |
| --- | --- | --- | --- |
| `ECU ORIGINAL MAPS 2001 TO 2019` | `106 Rallye 1.3 100hp Magneti Marelli IAW 8P.40.ORI.BIN`; `Citroen Xantia 1.6L 8v iaw 8p.40 (607C).std` | Confirms that public indexes mention a 106 Rallye 1.3 IAW 8P.40 original binary and a Xantia 1.6 IAW 8P.40 `.std` definition/file. The `.std` extension may be an ECM/driver-style definition, not TunerPro XDF. | Deep-research / public-index lead only. Do not use as offset proof. |
| `-=Scan Tool Programs=-` | `PEUGEOT 106 1.6 IAW 8P.40 total.zip` | Suggests a 106 1.6 8P.40 package exists in old scan/chip-tool collections, but contents are unknown. | Deep-research / public-index lead only. |

Related public forum lead:

- Digital-Kaos archived thread:
  `https://www.digital-kaos.co.uk/forums/archive/index.php/t-206204.html`
- The thread is about a Peugeot 106 Rallye 1.3 IAW 8P.40 `27C512` file with
  checksum `B59A`, size `65536`, label `16143.124`, and OE `9620697280`.
- One reply claims an ECM6.3 `Driver 106RALL2`; another says there are two fuel
  maps with `9` load sites and about `21` speed sites, describes them as
  correction maps around stoichiometric AFR, mentions ignition and WOT maps, and
  gives an RPM-limiter formula of `21000000 / 16-bit value`.

How to use these leads:

- Treat `106RALL2`, `16143.124`, `9620697280`, `607C`, and `.std` as search
  terms for future manual research.
- The claimed `9` load-site fuel/correction maps are interesting because many
  local code-confirmed tables use 9 load columns, but no local consumer has yet
  proved a main fuel table.
- The claimed `21000000 / value` limiter formula does not match the current
  local period/RPM axis scaling (`15000000 / period`) used for `0x929E`, so it
  should be treated as a variant/tool lead, not a replacement for local math.
- Do not import addresses, scalings, or labels from these public-index/forum
  references without local ROM evidence.

XDF follow-up:

- XDF version `0.13` adds a `Public Index Leads` category with raw `21x9`
  overlays at `0x802E` and `0x80EB`, plus a `5x9` tail view at `0x81A8`.
- Those views are deliberately labeled overlays. They are for visual alignment
  testing against the public lead only and do not supersede the primary MOD2
  split views at `0x802E` (`24x9`) and `0x8106` (`23x9`).

## Map-Family Checklist

This table maps the public OldSkullTuning map-family list to the current local
reverse-engineering status. It is a checklist, not a claim that all public names
have been matched to exact local offsets.

| Public map family | Current local candidate/status | Evidence state |
| --- | --- | --- |
| Main fuel multiplier | No confirmed offset yet. Split `0x802E-0x8105` and `0x8106-0x81D4` remain tune-related candidates. | Still unconfirmed. Do not call either split "main fuel" yet. |
| Spark advance high octane | `0x8A69-0x8B40`, `24x9`, `raw / 2` degrees. | Locally code-confirmed lookup; likely high/default from selector and high-load comparison. |
| Spark advance low octane | `0x8B41-0x8C18`, `24x9`, `raw / 2` degrees. | Locally code-confirmed lookup; likely low/alternate. |
| Spark advance WOT | `0x8C19-0x8C30`, RPM-only vector, `raw / 2` degrees. | Locally code-confirmed bypass path; likely WOT/RPM-only spark. |
| Spark advance correction | No final public-name match. `0x9187-0x925E` and `0x89F3-0x8A05` are correction/load candidates. | Still unconfirmed. |
| Spark advance minimum | No confirmed local offset. | Still unconfirmed. |
| Spark advance idle | No confirmed local offset. | Still unconfirmed. |
| Dwell | No confirmed local offset. | Still unconfirmed. |
| Air density correction by temperature | `0x9187-0x925E` may be correction/load-model related, but not proven to be air density. | Still unconfirmed. |
| Volumetric efficiency correction | No confirmed local offset. `0x802E`/`0x8106` remain possible tune-related structures. | Still unconfirmed. |
| RPM axis | `0x929E-0x92CD`, code-confirmed 24-point period/RPM axis for `0x2036`. | Locally code-confirmed axis. |
| Load/mbar axis | `0x2034` is a load/MAP-like 8.8 axis; XDF labels use `0, 128, ..., 1024`. | Locally code-confirmed axis path, exact pressure scaling still provisional. |
| RPM limiter | `0x879E` / `0x87A0`, likely limiter set/clear period thresholds. | Locally code-referenced and MOD2-touched; meaning likely but still verify on hardware/logs. |

## External Evidence Boundaries

- Public pages confirm that IAW 8P.40 is a plausible Peugeot 106 1.3 Rallye ECU
  and that public XDF/mappack vendors expose the same broad map families we are
  hunting.
- Public pages do not confirm this repository's map offsets. Offsets must remain
  tied to local disassembly, MOD2 deltas, axes, and live/bench behavior.
- Generic 8P-family pinouts and sensor lists are useful for naming hypotheses,
  but they must not be treated as exact 8P.40 wiring proof.
- The 100 kPa MAP evidence supports the MAP/load-like interpretation of
  `0x2034`, but the ADC transfer and pressure conversion still need decoding.

## Bench / EPROM Workflow Cautions

- Preserve the original ROM dumps unchanged and compare repeated reads before
  editing.
- Work on copied binaries with clear names; do not edit stock `.bin` files in
  place.
- Correct the checksum pair at `0x800C-0x800F` after any ROM edit outside the
  checksum-skipped region.
- Validate changes in an emulator, on a bench, or with careful logging before
  road use.
- Treat generic 8P connector references as cross-checks. Confirm power, grounds,
  relay behavior, and diagnostic pins on the actual harness or ECU before bench
  powering.
- Avoid broad simultaneous changes. The XDF remains an inspection and
  reverse-engineering definition, not a fully decoded production tuning package.
