# Repository Index — E78_14T

> Research & development project for the **AcDelco E78 ECU** and **GM/Opel 1.4T A14NET (LUJ/LUV)** engine platform, primarily on the **Opel Corsa E** chassis. Covers ECU tuning, engine internals, CAN bus reverse engineering, data logging, custom electronics, and firmware analysis. Also includes some BMW N57 (F30 330D) and Opel Astra material.

**License:** [The Unlicense](LICENSE) (public domain)

---

## Table of Contents

- [Root Files](#root-files)
- [ECU Pinout Documentation](#ecu_pinout)
- [GMLAN — CAN Bus Protocol](#gmlan)
- [VCM — VCM Scanner Configuration](#vcm)
- [VirtualDyno — Virtual Dynamometer App](#virtualdyno)
- [Corsa E M32 Gearbox](#corsa_e_m32_gearbox)
- [ECUMaster — Standalone ECU Tunes & Logs](#ecumaster)
- [Engine Assembly](#engine_assembly)
- [HPTuners Logs (logs/)](#logs)
- [HPTuners Logs — Phase 2 (logs_2/)](#logs_2)
- [ECUMaster Logs — Phase 3 (logs_3/)](#logs_3)
- [New Pistons Logs (logs_4_new_pistons/)](#logs_4_new_pistons)
- [CSV Exports (logs_csv/)](#logs_csv)
- [Tune Files (tunes/)](#tunes)
- [Sample Tunes (sample_tunes/)](#sample_tunes)
- [Tuning Data & Calculations](#tuning_data)
- [XDF — ECU Map Definitions](#xdf)
- [Source Code (sources/)](#sources)
- [Other / Miscellaneous](#other)
- [Shared Archives (share/)](#share)

---

## Root Files

| File | Description |
|------|-------------|
| `README.md` | Engine specs (bore, stroke, cams), injector data (Bosch 0 280 158 205 / 117), fuel pressure notes, and math formulas (BMEP, HP, injector pulse width) |
| `HPTQCalc.xlsx` | Horsepower / torque calculator spreadsheet |
| `180hp_VE_calc.pdn` | Volumetric efficiency calculation graphic (Paint.NET) |
| `stock_turbo_map.png` | Compressor map for the stock turbocharger |
| `turbo_choices.pdn` | Turbo selection comparison graphic (Paint.NET) |
| `Yeet.txt` | Parts list & cost estimate — forged rods, pistons, valve springs, Garrett GBC22-350 (~$1810 USD total) |
| `.gitignore` | Git ignore rules |
| `LICENSE` | The Unlicense (public domain) |

---

<a id="ecu_pinout"></a>
## ECU_pinout/ — ECU & Module Pinout Documentation

Hardware pinout references for the Corsa E and related GM vehicles.

| Path | Description |
|------|-------------|
| `2011_cruze_BCM_pinout.pdf` | Body Control Module pinout — 2011 Cruze |
| `2012_cruze_EBCM_pinout.pdf` | Electronic Brake Control Module pinout — 2012 Cruze |
| `2013_cruze_data_comm_low_speed_GMLAN_2852274_anno4.jpg` | Annotated GMLAN low-speed bus diagram |
| `2016 l96 6L90 ECM PINOUT.pdf` | L96 / 6L90 ECM connector pinout |
| `2016 l96 6L90 ECM X3 PINOUT.pdf` | L96 / 6L90 ECM X3 connector pinout |
| `DBW_Pinout.pdf` | Drive-By-Wire (electronic throttle) pinout |
| `Generator/` | GM Regulated Voltage Control (RVC) alternator documentation — terminal L (PWM duty cycle control) and terminal F (field load monitoring) |
| `X2/` | Connector X2 pinout photos (6 images, a–f) |
| `odometer_connector/pinout.txt` | Instrument cluster connector pinout — GMLAN, battery, ignition, DIC switches, ambient temp sensor, dimming |

---

<a id="gmlan"></a>
## GMLAN/ — CAN Bus Protocol Implementation

Arduino-based GMLAN (GM Local Area Network) CAN bus communication project.

- `GMLAN/GMLAN.sln` — Visual Studio solution
- `main/main.ino` — Arduino sketch implementing CAN bus communication

---

<a id="vcm"></a>
## VCM/ — VCM Scanner Configuration

Configuration files for **VCM Scanner** (HPTuners' logging/diagnostics tool).

| Subdirectory | Contents |
|--------------|----------|
| `VCM_Channels/` | Channel definitions (6 XML files) — AEM wideband AFR, Astra channels, Corsa E channels |
| `VCM_Charts/` | Chart layout configurations (4 XML) |
| `VCM_Gauges/` | Gauge display definitions |
| `VCM_Graphs/` | Graph configurations for Corsa E |
| `VCM_Layouts/` | Dashboard layouts |
| `VCM_MathParams/` | Calculated parameters (8 XML) — engine power, torque, VE, fuel pressure delta, injector duty cycle, wastegate duty |

**Spreadsheets:**
- `CamAngleConversion.xlsx` — Cam phaser angle calculations
- `FuelInjectorCalculator.xlsx` — Injector flow rate & sizing calculator

---

<a id="virtualdyno"></a>
## VirtualDyno/ — Virtual Dynamometer Application

C# Windows Forms application (`.sln` + `.csproj`) for estimating engine power from logged data. Likely uses vehicle weight, gear ratios, and acceleration to compute a virtual dyno run.

- `VirtualDyno.sln` — Solution file
- `MainForm.cs` — Main UI
- `Program.cs` — Entry point

---

<a id="corsa_e_m32_gearbox"></a>
## corsa_e_m32_gearbox/ — M32 Gearbox & Differential

Photo documentation of the M32 gearbox differential internals.

- `diff/` — 6 photos of the differential (dated 2021-02-16)
- `diff/nice/` — 6 additional detailed photos

---

<a id="ecumaster"></a>
## ecumaster/ — ECUMaster Standalone ECU

Tunes (`.emub`), logs (`.emublog`), CAN bus captures, and layouts for the **ECUMaster EMU Black** standalone ECU running the A14NET engine.

### Tune Maps (`.emub`)

| File | Description |
|------|-------------|
| `a14net.emub` | Current / active A14NET tune |
| `a14net_before_forging_stock.emub` | Backup of tune before forged internals |
| `a14net_hiroshima_hairdryer_piston_space_program_map.emub` | Experimental high-boost map |
| `a14net_old.emub` | Previous tune revision |
| `base_m54b30.emub` | BMW M54B30 base map (separate project) |
| `w124t_m111.emub` | Mercedes W124 M111 tune (separate project) |

### Log Files

Organized chronologically from 2023–2026:
- `ecumaster/logs/2023/corsa/` — Early ECUMaster logs (cold starts, long drives)
- `ecumaster/logs/2024/corsa/` — G25-550 turbo testing, boost tuning
- `ecumaster/logs/2025/corsa/` — PCV fixes, boost tests, latest development
- `ecumaster/20250831/` — August 2025 session logs
- Anti-lag test logs (2023-09-09 through 2023-09-10)

### CAN Bus

- `can_logs/` — 8+ `.candump` files from key-on and engine-running captures
- `can_logs/corsa_e_can.dbc` — CAN database definition for Corsa E
- `can_logs/dbc/gm_global_a_powertrain_generated.dbc` — GM Global A powertrain CAN database (~15 KB)

### Other
- `ECUMaster EMU First Start Checklist.docx` — Setup checklist
- `layout_template.emublayout` — Dashboard layout

---

<a id="logs"></a>
## logs/ — HPTuners Logs (Phase 1 — Stock & Early Mods)

**~57 `.hpl` log files** from HPTuners data logging during the original E78 ECU phase.

| Subdirectory | Count | Description |
|--------------|-------|-------------|
| *(root)* | ~57 | Cold starts, MAF tuning, wideband feedback, general driving |
| `meth/` | ~27 | **Methanol injection testing** — logs at 150–250 kPa boost with various cam angles |
| `newturbo/` | ~70 | **New turbocharger evaluation** — wastegate tuning, injector testing, wideband logging |

Key log series:
- `cold_start_*.hpl` — Cold start behavior
- `maf_tuning_*.hpl`, `maf_wideband_*.hpl` — MAF sensor calibration with wideband O2
- `meth/meth_*.hpl` — Methanol injection sweeps at different boost pressures
- `newturbo/newturbo_*.hpl` — Upgraded turbo development & wastegate calibration

---

<a id="logs_2"></a>
## logs_2/ — HPTuners Logs (Phase 2 — Astra, Cams, Dyno, Fuel)

Extended HPTuners logging phase covering multiple vehicles and tuning areas.

| Subdirectory | Contents |
|--------------|----------|
| `astra/` through `astra4/` | Stock Astra tuning iterations (14 + 11 + 5 + 2 `.hpl` files) |
| `cam_tuning/` | 25 logs — VVT angle experiments and cam timing optimization |
| `fuel_tuning/` | 36 logs — Fuel delivery and injector tuning |
| `new_cams/` | 19 logs — Aftermarket camshaft testing |
| `intercooler_shroud/` | 4 logs — Intercooler shroud/ducting modification testing |
| `dyno/` | Dyno session — Corsa E 1.4T 2019 pulls at various boost levels + graph PNGs |
| *(root)* | Corsa E baselines (2016, 2019), cold driving, knock testing, injector tests |

---

<a id="logs_3"></a>
## logs_3/ — ECUMaster Logs (Phase 3 — EMU Black Build)

ECUMaster EMU Black standalone ECU build phase.

- `CorsaE-EmuBlack/QuickSave/` — **36 quicksave `.emub` map revisions** (July–November 2025) — iterative tuning snapshots
- `CorsaE-EmuBlack/desktops.emublayout` — EMU Black desktop layout

---

<a id="logs_4_new_pistons"></a>
## logs_4_new_pistons/ — Forged Pistons Break-In

Initial testing after installing forged pistons (March 2026).

- `20260322_1852_pistons_drive1.emublog` — First drive
- `20260322_1905_pistons_drive2.emublog` — Second drive
- `map_file.emub` — Map used during break-in

---

<a id="logs_csv"></a>
## logs_csv/ — CSV Exports

- `newlog3.csv` — Exported log data in CSV format
- `newlog3.dynolog` — Dynamometer log format export

---

<a id="tunes"></a>
## tunes/ — ECU Binary Images & Map Files

Raw ECU firmware binaries (`.bin`), calibration files, and map definitions for multiple platforms.

| Directory | Platform | Contents |
|-----------|----------|----------|
| `AcDelco E78 Full/` | AcDelco E78 | 8 files — firmware binaries |
| `AcDelco E98A/` | AcDelco E98A | 1 file |
| `Delco E98a/` | Delco E98A | 3 files |
| `Opel Corsa E 1.4 Turbo 2019/` | E78 (Corsa E) | 11 files — includes `bcm/` (body control module) and `change_everything_bins/` (12 bin variants) |
| `astra_j_14t/` | Astra J 1.4T | 1 file |
| `BMW_N57_F30/` | BMW F30 330D (N57) | Bosch EDC17C56 — OBD-read `.bin`, WinOLS stage1 tune, `rev_eng.xdf`, DAMOS A2L files (EDC17C50 + EDC17C56, ~30 MB each) |
| `Z20LEH Stock/` | Opel Z20LEH (2.0T) | 1 stock binary |
| `Z20LEL Stock/` | Opel Z20LEL (2.0T) | 1 stock binary |
| `E78.xdf/` | E78 XDF development | XDF map definition files |

---

<a id="sample_tunes"></a>
## sample_tunes/ — Reference HPTuners Tunes

**~28 `.hpt` tune files** from various GM 1.4T vehicles used as references.

| Source Vehicle | Files |
|----------------|-------|
| 2012–2017 Chevrolet Cruze 1.4T | Multiple stock & tuned variants |
| 2013 Sonic RS 1.4 | Stock reference |
| Buick Encore 1.4T | Stock reference |
| Vanderhall 1.4T | Reference tune |

**Subdirectories with iterative tuning:**

| Directory | Description |
|-----------|-------------|
| `adam/` | Adam's A14T tune — 23 files (`.hpt` + `.hpl` logs) |
| `adam3/` | Adam variant 3 — turbo + wastegate tuning (6 `.hpt`, 1 `.xdf`, 15 logs) |
| `adam4/` | Adam variant 4 — boost control fixes (7 `.hpt`) |
| `astra/` | Astra K 2017 1.6T — 7 tune variants |
| `corsa/` | Corsa E reference library — 14 `.hpt` files |

---

<a id="tuning_data"></a>
## tuning_data/ — Tuning Calculations & Injector Data

- `0280158117_data.jpg` — Bosch 0 280 158 117 injector datasheet scan
- `airflow_vs_rpm.xlsx` — Airflow calculations across RPM range
- `detailed_injector_calc.xlsx` — Detailed injector sizing and flow rate calculations

---

<a id="xdf"></a>
## xdf/ — XDF ECU Map Definition Files

[XDF files](https://en.wikipedia.org/wiki/XDF) define table locations and scaling for reading/editing ECU firmware binaries (used with TunerPro or similar tools).

| File | Description |
|------|-------------|
| `E78_DesiredECT_OS_12646746.xdf` | Desired Engine Coolant Temperature map — OS 12646746 |
| `acdelco_e78_os12669508.xdf` | AcDelco E78 map definitions — OS 12669508 |
| `acdelco_e78_views.xdf` | AcDelco E78 with custom view configurations |

---

<a id="sources"></a>
## sources/ — Source Code & Hardware Projects

### Uni78/ — E78 ECU Firmware Analysis Tools (C# / .NET)

Main software project for reverse engineering the E78 ECU firmware.

- **`Uni78/`** — Core application (`Program.cs`, includes `data/firm.bin` firmware binary)
- **`DamosCSVParser/`** — Parses DAMOS CSV exports (WinOLS format) to extract ECU parameter definitions
  - `Damos.cs`, `DamosNames.cs` — Parser logic
  - `data/winols_astra.csv` — Sample Astra DAMOS export
- **`FirmwareScanner/`** — Scans firmware binaries for calibration data ranges
  - `RangeScanner.cs` — Range scanning algorithm
  - `data/firm.bin` — Firmware binary
- **`notes.md`** — Links to MPC5566 datasheet, PowerPC boot sequence, Unicorn Engine samples (for emulation)

### CorsaCore/ — ESP32 Vehicle Interface Firmware

PlatformIO/ESP-IDF project for a **TTGO T7 v1.4 Mini32** (ESP32) board. A multi-function vehicle interface with:

| Module | File | Purpose |
|--------|------|---------|
| Main | `main.cpp` | Entry point & task orchestration |
| Clock | `core2_clock.cpp` | Timekeeping |
| Filesystem | `core2_filesystem.cpp` | SPIFFS/flash filesystem |
| Flash | `core2_flash.cpp` | Flash memory operations |
| GPIO | `core2_gpio.cpp` | General purpose I/O |
| JSON | `core2_json.cpp` | JSON parsing/serialization |
| MCP320x | `core2_mcp320x.cpp` | MCP3204/3208 ADC (analog sensor input via SPI) |
| OLED | `core2_oled.cpp` | OLED display driver |
| Shell | `core2_shell.cpp` | Serial command shell |
| SPI | `core2_spi.cpp` | SPI bus management |
| Telnet | `core2_telnet.cpp` | Telnet server for remote access |
| Web | `core2_web.cpp` | HTTP web server interface |
| WiFi | `core2_wifi.cpp` | WiFi connectivity |

### CorsaCAN/ — CAN Bus Arduino Project

PlatformIO Arduino project for CAN bus communication (`src/Arduino_CAN.cpp`).

### Arduino_CAN/ — CAN Bus Sketch (Simple)

Standalone Arduino sketch for CAN bus communication (`Arduino_CAN.ino`).

### EasyEDA/ — Custom PCB Design

- `Gerber/Gerber_PCB_CorsaE_12V_to_5V_LLC.zip` — Gerber manufacturing files for a **12V→5V LLC converter** PCB (powers ESP32/electronics from vehicle 12V)
- `projects/CorsaE/` — EasyEDA schematic and PCB layout files

### Other

- `hptuners_com_sniffing.zip` — Captured network traffic from HPTuners software (protocol analysis)

---

<a id="other"></a>
## other/ — Miscellaneous

- `AUTOSAR_XCP_ReferenceBook_V3.0_EN.pdf` — AUTOSAR XCP (Universal Measurement and Calibration Protocol) reference — used for ECU calibration/measurement
- `bins.zip` — Archive of binary files

---

<a id="share"></a>
## share/ — Shared Archives

- `AstraK2017_16T.zip` — Astra K 2017 1.6T tune/data package for sharing

---

## Project Timeline (approximate)

| Phase | Period | Focus |
|-------|--------|-------|
| **1 — Stock E78 Tuning** | 2021–2023 | HPTuners-based tuning of the stock AcDelco E78 ECU — MAF calibration, injector scaling, cam timing |
| **2 — Hardware Upgrades** | 2022–2023 | New turbo (Garrett GBC22-350 → G25-550), methanol injection testing, upgraded injectors |
| **3 — ECUMaster Standalone** | 2023–2025 | Transition to ECUMaster EMU Black standalone ECU — full engine management, anti-lag development |
| **4 — Forged Internals** | 2025–2026 | Forged pistons & rods, continued EMU Black tuning with stronger internals |
| **Side Projects** | Ongoing | BMW F30 N57 tuning, Astra K 1.6T, CAN bus reverse engineering, ESP32 vehicle interface, firmware analysis tools |

---

## Key Technologies & Tools

- **HPTuners** — VCM Suite for E78 ECU flash tuning and data logging (`.hpt`, `.hpl`)
- **ECUMaster EMU Black** — Standalone engine management (`.emub`, `.emublog`)
- **TunerPro / XDF** — Open ECU map editing via XDF definition files
- **WinOLS** — ECU calibration and DAMOS file editing
- **PlatformIO / Arduino / ESP-IDF** — Embedded firmware development
- **EasyEDA** — PCB schematic and layout design
- **GMLAN / CAN bus** — Vehicle network communication protocols
