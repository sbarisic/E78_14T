# Marelli IAW 8P.40 Evidence Notes
This is the consolidated source for confidence status, public-source context, sensor clues, comparison evidence, and generated analyzer snapshots. Local code-path interpretation belongs in `LOGIC.md`.
## XDF Display Note
XDF v0.44 uses 1-based `CATEGORYMEM category` values because TunerPro displays
membership `N` as the Nth category definition. Category definitions still start
at index `0x0`; the shifted memberships are intentional and keep the on-screen
folders aligned with the subsystem names below. Version `0.44` also corrects
the `$2040` scheduler-support table boundaries: `0x92FA` is a 1x9 table,
`0x9303` is a separate signed subvector, and `0x8789` is a 1x9 word table.
Version `0.50` labels the shared scheduler axis as
`$2040 = max($00CC - 0x8000, 0) >> 4`, displays numeric decimal `$00CC`
sites so TunerPro does not coerce hex/text labels to zero, and keeps only a
provisional `2 us/tick` ms view for `0x8789`; raw timer ticks remain
authoritative.
Version `0.51` removes the early raw 16x16 lead windows at `0x5100`, `0x5200`,
`0x5300`, and `0xB500` from the active XDF after disassembly confirmed those
ranges are executable code, not calibration tables.
Version `0.52` renames `0x869A` as a raw fuel-cut/state-delay table by
positive load rise since state entry and RPM, with numeric raw load-rise labels
and raw countdown tick values.
Version `0.53` adds the complete 21-word ROM vector table and exact non-tuning
firmware-support constants for expected stack top `0x916A = 0x27FF` and
checksum-service enable byte `0x916E = 0xFF`. It also records the corrected
main-loop addresses `D2EE/D2F1/D2F4`, loop-back jump at `D6A9`, and incremental
checksum routine range `0x5AD6-0x5B19`; calibration maps and scaling are unchanged.
Version `0.54` removes obsolete MOD2 scalar/last-cell aliases and the five
redundant percentage fuel-trim views. Signed raw fuel views remain authoritative,
and multiplier views remain the primary tuning displays. It also adopts
code-trace-based primary/alternate limiter, spark bank A/B, RPM-only bypass,
and fast closed-loop fuel-correction names.

## Reverse-Engineering Artifact Status

The reverse-engineering snapshots are now organized as `reverse_eng/v1`,
`reverse_eng/v2`, and `reverse_eng/v3`. v1 retains the original executable
report, code ranges, vector CSV, call edges, and stock/MOD2 diff regions. v2 is
superseded. v3 is the current annotation/symbol-database design.

Locally verified v3 facts:

- Its `13,755` raw address records are byte/mnemonic-identical to v1.
- It preserves the same `680` direct-call edges and `21` vector words.
- It contains `526` symbols and `361` routine entries.
- Five ownership regression tests pass, all direct calls have an explicit
  owner, and the previous 19 call-site misattributions are corrected.
- Six discontiguous routine spans now expose exact decoded blocks, decoded
  byte counts, and gap bytes rather than implying continuous executable code.
- The newly separated entries at `0x6C6A`, `0x6CFB`, `0x74CA`, `0xD80B`, and
  `0xE080` strengthen scheduler, period, and SCI-service tracing.

The v3 resolved CSV regenerates byte-for-byte. The annotated ASM regenerates
with identical text but platform-dependent LF/CRLF bytes, and the SQLite schema
and ordered logical rows regenerate identically while the physical SQLite file
hash differs. Therefore `verify_reproducibility.py` currently reports ASM and
SQLite hash mismatches on Windows even though semantic content matches.
The root `tools/test_iaw8p40_tools.py` vector-metadata test also still points
to the pre-reorganization `reverse_eng/IAW8P40_peugeot106_vectors.csv` path;
the authoritative v1 CSV now lives under `reverse_eng/v1`, so that integration
test fails until its fixture path is updated.

v3 is a core firmware symbol database, not a complete XDF inventory. Its 44 ROM
symbols all have matching active-XDF bases, but many exact warmup, transient,
idle, adaptive, and support views remain documented only in the XDF/`LOGIC.md`.
It also omits confirmed checksum-service enable byte `0x916E`, which remains in
v1 and active XDF v0.54. The active XDF uses the software-proven fast closed-loop
fuel-correction role for `0x84E3`, but does not promote `$200C` to a physically
confirmed O2/lambda channel because hardware proof is still absent.

## Evidence Status
This table separates code-confirmed structures from MOD2/same-family-supported
candidates and visual/public-index probes. The current corpus has six local
64 KiB images: Peugeot stock, Peugeot `Stok`, Peugeot MOD2, Xantia 607C,
`Peug.106Rally.org.bin`, and `RALLY13.ORI`. `Peug.106Rally.org.bin` is kept as
suspicious comparison evidence because it has reset vector `0xB800` but a
nonzero prefix and invalid checksum byte sum. `RALLY13.ORI` is checksum-valid
same-family comparison evidence. Fuel names stay likely/candidate until a
Peugeot-local consumer reaches fuel pulse width, fuel time, lambda correction,
air-charge math, or injection scheduling.

| Offset | Shape | Label | Code-confirmed | MOD2-touched | Same-family comparable | Scaling | Confidence | Next proof required |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `0x802B-0x8102` | `24x9` | Signed Fuel IAT/RPM Correction A | Yes; XDF `Fuel IAT/RPM Corrections` category | Yes, signed deltas in MOD2 | Xantia/RALLY13 comparable but strategy differs | Signed 8-bit; X likely IAT path `0x92D9 -> $2038` displayed as inverted consumer order `-40..120 C`, Y RPM `0x929E`, output `$204A` into `$204B -> $00C1` | High structure, medium physical role | Prove exact sensor pin and keep final injector driver/pin hardware proof separate. |
| `0x8103-0x81DA` | `24x9` | Signed Fuel IAT/RPM Correction B | Yes; XDF `Fuel IAT/RPM Corrections` category | Yes, signed deltas in MOD2 | Xantia/RALLY13 comparable but strategy differs | Signed 8-bit; X likely IAT path `0x92D9 -> $2038` displayed as inverted consumer order `-40..120 C`, Y RPM `0x929E`, output `$204D` into `$204E/$204F` blend path | High structure, medium physical role | Prove exact sensor pin and keep final injector driver/pin hardware proof separate. |
| `0x81F8-0x821B` | `4x9` | Low-RPM Fuel Trim A | Yes; alternate `$E38B` base | Yes, overlaps fuel-trim region | Same-family comparison only | Signed 8-bit; guarded low-RPM/submode slice before `0x821C`; raw, percent, and multiplier XDF views are exposed | Alternate fuel-trim path | Use carefully until the exact low-RPM/submode guard is fully named. |
| `0x821C-0x82F3` | `24x9` | Signed Fuel Quantity Trim A | Yes; selected by `$E38B` when `$20B1 != 0` | Yes, fuel-trim region candidate | Same-family comparison only | Signed 8-bit; X runtime `$2034`, Y RPM `$2036`, output `$2084`; `$E715` applies roughly `fuel += fuel * raw / 256` | Strongest signed fuel quantity trim | Do not treat as VE/base fuel; prove relationship to any pure base table separately. |
| `0x82F4-0x8317` | `4x9` | Low-RPM Fuel Trim B | Yes; alternate `$E38B` base | Yes, overlaps fuel-trim region | Same-family comparison only | Signed 8-bit; guarded low-RPM/submode slice before `0x8318`; raw, percent, and multiplier XDF views are exposed | Alternate fuel-trim path | Use carefully until the exact low-RPM/submode guard is fully named. |
| `0x8318-0x83EF` | `24x9` | Signed Fuel Quantity Trim B | Yes; selected by `$E38B` when `$20B1 == 0` | Yes, fuel-trim region candidate | Same-family comparison only | Signed 8-bit; X runtime `$2034`, Y RPM `$2036`, output `$2084`; `$20B1` selects fuel trim banks too | Strongest signed fuel quantity trim | Do not treat as VE/base fuel; prove relationship to any pure base table separately. |
| `0x83F0-0x8407` | `1x24` | RPM-only Fuel Trim / Bypass Vector Candidate | Yes; selected by `$E38B` bypass branch | Yes, fuel-trim region candidate | Same-family comparison only | Signed 8-bit; X RPM `$2036`, output `$2084` | Strong RPM-only trim/bypass candidate | Prove bypass condition and final operating mode. |
| `0x85BA-0x8631` | `24x5` | High-Load Fuel Pulse Extension / Duration Support | Yes; `$6E96` high-load path | No | Same-family comparison only | Raw; output `$2063` is doubled into the `$00C3` duration path | Fuel duration support | Do not treat as event phase or main fuel trim. |
| `0x869A-0x8771` | `24x9` | Fuel-Cut / State Delay vs Load Rise and RPM | Yes; `0x9B79` B2D6 path stores output to `$2391` | No | Same-family comparison only | Raw countdown ticks; X is clamped positive `$2014 - $2394` load rise with `$2394` snapshot from `$00CE`, Y RPM `$2036` | State-delay / fuel-cut-mode delay | Not fuel quantity, spark, VE, or a limiter threshold; expiry path sets `$00A3=0x04`, clears `$00AB`, and zeros `$00C3`. |
| `0x877E-0x8786` | `1x9` | Fuel Output Event Width Limit / Previous Width | Yes; `$D5DF` scheduler-support path | No | Same-family comparison only | Raw byte vector indexed by `$2040 = max($00CC - 0x8000, 0) >> 4`; feeds `$00BF` | Fuel output timing support | Keep raw; not fuel quantity. |
| `0x8787-0x8788` | word | OC3 Period-Fit Guard Word | Yes; used around `$706C-$7074` | No | Same-family comparison only | Raw 16-bit timer ticks | Fuel output timing guard | Do not convert to ms or crank degrees until E-clock/prescaler proof. |
| `0x8789-0x879A` | `1x9 words` | Fuel Output Edge Offset / Deadline | Yes; `$B26E` path stores result to `$2086` | No | Same-family comparison only | Raw 16-bit timer-tick words indexed by `$2040 = max($00CC - 0x8000, 0) >> 4`; optional ms view assumes `2 us/tick`; `0x879B/0x879C` are separate data | Edge-offset/deadline-style support | Not fuel quantity or normal injector battery deadtime; raw ticks remain authoritative. |
| `0x87B1-0x8888` | `24x9` | Injector/Event Phase Offset | Yes; output `$00BE -> $21C6` | No | Same-family comparison only | Raw; X `$2034`, Y `$2036`; stock table is all zero | Strong fuel event phase candidate | Changes affect event timing/phase, not fuel quantity; use carefully. |
| `0x84E3-0x84EB` | `1x9` | Fast Closed-Loop Fuel Correction vs `$2040` | Yes; `$E83E-$E848` indexes `$2040` and stores fast correction `$2049` | TBD | Same-family comparison only | Raw; output `$2049` applies to `$00C1` | Strong software closed-loop fuel correction | `$200C` physical lambda/O2 origin remains provisional; old oversized view was retired because `0x84EC/0x84ED` are separate labels. |
| `0x84EC` | byte | Scheduler `$00D3` Threshold Byte | Yes; `$7201-$7206` compares `$00D3` with `L84EC` | No | Same-family comparison only | Raw threshold | Scheduler/state threshold | Kept separate from both `0x84E3` and `0x84ED`. |
| RAM `$20B9` | runtime word | Adaptive Fuel Trim | Yes; applied around `$E748` | Not ROM data | Strategy evidence | Centred at `$8000`; high byte differs from `$80` when active | Strong adaptive trim candidate | Confirm lambda behavior from logs/scope. |
| RAM `$0060/$0069` | learned RAM cells | Adaptive Trim Cell Tables | Yes; interpolated by `$C94B` | Not ROM data | Strategy evidence | Neutral `$80`; indexed by likely CTS axis family | Learned long-term trim cells | Confirm update behavior from logs. |
| `0x9000-0x912B` | vectors/scalars | Closed-Loop / Adaptive Calibration | Yes; `$C000-$C90E` state machine | Mostly not MOD2-touched | Same-family comparison only | Raw vectors and thresholds; includes `0x9073` ramp target | Strong closed-loop/adaptive calibration region | Finish scalar naming in `0x9100-0x912B`. |
| `0x802E-0x80EA` | `21x9` | Retired Misaligned Slice Inside `0x802B` | No active XDF entry | Yes, because it overlaps `0x802B` | Same-offset comparison only | Historical raw visual probe | Retired/debug only | Removed from active XDF v0.42; do not tune as VE. |
| `0x802E-0x8105` | `24x9` | Retired Boundary View for `0x802E` | No active XDF entry | Yes, because it overlaps `0x802B/0x8103` | Same-offset comparison only | Historical raw visual probe | Retired/debug only | Removed from active XDF v0.42; do not tune as VE. |
| `0x80EB-0x81A7` | `21x9` | Retired Signed Boundary Slice | No active XDF entry | Yes, overlaps corrected signed region | Same-offset comparison only | Signed 8-bit historical view; starts at `0x802B+0xC0` and crosses into `0x8103` | Retired/debug only | Removed from active XDF v0.42; do not tune as a standalone map. |
| `0x81A8-0x81D4` | `5x9` | Retired Alignment Probe Tail | No active XDF entry | Yes, overlaps corrected signed region | Same-offset comparison only | Raw | Retired/debug only | Removed from active XDF v0.42. |
| `0x80F1-0x81D1` | `25x9` | Retired Signed Alignment Probe | No active XDF entry | Yes, overlaps corrected signed region | Same-offset comparison only | Signed 8-bit historical view | Retired/debug only | Removed from active XDF v0.42. |
| `0x8A69-0x8B40` | `24x9` | Main Spark Bank A / Default | Yes, Peugeot stock/MOD2; XDF `Ignition Main` category | Yes | Peug public file uses same offset but altered; RALLY13 shifted to `0x8A84` | Z `raw / 2` degrees; X rounded display-only `0-100 kPa` from runtime `0x2034` | High structural/default-bank role | High-octane remains a physical hypothesis; prove exact MAP transfer. |
| `0x8B41-0x8C18` | `24x9` | Main Spark Bank B / Alternate | Yes, Peugeot stock/MOD2; XDF `Ignition Main` category | Yes | Peug public file uses same offset but altered; RALLY13 shifted to `0x8B5C` | Z `raw / 2` degrees; X rounded display-only `0-100 kPa` from runtime `0x2034` | High structural/alternate-bank role | Low-octane remains a physical hypothesis; prove exact MAP transfer. |
| `0x8C19-0x8C30` | `1x24` | RPM-only Bypass Spark Vector | Yes, Peugeot stock/MOD2; XDF `Ignition Main` category | No | Peug public file unchanged at same offset; RALLY13 shifted to `0x8C34`; Xantia differs strongly | `raw / 2` degrees, RPM-only axis `0x2036` | Medium-high bypass role | WOT remains a physical hypothesis; finish the bypass-condition trace. |
| `0x9187-0x925E` | `24x9` | Load / Air-Charge Model Factor | Yes | Yes, `62 / 216` | Yes, but strategy differs | `raw / 230` hypothesis | Medium-high structural | Prove exact physical role: air density, VE, fuel, or load-model correction. |
| `0x888E-0x8965` | `24x9` | Idle Air / Idle Bypass Target | Yes; XDF `Idle / Actuator` category | No | Same-family comparison only | Raw; X `$2034`, Y `$2036`, output `$2484` | Medium-high idle/actuator candidate | Trace `$1050.04` to idle actuator/driver hardware. |
| `0x8970-0x8980` | `1x17` | CTS Idle Target / Cap Vector | Candidate; used with `$203E` in idle path | TBD | Same-family comparison only | Raw; output `$2486` | Medium likely CTS idle vector | Confirm CTS pin and actuator hardware. |
| `0x8010-0x8027` | `1x12 words` | SPI Output Pointer Frame | Yes; consumed by `0x9F02-0xA001` | No | Strategy specific | 16-bit pointers to live RAM/status | Non-tune | Keep out of fuel/spark calibration interpretation. |
| `0x8E6F/0x8EC7/0x8F1C/0x8F71` | `17x5` | Adaptive Trim Dynamics Cluster | Yes; `$D105-$D15D` cluster | No | Same-family comparison only | Raw; axes `$00D0`-derived load by `$2044`; outputs `$24AB/$24AF/$24AC/$24AD` | Strong lambda/adaptive dynamics role | Decode `$CC00-$CE38` state machine naming. |
| `0x89C7/0x89DA/0x8A52` | `1x19` | Ignition Output / Per-event Retard Vectors | Yes; XDF ignition output category | `0x8A52` unchanged, `0x89C7/0x89DA` unchanged | Same offset not authoritative | Raw; `$2044` 400 rpm sites | Strong software ignition strategy role | Decode `$7Cxx-$7Fxx` event table and hardware coil output. |
| `0x89F3-0x8A05` | `1x19` | Per-event Retard/Gain Candidate | Yes; XDF `Ignition Output / Retard` category | Yes, `16 / 19` | Same offset not authoritative | Raw; `$2044` 400 rpm sites | Medium-high structure | Prove whether it is knock/roughness/adaptive retard gain or broader per-event correction. |
| `0x7CDA/0x7CEA` | selector data | Ignition Event Selector Tables | Yes; event builder data | No | Strategy specific | Count byte plus `[threshold,event,aux]` triples | Strong non-map data classification | Do not expose as tuning maps; continue decoding `$23xx` records. |
| `0x879E/0x87A0` | `2x16-bit` | Primary RPM Limiter Set/Clear Thresholds | Yes; `0x6F01-0x6FE2` directly compares engine period and controls limiter bit `$00A4.10` | Yes | No | `15000000 / period`, locally consistent with the code-confirmed RPM axis | High software role | Hardware/log validation remains useful; public `21000000 / value` remains an unadopted lead. |
| `RAM 0x2034` | runtime `8.8` axis | MAP/load kPa estimate axis | Yes, runtime axis | Not directly a ROM table | Physical comparison only | XDF spark display rounded integer `0-100 kPa`; raw axis still `0-0x0800` style | Medium-high MAP/load | Prove exact ADC channel and transfer curve. |
| `RAM 0x2036` | runtime `8.8` axis | RPM-normalized axis | Yes, runtime axis | Not directly a ROM table | Physical comparison only | Produced from `0x929E` period table | High | Confirm exact timer clock basis if live RPM logging becomes available. |
| `0x929E-0x92CD` | `1x24` | Code-Confirmed RPM Axis | Yes; XDF `Axes / Sensor Conversions` category | No | Xantia comparable only as family pattern | `15000000 / raw period` | High | Confirm exact timer clock basis if live RPM logging becomes available. |
| `0x9291-0x9299` | `1x9` | TPS / Load-Delta Breakpoints | Yes; XDF `Axes / Sensor Conversions` category | No | Same-family comparison only | Raw processed `$2017` counts; bytes `00 03 0B 16 25 36 59 84 C9`; count `0x929A=9` | High structural | Direct users are `0x9187` and `0x9073`; indirect `$2042` consumers are `0x8508/0x8529/0x8558/0x8579/0x8652/0x8671`. Baseline-subtracted TPS/load-delta axis; not absolute TPS volts, MAP, or final load. |
| `0x92CF-0x92D7` | `1x9` | Likely CTS ADC Breakpoints B | Yes; XDF `Axes / Sensor Conversions` category | No | Same-family comparison only | NTC-matching ADC breakpoints `12..246`; count `0x92D8=9`; path `0x2008 -> 0x2122 -> $203C/$203E` | High NTC structure, medium-high CTS role | Confirm CTS role from ADC/pin/live evidence. |
| `0x92D9-0x92E1` | `1x9` | Likely IAT ADC Breakpoints A | Yes; XDF `Axes / Sensor Conversions` category | No | Same-family comparison only | NTC-matching ADC breakpoints `12..246`; count `0x92E2=9`; path `0x200A -> 0x2124 -> $2038/$203A` | High NTC structure, medium-high IAT role | Confirm IAT role from ADC/pin/live evidence. |
| `0x92FA-0x9302` | `1x9` | Fuel Output Scheduler Scale vs `$00CC` Surplus `$2040` | Yes; `$D5DF` scheduler-support path | No | Same-family comparison only | Unsigned raw byte indexed by `$2040 = max($00CC - 0x8000, 0) >> 4`; interpolated result is multiplied by `40` and stored to `$2388` | Fuel output timing support | Keep raw; no ms/crank-degree conversion until clock and prescaler are proven. |
| `0x400E-0x4016` | `1x9` | Temperature Raw Output Vector | Yes; XDF `Axes / Sensor Conversions` category | No | Same-family comparison only | Stored `160..0`, best interpreted as `deg C + 40` for sites `120..-40 C` | High temp-transfer structure | Confirm exact CTS/IAT channel assignment from ADC/pin/live evidence. |
| `0x55A0-0x55B1` | `1x18` | Diagnostic Event-Code Table | Yes, diagnostic queue | No | Not a tune map | Raw | High diagnostic | Decode external event meanings from callers and service protocol. |
| `0x9131-0x9169` | `19x3` | State Descriptor Triples | Yes, descriptor subsystem | No | Not a tune map | Raw | High diagnostic/state | Decode descriptor fields and event/state semantics. |

## NTC ADC Breakpoint Verification

The two temperature-axis candidates are not stored as resistance values. They
are 8-bit ADC breakpoint curves that feed the common temperature transfer
vector at `0x400E`.

| Sensor path | ROM offset | Bytes | Decimal ADC breakpoints | Count byte |
| --- | ---: | --- | --- | ---: |
| Temp path B, likely CTS-side | `0x92CF` | `0C 14 22 39 5D 8E BF E3 F6` | `12, 20, 34, 57, 93, 142, 191, 227, 246` | `0x92D8 = 09` |
| Temp path A, likely IAT-side | `0x92D9` | `0C 14 22 39 5D 8E BF E3 F6` | `12, 20, 34, 57, 93, 142, 191, 227, 246` | `0x92E2 = 09` |

The shared transfer/output vector is:

| ROM offset | Bytes | Decimal | Interpretation |
| ---: | --- | --- | --- |
| `0x400E` | `A0 8C 78 64 50 3C 28 14 00` | `160, 140, 120, 100, 80, 60, 40, 20, 0` | Stored temperature raw output, likely `deg C + 40`. |

Interpreted temperature sites:

| Interpreted temperature | ROM ADC breakpoint |
| ---: | ---: |
| `120 C` | `12` |
| `100 C` | `20` |
| `80 C` | `34` |
| `60 C` | `57` |
| `40 C` | `93` |
| `20 C` | `142` |
| `0 C` | `191` |
| `-20 C` | `227` |
| `-40 C` | `246` |

Using the available coolant-sensor midpoint resistance values as a sanity
check, the implied pull-up resistor converges near `2 kOhm` when computed as
`Rpull = Rntc * (255 - ADC) / ADC`:

| Point | NTC midpoint resistance | ROM ADC | Implied pull-up |
| ---: | ---: | ---: | ---: |
| `0 C` | `6400 ohm` | `191` | `2145 ohm` |
| `20 C` | `2500 ohm` | `142` | `1989 ohm` |
| `80 C` | `315 ohm` | `34` | `2048 ohm` |

This is strong evidence that `0x92CF` and `0x92D9` are NTC temperature-sensor
ADC conversion breakpoint tables. The CTS/IAT side assignment remains
provisional until the ADC channel-to-pin path is confirmed on the ECU or by
coherent live diagnostics.

The raw helper tables stay in that hot-to-cold order. The firmware then inverts
the 8.8 breakpoint index before storing the runtime axes, so active XDF consumer
maps indexed by `$2038/$203A/$203C/$203E` display cold-to-hot labels. The
hardware document's coolant temperature pin 13 and air temperature pin 31
support the physical interpretation, but they do not prove final ROM table
output units.

| Evidence-backed display axis | Active XDF consumers |
| --- | --- |
| Raw ADC helper hot-to-cold `120,100,80,60,40,20,0,-20,-40 C` | `0x92CF`, `0x92D9`; Z values remain raw ADC counts |
| 9-point cold-to-hot `-40,-20,0,20,40,60,80,100,120 C` likely IAT `$2038` | `0x802B`, `0x8103` |
| 17-point cold-to-hot `-40..120 C` likely IAT doubled `$203A` | `0x8C7C` |
| 9-point cold-to-hot `-40,-20,0,20,40,60,80,100,120 C` likely CTS `$203C` | `0x8452`, `0x84ED`, `0x84F6`, `0x853B`, `0x8546`, `0x858B`, `0x859F`, `0x8636`, `0x863F`, `0x8648`, `0x8689`, `0x8DD9`, `0x90D6` |
| 17-point cold-to-hot `-40..120 C` likely CTS doubled `$203E` | `0x8D15`, `0x8408`, `0x841B`, `0x843D`, `0x845B`, `0x846C`, `0x847D`, `0x848E`, `0x849F`, `0x84B0`, `0x84C1`, `0x84D2`, `0x8970`, `0x8DAE`, `0x9000`, `0x9011`, `0x9022`, `0x9033`, `0x9044`, `0x90EF` |
| 9-point `0x9291` / `$2042` helper axis | Direct `0x9291` users are `0x9187` and `0x9073`; `0x8508`, `0x8529`, `0x8558`, `0x8579`, `0x8652`, and `0x8671` are indirect `$2042` consumers. DHC11 shows `$2042` for this family, not `$203C`. |

This is an axis-label upgrade only. Fuel, warmup/afterstart, transient, idle,
closed-loop, and timer cells remain raw or raw word values unless their output
scaling is separately established. The spark temperature/load corrections keep
raw signed views; the degree views are convenience `raw / 2` displays.

## Remaining DHC11 Lookup Evidence

The DHC11 listing exposes exact helper-referenced lookup bases that were either
absent from the active XDF or only visible inside broad raw blocks. XDF version
`0.41` adds named inspection views for these bases. This is evidence for code
usage and table boundaries, not proof of final physical output units.

| Cluster | Exact bases added | Evidence / scaling status |
| --- | --- | --- |
| Fuel/transient | `0x81E0`, `0x8508`, `0x8511`, `0x8529`, `0x8561`, `0x8579` | DHC11 helper calls from `$2036` RPM and `$2042`; `0x8529/0x8579` are raw word tables, the rest raw byte vectors. |
| Warmup/afterstart | `0x841B`, `0x843D`, `0x8452`, `0x84ED` | `$203E` and `$203C` CTS-family lookups; `0x841B` is raw word, the others raw byte. |
| Idle/state | `0x8636`, `0x863F`, `0x8648`, `0x8652`, `0x8671`, `0x8689`, `0x899A` | `$203C`, `$2042`, and `$2036` lookups feeding state/idle or closed-loop entry variables; raw byte values only. |
| Spark transition/state | `0x87A6`, `0x87AB`, `0x8E04`, `0x8E0D`, `0x8E18` | `$2046` and capped `$2065` lookups feeding `$214F` and `$2146`; raw byte values only. |
| Adaptive entry | `0x8E36`, `0x8E3D`, `0x8E46`, `0x8E57` | `0x8E36/0x8E3D` are heterogeneous raw threshold records; `0x8E46/0x8E57` are `$2044`-indexed raw RPM-offset vectors. |
| Scheduler | `0x92FA`, `0x877E`, `0x8789`, `0x9303` | `$2040 = max($00CC - 0x8000, 0) >> 4` feeds scheduler support. `0x92FA` stores scaled output to `$2388`; `0x877E` feeds `$00BF`; `0x8789` feeds edge-offset/deadline term `$2086`; exact signed base `0x9303` feeds `$2048`, with final cell guard/unproven. |

The scalar helper bases around `0x89EE/0x89EF` remain represented by the
existing `0x89ED-0x89F2` per-event control-scalar view because that path uses
compact scalar records rather than standalone maps.

## External Evidence
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

- XDF version `0.30` demotes the old public-index `0x802E` visual fuel/VE lead
  to a legacy misaligned slice inside the signed `0x802B` table.
- Later disassembly supersedes the older `0x92CF` X-axis wording for the signed
  fuel correction pair: `0x802B` and `0x8103` use the `0x92D9 -> $2038`
  likely IAT path and confirmed `0x929E` RPM Y labels. `0x92CF` is the sibling
  likely CTS path.
- It adds signed fuel quantity trim candidates at `0x821C` and `0x8318`,
  plus the RPM-only bypass vector at `0x83F0`. These feed `$2084 -> $00C1`
  through the local `$E38B/$E715` path.
- It restores the `Confirmed` category/category 10 memberships for
  code-confirmed spark maps and supporting axes, and displays the 2D spark-bank
  `0x2034` axis as rounded provisional `0-100 kPa` MAP/load labels.
- `0x802E`, `0x80EB`, `0x81A8`, and `0x80F1` are retired alignment probes only.
  `0x80EB` is a signed boundary slice at `0x802B+0xC0`, not a standalone
  public-index map. XDF v0.42 removes these historical probes from the active
  table tree.

Local multi-BIN analysis follow-up:

- `tools/iaw8p40_analyze.py` confirms the Xantia 607C file has checksum pair
  `0x9F83/0x607C` and reset vector `0xB800`.
- Peugeot stock vs Xantia differs by `42021` bytes across `1038` regions, so
  Xantia same-offset comparisons are supporting evidence only.
- The corrected Peugeot `24x9 @ 0x802B` and `24x9 @ 0x8103` signed tables are
  MOD2-touched and code-referenced. Same-family comparisons remain supporting
  evidence only.

## Map-Family Checklist

This table maps the public OldSkullTuning map-family list to the current local
reverse-engineering status. It is a checklist, not a claim that all public names
have been matched to exact local offsets.

| Public map family | Current local candidate/status | Evidence state |
| --- | --- | --- |
| Main fuel multiplier | No pure VE/base table is proven yet. The old `0x802E` visual lead is demoted; `0x821C/0x8318` are now the strongest signed fuel quantity trim candidates. `$00C1 -> $00C3 -> $00BC` is pulse width/duration, while `$87B1 -> $00BE -> $21C6` is event phase. | OC1 schedules `TOC1 = $00B8 + $21C6`, OC3 handles the pulse edge, and exact driver/pin plus tick-to-ms/degree proof remains hardware-level. |
| Spark advance high octane | `0x8A69-0x8B40`, `24x9`, `raw / 2` degrees. | Locally code-confirmed for Peugeot stock/MOD2; likely high/default from selector and high-load comparison. `RALLY13.ORI` shifts the same stock bundle to `0x8A84`. |
| Spark advance low octane | `0x8B41-0x8C18`, `24x9`, `raw / 2` degrees. | Locally code-confirmed for Peugeot stock/MOD2; likely low/alternate. `RALLY13.ORI` shifts the same stock bundle to `0x8B5C`. |
| Spark advance WOT | `0x8C19-0x8C30`, RPM-only vector, `raw / 2` degrees. | Locally code-confirmed bypass path; likely WOT/RPM-only spark. `RALLY13.ORI` shifts this vector to `0x8C34`; `Peug.106Rally.org.bin` leaves it unchanged at `0x8C19`. |
| Spark advance correction | No final public-name match. `0x89F3-0x8A05` is now grouped with ignition output/retard strategy; `0x9187-0x925E` is load/air-charge modelling, not spark. | Still unconfirmed. |
| Spark advance minimum | No confirmed local offset. | Still unconfirmed. |
| Spark advance idle | No confirmed local offset. | Still unconfirmed. |
| Dwell | No confirmed local offset. | Still unconfirmed. |
| Air density correction by temperature | Public screenshot shows a `24x9` RPM-by-temperature factor table, but the visible data was not found verbatim in the local stock or MOD2 dumps. `0x9187-0x925E` may be load/air-charge model related, but is not proven air density. | Still unconfirmed. |
| Volumetric efficiency correction | No confirmed local VE table. `0x802B/0x8103` are signed temp-like/RPM fuel correction candidates, not proven VE. | Still unconfirmed. |
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
- The public air-density screenshot is evidence for a map family name only. It
  does not confirm a local offset in this ROM.

## IES2 / IAW-8F.68 Diagnostic Reference

IES2 is the public `IAW ECU Scan 2` C# diagnostic application for FIAT OBD-I
Magneti Marelli ECUs. Its repository README describes support for IAW
`6F/8F/16F/18F/18FD` and later `04K` units, not IAW 8P.40. Keep this as a
related Marelli live-data and diagnostic-protocol reference only. It does not
publish Peugeot 106 IAW 8P.40 map addresses, XDF data, ROM offsets, or protocol
compatibility proof.

Checked source files:

- Repository/readme: https://github.com/TzOk83/IES2/tree/master
- `iaw8f_68.cs`: https://github.com/TzOk83/IES2/blob/master/IES_2/ECU/iaw8f_68.cs
- `ecu.cs`: https://github.com/TzOk83/IES2/blob/master/IES_2/ECU/ecu.cs

`iaw8f_68.cs` identifies IAW-8F.68 as `Magneti-Marelli IAW-8F.68 MPI
(Alfa 33)`, detected by ISO substring `B683` or CODRIC prefix `61600`. Since
8F and 8P are adjacent Marelli IAW-era systems, these values are useful for
runtime naming and scaling hypotheses, but they are not local 8P.40 proof.

Live-data request/scaling references from IAW-8F.68:

| Diagnostic value | IES2 request byte(s) | Decode/scaling | 8P.40 use |
| --- | ---: | --- | --- |
| RPM / period | `0x01, 0x02` | `rpm = 15000000 / raw16` | Corroborates the current `0x929E -> 0x2036` RPM-axis scaling. |
| Injection duration | `0x03, 0x04` | `raw16 / 500 ms` | Bench/live-data target for proving final fuel pulse-width RAM. |
| Ignition advance | `0x05` | `raw / 2 degrees` | Corroborates current spark table display scaling. |
| MAP | `0x06` | `raw * 4 hPa` | Useful sanity check for `0x2034` MAP/load-like axis validation. |
| Air temperature | `0x07` | `raw - 40 C` | Supports IAT naming/scaling hypotheses for the `0x92D9` axis family. |
| Coolant temperature | `0x08` | `raw - 40 C` | Supports CTS naming/scaling hypotheses for the `0x92CF` axis family. |
| Throttle angle | `0x09` | `raw * 0.4234 - 2.9638` | Candidate TPS normalization reference. |
| Battery voltage | `0x0A` | `raw * 0.0625 V` | Candidate voltage-correction tracing reference. |
| Lambda correction | `0x0B` | `raw * 0.002656 + 0.66` | Helps interpret closed-loop/adaptive fuel correction variables. |
| Idle stepper position | `0x0C` | raw steps | Supports idle-air / idle-bypass table classification. |
| Idle integral term | `0x0D` | signed byte | Candidate idle-control RAM tracing reference. |
| Idle proportional term | `0x0E` | signed byte | Candidate idle-control RAM tracing reference. |
| Trim position | `0x0F` | `raw - 128` | Supports signed/centered fuel-trim conventions. |
| Desired idle | `0x26` | `raw * 8 rpm` | Useful for idle target vector/table validation. |
| Idle offset | `0x27` | `(raw - 128) * 8 rpm` | Useful for idle correction tracing. |

IES2 protocol facts from `ecu.cs`:

- Passive diagnostic init uses `1200` baud and sends `0x0F`, `0xAA`, `0xCC`,
  then switches to `7680` baud.
- Queries are one request byte at a time; the code discards the echo byte and
  then reads one response byte.
- ISO is read with request bytes `0x2A-0x2F`.
- CODRIC is read with request bytes `0x17-0x20`.

IAW-8F.68 also defines diagnostic request families that are useful search
targets in the 8P.40 service dispatcher:

- error/status bytes: `0x10`, `0x11`, `0x12`, `0x14`, `0x15`, `0x16`.
- active tests: fuel pump `0x80`, injectors `0x81`, coils `0x82/0x83`,
  clear codes `0x84`, EVAP `0x85`, tachometer `0x86`, A/C relay `0x87`,
  generic relay `0x88`, trim/stepper reset or toggle around `0x89/0x91`.

Actionable boundary: use these IDs to guide 8P.40 diagnostic tracing and bench
tests. Do not upgrade any XDF labels, map names, or ROM offsets solely from
IES2.

## Air-Density Screenshot Lead

The TunerPro screenshot labelled `Air density correction factor by temperature`
was converted into byte candidates and searched against:

- `M27C512_original.BIN`
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_Stok.bin`
- `1_3L_8V_IAW8P40/1.3L_8V_IAW8P40_MOD2.bin`

The search treated it as a `24x9` table with RPM-like rows and temperature
columns. It tried likely display equations and orientations:

- `raw / 230`, matching the current local `0x9187` load/air-charge factor display.
- `raw / 100`, `raw / 128`, and `raw / 200`.
- Normal, row-reversed, column-reversed, both-reversed, and transposed layouts.

No exact local match was found. The nearest functional local candidate remains
`Load / Air-Charge Model Factor 24x9 @ 0x9187`, but the byte values
do not match the screenshot. Loose numeric matches around `0x8A9C` are inside
the code-confirmed spark bank, so they are false positives.

Actionable conclusion: keep `Air density correction by temperature` on the
checklist, but do not rename an XDF table from this screenshot alone. The next
proof path is static tracing from IAT/CTS ADC channels into correction lookups.

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
## Sensor References
This file records external sensor clues useful for naming RAM variables and map
axes in the Marelli IAW 8P.40 ROM. These are supporting references, not final
proof of ECU transfer functions.

## Vehicle / ECU Match

- Vehicle: Peugeot 106 I 1.3 Rallye.
- Engine: TU2J2 / MFZ, 1294 cc, about 72 kW / 98-100 hp.
- ECU family: Magneti Marelli 8P / IAW 8P.40.

Useful references:

- BossECU fitment page lists `TU2J2 (MFZ) MM IAW 8AP.40 93-96 Peugeot 106
  1.3i Rallye`.
- PeugeotBook describes the Magneti Marelli 8P engine-management system as
  injection/ignition control.

## Confirmed / Likely ECU-Facing Sensors

The TU2J2/MFZ wiring reference lists these relevant component IDs:

| ID | Sensor / component | Reverse-engineering use |
| --- | --- | --- |
| `B24` | Coolant temperature sensor | Should correspond to one ADC channel and warmup/enrichment/fan/back-up logic. |
| `B25` | Inlet air temperature sensor | Should correspond to one ADC channel and air-density correction. |
| `B33` | Vehicle speed sensor | Mentioned by some generic references, but current firmware evidence does not tie it to the `0x00D4/0x2044` family. |
| `B69` | Knock sensor, marked for 1.3 | Supports the idea that dual spark banks may be knock/octane related, but bank meaning is not proven. |
| `B72` | Heated oxygen sensor | Supports closed-loop mixture/adaptation and diagnostic logic. |
| `B75` | Crankshaft speed sensor | Source for period/RPM logic, likely upstream of `0x00BA` and `0x2036`. |
| `B83` | Manifold absolute pressure sensor | Strong clue for the `0x2034` load/MAP axis. |
| `B147` | Throttle position sensor | Should correspond to one ADC channel and transient/idle/WOT logic. |

PeugeotBook also lists Magneti Marelli system service items including the
throttle potentiometer, idle-speed control stepper motor, MAP sensor, coolant
temperature sensor, inlet air temperature sensor, crankshaft sensor, knock
sensor, and throttle-housing heating element. Vehicle-speed references are
treated as generic/variant evidence until a 1.3 Rallye 8P.40 pin path is proven.

## MAP Sensor Clue

The MAP sensor is the most useful clue for the current XDF axes.

External evidence:

- A used-part listing for a Peugeot 106 I 1.3 Rallye TU2J2/MFZ shows MAP sensor
  part `PRT03E04 3358AA` removed from a 1294 cc, 72 kW 106 Rallye donor.
- A product sheet for Magneti Marelli `PRT03/04` describes it as a 1 bar analog
  absolute pressure sensor with a pressure range of `17-105 kPa`.
- The user also found a related `PRT 03E/02 2624AL 100 kPa` marking. This is
  consistent with the same PRT03-family 1 bar MAP-sensor class.
- A checked EuroFrance listing for `PRT03E/02` / `1920P2` also lists the part
  as a Magneti Marelli 3-pin MAP/vacuum sensor for Citroen/Fiat/Peugeot with
  `100kPa` marking.

Reverse-engineering implications:

- A 100 kPa / 1 bar MAP sensor strongly supports interpreting the `0x2034`
  spark-table axis as MAP/load-like rather than a generic `0-8` index.
- The XDF now labels the likely spark-bank x-axis as `0, 128, 256, 384, 512,
  640, 768, 896, 1024`.
- That is still provisional: the code proves `0x2034` is an 8.8 axis derived
  from `0x00CE`, and `0x00CE` can be produced from `0x00D0 << 2`, but the exact
  sensor transfer function and mbar conversion are not fully decoded.

## Next Sensor-Mapping Targets

Repeatable scanner evidence from `tools/iaw8p40_analyze.py`:

| Address | Peugeot refs | Xantia refs | Sensor-trace relevance |
| --- | ---: | ---: | --- |
| `0x1030` | `16` | `14` | ADC conversion control writes. |
| `0x1031` | `8` | `6` | ADC result byte source. |
| `0x1032` | `5` | `5` | ADC result byte source. |
| `0x1033` | `7` | `7` | ADC result byte source feeding several `0x2007/0x200D/0x2013` paths. |
| `0x1034` | `7` | `7` | ADC result byte source. |
| `0x2007-0x200E` | `4-7` each | `3-10` each | Raw or lightly processed ADC channel RAM. |
| `0x2013` | `11` | `13` | Processed sensor/status byte with many comparisons. |
| `0x00CE` | `19` | `10` | Load/air-charge word path. |
| `0x00D0` | `22` | `26` | Load-model byte / air-charge byte family. |
| `0x2034` | `8` | `3` | Normalized load/MAP-like axis consumer. |

The scan confirms the same general ADC/register family in Peugeot and Xantia,
but the exact channel meanings still need local Peugeot consumer/fallback proof.

1. Decode the ADC sampling order for RAM `0x2007-0x200E`.
2. Match ADC channels to `B24`, `B25`, `B83`, and `B147`.
3. Trace coolant and inlet-air fallback constants. These often reveal NTC lookup
   tables and can identify which ADC byte is which.
4. Trace the knock path around the `0x20B1` spark-bank selector and nearby
   routines at `0xBF0A`, `0xBF30`, and `0xCBEF`.
5. Trace IAT/CTS correction consumers before naming an air-density map. A public
   screenshot shows a `24x9` RPM-by-temperature `Air density correction factor
   by temperature` table, but that exact byte matrix was not found in the local
   stock or MOD2 Peugeot 106 dumps using likely scalings and orientations.
6. Continue the fuel/charge proof from the signed `0x802B/0x8103` correction
   pair into `$204B`, `$00C1`, `$2051`, `$00C3`, `$00BC`, and the provisional
   `$1016` scheduler bridge. The old `0x802E` view is legacy alignment context
   only, not a table base to tune.
7. Use live data if available:
   - key-on engine-off MAP should be near barometric pressure,
   - warm idle MAP should be much lower than WOT,
   - TPS should sweep monotonically with throttle,
   - IAT/CTS should move predictably with temperature.

## Air-Density Screenshot Boundary

The screenshot is useful because it tells us what to hunt for: an RPM-by-IAT or
RPM-by-temperature correction surface. It is not local offset proof. Searches
against the current dumps did not find the displayed values as a `24x9` table
under `raw / 230`, `raw / 100`, `raw / 128`, or `raw / 200`, including reversed
and transposed views. The closest meaningful local correction candidate remains
`0x9187`, but its bytes are different and its confirmed path currently feeds the
load-model chain `0x00D0 -> 0x00CE -> 0x2034`.

## Signed IAT/RPM Fuel Correction Boundary

The old `0x802E` fuel/VE-looking surface is now treated as a legacy misaligned
slice inside the code-referenced signed table at `0x802B`. The corrected pair is
`0x802B` and `0x8103`, both signed `24x9` IAT/RPM fuel correction
candidates.
Their X axis uses the likely IAT `0x92D9 -> $2038` path and now displays the
firmware-inverted consumer order `-40..120 C`; their Y axis uses the confirmed
`0x929E` RPM labels into `$2036`, and their outputs are `$204A` and `$204D`.
`$204A` feeds `$204B -> $00C1`; `$204D` feeds the `$204E/$204F` blend path. The
exact temperature sensor identity and final injector channel remain
provisional.

## Source URLs

- PeugeotBook Magneti Marelli 8P overview:
  https://www.peugeotbook.ru/en/10X/106/power/multi-point/fuel-injection-systems-general-informati
- PeugeotBook Magneti Marelli components:
  https://www.peugeotbook.ru/en/10X/106/power/multi-point/magneti-mareili-system-components-removal-and-refitting
- TU2J2/MFZ wiring/component reference:
  https://shemicar.ru/elektroshema-dvigatelya-tu2j2l-z-peugeot-106-i/
- TU2J2/MFZ MM8P wiring PDF:
  https://prepa205gti.wordpress.com/wp-content/uploads/2014/01/magneti_marelli_8p-multipoint-injection-tu2j2z_l_106.pdf
- Peugeot 106 1.3 Rallye MAP sensor listing:
  https://www.proxyparts.com/car-parts-stock/information/part-number/prt03e04/part/mapping-sensor-%28intake-manifold%29/partid/21378782/
- Magneti Marelli PRT03/04 product sheet:
  https://www.compsystems.com.au/index.php/store/download-pdf?product_id=423
- Magneti Marelli PRT03E/02 100 kPa listing:
  https://eurofrance.ie/map-manifold-pressure-sensor-prt03e-02-1920p2-citroen-peugeot-fiat.html
- BossECU IAW 8P fitment reference:
  https://bossgarage.eu/en-ww/products/bossecu-psa-nfw
## XDF Crash Bisect
These XDFs are generated from the known-good v0.14 definition unless their name says otherwise.
Load them in TunerPro in numeric order and note the first one that crashes.

1. `bisect_00_safe_v014.xdf`
   Baseline copy of the XDF version confirmed to load.
2. `bisect_01_spark_rounded_x_labels_only.xdf`
   Only changes the two spark-bank X labels from raw 0..1024 to display 0..100.
3. `bisect_02_confirmed_category_decimal10_only.xdf`
   Adds category `0xA` and moves confirmed entries into decimal category `10`.
4. `bisect_03_confirmed_category_hex0xA_only.xdf`
   Same category test, but memberships use `0xA`.
5. `bisect_04_80F1_25x9_unsigned_no_typeflags.xdf`
   Changes only table `0x218` to the 25x9 `0x80F1` alignment, unsigned/raw.
6. `bisect_05_80F1_25x9_signed_typeflags.xdf`
   Same `0x80F1` alignment, but with TunerPro signed-byte `mmedtypeflags="0x01"`.
7. `bisect_06_rounded_labels_plus_category_decimal10.xdf`
   Combines rounded spark labels with decimal Confirmed category memberships.
8. `bisect_07_rounded_labels_plus_category_hex0xA.xdf`
   Combines rounded spark labels with hex Confirmed category memberships.
9. `bisect_08_exact_head_v021_crashy_candidate.xdf`
   Byte-faithful exact committed v0.21 candidate for reproducing the crash.

Second-stage files, generated after `00` through `07` loaded and only `08` crashed:

10. `bisect_09_all_structural_v021_old_text.xdf`
    Combines the v0.21 structural changes: signed `0x80F1`, rounded spark X labels, and decimal Confirmed category memberships, while keeping older prose.
11. `bisect_10_exact_v021_with_v014_prose.xdf`
    Starts from exact v0.21, then restores v0.14 header/table prose for the changed entries.
12. `bisect_11_structural_plus_v021_header_prose.xdf`
    Adds only the v0.21 header/version prose to the structural test.
13. `bisect_12_structural_plus_v021_spark_prose.xdf`
    Adds only the v0.21 spark/RPM/helper-axis prose to the structural test.
14. `bisect_13_structural_plus_v021_fuel_probe_prose.xdf`
    Adds only the v0.21 fuel/adjacent-probe prose to the structural test.
15. `bisect_14_structural_plus_all_v021_prose.xdf`
    Adds all v0.21 changed prose back onto the structural test.

Third-stage files, generated after `08`, `12`, and `14` crashed:

16. `bisect_15_only_0x227_rpm_axis_prose.xdf`
    Adds only the v0.21 RPM-axis prose.
17. `bisect_16_only_0x228_high_spark_prose.xdf`
    Adds only the v0.21 high/default spark-bank prose.
18. `bisect_17_only_0x229_low_spark_prose.xdf`
    Adds only the v0.21 low/alternate spark-bank prose.
19. `bisect_18_only_0x22A_axis_9291_prose.xdf`
    Adds only the v0.21 0x9291 TPS/load-delta axis prose.
20. `bisect_19_only_0x22B_axis_92CF_prose.xdf`
    Adds only the v0.21 0x92CF helper-axis prose.
21. `bisect_20_only_0x22C_wot_spark_prose.xdf`
    Adds only the v0.21 WOT spark-vector prose.
22. `bisect_21_0x228_0x229_bank_prose_only.xdf`
    Adds both long v0.21 spark-bank descriptions.
23. `bisect_22_small_prose_no_big_banks.xdf`
    Adds all smaller spark/RPM/helper prose but excludes the two long bank descriptions.
24. `bisect_23_candidate_v022_compact_spark_prose.xdf`
    Candidate fixed XDF: v0.21 structures with compact TunerPro-friendly spark/RPM/helper descriptions.

Result so far: `16`, `17`, and `21` do not open, which isolates the crash to the long v0.21 spark-bank descriptions for `0x228` and `0x229`. The main `IAW8P40_peugeot106_firstpass.xdf` is now updated from `bisect_23_candidate_v022_compact_spark_prose.xdf`: v0.21 structures, compact spark/RPM/helper descriptions, and file version `0.22`.
<!-- BEGIN GENERATED ANALYSIS -->
## Generated Analyzer Snapshots

Generated by `python tools/iaw8p40_analyze.py --write-analysis`.

## ROM Overview

| Key | Label | Size | SHA256 | Checksum words | Pair sum | Byte sum 0x4000-0xFFFF | Valid checksum | Zero 0x0000-0x3FFF | Zero 0xB600-0xB7FF | Reset vector |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| `peugeot_stock` | Peugeot stock M27C512_original | 65536 | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xFFFF` | `0xB59A` | yes | yes | yes | `0xB800` |
| `peugeot_stok` | Peugeot Stok folder duplicate | 65536 | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xFFFF` | `0xB59A` | yes | yes | yes | `0xB800` |
| `peugeot_mod2` | Peugeot MOD2 | 65536 | `D3E4A451EDD236104C79190372FA1BE1E45AAD09398EABE6F7B7E1479D810855` | `0x47BE/0xB841` | `0xFFFF` | `0xB841` | yes | yes | yes | `0xB800` |
| `xantia_607c` | Citroen Xantia 1.6 8v IAW 8P.40 607C | 65536 | `05470171F86B8525F962F13370846E6D4A1A6FBABC0107D90E1497F88A5DFE89` | `0x9F83/0x607C` | `0xFFFF` | `0x607C` | yes | yes | yes | `0xB800` |
| `peug_106rally_org` | Peug.106Rally.org.bin public/tuned comparison | 65536 | `FE7D7953298C575BC08E4C301CE7E911BCE082D1515E1FCA68509A2C980E0141` | `0x4A65/0xB59A` | `0xFFFF` | `0xE160` | no | no | yes | `0xB800` |
| `rally13_ori` | RALLY13.ORI same-family comparison | 65536 | `5F4EF679F6D262502D0023CF9F441111BC5C694CD4E281394AD0FCBA810854CF` | `0x7A41/0x85BE` | `0xFFFF` | `0x85BE` | yes | yes | yes | `0xB800` |

## Diff Regions

### `peugeot_stock` vs `peugeot_stok`

Total differing bytes: `0` in `0` contiguous regions.

| Start | End | Changed bytes |
| --- | --- | ---: |

### `peugeot_stock` vs `peugeot_mod2`

Total differing bytes: `479` in `87` contiguous regions.

| Start | End | Changed bytes |
| --- | --- | ---: |
| `0x800C` | `0x800F` | 4 |
| `0x8088` | `0x808D` | 6 |
| `0x8091` | `0x8096` | 6 |
| `0x80A9` | `0x80D5` | 45 |
| `0x80F1` | `0x8102` | 18 |
| `0x8169` | `0x816E` | 6 |
| `0x8172` | `0x8177` | 6 |
| `0x817B` | `0x8180` | 6 |
| `0x8184` | `0x8189` | 6 |
| `0x818D` | `0x8192` | 6 |
| `0x8196` | `0x819B` | 6 |
| `0x819F` | `0x81A4` | 6 |
| `0x81A8` | `0x81AD` | 6 |
| `0x81B1` | `0x81B6` | 6 |
| `0x81BA` | `0x81BF` | 6 |
| `0x81C3` | `0x81C8` | 6 |
| `0x81CC` | `0x81D1` | 6 |
| `0x879E` | `0x87A1` | 4 |
| `0x89F5` | `0x89FA` | 6 |
| `0x89FC` | `0x8A05` | 10 |
| `0x8A80` | `0x8A83` | 4 |
| `0x8A87` | `0x8A8C` | 6 |
| `0x8A90` | `0x8A95` | 6 |
| `0x8A99` | `0x8A9E` | 6 |
| `0x8AA2` | `0x8AA7` | 6 |
| `0x8AAB` | `0x8AB0` | 6 |
| `0x8AB5` | `0x8AB9` | 5 |
| `0x8ABE` | `0x8AC2` | 5 |
| `0x8AC7` | `0x8ACB` | 5 |
| `0x8AD1` | `0x8AD4` | 4 |
| `0x8ADA` | `0x8ADD` | 4 |
| `0x8AE3` | `0x8AE6` | 4 |
| `0x8AEC` | `0x8AEF` | 4 |
| `0x8AF5` | `0x8AF8` | 4 |
| `0x8AFE` | `0x8B01` | 4 |
| `0x8B07` | `0x8B0A` | 4 |
| `0x8B10` | `0x8B13` | 4 |
| `0x8B19` | `0x8B1C` | 4 |
| `0x8B22` | `0x8B25` | 4 |
| `0x8B2B` | `0x8B2E` | 4 |
| ... | ... | 47 more regions omitted |

### `peugeot_stock` vs `xantia_607c`

Total differing bytes: `42021` in `1038` contiguous regions.

| Start | End | Changed bytes |
| --- | --- | ---: |
| `0x4007` | `0x400C` | 6 |
| `0x4049` | `0x4049` | 1 |
| `0x404B` | `0x404C` | 2 |
| `0x4051` | `0x4051` | 1 |
| `0x4068` | `0x4069` | 2 |
| `0x4074` | `0x4074` | 1 |
| `0x407E` | `0x407E` | 1 |
| `0x4081` | `0x4081` | 1 |
| `0x4083` | `0x4083` | 1 |
| `0x4085` | `0x4085` | 1 |
| `0x408A` | `0x408A` | 1 |
| `0x408D` | `0x408D` | 1 |
| `0x4090` | `0x4090` | 1 |
| `0x4092` | `0x4092` | 1 |
| `0x4095` | `0x4095` | 1 |
| `0x4097` | `0x4097` | 1 |
| `0x409A` | `0x409A` | 1 |
| `0x409D` | `0x409D` | 1 |
| `0x40A0` | `0x40A0` | 1 |
| `0x40A6` | `0x40A6` | 1 |
| `0x40AA` | `0x40AA` | 1 |
| `0x40B7` | `0x40B8` | 2 |
| `0x40BE` | `0x40BE` | 1 |
| `0x40C1` | `0x40C1` | 1 |
| `0x40C5` | `0x40C5` | 1 |
| `0x40C8` | `0x40C8` | 1 |
| `0x40D5` | `0x40D6` | 2 |
| `0x40DB` | `0x40DC` | 2 |
| `0x40DF` | `0x40DF` | 1 |
| `0x40E3` | `0x40E3` | 1 |
| `0x4100` | `0x4100` | 1 |
| `0x4105` | `0x4105` | 1 |
| `0x4127` | `0x4127` | 1 |
| `0x412C` | `0x412C` | 1 |
| `0x4157` | `0x4157` | 1 |
| `0x4164` | `0x4165` | 2 |
| `0x4168` | `0x4168` | 1 |
| `0x416D` | `0x416D` | 1 |
| `0x4177` | `0x4177` | 1 |
| `0x417B` | `0x417C` | 2 |
| ... | ... | 998 more regions omitted |

### `peugeot_stock` vs `peug_106rally_org`

Total differing bytes: `16513` in `27` contiguous regions.

| Start | End | Changed bytes |
| --- | --- | ---: |
| `0x0032` | `0x03CF` | 926 |
| `0x03D1` | `0x3EC5` | 15093 |
| `0x879F` | `0x879F` | 1 |
| `0x87A1` | `0x87A1` | 1 |
| `0x8A73` | `0x8A79` | 7 |
| `0x8A7B` | `0x8C17` | 413 |
| `0x9188` | `0x918A` | 3 |
| `0x9191` | `0x9193` | 3 |
| `0x919C` | `0x919D` | 2 |
| `0x91EC` | `0x91EE` | 3 |
| `0x91F4` | `0x91F4` | 1 |
| `0x91FD` | `0x91FD` | 1 |
| `0x9206` | `0x9206` | 1 |
| `0x920F` | `0x920F` | 1 |
| `0x9211` | `0x9216` | 6 |
| `0x9218` | `0x9218` | 1 |
| `0x921B` | `0x921F` | 5 |
| `0x9221` | `0x9221` | 1 |
| `0x9224` | `0x9228` | 5 |
| `0x922A` | `0x922A` | 1 |
| `0x922D` | `0x9231` | 5 |
| `0x9233` | `0x923A` | 8 |
| `0x923C` | `0x923C` | 1 |
| `0x923F` | `0x9243` | 5 |
| `0x9248` | `0x924C` | 5 |
| `0x924F` | `0x9255` | 7 |
| `0x9258` | `0x925E` | 7 |

### `peugeot_stock` vs `rally13_ori`

Total differing bytes: `43767` in `954` contiguous regions.

| Start | End | Changed bytes |
| --- | --- | ---: |
| `0x4009` | `0x400C` | 4 |
| `0x4023` | `0x4023` | 1 |
| `0x4029` | `0x4029` | 1 |
| `0x402C` | `0x402C` | 1 |
| `0x4032` | `0x4032` | 1 |
| `0x4040` | `0x4040` | 1 |
| `0x4046` | `0x4046` | 1 |
| `0x4049` | `0x4049` | 1 |
| `0x404B` | `0x404C` | 2 |
| `0x404F` | `0x404F` | 1 |
| `0x4056` | `0x4056` | 1 |
| `0x4059` | `0x4059` | 1 |
| `0x405F` | `0x405F` | 1 |
| `0x4063` | `0x4063` | 1 |
| `0x4066` | `0x4066` | 1 |
| `0x4068` | `0x4069` | 2 |
| `0x406F` | `0x406F` | 1 |
| `0x4072` | `0x4072` | 1 |
| `0x4074` | `0x4074` | 1 |
| `0x4077` | `0x4077` | 1 |
| `0x407E` | `0x407E` | 1 |
| `0x4081` | `0x4081` | 1 |
| `0x4083` | `0x4085` | 3 |
| `0x4087` | `0x408E` | 8 |
| `0x4090` | `0x4090` | 1 |
| `0x4092` | `0x4092` | 1 |
| `0x4095` | `0x4165` | 209 |
| `0x4167` | `0x41B1` | 75 |
| `0x41B6` | `0x42B6` | 257 |
| `0x42B8` | `0x430D` | 86 |
| `0x430F` | `0x43FB` | 237 |
| `0x43FE` | `0x4409` | 12 |
| `0x440B` | `0x440C` | 2 |
| `0x440E` | `0x4445` | 56 |
| `0x4447` | `0x4448` | 2 |
| `0x444A` | `0x444A` | 1 |
| `0x444D` | `0x444D` | 1 |
| `0x4450` | `0x445A` | 11 |
| `0x445C` | `0x445D` | 2 |
| `0x445F` | `0x4481` | 35 |
| ... | ... | 914 more regions omitted |

## Known Table / Candidate Stats

| Name | Range | Shape | Peugeot values | peugeot_mod2 values / delta | xantia_607c values / delta | peug_106rally_org values / delta | rally13_ori values / delta | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `fuel_iat_rpm_corr_a_802b_signed_24x9` | `0x802B-0x8102` | `24x9` | `-121..-8 avg -68.6` | `-121..-8 avg -66.7; 75 cells +4..+6 avg +5.4` | `-112..-28 avg -80.0; 216 cells -76..+82 avg -11.4` | `-121..-8 avg -68.6; 0 cells +0..+0 avg +0.0` | `-110..-8 avg -68.4; 133 cells -14..+68 avg +0.4` | signed8 |
| `legacy_misaligned_slice_802e_21x9` | `0x802E-0x80EA` | `21x9` | `135..248 avg 189.4` | `135..248 avg 191.1; 57 cells +4..+6 avg +5.6` | `144..214 avg 174.5; 189 cells -76..+62 avg -14.9` | `135..248 avg 189.4; 0 cells +0..+0 avg +0.0` | `146..248 avg 189.7; 116 cells -13..+38 avg +0.5` | raw |
| `legacy_boundary_slice_802e_24x9` | `0x802E-0x8105` | `24x9` | `135..248 avg 187.8` | `135..248 avg 189.7; 75 cells +4..+6 avg +5.4` | `144..228 avg 176.0; 216 cells -76..+82 avg -11.8` | `135..248 avg 187.8; 0 cells +0..+0 avg +0.0` | `140..248 avg 187.8; 133 cells -25..+68 avg -0.1` | raw |
| `legacy_signed_boundary_slice_80eb_21x9` | `0x80EB-0x81A7` | `21x9` | `-128..110 avg -41.7` | `-128..110 avg -40.1; 60 cells +5..+5 avg +5.0` | `-82..52 avg -17.1; 189 cells -91..+100 avg +24.6` | `-128..110 avg -41.7; 0 cells +0..+0 avg +0.0` | `-128..110 avg -41.4; 126 cells -50..+146 avg +0.5` | signed8 |
| `legacy_signed_alignment_probe_80f1_25x9` | `0x80F1-0x81D1` | `25x9` | `-128..116 avg -31.5` | `-128..116 avg -29.2; 90 cells +5..+18 avg +5.9` | `-80..74 avg -10.3; 225 cells -91..+100 avg +21.2` | `-128..116 avg -31.5; 0 cells +0..+0 avg +0.0` | `-128..127 avg -30.7; 150 cells -50..+146 avg +1.2` | signed8 |
| `fuel_correction_offset_8028_word` | `0x8028-0x8029` | `1x1` | `438..438 avg 438.0` | `438..438 avg 438.0; 0 cells +0..+0 avg +0.0` | `417..417 avg 417.0; 1 cells -21..-21 avg -21.0` | `438..438 avg 438.0; 0 cells +0..+0 avg +0.0` | `438..438 avg 438.0; 0 cells +0..+0 avg +0.0` | word16 raw |
| `fuel_correction_timer_reload_802a` | `0x802A-0x802A` | `1x1` | `1..1 avg 1.0` | `1..1 avg 1.0; 0 cells +0..+0 avg +0.0` | `227..227 avg 227.0; 1 cells +226..+226 avg +226.0` | `1..1 avg 1.0; 0 cells +0..+0 avg +0.0` | `162..162 avg 162.0; 1 cells +161..+161 avg +161.0` | raw |
| `fuel_iat_rpm_corr_b_8103_signed_24x9` | `0x8103-0x81DA` | `24x9` | `-128..127 avg -22.8` | `-128..127 avg -20.8; 72 cells +5..+18 avg +6.1` | `-54..74 avg -4.9; 216 cells -92..+100 avg +17.9` | `-128..127 avg -22.8; 0 cells +0..+0 avg +0.0` | `-128..127 avg -22.6; 145 cells -50..+146 avg +0.3` | signed8 |
| `legacy_public_probe_tail_81a8_5x9` | `0x81A8-0x81D4` | `5x9` | `0..254 avg 165.1` | `0..255 avg 124.6; 30 cells -251..+18 avg -60.7` | `2..255 avg 119.1; 45 cells -245..+239 avg -46.0` | `0..254 avg 165.1; 0 cells +0..+0 avg +0.0` | `0..254 avg 166.1; 30 cells -161..+254 avg +1.5` | raw |
| `fuel_correction_enable_base_81db` | `0x81DB-0x81DB` | `1x1` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `38..38 avg 38.0; 1 cells +38..+38 avg +38.0` | raw |
| `fuel_period_gate_threshold_a_81dc_word` | `0x81DC-0x81DD` | `1x1` | `950..950 avg 950.0` | `950..950 avg 950.0; 0 cells +0..+0 avg +0.0` | `16480..16480 avg 16480.0; 1 cells +15530..+15530 avg +15530.0` | `950..950 avg 950.0; 0 cells +0..+0 avg +0.0` | `2570..2570 avg 2570.0; 1 cells +1620..+1620 avg +1620.0` | word16 raw |
| `fuel_period_gate_threshold_b_81de_word` | `0x81DE-0x81DF` | `1x1` | `16..16 avg 16.0` | `16..16 avg 16.0; 0 cells +0..+0 avg +0.0` | `980..980 avg 980.0; 1 cells +964..+964 avg +964.0` | `16..16 avg 16.0; 0 cells +0..+0 avg +0.0` | `16480..16480 avg 16480.0; 1 cells +16464..+16464 avg +16464.0` | word16 raw |
| `signed_low_rpm_fuel_trim_a_81f8_4x9` | `0x81F8-0x821B` | `4x9` | `-9..37 avg 7.3` | `-9..37 avg 7.3; 0 cells +0..+0 avg +0.0` | `-13..48 avg 16.5; 36 cells -18..+52 avg +9.2` | `-9..37 avg 7.3; 0 cells +0..+0 avg +0.0` | `-9..37 avg 7.4; 30 cells -37..+23 avg +0.1` | signed8 raw/256 trim |
| `signed_fuel_quantity_trim_a_821c_24x9` | `0x821C-0x82F3` | `24x9` | `-4..127 avg 28.6` | `-4..127 avg 28.6; 0 cells +0..+0 avg +0.0` | `-10..112 avg 32.0; 214 cells -119..+114 avg +3.4` | `-4..127 avg 28.6; 0 cells +0..+0 avg +0.0` | `-4..127 avg 27.7; 206 cells -131..+129 avg -0.9` | signed8 raw/256 trim |
| `signed_low_rpm_fuel_trim_b_82f4_4x9` | `0x82F4-0x8317` | `4x9` | `-9..37 avg 7.3` | `-9..37 avg 7.3; 0 cells +0..+0 avg +0.0` | `-13..80 avg 11.0; 36 cells -18..+80 avg +3.7` | `-9..37 avg 7.3; 0 cells +0..+0 avg +0.0` | `-9..60 avg 9.5; 30 cells -37..+52 avg +2.6` | signed8 raw/256 trim |
| `signed_fuel_quantity_trim_b_8318_24x9` | `0x8318-0x83EF` | `24x9` | `-11..74 avg 2.4` | `-11..74 avg 2.4; 0 cells +0..+0 avg +0.0` | `-10..112 avg 32.4; 210 cells -70..+123 avg +30.9` | `-11..74 avg 2.4; 0 cells +0..+0 avg +0.0` | `-11..74 avg 2.6; 166 cells -74..+76 avg +0.3` | signed8 raw/256 trim |
| `rpm_only_fuel_trim_bypass_83f0_signed_1x24` | `0x83F0-0x8407` | `1x24` | `31..93 avg 47.0` | `31..93 avg 47.0; 0 cells +0..+0 avg +0.0` | `27..80 avg 46.9; 24 cells -35..+38 avg -0.1` | `31..93 avg 47.0; 0 cells +0..+0 avg +0.0` | `0..93 avg 36.0; 23 cells -93..+38 avg -11.5` | signed8 |
| `fuel_period_gated_rpm_multiplier_81e0_1x24` | `0x81E0-0x81F7` | `1x24` | `14..32 avg 19.2` | `14..32 avg 19.2; 0 cells +0..+0 avg +0.0` | `0..32 avg 29.7; 19 cells -32..+18 avg +13.2` | `14..32 avg 19.2; 0 cells +0..+0 avg +0.0` | `0..182 avg 25.3; 8 cells -32..+150 avg +18.1` | raw |
| `cts_warmup_fuel_corr_8408_1x17` | `0x8408-0x8418` | `1x17` | `0..128 avg 36.9` | `0..128 avg 36.9; 0 cells +0..+0 avg +0.0` | `0..128 avg 37.5; 13 cells -65..+41 avg +0.8` | `0..128 avg 36.9; 0 cells +0..+0 avg +0.0` | `0..128 avg 52.3; 16 cells -83..+65 avg +16.4` | raw |
| `afterstart_tps_hysteresis_additive_8419` | `0x8419-0x8419` | `1x1` | `3..3 avg 3.0` | `3..3 avg 3.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -3..-3 avg -3.0` | `3..3 avg 3.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -3..-3 avg -3.0` | raw |
| `afterstart_startup_seed_841a` | `0x841A-0x841A` | `1x1` | `16..16 avg 16.0` | `16..16 avg 16.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -16..-16 avg -16.0` | `16..16 avg 16.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -16..-16 avg -16.0` | raw |
| `cts_afterstart_threshold_841b_1x17_words` | `0x841B-0x843C` | `1x17` | `64..8652 avg 1518.5` | `64..8652 avg 1518.5; 0 cells +0..+0 avg +0.0` | `0..60160 avg 37560.9; 17 cells -6059..+59860 avg +36042.5` | `64..8652 avg 1518.5; 0 cells +0..+0 avg +0.0` | `0..32874 avg 6207.1; 17 cells -8652..+27166 avg +4688.6` | word16 raw |
| `cts_afterstart_decay_scale_843d_1x17` | `0x843D-0x844D` | `1x17` | `22..175 avg 58.1` | `22..175 avg 58.1; 0 cells +0..+0 avg +0.0` | `19..219 avg 64.3; 15 cells -45..+57 avg +7.0` | `22..175 avg 58.1; 0 cells +0..+0 avg +0.0` | `0..244 avg 48.2; 17 cells -174..+86 avg -9.9` | raw |
| `afterstart_step_timer_844e` | `0x844E-0x844E` | `1x1` | `8..8 avg 8.0` | `8..8 avg 8.0; 0 cells +0..+0 avg +0.0` | `19..19 avg 19.0; 1 cells +11..+11 avg +11.0` | `8..8 avg 8.0; 0 cells +0..+0 avg +0.0` | `64..64 avg 64.0; 1 cells +56..+56 avg +56.0` | raw |
| `afterstart_reference_844f_word` | `0x844F-0x8450` | `1x1` | `1013..1013 avg 1013.0` | `1013..1013 avg 1013.0; 0 cells +0..+0 avg +0.0` | `2051..2051 avg 2051.0; 1 cells +1038..+1038 avg +1038.0` | `1013..1013 avg 1013.0; 0 cells +0..+0 avg +0.0` | `64..64 avg 64.0; 1 cells -949..-949 avg -949.0` | word16 raw |
| `afterstart_decay_multiplier_8451` | `0x8451-0x8451` | `1x1` | `69..69 avg 69.0` | `69..69 avg 69.0; 0 cells +0..+0 avg +0.0` | `245..245 avg 245.0; 1 cells +176..+176 avg +176.0` | `69..69 avg 69.0; 0 cells +0..+0 avg +0.0` | `175..175 avg 175.0; 1 cells +106..+106 avg +106.0` | raw |
| `cts_startup_output_seed_8452_1x9` | `0x8452-0x845A` | `1x9` | `45..45 avg 45.0` | `45..45 avg 45.0; 0 cells +0..+0 avg +0.0` | `0..69 avg 17.7; 9 cells -45..+24 avg -27.3` | `45..45 avg 45.0; 0 cells +0..+0 avg +0.0` | `26..162 avg 71.3; 9 cells -19..+117 avg +26.3` | raw |
| `cts_warmup_afterstart_init_a_845b_1x17` | `0x845B-0x846B` | `1x17` | `11..255 avg 67.1` | `11..255 avg 67.1; 0 cells +0..+0 avg +0.0` | `11..255 avg 72.1; 11 cells -239..+143 avg +7.7` | `11..255 avg 67.1; 0 cells +0..+0 avg +0.0` | `3..245 avg 45.1; 17 cells -231..+228 avg -22.1` | raw |
| `cts_warmup_afterstart_init_b_846c_1x17` | `0x846C-0x847C` | `1x17` | `8..204 avg 72.3` | `8..204 avg 72.3; 0 cells +0..+0 avg +0.0` | `11..255 avg 68.0; 17 cells -185..+117 avg -4.3` | `8..204 avg 72.3; 0 cells +0..+0 avg +0.0` | `11..255 avg 71.7; 17 cells -159..+164 avg -0.6` | raw |
| `cts_afterstart_timer_a_847d_1x17` | `0x847D-0x848D` | `1x17` | `46..192 avg 93.9` | `46..192 avg 93.9; 0 cells +0..+0 avg +0.0` | `19..192 avg 122.0; 17 cells -173..+69 avg +28.1` | `46..192 avg 93.9; 0 cells +0..+0 avg +0.0` | `8..204 avg 68.6; 17 cells -173..+74 avg -25.3` | raw |
| `cts_afterstart_timer_b_848e_1x17` | `0x848E-0x849E` | `1x17` | `47..255 avg 120.5` | `47..255 avg 120.5; 0 cells +0..+0 avg +0.0` | `80..192 avg 123.7; 17 cells -140..+52 avg +3.2` | `47..255 avg 120.5; 0 cells +0..+0 avg +0.0` | `32..192 avg 92.8; 17 cells -223..+31 avg -27.7` | raw |
| `cts_afterstart_target_limit_a_849f_1x17` | `0x849F-0x84AF` | `1x17` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..78 avg 4.6; 1 cells +78..+78 avg +78.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `46..255 avg 120.4; 17 cells +46..+255 avg +120.4` | raw |
| `cts_afterstart_target_limit_b_84b0_1x17` | `0x84B0-0x84C0` | `1x17` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..47 avg 8.3; 3 cells +47..+47 avg +47.0` | raw |
| `cts_afterstart_decay_blend_a_84c1_1x17` | `0x84C1-0x84D1` | `1x17` | `40..225 avg 141.6` | `40..225 avg 141.6; 0 cells +0..+0 avg +0.0` | `0..150 avg 60.4; 15 cells -161..-2 avg -92.0` | `40..225 avg 141.6; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 17 cells -225..-40 avg -141.6` | raw |
| `cts_afterstart_decay_blend_b_84d2_1x17` | `0x84D2-0x84E2` | `1x17` | `16..104 avg 49.1` | `16..104 avg 49.1; 0 cells +0..+0 avg +0.0` | `40..150 avg 74.3; 15 cells -26..+134 avg +28.6` | `16..104 avg 49.1; 0 cells +0..+0 avg +0.0` | `0..225 avg 101.9; 14 cells -16..+209 avg +64.1` | raw |
| `internal_2040_fuel_pulse_corr_84e3_1x9` | `0x84E3-0x84EB` | `1x9` | `0..5 avg 2.4` | `0..5 avg 2.4; 0 cells +0..+0 avg +0.0` | `0..150 avg 19.1; 6 cells +1..+145 avg +25.0` | `0..5 avg 2.4; 0 cells +0..+0 avg +0.0` | `16..225 avg 92.8; 9 cells +13..+221 avg +90.3` | raw |
| `scheduler_00d3_threshold_84ec_1x1` | `0x84EC-0x84EC` | `1x1` | `187..187 avg 187.0` | `187..187 avg 187.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -187..-187 avg -187.0` | `187..187 avg 187.0; 0 cells +0..+0 avg +0.0` | `39..39 avg 39.0; 1 cells -148..-148 avg -148.0` | raw |
| `cts_scheduler_threshold_84ed_1x9` | `0x84ED-0x84F5` | `1x9` | `2..181 avg 67.2` | `2..181 avg 67.2; 0 cells +0..+0 avg +0.0` | `40..255 avg 127.2; 9 cells +28..+84 avg +60.0` | `2..181 avg 67.2; 0 cells +0..+0 avg +0.0` | `41..57 avg 47.6; 9 cells -140..+41 avg -19.7` | raw |
| `cts_transient_word_scale_a_84f6_1x9_words` | `0x84F6-0x8507` | `1x9` | `2541..12288 avg 7414.6` | `2541..12288 avg 7414.6; 0 cells +0..+0 avg +0.0` | `407..10280 avg 3271.6; 9 cells -5451..-2008 avg -4143.0` | `2541..12288 avg 7414.6; 0 cells +0..+0 avg +0.0` | `0..48053 avg 13437.8; 9 cells -10042..+41857 avg +6023.2` | word16 raw |
| `transient_2042_gain_a_8508_1x9` | `0x8508-0x8510` | `1x9` | `0..176 avg 60.3` | `0..176 avg 60.3; 0 cells +0..+0 avg +0.0` | `0..151 avg 28.9; 9 cells -160..+149 avg -31.4` | `0..176 avg 60.3; 0 cells +0..+0 avg +0.0` | `2..196 avg 57.2; 8 cells -151..+52 avg -3.5` | raw |
| `rpm_transient_gain_a_8511_1x24` | `0x8511-0x8528` | `1x24` | `36..46 avg 39.8` | `36..46 avg 39.8; 0 cells +0..+0 avg +0.0` | `10..54 avg 24.3; 24 cells -32..+14 avg -15.5` | `36..46 avg 39.8; 0 cells +0..+0 avg +0.0` | `0..196 avg 78.4; 24 cells -39..+160 avg +38.5` | raw |
| `transient_2042_word_target_a_8529_1x9_words` | `0x8529-0x853A` | `1x9` | `0..12912 avg 5290.1` | `0..12912 avg 5290.1; 0 cells +0..+0 avg +0.0` | `500..19276 avg 5510.0; 9 cells -4928..+19276 avg +219.9` | `0..12912 avg 5290.1; 0 cells +0..+0 avg +0.0` | `9509..11052 avg 10137.4; 9 cells -1860..+9509 avg +4847.3` | word16 raw |
| `cts_transient_vector_a_853b_1x9` | `0x853B-0x8543` | `1x9` | `0..169 avg 54.7` | `0..169 avg 54.7; 0 cells +0..+0 avg +0.0` | `0..117 avg 66.9; 8 cells -136..+92 avg +13.8` | `0..169 avg 54.7; 0 cells +0..+0 avg +0.0` | `0..96 avg 26.1; 8 cells -124..+96 avg -32.1` | raw |
| `transient_branch_scale_8544` | `0x8544-0x8544` | `1x1` | `32..32 avg 32.0` | `32..32 avg 32.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -32..-32 avg -32.0` | `32..32 avg 32.0; 0 cells +0..+0 avg +0.0` | `7..7 avg 7.0; 1 cells -25..-25 avg -25.0` | raw |
| `transient_decay_threshold_8545` | `0x8545-0x8545` | `1x1` | `156..156 avg 156.0` | `156..156 avg 156.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -156..-156 avg -156.0` | `156..156 avg 156.0; 0 cells +0..+0 avg +0.0` | `208..208 avg 208.0; 1 cells +52..+52 avg +52.0` | raw |
| `cts_transient_word_scale_b_8546_1x9_words` | `0x8546-0x8557` | `1x9` | `1175..6144 avg 3107.4` | `1175..6144 avg 3107.4; 0 cells +0..+0 avg +0.0` | `1175..12444 avg 4359.6; 7 cells +828..+6300 avg +1609.9` | `1175..6144 avg 3107.4; 0 cells +0..+0 avg +0.0` | `0..43394 avg 13243.2; 9 cells -2649..+41391 avg +10135.8` | word16 raw |
| `transient_2042_vector_b_8558_1x9` | `0x8558-0x8560` | `1x9` | `80..254 avg 126.3` | `80..254 avg 126.3; 0 cells +0..+0 avg +0.0` | `4..152 avg 94.1; 7 cells -102..+71 avg -41.4` | `80..254 avg 126.3; 0 cells +0..+0 avg +0.0` | `0..196 avg 64.6; 9 cells -174..+76 avg -61.8` | raw |
| `rpm_transient_gain_b_8561_1x24` | `0x8561-0x8578` | `1x24` | `5..18 avg 9.9` | `5..18 avg 9.9; 0 cells +0..+0 avg +0.0` | `5..254 avg 27.0; 10 cells -5..+249 avg +40.9` | `5..18 avg 9.9; 0 cells +0..+0 avg +0.0` | `4..254 avg 81.3; 24 cells -13..+236 avg +71.4` | raw |
| `transient_2042_word_target_b_8579_1x9_words` | `0x8579-0x858A` | `1x9` | `0..6000 avg 2946.9` | `0..6000 avg 2946.9; 0 cells +0..+0 avg +0.0` | `4626..15500 avg 11611.1; 9 cells -1374..+11142 avg +8664.2` | `0..6000 avg 2946.9; 0 cells +0..+0 avg +0.0` | `1285..4626 avg 2313.8; 9 cells -4715..+4626 avg -633.1` | word16 raw |
| `cts_transient_vector_c_858b_1x9` | `0x858B-0x8593` | `1x9` | `0..16 avg 5.2` | `0..16 avg 5.2; 0 cells +0..+0 avg +0.0` | `0..112 avg 30.6; 8 cells +2..+105 avg +28.5` | `0..16 avg 5.2; 0 cells +0..+0 avg +0.0` | `18..144 avg 48.2; 9 cells +2..+144 avg +43.0` | raw |
| `transient_a_input_offset_8595` | `0x8595-0x8595` | `1x1` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `6..6 avg 6.0; 1 cells +6..+6 avg +6.0` | raw |
| `transient_enrichment_a_8596_1x9` | `0x8596-0x859E` | `1x9` | `0..160 avg 74.7` | `0..160 avg 74.7; 0 cells +0..+0 avg +0.0` | `0..112 avg 32.4; 9 cells -87..+26 avg -42.2` | `0..160 avg 74.7; 0 cells +0..+0 avg +0.0` | `0..178 avg 40.4; 9 cells -160..+157 avg -34.2` | raw |
| `cts_transient_temperature_scale_859f_1x9` | `0x859F-0x85A7` | `1x9` | `0..179 avg 62.8` | `0..179 avg 62.8; 0 cells +0..+0 avg +0.0` | `0..179 avg 98.3; 8 cells -19..+81 avg +40.0` | `0..179 avg 62.8; 0 cells +0..+0 avg +0.0` | `0..16 avg 5.2; 7 cells -179..+6 avg -74.0` | raw |
| `transient_b_entry_threshold_a_85a8` | `0x85A8-0x85A8` | `1x1` | `10..10 avg 10.0` | `10..10 avg 10.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -10..-10 avg -10.0` | `10..10 avg 10.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -10..-10 avg -10.0` | raw |
| `transient_b_entry_threshold_b_85a9` | `0x85A9-0x85A9` | `1x1` | `24..24 avg 24.0` | `24..24 avg 24.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -24..-24 avg -24.0` | `24..24 avg 24.0; 0 cells +0..+0 avg +0.0` | `26..26 avg 26.0; 1 cells +2..+2 avg +2.0` | raw |
| `transient_b_load_rpm_additive_threshold_85aa` | `0x85AA-0x85AA` | `1x1` | `8..8 avg 8.0` | `8..8 avg 8.0; 0 cells +0..+0 avg +0.0` | `10..10 avg 10.0; 1 cells +2..+2 avg +2.0` | `8..8 avg 8.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -8..-8 avg -8.0` | raw |
| `transient_b_lower_cutoff_85ab_word` | `0x85AB-0x85AC` | `1x1` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `5128..5128 avg 5128.0; 1 cells +5128..+5128 avg +5128.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `10..10 avg 10.0; 1 cells +10..+10 avg +10.0` | word16 raw |
| `transient_b_input_offset_85ae` | `0x85AE-0x85AE` | `1x1` | `22..22 avg 22.0` | `22..22 avg 22.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -22..-22 avg -22.0` | `22..22 avg 22.0; 0 cells +0..+0 avg +0.0` | `53..53 avg 53.0; 1 cells +31..+31 avg +31.0` | raw |
| `transient_enrichment_b_85af_1x9` | `0x85AF-0x85B7` | `1x9` | `0..202 avg 122.2` | `0..202 avg 122.2; 0 cells +0..+0 avg +0.0` | `0..128 avg 68.7; 9 cells -122..+26 avg -53.6` | `0..202 avg 122.2; 0 cells +0..+0 avg +0.0` | `64..179 avg 119.4; 9 cells -138..+74 avg -2.8` | raw |
| `high_load_fuel_pulse_extension_85ba_24x5` | `0x85BA-0x8631` | `24x5` | `0..25 avg 2.2` | `0..25 avg 2.2; 0 cells +0..+0 avg +0.0` | `0..40 avg 0.3; 19 cells -25..+40 avg -11.8` | `0..25 avg 2.2; 0 cells +0..+0 avg +0.0` | `0..202 avg 13.0; 46 cells -25..+202 avg +28.0` | raw duration support |
| `cts_idle_state_target_a_8636_1x9` | `0x8636-0x863E` | `1x9` | `93..115 avg 102.6` | `93..115 avg 102.6; 0 cells +0..+0 avg +0.0` | `14..166 avg 97.0; 9 cells -101..+51 avg -5.6` | `93..115 avg 102.6; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 9 cells -115..-93 avg -102.6` | raw |
| `cts_idle_state_target_b_863f_1x9` | `0x863F-0x8647` | `1x9` | `106..163 avg 126.2` | `106..163 avg 126.2; 0 cells +0..+0 avg +0.0` | `100..180 avg 129.9; 9 cells -63..+62 avg +3.7` | `106..163 avg 126.2; 0 cells +0..+0 avg +0.0` | `0..23 avg 2.6; 9 cells -163..-83 avg -123.7` | raw |
| `cts_idle_state_target_c_8648_1x9` | `0x8648-0x8650` | `1x9` | `118..177 avg 144.6` | `118..177 avg 144.6; 0 cells +0..+0 avg +0.0` | `106..177 avg 135.6; 9 cells -71..+34 avg -9.0` | `118..177 avg 144.6; 0 cells +0..+0 avg +0.0` | `0..166 avg 81.1; 9 cells -175..+3 avg -63.4` | raw |
| `state_2042_threshold_8652_1x9` | `0x8652-0x865A` | `1x9` | `17..70 avg 33.8` | `17..70 avg 33.8; 0 cells +0..+0 avg +0.0` | `13..106 avg 42.8; 9 cells -34..+89 avg +9.0` | `17..70 avg 33.8; 0 cells +0..+0 avg +0.0` | `93..163 avg 121.9; 9 cells +42..+146 avg +88.1` | raw |
| `state_2042_minimum_8671_1x9` | `0x8671-0x8679` | `1x9` | `2..4 avg 2.8` | `2..4 avg 2.8; 0 cells +0..+0 avg +0.0` | `0..255 avg 31.4; 8 cells -2..+253 avg +32.2` | `2..4 avg 2.8; 0 cells +0..+0 avg +0.0` | `0..255 avg 35.2; 9 cells -2..+253 avg +32.4` | raw |
| `cts_idle_state_limit_8689_1x9` | `0x8689-0x8691` | `1x9` | `60..80 avg 66.7` | `60..80 avg 66.7; 0 cells +0..+0 avg +0.0` | `12..115 avg 61.2; 7 cells -68..+55 avg -7.0` | `60..80 avg 66.7; 0 cells +0..+0 avg +0.0` | `2..10 avg 3.4; 9 cells -78..-56 avg -63.2` | raw |
| `fuel_cut_state_delay_loadrise_rpm_869a_24x9` | `0x869A-0x8771` | `24x9` | `0..48 avg 14.0` | `0..48 avg 14.0; 0 cells +0..+0 avg +0.0` | `0..255 avg 29.0; 141 cells -48..+255 avg +23.0` | `0..48 avg 14.0; 0 cells +0..+0 avg +0.0` | `0..255 avg 19.5; 155 cells -48..+255 avg +7.7` | raw countdown ticks |
| `transient_a_lower_cutoff_877b_word` | `0x877B-0x877C` | `1x1` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `16385..16385 avg 16385.0; 1 cells +16385..+16385 avg +16385.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | word16 raw |
| `event_width_limit_prev_width_877e_1x9` | `0x877E-0x8786` | `1x9` | `37..37 avg 37.0` | `37..37 avg 37.0; 0 cells +0..+0 avg +0.0` | `0..81 avg 28.0; 9 cells -37..+44 avg -9.0` | `37..37 avg 37.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 9 cells -37..-37 avg -37.0` | raw |
| `oc3_period_fit_guard_8787_word` | `0x8787-0x8788` | `1x1` | `725..725 avg 725.0` | `725..725 avg 725.0; 0 cells +0..+0 avg +0.0` | `7967..7967 avg 7967.0; 1 cells +7242..+7242 avg +7242.0` | `725..725 avg 725.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -725..-725 avg -725.0` | word16 raw |
| `fuel_output_edge_offset_8789_1x9_words` | `0x8789-0x879A` | `1x9` | `210..1085 avg 496.7` | `210..1085 avg 496.7; 0 cells +0..+0 avg +0.0` | `7938..7967 avg 7963.8; 9 cells +6882..+7728 avg +7467.1` | `210..1085 avg 496.7; 0 cells +0..+0 avg +0.0` | `0..51280 avg 8592.6; 9 cells -1085..+50674 avg +8095.9` | word16 raw |
| `spark_transition_2046_a_87a6_1x5` | `0x87A6-0x87AA` | `1x5` | `1..2 avg 1.6` | `1..2 avg 1.6; 0 cells +0..+0 avg +0.0` | `0..216 avg 44.6; 5 cells -2..+215 avg +43.0` | `1..2 avg 1.6; 0 cells +0..+0 avg +0.0` | `37..37 avg 37.0; 5 cells +35..+36 avg +35.4` | raw |
| `spark_transition_2046_b_87ab_1x6` | `0x87AB-0x87B0` | `1x6` | `2..10 avg 5.8` | `2..10 avg 5.8; 0 cells +0..+0 avg +0.0` | `0..170 avg 70.8; 6 cells -9..+165 avg +65.0` | `2..10 avg 5.8; 0 cells +0..+0 avg +0.0` | `2..213 avg 60.5; 6 cells -8..+211 avg +54.7` | raw |
| `injector_event_phase_offset_87b1_24x9` | `0x87B1-0x8888` | `24x9` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..214 avg 3.0; 19 cells +2..+214 avg +33.8` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..246 avg 9.9; 38 cells +1..+246 avg +56.0` | raw phase |
| `injector_phase_slew_limit_8889` | `0x8889-0x8889` | `1x1` | `3..3 avg 3.0` | `3..3 avg 3.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -3..-3 avg -3.0` | `3..3 avg 3.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 1 cells -3..-3 avg -3.0` | raw |
| `idle_air_bypass_target_888e_24x9` | `0x888E-0x8965` | `24x9` | `1..38 avg 14.5` | `1..38 avg 14.5; 0 cells +0..+0 avg +0.0` | `0..255 avg 54.3; 213 cells -38..+254 avg +40.3` | `1..38 avg 14.5; 0 cells +0..+0 avg +0.0` | `0..100 avg 9.8; 208 cells -38..+99 avg -4.9` | raw |
| `idle_afterstart_condition_threshold_896f` | `0x896F-0x896F` | `1x1` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `128..128 avg 128.0; 1 cells +128..+128 avg +128.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `38..38 avg 38.0; 1 cells +38..+38 avg +38.0` | raw |
| `cts_idle_target_cap_8970_1x17` | `0x8970-0x8980` | `1x17` | `0..254 avg 164.4` | `0..254 avg 164.4; 0 cells +0..+0 avg +0.0` | `0..128 avg 35.6; 17 cells -254..+4 avg -128.8` | `0..254 avg 164.4; 0 cells +0..+0 avg +0.0` | `1..38 avg 24.9; 17 cells -253..+38 avg -139.4` | raw |
| `tps_afterstart_threshold_8990` | `0x8990-0x8990` | `1x1` | `208..208 avg 208.0` | `208..208 avg 208.0; 0 cells +0..+0 avg +0.0` | `21..21 avg 21.0; 1 cells -187..-187 avg -187.0` | `208..208 avg 208.0; 0 cells +0..+0 avg +0.0` | `2..2 avg 2.0; 1 cells -206..-206 avg -206.0` | raw |
| `rpm_closed_loop_entry_offset_899a_1x24` | `0x899A-0x89B1` | `1x24` | `32..140 avg 48.4` | `32..140 avg 48.4; 0 cells +0..+0 avg +0.0` | `0..176 avg 12.3; 24 cells -140..+144 avg -36.1` | `32..140 avg 48.4; 0 cells +0..+0 avg +0.0` | `0..255 avg 130.2; 23 cells -112..+223 avg +85.4` | raw |
| `spark_high_default_24x9` | `0x8A69-0x8B40` | `24x9` | `16..93 avg 62.5` | `16..93 avg 64.7; 101 cells +2..+20 avg +4.6` | `17..119 avg 64.3; 214 cells -58..+99 avg +1.8` | `16..112 avg 84.5; 205 cells +5..+54 avg +23.2` | `0..255 avg 59.1; 195 cells -52..+209 avg -3.7` | raw/2 deg |
| `spark_low_alternate_24x9` | `0x8B41-0x8C18` | `24x9` | `20..100 avg 59.6` | `20..100 avg 64.6; 145 cells +2..+18 avg +7.5` | `0..146 avg 38.8; 214 cells -96..+99 avg -21.0` | `42..121 avg 86.1; 215 cells +13..+49 avg +26.6` | `20..100 avg 59.4; 206 cells -46..+55 avg -0.2` | raw/2 deg |
| `wot_spark_vector_1x24` | `0x8C19-0x8C30` | `1x24` | `16..62 avg 49.0` | `16..62 avg 49.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 24 cells -62..-16 avg -49.0` | `16..62 avg 49.0; 0 cells +0..+0 avg +0.0` | `54..96 avg 74.8; 24 cells -6..+64 avg +25.8` | raw/2 deg |
| `spark_mode_vector_a_8c31_1x24` | `0x8C31-0x8C48` | `1x24` | `8..52 avg 40.6` | `8..52 avg 40.6; 0 cells +0..+0 avg +0.0` | `0..255 avg 178.5; 24 cells -52..+244 avg +138.0` | `8..52 avg 40.6; 0 cells +0..+0 avg +0.0` | `16..72 avg 49.5; 24 cells -18..+32 avg +8.9` | raw/2 deg |
| `spark_mode_vector_b_8c49_1x24` | `0x8C49-0x8C60` | `1x24` | `12..80 avg 46.6` | `12..80 avg 46.6; 0 cells +0..+0 avg +0.0` | `0..252 avg 185.6; 24 cells -79..+240 avg +139.0` | `12..80 avg 46.6; 0 cells +0..+0 avg +0.0` | `8..62 avg 41.8; 24 cells -35..+40 avg -4.8` | raw/2 deg |
| `spark_mode_vector_c_8c61_1x24` | `0x8C61-0x8C78` | `1x24` | `0..72 avg 38.7` | `0..72 avg 38.7; 0 cells +0..+0 avg +0.0` | `0..248 avg 122.5; 23 cells -72..+246 avg +87.5` | `0..72 avg 38.7; 0 cells +0..+0 avg +0.0` | `12..79 avg 43.5; 24 cells -26..+52 avg +4.8` | raw/2 deg |
| `spark_iat_load_corr_a_8c7c_signed_17x9` | `0x8C7C-0x8D14` | `17x9` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `-12..48 avg 1.6; 19 cells -12..+48 avg +13.2` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `-110..124 avg 7.6; 29 cells -110..+124 avg +40.2` | signed8 |
| `spark_cts_load_corr_b_8d15_signed_17x9` | `0x8D15-0x8DAD` | `17x9` | `-9..10 avg -0.0` | `-9..10 avg -0.0; 0 cells +0..+0 avg +0.0` | `-128..127 avg 17.2; 120 cells -138..+123 avg +21.9` | `-9..10 avg -0.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 30 cells -10..+9 avg +0.2` | signed8 |
| `spark_cts_temp_decay_8dae_1x17` | `0x8DAE-0x8DBE` | `1x17` | `0..30 avg 10.2` | `0..30 avg 10.2; 0 cells +0..+0 avg +0.0` | `54..167 avg 105.2; 17 cells +29..+162 avg +95.0` | `0..30 avg 10.2; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 11 cells -30..-5 avg -15.7` | raw |
| `spark_cts_mode_delay_8dd9_1x9` | `0x8DD9-0x8DE1` | `1x9` | `1..255 avg 71.4` | `1..255 avg 71.4; 0 cells +0..+0 avg +0.0` | `19..21 avg 20.8; 9 cells -234..+20 avg -50.7` | `1..255 avg 71.4; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 9 cells -255..-1 avg -71.4` | raw |
| `spark_state_decay_a_8e04_1x9` | `0x8E04-0x8E0C` | `1x9` | `0..100 avg 88.9` | `0..100 avg 88.9; 0 cells +0..+0 avg +0.0` | `19..21 avg 20.6; 9 cells -81..+21 avg -68.3` | `0..100 avg 88.9; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 8 cells -100..-100 avg -100.0` | raw |
| `spark_state_decay_b_8e0d_1x9` | `0x8E0D-0x8E15` | `1x9` | `64..128 avg 120.9` | `64..128 avg 120.9; 0 cells +0..+0 avg +0.0` | `19..21 avg 20.6; 9 cells -109..-43 avg -100.3` | `64..128 avg 120.9; 0 cells +0..+0 avg +0.0` | `0..10 avg 3.3; 9 cells -128..-64 avg -117.6` | raw |
| `spark_state_decay_c_8e18_1x9` | `0x8E18-0x8E20` | `1x9` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `19..21 avg 20.6; 9 cells +19..+21 avg +20.6` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..10 avg 3.3; 3 cells +10..+10 avg +10.0` | raw |
| `adaptive_entry_threshold_a_8e36_1x7` | `0x8E36-0x8E3C` | `1x7` | `0..217 avg 62.4` | `0..217 avg 62.4; 0 cells +0..+0 avg +0.0` | `16..16 avg 16.0; 7 cells -201..+16 avg -46.4` | `0..217 avg 62.4; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 5 cells -217..-10 avg -87.4` | raw |
| `adaptive_entry_threshold_b_8e3d_1x7` | `0x8E3D-0x8E43` | `1x7` | `0..90 avg 37.9` | `0..90 avg 37.9; 0 cells +0..+0 avg +0.0` | `16..16 avg 16.0; 7 cells -74..+16 avg -21.9` | `0..90 avg 37.9; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 5 cells -90..-11 avg -53.0` | raw |
| `adaptive_entry_rpm_offset_a_8e46_1x17` | `0x8E46-0x8E56` | `1x17` | `47..167 avg 65.7` | `47..167 avg 65.7; 0 cells +0..+0 avg +0.0` | `16..16 avg 16.0; 17 cells -151..-31 avg -49.7` | `47..167 avg 65.7; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 17 cells -167..-47 avg -65.7` | raw |
| `adaptive_entry_rpm_offset_b_8e57_1x17` | `0x8E57-0x8E67` | `1x17` | `42..130 avg 58.8` | `42..130 avg 58.8; 0 cells +0..+0 avg +0.0` | `16..16 avg 16.0; 17 cells -114..-26 avg -42.8` | `42..130 avg 58.8; 0 cells +0..+0 avg +0.0` | `0..251 avg 161.9; 17 cells -42..+209 avg +103.1` | raw |
| `adaptive_trim_dynamics_a_8e6f_17x5` | `0x8E6F-0x8EC3` | `17x5` | `10..16 avg 13.9` | `10..16 avg 13.9; 0 cells +0..+0 avg +0.0` | `16..16 avg 16.0; 30 cells +6..+6 avg +6.0` | `10..16 avg 13.9; 0 cells +0..+0 avg +0.0` | `0..255 avg 31.0; 83 cells -16..+245 avg +17.5` | raw |
| `adaptive_trim_dynamics_b_8ec7_17x5` | `0x8EC7-0x8F1B` | `17x5` | `16..16 avg 16.0` | `16..16 avg 16.0; 0 cells +0..+0 avg +0.0` | `0..16 avg 1.7; 76 cells -16..-16 avg -16.0` | `16..16 avg 16.0; 0 cells +0..+0 avg +0.0` | `0..255 avg 67.0; 82 cells -16..+239 avg +52.9` | raw |
| `adaptive_trim_timer_8f1c_17x5` | `0x8F1C-0x8F70` | `17x5` | `0..32 avg 6.7` | `0..32 avg 6.7; 0 cells +0..+0 avg +0.0` | `0..255 avg 68.1; 75 cells -21..+250 avg +69.6` | `0..32 avg 6.7; 0 cells +0..+0 avg +0.0` | `0..255 avg 37.3; 81 cells -16..+242 avg +32.1` | raw |
| `adaptive_trim_hold_8f71_17x5` | `0x8F71-0x8FC5` | `17x5` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..254 avg 43.7; 80 cells +1..+254 avg +46.4` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `10..64 avg 16.6; 85 cells +10..+64 avg +16.6` | raw |
| `closed_loop_base_a_9000_1x17` | `0x9000-0x9010` | `1x17` | `29..80 avg 53.1` | `29..80 avg 53.1; 0 cells +0..+0 avg +0.0` | `0..85 avg 54.6; 17 cells -63..+54 avg +1.5` | `29..80 avg 53.1; 0 cells +0..+0 avg +0.0` | `0..25 avg 6.0; 17 cells -80..-5 avg -47.1` | raw |
| `closed_loop_base_b_9011_1x17` | `0x9011-0x9021` | `1x17` | `32..152 avg 70.4` | `32..152 avg 70.4; 0 cells +0..+0 avg +0.0` | `42..94 avg 74.4; 17 cells -87..+62 avg +4.1` | `32..152 avg 70.4; 0 cells +0..+0 avg +0.0` | `5..25 avg 17.8; 17 cells -141..-7 avg -52.6` | raw |
| `closed_loop_base_c_9022_1x17` | `0x9022-0x9032` | `1x17` | `32..152 avg 70.4` | `32..152 avg 70.4; 0 cells +0..+0 avg +0.0` | `49..240 avg 122.6; 17 cells -103..+208 avg +52.2` | `32..152 avg 70.4; 0 cells +0..+0 avg +0.0` | `5..23 avg 16.6; 17 cells -141..-9 avg -53.8` | raw |
| `closed_loop_initial_delay_9033_1x17` | `0x9033-0x9043` | `1x17` | `0..42 avg 11.8` | `0..42 avg 11.8; 0 cells +0..+0 avg +0.0` | `0..200 avg 32.1; 17 cells -32..+191 avg +20.4` | `0..42 avg 11.8; 0 cells +0..+0 avg +0.0` | `0..17 avg 9.1; 15 cells -33..+16 avg -3.0` | raw |
| `closed_loop_timer_reload_9044_1x17` | `0x9044-0x9054` | `1x17` | `2..8 avg 4.4` | `2..8 avg 4.4; 0 cells +0..+0 avg +0.0` | `7..144 avg 24.4; 17 cells +2..+142 avg +20.1` | `2..8 avg 4.4; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 17 cells -8..-2 avg -4.4` | raw |
| `closed_loop_dynamic_load_9068_1x11` | `0x9068-0x9072` | `1x11` | `0..8 avg 1.0` | `0..8 avg 1.0; 0 cells +0..+0 avg +0.0` | `0..144 avg 31.4; 8 cells -3..+144 avg +41.8` | `0..8 avg 1.0; 0 cells +0..+0 avg +0.0` | `0..0 avg 0.0; 2 cells -8..-3 avg -5.5` | raw |
| `closed_loop_ramp_target_9073_11x9` | `0x9073-0x90D5` | `11x9` | `0..0 avg 0.0` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..255 avg 37.7; 95 cells +1..+255 avg +39.3` | `0..0 avg 0.0; 0 cells +0..+0 avg +0.0` | `0..255 avg 36.2; 46 cells +1..+255 avg +77.9` | raw |
| `closed_loop_ramp_temp_scale_90d6_1x9` | `0x90D6-0x90DE` | `1x9` | `255..255 avg 255.0` | `255..255 avg 255.0; 0 cells +0..+0 avg +0.0` | `40..255 avg 199.4; 5 cells -215..-19 avg -100.0` | `255..255 avg 255.0; 0 cells +0..+0 avg +0.0` | `0..255 avg 61.1; 8 cells -255..-175 avg -218.1` | raw |
| `closed_loop_state_delay_90ef_1x17` | `0x90EF-0x90FF` | `1x17` | `7..34 avg 14.8` | `7..34 avg 14.8; 0 cells +0..+0 avg +0.0` | `102..255 avg 198.1; 17 cells +93..+244 avg +183.3` | `7..34 avg 14.8; 0 cells +0..+0 avg +0.0` | `32..152 avg 70.4; 17 cells +19..+145 avg +55.6` | raw |
| `load_aircharge_model_factor_9187_24x9` | `0x9187-0x925E` | `24x9` | `33..254 avg 179.2` | `33..254 avg 180.1; 62 cells -94..+32 avg +3.3` | `0..255 avg 100.0; 216 cells -254..+188 avg -79.2` | `33..255 avg 183.6; 72 cells -76..+109 avg +13.3` | `0..255 avg 37.5; 216 cells -254..+221 avg -141.7` | raw/230 hypothesis |
| `rpm_axis_period_1x24` | `0x929E-0x92B5` | `1x24` | `22..239 avg 100.0` | `22..239 avg 100.0; 0 cells +0..+0 avg +0.0` | `4..253 avg 105.1; 24 cells -214..+227 avg +5.1` | `22..239 avg 100.0; 0 cells +0..+0 avg +0.0` | `75..245 avg 166.9; 24 cells -122..+220 avg +66.9` | period axis |
| `likely_cts_adc_breakpoints_b_92cf_1x9` | `0x92CF-0x92D7` | `1x9` | `12..246 avg 113.6` | `12..246 avg 113.6; 0 cells +0..+0 avg +0.0` | `6..252 avg 82.0; 9 cells -122..+23 avg -31.6` | `12..246 avg 113.6; 0 cells +0..+0 avg +0.0` | `51..244 avg 135.1; 9 cells -195..+78 avg +21.6` | raw |
| `likely_iat_adc_breakpoints_a_92d9_1x9` | `0x92D9-0x92E1` | `1x9` | `12..246 avg 113.6` | `12..246 avg 113.6; 0 cells +0..+0 avg +0.0` | `16..253 avg 101.7; 9 cells -230..+223 avg -11.9` | `12..246 avg 113.6; 0 cells +0..+0 avg +0.0` | `50..243 avg 128.1; 9 cells -192..+121 avg +14.6` | raw |
| `fuel_output_scheduler_scale_92fa_1x9` | `0x92FA-0x9302` | `1x9` | `39..124 avg 66.9` | `39..124 avg 66.9; 0 cells +0..+0 avg +0.0` | `16..253 avg 56.1; 9 cells -100..+158 avg -10.8` | `39..124 avg 66.9; 0 cells +0..+0 avg +0.0` | `42..243 avg 113.8; 9 cells -53..+198 avg +46.9` | raw |
| `scheduler_2040_signed_subvector_9303_1x10` | `0x9303-0x930C` | `1x10` | `-2..16 avg 2.7` | `-2..16 avg 2.7; 0 cells +0..+0 avg +0.0` | `-77..64 avg 11.4; 9 cells -75..+48 avg +9.7` | `-2..16 avg 2.7; 0 cells +0..+0 avg +0.0` | `-77..84 avg 19.4; 10 cells -75..+85 avg +16.7` | signed8 |
| `temp_raw_output_c_plus_40_400e_1x9` | `0x400E-0x4016` | `1x9` | `0..160 avg 80.0` | `0..160 avg 80.0; 0 cells +0..+0 avg +0.0` | `0..160 avg 80.0; 0 cells +0..+0 avg +0.0` | `0..160 avg 80.0; 0 cells +0..+0 avg +0.0` | `0..160 avg 80.0; 0 cells +0..+0 avg +0.0` | raw |
| `control_scalars_1x6` | `0x89ED-0x89F2` | `1x6` | `0..144 avg 72.0` | `0..144 avg 72.0; 0 cells +0..+0 avg +0.0` | `17..50 avg 34.2; 6 cells -122..+44 avg -37.8` | `0..144 avg 72.0; 0 cells +0..+0 avg +0.0` | `14..17 avg 15.0; 6 cells -130..+14 avg -57.0` | raw |
| `ignition_phase_factor_89c7_1x19` | `0x89C7-0x89D9` | `1x19` | `14..17 avg 15.9` | `14..17 avg 15.9; 0 cells +0..+0 avg +0.0` | `18..36 avg 26.9; 19 cells +1..+22 avg +11.1` | `14..17 avg 15.9; 0 cells +0..+0 avg +0.0` | `32..140 avg 52.7; 19 cells +15..+126 avg +36.8` | raw |
| `ignition_width_dwell_factor_89da_1x19` | `0x89DA-0x89EC` | `1x19` | `20..32 avg 29.8` | `20..32 avg 29.8; 0 cells +0..+0 avg +0.0` | `18..48 avg 32.8; 16 cells -14..+24 avg +3.6` | `20..32 avg 29.8; 0 cells +0..+0 avg +0.0` | `1..247 avg 49.7; 18 cells -31..+215 avg +21.1` | raw |
| `per_event_retard_gain_89f3_1x19` | `0x89F3-0x8A05` | `1x19` | `64..170 avg 123.2` | `64..172 avg 129.1; 16 cells +2..+18 avg +7.0` | `23..62 avg 46.1; 19 cells -142..-17 avg -77.2` | `64..170 avg 123.2; 0 cells +0..+0 avg +0.0` | `14..32 avg 28.5; 19 cells -138..-48 avg -94.7` | raw |
| `ignition_retard_activation_scalars_8a23_1x4` | `0x8A23-0x8A26` | `1x4` | `4..128 avg 73.0` | `4..128 avg 73.0; 0 cells +0..+0 avg +0.0` | `27..62 avg 45.8; 4 cells -76..+38 avg -27.2` | `4..128 avg 73.0; 0 cells +0..+0 avg +0.0` | `0..160 avg 50.5; 4 cells -118..+156 avg -22.5` | raw |
| `per_event_retard_cap_8a52_1x19` | `0x8A52-0x8A64` | `1x19` | `18..34 avg 26.2` | `18..34 avg 26.2; 0 cells +0..+0 avg +0.0` | `52..110 avg 86.3; 19 cells +21..+84 avg +60.2` | `18..34 avg 26.2; 0 cells +0..+0 avg +0.0` | `6..32 avg 26.5; 18 cells -12..+12 avg +0.4` | raw |

## Helper / JSR Scan

### `peugeot_stock`

Most common extended JSR targets:

| Target | Count |
| --- | ---: |
| `0xB2AB` | 53 |
| `0x54EB` | 32 |
| `0x54FE` | 26 |
| `0x58F2` | 18 |
| `0x5982` | 18 |
| `0xB2D6` | 12 |
| `0xCAC5` | 10 |
| `0xB3F6` | 9 |
| `0xE6DA` | 9 |
| `0xEFC0` | 9 |
| `0xB26E` | 8 |
| `0xDD57` | 8 |
| `0xB42F` | 7 |
| `0xB383` | 7 |
| `0x4C36` | 7 |
| `0xBD6E` | 7 |
| `0x69CF` | 6 |
| `0x4B52` | 5 |
| `0x6E18` | 5 |
| `0x667C` | 5 |

Focused helper calls:

| Helper | Count | First call sites | Nearby known table literals |
| --- | ---: | --- | --- |
| `0xB2D6` | 12 | 0x4927, 0x6366, 0x6ECA, 0x7270, 0x9BAE, 0xBA57, 0xBE90, 0xC2BE, 0xD131, 0xD13D, 0xD149, 0xD15A | 0x8318 at 0x6356, 0x9187 at 0x6361, 0x9291 at 0x6352, 0x85BA at 0x6EC0, 0x87B1 at 0x7265, 0x8889 at 0x727A, 0x869A at 0x9BA4, 0x8A27 at 0xBA62, 0x888E at 0xBE85, 0x8970 at 0xBE98, 0x8E18 at 0xBE86, 0x9073 at 0xC2B4 |
| `0xB2AB` | 53 | 0x4353, 0x43A3, 0x44B4, 0x4599, 0x45BF, 0x46EB, 0x48FF, 0x49B0, 0x49C1, 0x560F, 0x5618, 0x575F | 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8DD9 at 0x44AF, 0x8E0D at 0x4585, 0x8E18 at 0x458E, 0x8C61 at 0x45BA, 0x87A6 at 0x46D8, 0x8A69 at 0x4905, 0x8B41 at 0x490D, 0x8C19 at 0x48FA |
| `0xB383` | 7 | 0x41E9, 0x4349, 0x4399, 0x5CFC, 0x5D81, 0x6354, 0xC289 | 0x9291 at 0x41E1, 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8318 at 0x5CFE, 0x92CF at 0x5D01, 0x92D9 at 0x5CF7, 0x8318 at 0x5D83, 0x92CF at 0x5D7C, 0x92D9 at 0x5D86, 0x8318 at 0x6356 |
| `0xB3B9` | 1 | 0xD47C | 0x929E at 0xD46E |

### `peugeot_stok`

Most common extended JSR targets:

| Target | Count |
| --- | ---: |
| `0xB2AB` | 53 |
| `0x54EB` | 32 |
| `0x54FE` | 26 |
| `0x58F2` | 18 |
| `0x5982` | 18 |
| `0xB2D6` | 12 |
| `0xCAC5` | 10 |
| `0xB3F6` | 9 |
| `0xE6DA` | 9 |
| `0xEFC0` | 9 |
| `0xB26E` | 8 |
| `0xDD57` | 8 |
| `0xB42F` | 7 |
| `0xB383` | 7 |
| `0x4C36` | 7 |
| `0xBD6E` | 7 |
| `0x69CF` | 6 |
| `0x4B52` | 5 |
| `0x6E18` | 5 |
| `0x667C` | 5 |

Focused helper calls:

| Helper | Count | First call sites | Nearby known table literals |
| --- | ---: | --- | --- |
| `0xB2D6` | 12 | 0x4927, 0x6366, 0x6ECA, 0x7270, 0x9BAE, 0xBA57, 0xBE90, 0xC2BE, 0xD131, 0xD13D, 0xD149, 0xD15A | 0x8318 at 0x6356, 0x9187 at 0x6361, 0x9291 at 0x6352, 0x85BA at 0x6EC0, 0x87B1 at 0x7265, 0x8889 at 0x727A, 0x869A at 0x9BA4, 0x8A27 at 0xBA62, 0x888E at 0xBE85, 0x8970 at 0xBE98, 0x8E18 at 0xBE86, 0x9073 at 0xC2B4 |
| `0xB2AB` | 53 | 0x4353, 0x43A3, 0x44B4, 0x4599, 0x45BF, 0x46EB, 0x48FF, 0x49B0, 0x49C1, 0x560F, 0x5618, 0x575F | 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8DD9 at 0x44AF, 0x8E0D at 0x4585, 0x8E18 at 0x458E, 0x8C61 at 0x45BA, 0x87A6 at 0x46D8, 0x8A69 at 0x4905, 0x8B41 at 0x490D, 0x8C19 at 0x48FA |
| `0xB383` | 7 | 0x41E9, 0x4349, 0x4399, 0x5CFC, 0x5D81, 0x6354, 0xC289 | 0x9291 at 0x41E1, 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8318 at 0x5CFE, 0x92CF at 0x5D01, 0x92D9 at 0x5CF7, 0x8318 at 0x5D83, 0x92CF at 0x5D7C, 0x92D9 at 0x5D86, 0x8318 at 0x6356 |
| `0xB3B9` | 1 | 0xD47C | 0x929E at 0xD46E |

### `peugeot_mod2`

Most common extended JSR targets:

| Target | Count |
| --- | ---: |
| `0xB2AB` | 53 |
| `0x54EB` | 32 |
| `0x54FE` | 26 |
| `0x58F2` | 18 |
| `0x5982` | 18 |
| `0xB2D6` | 12 |
| `0xCAC5` | 10 |
| `0xB3F6` | 9 |
| `0xE6DA` | 9 |
| `0xEFC0` | 9 |
| `0xB26E` | 8 |
| `0xDD57` | 8 |
| `0xB42F` | 7 |
| `0xB383` | 7 |
| `0x4C36` | 7 |
| `0xBD6E` | 7 |
| `0x69CF` | 6 |
| `0x4B52` | 5 |
| `0x6E18` | 5 |
| `0x667C` | 5 |

Focused helper calls:

| Helper | Count | First call sites | Nearby known table literals |
| --- | ---: | --- | --- |
| `0xB2D6` | 12 | 0x4927, 0x6366, 0x6ECA, 0x7270, 0x9BAE, 0xBA57, 0xBE90, 0xC2BE, 0xD131, 0xD13D, 0xD149, 0xD15A | 0x8318 at 0x6356, 0x9187 at 0x6361, 0x9291 at 0x6352, 0x85BA at 0x6EC0, 0x87B1 at 0x7265, 0x8889 at 0x727A, 0x869A at 0x9BA4, 0x8A27 at 0xBA62, 0x888E at 0xBE85, 0x8970 at 0xBE98, 0x8E18 at 0xBE86, 0x9073 at 0xC2B4 |
| `0xB2AB` | 53 | 0x4353, 0x43A3, 0x44B4, 0x4599, 0x45BF, 0x46EB, 0x48FF, 0x49B0, 0x49C1, 0x560F, 0x5618, 0x575F | 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8DD9 at 0x44AF, 0x8E0D at 0x4585, 0x8E18 at 0x458E, 0x8C61 at 0x45BA, 0x87A6 at 0x46D8, 0x8A69 at 0x4905, 0x8B41 at 0x490D, 0x8C19 at 0x48FA |
| `0xB383` | 7 | 0x41E9, 0x4349, 0x4399, 0x5CFC, 0x5D81, 0x6354, 0xC289 | 0x9291 at 0x41E1, 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8318 at 0x5CFE, 0x92CF at 0x5D01, 0x92D9 at 0x5CF7, 0x8318 at 0x5D83, 0x92CF at 0x5D7C, 0x92D9 at 0x5D86, 0x8318 at 0x6356 |
| `0xB3B9` | 1 | 0xD47C | 0x929E at 0xD46E |

### `xantia_607c`

Most common extended JSR targets:

| Target | Count |
| --- | ---: |
| `0xB023` | 50 |
| `0x5573` | 32 |
| `0x5586` | 26 |
| `0x5984` | 18 |
| `0x5A14` | 18 |
| `0xBDB5` | 11 |
| `0xB04E` | 10 |
| `0xE7EF` | 9 |
| `0xB16E` | 8 |
| `0xB0FB` | 8 |
| `0xAFE6` | 8 |
| `0xDE5B` | 8 |
| `0xB1A7` | 7 |
| `0x4CAF` | 7 |
| `0xB2CB` | 7 |
| `0xB518` | 7 |
| `0x6A6C` | 6 |
| `0x4BCB` | 5 |
| `0x6719` | 5 |
| `0x7D0E` | 5 |

Focused helper calls:

| Helper | Count | First call sites | Nearby known table literals |
| --- | ---: | --- | --- |
| `0xB2CB` | 7 | 0x5028, 0x50F2, 0x5283, 0x5365, 0x54A1, 0x9641, 0x96E1 | 0x8508 at 0x5270 |
| `0xB349` | 4 | 0x4FF6, 0x96B0, 0xB88D, 0xD973 | 0x8689 at 0x4FF9 |

### `peug_106rally_org`

Most common extended JSR targets:

| Target | Count |
| --- | ---: |
| `0xB2AB` | 53 |
| `0x54EB` | 32 |
| `0x54FE` | 26 |
| `0x58F2` | 18 |
| `0x5982` | 18 |
| `0xB2D6` | 12 |
| `0xCAC5` | 10 |
| `0xB3F6` | 9 |
| `0xE6DA` | 9 |
| `0xEFC0` | 9 |
| `0xB26E` | 8 |
| `0xDD57` | 8 |
| `0xB42F` | 7 |
| `0xB383` | 7 |
| `0x4C36` | 7 |
| `0xBD6E` | 7 |
| `0x69CF` | 6 |
| `0x4B52` | 5 |
| `0x6E18` | 5 |
| `0x667C` | 5 |

Focused helper calls:

| Helper | Count | First call sites | Nearby known table literals |
| --- | ---: | --- | --- |
| `0xB2D6` | 12 | 0x4927, 0x6366, 0x6ECA, 0x7270, 0x9BAE, 0xBA57, 0xBE90, 0xC2BE, 0xD131, 0xD13D, 0xD149, 0xD15A | 0x8318 at 0x6356, 0x9187 at 0x6361, 0x9291 at 0x6352, 0x85BA at 0x6EC0, 0x87B1 at 0x7265, 0x8889 at 0x727A, 0x869A at 0x9BA4, 0x8A27 at 0xBA62, 0x888E at 0xBE85, 0x8970 at 0xBE98, 0x8E18 at 0xBE86, 0x9073 at 0xC2B4 |
| `0xB2AB` | 53 | 0x4353, 0x43A3, 0x44B4, 0x4599, 0x45BF, 0x46EB, 0x48FF, 0x49B0, 0x49C1, 0x560F, 0x5618, 0x575F | 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8DD9 at 0x44AF, 0x8E0D at 0x4585, 0x8E18 at 0x458E, 0x8C61 at 0x45BA, 0x87A6 at 0x46D8, 0x8A69 at 0x4905, 0x8B41 at 0x490D, 0x8C19 at 0x48FA |
| `0xB383` | 7 | 0x41E9, 0x4349, 0x4399, 0x5CFC, 0x5D81, 0x6354, 0xC289 | 0x9291 at 0x41E1, 0x92CF at 0x4341, 0x400E at 0x4351, 0x92D9 at 0x4391, 0x400E at 0x43A1, 0x8318 at 0x5CFE, 0x92CF at 0x5D01, 0x92D9 at 0x5CF7, 0x8318 at 0x5D83, 0x92CF at 0x5D7C, 0x92D9 at 0x5D86, 0x8318 at 0x6356 |
| `0xB3B9` | 1 | 0xD47C | 0x929E at 0xD46E |

### `rally13_ori`

Most common extended JSR targets:

| Target | Count |
| --- | ---: |
| `0xB251` | 56 |
| `0x55B9` | 32 |
| `0x55CC` | 26 |
| `0x5A00` | 18 |
| `0x5A90` | 18 |
| `0xB27C` | 12 |
| `0xBEF9` | 11 |
| `0xB39C` | 9 |
| `0xEC4A` | 9 |
| `0xB214` | 8 |
| `0xE259` | 8 |
| `0xB3D5` | 7 |
| `0xB329` | 7 |
| `0x4CF7` | 7 |
| `0xBDDB` | 7 |
| `0x6AF1` | 6 |
| `0x4C16` | 5 |
| `0xDB18` | 5 |
| `0x679E` | 5 |
| `0x9CC9` | 5 |

Focused helper calls:

| Helper | Count | First call sites | Nearby known table literals |
| --- | ---: | --- | --- |
| `0xB2CB` | 0 | - | - |
| `0xB349` | 0 | - | - |

## RAM / Register Reference Scan

### `peugeot_stock`

| Address | Count | Operations | First sites |
| --- | ---: | --- | --- |
| `0x0060` | 1 | LDY imm:1 | 0xCB46 |
| `0x0069` | 6 | LDY imm:3, LDAA dir:2, CMPA dir:1 | 0x63DD, 0xCB50, 0xCC21, 0xD89E, 0xD8FE, 0xD910 |
| `0x005D` | 14 | LDAA dir:4, CMPA dir:3, STAA dir:3, STAB dir:2, INC ext:1, DEC ext:1 | 0x56BD, 0x63AA, 0x642C, 0x643F, 0x6CD4, 0x6DB5, 0xC1B1, 0xC1C6, 0xC6FD, 0xC787 |
| `0x005E` | 12 | STAA dir:3, LDAA dir:2, LDAB dir:2, CMPA dir:1, INC ext:1, DEC ext:1, STAB dir:1, CLR ext:1 | 0x6020, 0x639B, 0x642F, 0x6435, 0x643B, 0x6442, 0x6446, 0x644D, 0xC9EE, 0xCA91 |
| `0x005F` | 8 | STAB dir:2, STAA dir:1, LDX dir:1, CLR ext:1, LDAA dir:1, LDAB dir:1, LDD dir:1 | 0x63A8, 0x6423, 0x6CC7, 0xA2BE, 0xCA10, 0xCB0D, 0xD14B, 0xD6E1 |
| `0x00B6` | 20 | LDAA dir:6, STAB dir:3, STAA dir:2, ADDD dir:2, LDD dir:2, CMPA dir:1, STX ext:1, STX dir:1, LDAB dir:1, SUBD dir:1 | 0x41E2, 0x4424, 0x46D0, 0x48AA, 0x67F1, 0x96D7, 0x9733, 0xB0F0, 0xB13C, 0xB160 |
| `0x00BC` | 24 | STD dir:11, SUBD dir:6, LDD dir:5, ADDD dir:2 | 0x6F6F, 0x6F84, 0x6F89, 0x6F91, 0x6F9F, 0x6FA6, 0x6FF4, 0x7014, 0x702C, 0x7032 |
| `0x00BF` | 7 | LDD dir:3, SUBD dir:2, STD dir:2 | 0x6E9A, 0x6F7D, 0x6F86, 0x6F9D, 0x721D, 0xD5D5, 0xD5FE |
| `0x00C1` | 39 | STD dir:14, LDD dir:8, LDAA dir:6, ADDD dir:5, SUBD dir:4, CMPB dir:1, LDX dir:1 | 0x58DA, 0x6E9E, 0x6ED6, 0x6EDD, 0x6EE8, 0x9989, 0xAE2B, 0xE5F1, 0xE605, 0xE611 |
| `0x00C3` | 11 | LDD dir:5, STD dir:4, STX dir:2 | 0x6EEA, 0x6F6C, 0x6F73, 0x6FA3, 0x7010, 0x7029, 0x79B5, 0x9B46, 0xDFC8, 0xE6D3 |
| `0x00C5` | 11 | STAA dir:4, LDAA dir:4, STD dir:2, LDAB dir:1 | 0x9676, 0xE647, 0xE7D7, 0xE9C7, 0xEA21, 0xEA26, 0xEA49, 0xEA78, 0xEA7D, 0xEA8B |
| `0x00C6` | 10 | LDAA dir:2, LDX dir:2, CLR ext:2, SUBD dir:1, STX dir:1, ADDD dir:1, LDAB dir:1 | 0x5C55, 0x63EE, 0xA2B1, 0xA2D1, 0xA52F, 0xA53B, 0xE7D9, 0xE9C9, 0xEA43, 0xEA6E |
| `0x00CC` | 13 | LDAA dir:7, LDD dir:2, STD dir:2, CMPB dir:1, ADDD dir:1 | 0x43C7, 0x43D5, 0x43F3, 0x6084, 0x60DA, 0x80EA, 0x9387, 0x93A9, 0x93E6, 0x945D |
| `0x00CE` | 19 | LDD dir:12, LDX dir:2, ADDD dir:2, STX dir:1, STD dir:1, CPX dir:1 | 0x4073, 0x409C, 0x412B, 0x41A1, 0x42E1, 0x45F3, 0x4FC1, 0x5E5E, 0x5E7C, 0x97E7 |
| `0x00D0` | 22 | LDAA dir:14, LDAB dir:4, STAB dir:2, CMPA dir:1, STX dir:1 | 0x574A, 0x57BD, 0x5E5C, 0x5E77, 0x5F07, 0x5FAA, 0x8073, 0x96DE, 0x96F7, 0x97F4 |
| `0x100B` | 3 | STAA ext:3 | 0x75B7, 0xB549, 0xD346 |
| `0x100E` | 30 | LDD ext:28, ADDD ext:2 | 0x4FA7, 0x4FD3, 0x51BE, 0x53A3, 0x5880, 0x6CEC, 0x6EF5, 0x6FC8, 0x705F, 0x71D0 |
| `0x1016` | 3 | STD ext:2, LDD ext:1 | 0x4E13, 0x6EFB, 0x6FC5 |
| `0x1018` | 18 | STD ext:13, LDD ext:2, ADDD ext:2, SUBD ext:1 | 0x75CF, 0x75E3, 0x7984, 0x79B9, 0x79FE, 0x7A24, 0x7C29, 0x7C52, 0x7F52, 0x7F57 |
| `0x101A` | 13 | STD ext:10, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x6CEF, 0x7085, 0x7096, 0x70C1, 0x70D4, 0x70D7, 0x70E8, 0x70F9, 0x71D3, 0xA939 |
| `0x101C` | 9 | STD ext:7, LDD ext:2 | 0x4FAD, 0x4FD9, 0x503F, 0x5045, 0xBC6A, 0xBC8C, 0xBCAB, 0xBCB4, 0xDEFD |
| `0x1020` | 8 | STAA ext:4, CMPB ext:1, SUBD ext:1, LDAA ext:1, CLR ext:1 | 0x4C2B, 0x5BB3, 0x6BD5, 0x6D3C, 0x6DB2, 0xB544, 0xB951, 0xD82C |
| `0x1022` | 5 | CLR ext:3, LDAA ext:1, STAA ext:1 | 0x4F1D, 0x6BCF, 0x6BF0, 0x6DAC, 0xD82F |
| `0x1023` | 39 | STAA ext:23, STAB ext:11, LDAA ext:5 | 0x4FB2, 0x4FDE, 0x504A, 0x50D6, 0x512C, 0x5145, 0x5183, 0x519A, 0x51A7, 0x5259 |
| `0x1028` | 4 | STAA ext:4 | 0x9EF4, 0x9EFC, 0xA01B, 0xA01E |
| `0x1029` | 20 | LDAA ext:18, LDAB ext:2 | 0x9EEC, 0x9F06, 0x9F1C, 0x9F34, 0x9F44, 0x9F52, 0x9F60, 0x9F6E, 0x9F7C, 0x9F8A |
| `0x102A` | 19 | STAB ext:13, STAA ext:3, LDAA ext:2, CMPA ext:1 | 0x9EEF, 0x9F37, 0x9F47, 0x9F55, 0x9F63, 0x9F71, 0x9F7F, 0x9F8D, 0x9F9B, 0x9FAA |
| `0x1030` | 16 | STAA ext:16 | 0x40E8, 0x4133, 0x51EF, 0x52D1, 0xB82C, 0xB8C0, 0xBC23, 0xBCD0, 0xDA6B, 0xDA88 |
| `0x1031` | 8 | LDAA ext:6, LDY imm:2 | 0x401E, 0x4113, 0x53CC, 0xBC2B, 0xBCD8, 0xDAB8, 0xDE48, 0xE116 |
| `0x1032` | 5 | LDAA ext:4, LDY imm:1 | 0x403B, 0x4140, 0x52A8, 0x53D9, 0xDE31 |
| `0x1033` | 7 | LDAA ext:6, LDY imm:1 | 0x4024, 0x4041, 0x4119, 0x4146, 0x52B5, 0x53E6, 0xDE17 |
| `0x1034` | 7 | LDAA ext:6, LDY imm:1 | 0x402D, 0x405A, 0x411F, 0x414C, 0x52C2, 0x53F3, 0xDE5F |
| `0x1050` | 40 | STAA ext:24, LDAA ext:15, CLR ext:1 | 0x4F3E, 0x50E3, 0x50E8, 0x50EB, 0x50F0, 0x5148, 0x514D, 0x51AE, 0x51B3, 0x51C3 |
| `0x2001` | 8 | STX ext:5, STAA ext:2, STAB ext:1 | 0x4687, 0x4693, 0x476D, 0x5270, 0x5482, 0x5C4F, 0x5ECE, 0xD7BC |
| `0x2002` | 4 | STX ext:3, STAA ext:1 | 0x4892, 0x7E44, 0xA9C1, 0xC710 |
| `0x2007` | 5 | LDAA ext:3, STAA ext:2 | 0x4044, 0x4149, 0x5E97, 0x5EEC, 0x96D3 |
| `0x2008` | 7 | LDAA ext:4, STAA ext:2, STX ext:1 | 0x4021, 0x40CE, 0x4116, 0x4322, 0x5C19, 0x96E9, 0xBB8A |
| `0x2009` | 6 | LDAA ext:3, STAA ext:2, CLR ext:1 | 0x40D7, 0x432B, 0x5BA0, 0x5BC4, 0x5CE9, 0xC61B |
| `0x200A` | 7 | LDAA ext:4, STAA ext:3 | 0x4030, 0x40B0, 0x4123, 0x4372, 0x5D1F, 0x6D25, 0x96F3 |
| `0x200B` | 5 | STAA ext:2, LDD ext:1, LDAA ext:1, STX ext:1 | 0x40B9, 0x437B, 0x47F1, 0x5D5D, 0x9554 |
| `0x200C` | 4 | STAA ext:2, LDAA ext:2 | 0x403E, 0x4143, 0x5B1B, 0x5B8E |
| `0x200D` | 4 | STAA ext:2, LDAA ext:1, CMPA ext:1 | 0x4027, 0x411C, 0x415D, 0x6933 |
| `0x200E` | 7 | LDAA ext:5, STAA ext:2 | 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x5DA8, 0x96DA |
| `0x2013` | 11 | CMPA ext:5, STAA ext:3, CMPB ext:2, LDAB ext:1 | 0x404D, 0x4128, 0x5F20, 0x9792, 0x97AF, 0x98FF, 0x997E, 0x99A9, 0x99EB, 0x9CC4 |
| `0x202B` | 10 | LDAA ext:5, STAA ext:2, LDAB ext:2, STAB ext:1 | 0x9714, 0x9728, 0xBE5F, 0xBED8, 0xBEE7, 0xCB89, 0xCE67, 0xCF0B, 0xE8E9, 0xE8F9 |
| `0x202C` | 2 | STAA ext:1, CLR ext:1 | 0xBEEF, 0xBEF7 |
| `0x2030` | 5 | LDAA ext:2, STAA ext:1, STAB ext:1, LDAB ext:1 | 0xC36C, 0xD6BB, 0xD7C0, 0xEACF, 0xEB16 |
| `0x2034` | 8 | LDD ext:7, STD ext:1 | 0x41AD, 0x4913, 0x495F, 0x6EA9, 0x7258, 0xBA34, 0xBE78, 0xE3CF |
| `0x2036` | 19 | LDD ext:17, STD ext:2 | 0x45BC, 0x48FC, 0x4919, 0x49AD, 0x635A, 0x6EB9, 0x725E, 0x9B9D, 0x9D13, 0xBE7E |
| `0x2038` | 5 | LDD ext:3, STD ext:1, LDAB ext:1 | 0x43B1, 0x4E49, 0x5C9F, 0xE84F, 0xE870 |
| `0x203A` | 2 | STD ext:1, LDD ext:1 | 0x43B5, 0x4953 |
| `0x203C` | 12 | LDD ext:9, LDAB ext:2, STD ext:1 | 0x4361, 0x44B1, 0x55F8, 0x720F, 0x72BC, 0x9B61, 0xC2A2, 0xC819, 0xC824, 0xE7F0 |
| `0x203E` | 17 | LDD ext:16, STD ext:1 | 0x4365, 0x4947, 0x49BE, 0x7129, 0x7140, 0x716B, 0xBE9A, 0xC01E, 0xC11A, 0xC127 |
| `0x2040` | 6 | LDD ext:5, STD ext:1 | 0x4400, 0x9525, 0xD5DF, 0xD5EF, 0xD6F5, 0xE83E |
| `0x2042` | 6 | LDD ext:5, STD ext:1 | 0x41EC, 0x5758, 0x97DA, 0xE3FD, 0xE4FF, 0xE97A |
| `0x2049` | 4 | STAA ext:2, CPX ext:1, LDAA ext:1 | 0x6F70, 0xE6A6, 0xE79E, 0xE848 |
| `0x204A` | 3 | STAA ext:2, LDAB ext:1 | 0xE786, 0xE869, 0xE928 |
| `0x204B` | 2 | LDD ext:1, STD ext:1 | 0xE5E8, 0xE959 |
| `0x204D` | 3 | STAA ext:2, LDAB ext:1 | 0xE78C, 0xE88A, 0xE95D |
| `0x204E` | 3 | LDAB ext:2, STD ext:1 | 0xE5FF, 0xE607, 0xE96D |
| `0x204F` | 2 | LDAB ext:2 | 0xE5F3, 0xE613 |
| `0x2050` | 2 | STAA ext:1, LDAB ext:1 | 0xE7ED, 0xE935 |
| `0x2051` | 4 | STD ext:2, CPX ext:1, LDD ext:1 | 0x6582, 0x6F48, 0xE6A1, 0xE7AE |
| `0x2053` | 5 | LDAB ext:2, LDAA ext:1, STAB ext:1, STAA ext:1 | 0xCC57, 0xE5E5, 0xE684, 0xE68A, 0xE7B4 |
| `0x2055` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xE654, 0xE7A6, 0xEAA7, 0xEAB5, 0xEAC4 |
| `0x2057` | 4 | STD ext:3, ADDD ext:1 | 0xE659, 0xE7A9, 0xEB02, 0xEB0E |
| `0x2059` | 15 | LDAA ext:8, STAA ext:4, LDAB ext:2, STAB ext:1 | 0x5B7D, 0x5B95, 0x7101, 0x713D, 0x729F, 0x9818, 0x999A, 0x9A9B, 0x9CA5, 0xBE14 |
| `0x2060` | 4 | STAA ext:3, LDAA ext:1 | 0x7153, 0xE9F9, 0xE9FC, 0xEA02 |
| `0x2062` | 3 | STAA ext:2, LDAA ext:1 | 0xE792, 0xE9D5, 0xE9DB |
| `0x2084` | 2 | STAA ext:2 | 0xE3E1, 0xE798 |
| `0x2085` | 3 | STAA ext:2, LDAA ext:1 | 0xE63B, 0xE79B, 0xE83B |
| `0x2086` | 6 | STD ext:3, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x706C, 0x707F, 0x70A4, 0xD5D7, 0xD60A, 0xD6DC |
| `0x2090` | 10 | LDAA ext:7, STAA ext:2, STAB ext:1 | 0x5685, 0xC03D, 0xC0E4, 0xC19E, 0xC1AA, 0xC1DF, 0xC86C, 0xC931, 0xC97C, 0xCAFE |
| `0x2091` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xC0F6, 0xC7AC, 0xC7AF, 0xC7C1, 0xC807 |
| `0x2093` | 1 | STAA ext:1 | 0xC03A |
| `0x2094` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC588, 0xC734, 0xCB4D |
| `0x2095` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC594, 0xC744, 0xCB57 |
| `0x2096` | 9 | LDAA ext:5, STAA ext:2, DEC ext:1, TST ext:1 | 0xC08B, 0xC0C0, 0xC0F3, 0xC124, 0xC1EE, 0xC1FE, 0xC361, 0xC5A8, 0xC8E7 |
| `0x2097` | 3 | STAA ext:2, TST ext:1 | 0x566C, 0x56F7, 0xC5C2 |
| `0x2098` | 11 | LDAA ext:7, INC ext:1, DEC ext:1, TST ext:1, STAA ext:1 | 0xC0CF, 0xC0FF, 0xC34D, 0xC398, 0xC3BB, 0xC3CA, 0xC3EA, 0xC400, 0xC43D, 0xC5CF |
| `0x2099` | 2 | STAA ext:1, TST ext:1 | 0xC227, 0xC5B5 |
| `0x209A` | 5 | STAA ext:3, LDAA ext:1, TST ext:1 | 0xC255, 0xC263, 0xC32F, 0xC5DC, 0xCAE3 |
| `0x209B` | 16 | STAA ext:9, LDAA ext:4, TST ext:1, DEC ext:1, INC ext:1 | 0xC0EA, 0xC187, 0xC457, 0xC4A3, 0xC4BB, 0xC4F2, 0xC510, 0xC53A, 0xC56B, 0xC5E9 |
| `0x209C` | 4 | LDD ext:2, STD ext:1, ADDD ext:1 | 0xC6F1, 0xC702, 0xC8A8, 0xC8B5 |
| `0x209E` | 4 | STD ext:3, LDD ext:1 | 0x6394, 0xC199, 0xC6E5, 0xC6E8 |
| `0x20A0` | 3 | STD ext:2, ADDD ext:1 | 0xC605, 0xC6C9, 0xC6EB |
| `0x20A2` | 3 | LDAA ext:2, STAB ext:1 | 0xC1BD, 0xC5F6, 0xC77E |
| `0x20A4` | 12 | STAA ext:5, LDAA ext:3, STAB ext:3, CLR ext:1 | 0x56BA, 0x6CD8, 0x6DB7, 0x96EC, 0x975C, 0xC1C3, 0xC5F9, 0xC731, 0xC784, 0xC9FA |
| `0x20A6` | 7 | STAA ext:3, LDAB ext:2, STD ext:1, STAB ext:1 | 0xC106, 0xC1C0, 0xC705, 0xC71A, 0xC72E, 0xC781, 0xC79A |
| `0x20A8` | 20 | LDAA ext:9, LDAB ext:5, CMPA ext:5, STAA ext:1 | 0x4A3A, 0x4A51, 0x5626, 0x984A, 0x9887, 0x998E, 0x9A60, 0x9A7A, 0x9ABB, 0xC086 |
| `0x20B1` | 9 | TST ext:5, LDAA ext:3, STAA ext:1 | 0x460A, 0x4907, 0xBF0A, 0xBF30, 0xCBA9, 0xCBFC, 0xE39E, 0xE3C0, 0xE942 |
| `0x20B9` | 15 | STD ext:6, CMPA ext:2, LDD ext:2, SUBD ext:2, LDAB ext:2, LDAA ext:1 | 0x61CE, 0x61D6, 0xCBB1, 0xCBC7, 0xCC98, 0xCDBC, 0xCDC8, 0xCDD3, 0xCDDF, 0xCDEA |
| `0x20BC` | 2 | STAA ext:2 | 0xBAB1, 0xBBEC |
| `0x20BD` | 1 | STAB ext:1 | 0xBB3A |
| `0x20BE` | 1 | STAB ext:1 | 0xBAE3 |
| `0x20BF` | 1 | STAB ext:1 | 0xBB00 |
| `0x20C0` | 1 | STAB ext:1 | 0xBB1D |
| `0x20C1` | 5 | STAA ext:3, LDAA ext:1, LDAB ext:1 | 0xAFF8, 0xAFFD, 0xB003, 0xBB6B, 0xBBC8 |
| `0x20C2` | 2 | STAA ext:2 | 0xBB37, 0xBC02 |
| `0x20C3` | 2 | STAA ext:2 | 0xBAE0, 0xBBF9 |
| `0x20C4` | 2 | STAA ext:2 | 0xBAFD, 0xBBFC |
| `0x20C5` | 2 | STAA ext:2 | 0xBB1A, 0xBBFF |
| `0x20D3` | 7 | LDAA ext:3, STAA ext:3, LDAB ext:1 | 0xB087, 0xB0EE, 0xB134, 0xB13A, 0xB1AC, 0xB1C8, 0xBBB3 |
| `0x20D4` | 7 | LDAA ext:5, STAA ext:2 | 0xB0FF, 0xB156, 0xB16F, 0xB188, 0xB1A1, 0xBA8E, 0xBBE0 |
| `0x20D5` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB198, 0xB1A4, 0xB1A9 |
| `0x20D6` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB14D, 0xB159, 0xB15E |
| `0x20D7` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB166, 0xB172, 0xB177 |
| `0x20D8` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB17F, 0xB18B, 0xB190 |
| `0x20D9` | 5 | LDAA ext:2, STAA ext:2, STX ext:1 | 0x9E48, 0xB193, 0xB19E, 0xB1C0, 0xBBB0 |
| `0x20DA` | 4 | LDAA ext:2, STAA ext:2 | 0xB148, 0xB153, 0xB1B1, 0xBBA7 |
| `0x20DB` | 4 | LDAA ext:2, STAA ext:2 | 0xB161, 0xB16C, 0xB1B6, 0xBBAA |
| `0x20DC` | 4 | LDAA ext:2, STAA ext:2 | 0xB17A, 0xB185, 0xB1BB, 0xBBAD |
| `0x20DD` | 2 | STAA ext:2 | 0xBA67, 0xBBF2 |
| `0x20DE` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4858, 0xB24D, 0xB269, 0xBBBF, 0xE5B3, 0xE5B8 |
| `0x20DF` | 6 | STAA ext:3, LDAB ext:1, ADDD ext:1, LDAA ext:1 | 0x4849, 0xA52D, 0xB1E1, 0xB260, 0xBBB6, 0xE5A0 |
| `0x20E0` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x484E, 0xB205, 0xB263, 0xBBB9, 0xE5A3, 0xE5A8 |
| `0x20E1` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4853, 0xB229, 0xB266, 0xBBBC, 0xE5AB, 0xE5B0 |
| `0x20E2` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48D2, 0x7D5D, 0x7D66, 0x95E8, 0xB258 |
| `0x20E3` | 7 | LDAB ext:2, LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48B4, 0x7A8E, 0x7B16, 0x7CFD, 0x7D06, 0x95DF, 0xB1EC |
| `0x20E4` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48BE, 0x7D3D, 0x7D46, 0x95E2, 0xB210 |
| `0x20E5` | 6 | LDAA ext:2, STAA ext:2, STAB ext:1, LDAB ext:1 | 0x48C8, 0x7A89, 0x7D1D, 0x7D26, 0x95E5, 0xB234 |
| `0x20E6` | 13 | LDAA ext:6, CMPA ext:5, STAA ext:2 | 0xB115, 0xB11A, 0xB1D9, 0xB1DE, 0xB1FD, 0xB202, 0xB221, 0xB226, 0xB245, 0xB24A |
| `0x20E7` | 3 | STAA ext:2, LDAA ext:1 | 0xBA74, 0xBBD4, 0xBD1E |
| `0x20E8` | 4 | STAA ext:2, LDAB ext:2 | 0xBA81, 0xBBDA, 0xBD40, 0xBD46 |
| `0x20E9` | 23 | LDAA ext:14, LDAB ext:6, STAA ext:3 | 0x7563, 0x7576, 0x75EA, 0x75FD, 0x7719, 0x7723, 0x7730, 0x7773, 0x778A, 0x7851 |
| `0x20EB` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9A, 0xBC67, 0xBC7A, 0xBD39 |
| `0x20ED` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9D, 0xBCB1, 0xBCC1, 0xBD4F |
| `0x2132` | 6 | STD ext:3, LDD ext:2, SUBD ext:1 | 0x4427, 0x4653, 0x465E, 0x4675, 0x467F, 0x4690 |
| `0x2134` | 2 | STD ext:2 | 0x442B, 0x49C5 |
| `0x2147` | 21 | STD ext:10, ADDD ext:6, LDY ext:1, LDX ext:1, STY ext:1, STX ext:1, LDD ext:1 | 0x4481, 0x454E, 0x4551, 0x45C4, 0x45DB, 0x45DC, 0x45E1, 0x45E2, 0x4602, 0x4605 |
| `0x2148` | 6 | LDAA ext:3, STAA ext:2, STAB ext:1 | 0x468C, 0x4756, 0x476A, 0x4862, 0x4874, 0x4936 |
| `0x2149` | 4 | STAB ext:1, TST ext:1, LDAA ext:1, DEC ext:1 | 0x46E5, 0x4702, 0x4772, 0x4777 |
| `0x214C` | 3 | LDAA ext:2, STAA ext:1 | 0x48DD, 0x48E6, 0x496D |
| `0x2122` | 3 | STD ext:2, LDAA ext:1 | 0x40E1, 0x433D, 0x4346 |
| `0x2124` | 3 | STD ext:2, LDAA ext:1 | 0x40C3, 0x438D, 0x4396 |
| `0x21C6` | 5 | STD ext:2, LDD ext:1, SUBD ext:1, STX ext:1 | 0x6FC0, 0x6FD1, 0x724C, 0x7298, 0x72A9 |
| `0x21C8` | 9 | LDD ext:4, STD ext:3, SUBD ext:2 | 0x6F65, 0x6FB0, 0x7024, 0x7075, 0x708A, 0x709C, 0x70CD, 0x70DF, 0x70F0 |
| `0x21CB` | 6 | ADDD ext:4, STD ext:1, SUBD ext:1 | 0x7062, 0x707C, 0x7090, 0x70C4, 0x70E5, 0x70F6 |
| `0x21CD` | 3 | STD ext:2, SUBD ext:1 | 0x704A, 0x70A7, 0x70ED |
| `0x21CF` | 4 | STD ext:2, LDD ext:1, ADDD ext:1 | 0x6FF1, 0x7034, 0x712C, 0x7219 |
| `0x2312` | 3 | LDY imm:2, STAA ext:1 | 0x7583, 0x7CF9, 0x9587 |
| `0x231E` | 3 | LDY imm:2, STAA ext:1 | 0x7570, 0x7D39, 0x958A |
| `0x232A` | 3 | LDY imm:2, STAA ext:1 | 0x757D, 0x7D19, 0x958D |
| `0x2336` | 3 | LDY imm:2, STAA ext:1 | 0x756A, 0x7D59, 0x9590 |
| `0x2348` | 14 | STD ext:6, LDD ext:6, ADDD ext:2 | 0x7CF6, 0x7D16, 0x7D36, 0x7D56, 0x7D74, 0x7D7E, 0x7DF4, 0x7E04, 0x7E55, 0x7E60 |
| `0x234A` | 9 | DEC ext:3, STD ext:2, STAA ext:1, CLR ext:1, ADDD ext:1, SUBD ext:1 | 0x7D84, 0x7DA9, 0x7DAC, 0x7DC3, 0x7E01, 0x7E12, 0x7E1D, 0x7E52, 0x7E58 |
| `0x234C` | 2 | STAA ext:1, DEC ext:1 | 0x7E4B, 0x7E5B |
| `0x234D` | 5 | STD ext:3, LDX ext:1, LDD ext:1 | 0x7DF0, 0x7DFD, 0x7E29, 0x7E3A, 0x7E68 |
| `0x2354` | 4 | LDAB ext:2, LDAA ext:1, STAB ext:1 | 0x7A07, 0x7A0F, 0x7F0C, 0x7F2E |
| `0x235C` | 13 | STD ext:2, SUBD ext:2, LDX ext:2, INC ext:2, LDD ext:1, STX ext:1, CLR ext:1, TST ext:1, DEC ext:1 | 0x78C9, 0x78EF, 0x7912, 0x7924, 0x7945, 0x7998, 0x7EBF, 0x7ED2, 0x7EDD, 0x7EF5 |
| `0x235E` | 4 | STX ext:1, LDAB ext:1, STD ext:1, ADDD ext:1 | 0x790F, 0x796C, 0x7EE8, 0x7EF2 |
| `0x2369` | 3 | STD ext:2, SUBD ext:1 | 0x7E88, 0x7EAB, 0x7F02 |
| `0x2376` | 2 | STD ext:1, LDX ext:1 | 0x7DE1, 0x7E6E |
| `0x2380` | 8 | LDD ext:4, STD ext:3, ADDD ext:1 | 0x7763, 0x7B74, 0x7B8B, 0x7D7A, 0x7DED, 0x7E4E, 0x7F08, 0x7F14 |
| `0x2382` | 7 | STX ext:3, LDD ext:2, LDAB ext:1, ADDD ext:1 | 0x7766, 0x7B77, 0x7B8E, 0x7DE4, 0x7ECD, 0x7EE4, 0x7EFA |
| `0x242B` | 3 | LDD ext:1, SUBD ext:1, STD ext:1 | 0xBC64, 0xBC76, 0xBD1B |
| `0x242D` | 2 | STD ext:1, SUBD ext:1 | 0xBCAE, 0xBCBD |
| `0x242F` | 5 | STD ext:2, ADDD ext:2, LDAA ext:1 | 0xBAB5, 0xBABE, 0xBAC6, 0xBB49, 0xBB53 |
| `0x2431` | 2 | STAA ext:2 | 0xBB68, 0xBB79 |
| `0x243C` | 10 | STD ext:2, CMPA ext:2, INC ext:1, STAA ext:1, LDD ext:1, CPX ext:1, STX ext:1, LDAA ext:1 | 0xC260, 0xC2C1, 0xC2D9, 0xC2DC, 0xC2E1, 0xC2EE, 0xC2F9, 0xC2FC, 0xC301, 0xC304 |
| `0x243E` | 3 | STAA ext:1, LDAA ext:1, LDAB ext:1 | 0xC2AC, 0xC31A, 0xC31F |
| `0x243F` | 6 | LDAA ext:4, STAA ext:2 | 0xC0A3, 0xC0B5, 0xC131, 0xC1E9, 0xC938, 0xC93E |
| `0x244C` | 2 | STAA ext:1, LDAA ext:1 | 0xC13E, 0xC1F8 |
| `0x245E` | 3 | STAA ext:2, DEC ext:1 | 0xC141, 0xC1F3, 0xC1FB |
| `0x2462` | 6 | LDAA ext:3, STAA ext:2, DEC ext:1 | 0xC4CC, 0xC4D1, 0xC546, 0xC54B, 0xC941, 0xC946 |
| `0x2463` | 6 | TST ext:2, DEC ext:2, STAA ext:2 | 0xC099, 0xC09E, 0xC0D8, 0xC0DD, 0xC110, 0xC190 |
| `0x2464` | 4 | LDAA ext:2, STAA ext:2 | 0xC1B8, 0xC1DC, 0xC927, 0xC92E |
| `0x2465` | 4 | STAA ext:2, LDAA ext:2 | 0xC1D4, 0xC779, 0xC918, 0xC924 |
| `0x249B` | 6 | STD ext:4, LDD ext:1, SUBD ext:1 | 0xCBB4, 0xCBCA, 0xCC9B, 0xCE04, 0xCE14, 0xCE5B |
| `0x24AB` | 2 | LDAA ext:1, STAA ext:1 | 0xCD51, 0xD134 |
| `0x24AC` | 2 | LDAA ext:1, STAA ext:1 | 0xCD04, 0xD140 |
| `0x24AD` | 2 | LDD ext:1, STD ext:1 | 0xCD0A, 0xD151 |
| `0x24AF` | 2 | LDAB ext:1, STAA ext:1 | 0xCD8C, 0xD15D |
| `0x24B0` | 6 | STD ext:4, ADDD ext:1, SUBD ext:1 | 0xCDB9, 0xCDC3, 0xCDCB, 0xCDDA, 0xCDE2, 0xCDFE |
| `0x2483` | 4 | STAB ext:1, LDAB ext:1, DEC ext:1, STAA ext:1 | 0xBEEA, 0xBEF2, 0xBEFC, 0xCB8C |
| `0x2484` | 3 | STAA ext:2, LDAB ext:1 | 0xBE93, 0xBEAF, 0xCB86 |
| `0x2486` | 2 | STAA ext:2 | 0xBEA0, 0xCB7D |
| `0x2488` | 1 | STAA ext:1 | 0xBECB |
| `0x248D` | 3 | STAA ext:2, LDAA ext:1 | 0xBF19, 0xBF20, 0xBF49 |
| `0x248E` | 2 | STAA ext:2 | 0xBF3F, 0xBF46 |
| `0x2584` | 3 | STD ext:2, SUBD ext:1 | 0xE4F9, 0xE58D, 0xE663 |
| `0x2590` | 3 | STD ext:2, ADDD ext:1 | 0xE3F4, 0xE4DB, 0xE65E |
| `0x2596` | 6 | ADDD ext:3, STD ext:2, SUBD ext:1 | 0xE780, 0xE903, 0xE913, 0xE921, 0xE924, 0xE92E |
| `0x25A3` | 6 | LDY imm:2, STD ext:2, ADDD ext:2 | 0xE84B, 0xE86C, 0xE931, 0xE93B, 0xE93F, 0xE953 |
| `0x2610` | 10 | STAB ext:4, LDAB ext:3, STX ext:2, CLR ext:1 | 0x4EDC, 0x6A37, 0x6B2C, 0x6B37, 0x6B46, 0x6B96, 0x6BA1, 0x6BB0, 0xCB10, 0xE948 |

### `peugeot_stok`

| Address | Count | Operations | First sites |
| --- | ---: | --- | --- |
| `0x0060` | 1 | LDY imm:1 | 0xCB46 |
| `0x0069` | 6 | LDY imm:3, LDAA dir:2, CMPA dir:1 | 0x63DD, 0xCB50, 0xCC21, 0xD89E, 0xD8FE, 0xD910 |
| `0x005D` | 14 | LDAA dir:4, CMPA dir:3, STAA dir:3, STAB dir:2, INC ext:1, DEC ext:1 | 0x56BD, 0x63AA, 0x642C, 0x643F, 0x6CD4, 0x6DB5, 0xC1B1, 0xC1C6, 0xC6FD, 0xC787 |
| `0x005E` | 12 | STAA dir:3, LDAA dir:2, LDAB dir:2, CMPA dir:1, INC ext:1, DEC ext:1, STAB dir:1, CLR ext:1 | 0x6020, 0x639B, 0x642F, 0x6435, 0x643B, 0x6442, 0x6446, 0x644D, 0xC9EE, 0xCA91 |
| `0x005F` | 8 | STAB dir:2, STAA dir:1, LDX dir:1, CLR ext:1, LDAA dir:1, LDAB dir:1, LDD dir:1 | 0x63A8, 0x6423, 0x6CC7, 0xA2BE, 0xCA10, 0xCB0D, 0xD14B, 0xD6E1 |
| `0x00B6` | 20 | LDAA dir:6, STAB dir:3, STAA dir:2, ADDD dir:2, LDD dir:2, CMPA dir:1, STX ext:1, STX dir:1, LDAB dir:1, SUBD dir:1 | 0x41E2, 0x4424, 0x46D0, 0x48AA, 0x67F1, 0x96D7, 0x9733, 0xB0F0, 0xB13C, 0xB160 |
| `0x00BC` | 24 | STD dir:11, SUBD dir:6, LDD dir:5, ADDD dir:2 | 0x6F6F, 0x6F84, 0x6F89, 0x6F91, 0x6F9F, 0x6FA6, 0x6FF4, 0x7014, 0x702C, 0x7032 |
| `0x00BF` | 7 | LDD dir:3, SUBD dir:2, STD dir:2 | 0x6E9A, 0x6F7D, 0x6F86, 0x6F9D, 0x721D, 0xD5D5, 0xD5FE |
| `0x00C1` | 39 | STD dir:14, LDD dir:8, LDAA dir:6, ADDD dir:5, SUBD dir:4, CMPB dir:1, LDX dir:1 | 0x58DA, 0x6E9E, 0x6ED6, 0x6EDD, 0x6EE8, 0x9989, 0xAE2B, 0xE5F1, 0xE605, 0xE611 |
| `0x00C3` | 11 | LDD dir:5, STD dir:4, STX dir:2 | 0x6EEA, 0x6F6C, 0x6F73, 0x6FA3, 0x7010, 0x7029, 0x79B5, 0x9B46, 0xDFC8, 0xE6D3 |
| `0x00C5` | 11 | STAA dir:4, LDAA dir:4, STD dir:2, LDAB dir:1 | 0x9676, 0xE647, 0xE7D7, 0xE9C7, 0xEA21, 0xEA26, 0xEA49, 0xEA78, 0xEA7D, 0xEA8B |
| `0x00C6` | 10 | LDAA dir:2, LDX dir:2, CLR ext:2, SUBD dir:1, STX dir:1, ADDD dir:1, LDAB dir:1 | 0x5C55, 0x63EE, 0xA2B1, 0xA2D1, 0xA52F, 0xA53B, 0xE7D9, 0xE9C9, 0xEA43, 0xEA6E |
| `0x00CC` | 13 | LDAA dir:7, LDD dir:2, STD dir:2, CMPB dir:1, ADDD dir:1 | 0x43C7, 0x43D5, 0x43F3, 0x6084, 0x60DA, 0x80EA, 0x9387, 0x93A9, 0x93E6, 0x945D |
| `0x00CE` | 19 | LDD dir:12, LDX dir:2, ADDD dir:2, STX dir:1, STD dir:1, CPX dir:1 | 0x4073, 0x409C, 0x412B, 0x41A1, 0x42E1, 0x45F3, 0x4FC1, 0x5E5E, 0x5E7C, 0x97E7 |
| `0x00D0` | 22 | LDAA dir:14, LDAB dir:4, STAB dir:2, CMPA dir:1, STX dir:1 | 0x574A, 0x57BD, 0x5E5C, 0x5E77, 0x5F07, 0x5FAA, 0x8073, 0x96DE, 0x96F7, 0x97F4 |
| `0x100B` | 3 | STAA ext:3 | 0x75B7, 0xB549, 0xD346 |
| `0x100E` | 30 | LDD ext:28, ADDD ext:2 | 0x4FA7, 0x4FD3, 0x51BE, 0x53A3, 0x5880, 0x6CEC, 0x6EF5, 0x6FC8, 0x705F, 0x71D0 |
| `0x1016` | 3 | STD ext:2, LDD ext:1 | 0x4E13, 0x6EFB, 0x6FC5 |
| `0x1018` | 18 | STD ext:13, LDD ext:2, ADDD ext:2, SUBD ext:1 | 0x75CF, 0x75E3, 0x7984, 0x79B9, 0x79FE, 0x7A24, 0x7C29, 0x7C52, 0x7F52, 0x7F57 |
| `0x101A` | 13 | STD ext:10, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x6CEF, 0x7085, 0x7096, 0x70C1, 0x70D4, 0x70D7, 0x70E8, 0x70F9, 0x71D3, 0xA939 |
| `0x101C` | 9 | STD ext:7, LDD ext:2 | 0x4FAD, 0x4FD9, 0x503F, 0x5045, 0xBC6A, 0xBC8C, 0xBCAB, 0xBCB4, 0xDEFD |
| `0x1020` | 8 | STAA ext:4, CMPB ext:1, SUBD ext:1, LDAA ext:1, CLR ext:1 | 0x4C2B, 0x5BB3, 0x6BD5, 0x6D3C, 0x6DB2, 0xB544, 0xB951, 0xD82C |
| `0x1022` | 5 | CLR ext:3, LDAA ext:1, STAA ext:1 | 0x4F1D, 0x6BCF, 0x6BF0, 0x6DAC, 0xD82F |
| `0x1023` | 39 | STAA ext:23, STAB ext:11, LDAA ext:5 | 0x4FB2, 0x4FDE, 0x504A, 0x50D6, 0x512C, 0x5145, 0x5183, 0x519A, 0x51A7, 0x5259 |
| `0x1028` | 4 | STAA ext:4 | 0x9EF4, 0x9EFC, 0xA01B, 0xA01E |
| `0x1029` | 20 | LDAA ext:18, LDAB ext:2 | 0x9EEC, 0x9F06, 0x9F1C, 0x9F34, 0x9F44, 0x9F52, 0x9F60, 0x9F6E, 0x9F7C, 0x9F8A |
| `0x102A` | 19 | STAB ext:13, STAA ext:3, LDAA ext:2, CMPA ext:1 | 0x9EEF, 0x9F37, 0x9F47, 0x9F55, 0x9F63, 0x9F71, 0x9F7F, 0x9F8D, 0x9F9B, 0x9FAA |
| `0x1030` | 16 | STAA ext:16 | 0x40E8, 0x4133, 0x51EF, 0x52D1, 0xB82C, 0xB8C0, 0xBC23, 0xBCD0, 0xDA6B, 0xDA88 |
| `0x1031` | 8 | LDAA ext:6, LDY imm:2 | 0x401E, 0x4113, 0x53CC, 0xBC2B, 0xBCD8, 0xDAB8, 0xDE48, 0xE116 |
| `0x1032` | 5 | LDAA ext:4, LDY imm:1 | 0x403B, 0x4140, 0x52A8, 0x53D9, 0xDE31 |
| `0x1033` | 7 | LDAA ext:6, LDY imm:1 | 0x4024, 0x4041, 0x4119, 0x4146, 0x52B5, 0x53E6, 0xDE17 |
| `0x1034` | 7 | LDAA ext:6, LDY imm:1 | 0x402D, 0x405A, 0x411F, 0x414C, 0x52C2, 0x53F3, 0xDE5F |
| `0x1050` | 40 | STAA ext:24, LDAA ext:15, CLR ext:1 | 0x4F3E, 0x50E3, 0x50E8, 0x50EB, 0x50F0, 0x5148, 0x514D, 0x51AE, 0x51B3, 0x51C3 |
| `0x2001` | 8 | STX ext:5, STAA ext:2, STAB ext:1 | 0x4687, 0x4693, 0x476D, 0x5270, 0x5482, 0x5C4F, 0x5ECE, 0xD7BC |
| `0x2002` | 4 | STX ext:3, STAA ext:1 | 0x4892, 0x7E44, 0xA9C1, 0xC710 |
| `0x2007` | 5 | LDAA ext:3, STAA ext:2 | 0x4044, 0x4149, 0x5E97, 0x5EEC, 0x96D3 |
| `0x2008` | 7 | LDAA ext:4, STAA ext:2, STX ext:1 | 0x4021, 0x40CE, 0x4116, 0x4322, 0x5C19, 0x96E9, 0xBB8A |
| `0x2009` | 6 | LDAA ext:3, STAA ext:2, CLR ext:1 | 0x40D7, 0x432B, 0x5BA0, 0x5BC4, 0x5CE9, 0xC61B |
| `0x200A` | 7 | LDAA ext:4, STAA ext:3 | 0x4030, 0x40B0, 0x4123, 0x4372, 0x5D1F, 0x6D25, 0x96F3 |
| `0x200B` | 5 | STAA ext:2, LDD ext:1, LDAA ext:1, STX ext:1 | 0x40B9, 0x437B, 0x47F1, 0x5D5D, 0x9554 |
| `0x200C` | 4 | STAA ext:2, LDAA ext:2 | 0x403E, 0x4143, 0x5B1B, 0x5B8E |
| `0x200D` | 4 | STAA ext:2, LDAA ext:1, CMPA ext:1 | 0x4027, 0x411C, 0x415D, 0x6933 |
| `0x200E` | 7 | LDAA ext:5, STAA ext:2 | 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x5DA8, 0x96DA |
| `0x2013` | 11 | CMPA ext:5, STAA ext:3, CMPB ext:2, LDAB ext:1 | 0x404D, 0x4128, 0x5F20, 0x9792, 0x97AF, 0x98FF, 0x997E, 0x99A9, 0x99EB, 0x9CC4 |
| `0x202B` | 10 | LDAA ext:5, STAA ext:2, LDAB ext:2, STAB ext:1 | 0x9714, 0x9728, 0xBE5F, 0xBED8, 0xBEE7, 0xCB89, 0xCE67, 0xCF0B, 0xE8E9, 0xE8F9 |
| `0x202C` | 2 | STAA ext:1, CLR ext:1 | 0xBEEF, 0xBEF7 |
| `0x2030` | 5 | LDAA ext:2, STAA ext:1, STAB ext:1, LDAB ext:1 | 0xC36C, 0xD6BB, 0xD7C0, 0xEACF, 0xEB16 |
| `0x2034` | 8 | LDD ext:7, STD ext:1 | 0x41AD, 0x4913, 0x495F, 0x6EA9, 0x7258, 0xBA34, 0xBE78, 0xE3CF |
| `0x2036` | 19 | LDD ext:17, STD ext:2 | 0x45BC, 0x48FC, 0x4919, 0x49AD, 0x635A, 0x6EB9, 0x725E, 0x9B9D, 0x9D13, 0xBE7E |
| `0x2038` | 5 | LDD ext:3, STD ext:1, LDAB ext:1 | 0x43B1, 0x4E49, 0x5C9F, 0xE84F, 0xE870 |
| `0x203A` | 2 | STD ext:1, LDD ext:1 | 0x43B5, 0x4953 |
| `0x203C` | 12 | LDD ext:9, LDAB ext:2, STD ext:1 | 0x4361, 0x44B1, 0x55F8, 0x720F, 0x72BC, 0x9B61, 0xC2A2, 0xC819, 0xC824, 0xE7F0 |
| `0x203E` | 17 | LDD ext:16, STD ext:1 | 0x4365, 0x4947, 0x49BE, 0x7129, 0x7140, 0x716B, 0xBE9A, 0xC01E, 0xC11A, 0xC127 |
| `0x2040` | 6 | LDD ext:5, STD ext:1 | 0x4400, 0x9525, 0xD5DF, 0xD5EF, 0xD6F5, 0xE83E |
| `0x2042` | 6 | LDD ext:5, STD ext:1 | 0x41EC, 0x5758, 0x97DA, 0xE3FD, 0xE4FF, 0xE97A |
| `0x2049` | 4 | STAA ext:2, CPX ext:1, LDAA ext:1 | 0x6F70, 0xE6A6, 0xE79E, 0xE848 |
| `0x204A` | 3 | STAA ext:2, LDAB ext:1 | 0xE786, 0xE869, 0xE928 |
| `0x204B` | 2 | LDD ext:1, STD ext:1 | 0xE5E8, 0xE959 |
| `0x204D` | 3 | STAA ext:2, LDAB ext:1 | 0xE78C, 0xE88A, 0xE95D |
| `0x204E` | 3 | LDAB ext:2, STD ext:1 | 0xE5FF, 0xE607, 0xE96D |
| `0x204F` | 2 | LDAB ext:2 | 0xE5F3, 0xE613 |
| `0x2050` | 2 | STAA ext:1, LDAB ext:1 | 0xE7ED, 0xE935 |
| `0x2051` | 4 | STD ext:2, CPX ext:1, LDD ext:1 | 0x6582, 0x6F48, 0xE6A1, 0xE7AE |
| `0x2053` | 5 | LDAB ext:2, LDAA ext:1, STAB ext:1, STAA ext:1 | 0xCC57, 0xE5E5, 0xE684, 0xE68A, 0xE7B4 |
| `0x2055` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xE654, 0xE7A6, 0xEAA7, 0xEAB5, 0xEAC4 |
| `0x2057` | 4 | STD ext:3, ADDD ext:1 | 0xE659, 0xE7A9, 0xEB02, 0xEB0E |
| `0x2059` | 15 | LDAA ext:8, STAA ext:4, LDAB ext:2, STAB ext:1 | 0x5B7D, 0x5B95, 0x7101, 0x713D, 0x729F, 0x9818, 0x999A, 0x9A9B, 0x9CA5, 0xBE14 |
| `0x2060` | 4 | STAA ext:3, LDAA ext:1 | 0x7153, 0xE9F9, 0xE9FC, 0xEA02 |
| `0x2062` | 3 | STAA ext:2, LDAA ext:1 | 0xE792, 0xE9D5, 0xE9DB |
| `0x2084` | 2 | STAA ext:2 | 0xE3E1, 0xE798 |
| `0x2085` | 3 | STAA ext:2, LDAA ext:1 | 0xE63B, 0xE79B, 0xE83B |
| `0x2086` | 6 | STD ext:3, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x706C, 0x707F, 0x70A4, 0xD5D7, 0xD60A, 0xD6DC |
| `0x2090` | 10 | LDAA ext:7, STAA ext:2, STAB ext:1 | 0x5685, 0xC03D, 0xC0E4, 0xC19E, 0xC1AA, 0xC1DF, 0xC86C, 0xC931, 0xC97C, 0xCAFE |
| `0x2091` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xC0F6, 0xC7AC, 0xC7AF, 0xC7C1, 0xC807 |
| `0x2093` | 1 | STAA ext:1 | 0xC03A |
| `0x2094` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC588, 0xC734, 0xCB4D |
| `0x2095` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC594, 0xC744, 0xCB57 |
| `0x2096` | 9 | LDAA ext:5, STAA ext:2, DEC ext:1, TST ext:1 | 0xC08B, 0xC0C0, 0xC0F3, 0xC124, 0xC1EE, 0xC1FE, 0xC361, 0xC5A8, 0xC8E7 |
| `0x2097` | 3 | STAA ext:2, TST ext:1 | 0x566C, 0x56F7, 0xC5C2 |
| `0x2098` | 11 | LDAA ext:7, INC ext:1, DEC ext:1, TST ext:1, STAA ext:1 | 0xC0CF, 0xC0FF, 0xC34D, 0xC398, 0xC3BB, 0xC3CA, 0xC3EA, 0xC400, 0xC43D, 0xC5CF |
| `0x2099` | 2 | STAA ext:1, TST ext:1 | 0xC227, 0xC5B5 |
| `0x209A` | 5 | STAA ext:3, LDAA ext:1, TST ext:1 | 0xC255, 0xC263, 0xC32F, 0xC5DC, 0xCAE3 |
| `0x209B` | 16 | STAA ext:9, LDAA ext:4, TST ext:1, DEC ext:1, INC ext:1 | 0xC0EA, 0xC187, 0xC457, 0xC4A3, 0xC4BB, 0xC4F2, 0xC510, 0xC53A, 0xC56B, 0xC5E9 |
| `0x209C` | 4 | LDD ext:2, STD ext:1, ADDD ext:1 | 0xC6F1, 0xC702, 0xC8A8, 0xC8B5 |
| `0x209E` | 4 | STD ext:3, LDD ext:1 | 0x6394, 0xC199, 0xC6E5, 0xC6E8 |
| `0x20A0` | 3 | STD ext:2, ADDD ext:1 | 0xC605, 0xC6C9, 0xC6EB |
| `0x20A2` | 3 | LDAA ext:2, STAB ext:1 | 0xC1BD, 0xC5F6, 0xC77E |
| `0x20A4` | 12 | STAA ext:5, LDAA ext:3, STAB ext:3, CLR ext:1 | 0x56BA, 0x6CD8, 0x6DB7, 0x96EC, 0x975C, 0xC1C3, 0xC5F9, 0xC731, 0xC784, 0xC9FA |
| `0x20A6` | 7 | STAA ext:3, LDAB ext:2, STD ext:1, STAB ext:1 | 0xC106, 0xC1C0, 0xC705, 0xC71A, 0xC72E, 0xC781, 0xC79A |
| `0x20A8` | 20 | LDAA ext:9, LDAB ext:5, CMPA ext:5, STAA ext:1 | 0x4A3A, 0x4A51, 0x5626, 0x984A, 0x9887, 0x998E, 0x9A60, 0x9A7A, 0x9ABB, 0xC086 |
| `0x20B1` | 9 | TST ext:5, LDAA ext:3, STAA ext:1 | 0x460A, 0x4907, 0xBF0A, 0xBF30, 0xCBA9, 0xCBFC, 0xE39E, 0xE3C0, 0xE942 |
| `0x20B9` | 15 | STD ext:6, CMPA ext:2, LDD ext:2, SUBD ext:2, LDAB ext:2, LDAA ext:1 | 0x61CE, 0x61D6, 0xCBB1, 0xCBC7, 0xCC98, 0xCDBC, 0xCDC8, 0xCDD3, 0xCDDF, 0xCDEA |
| `0x20BC` | 2 | STAA ext:2 | 0xBAB1, 0xBBEC |
| `0x20BD` | 1 | STAB ext:1 | 0xBB3A |
| `0x20BE` | 1 | STAB ext:1 | 0xBAE3 |
| `0x20BF` | 1 | STAB ext:1 | 0xBB00 |
| `0x20C0` | 1 | STAB ext:1 | 0xBB1D |
| `0x20C1` | 5 | STAA ext:3, LDAA ext:1, LDAB ext:1 | 0xAFF8, 0xAFFD, 0xB003, 0xBB6B, 0xBBC8 |
| `0x20C2` | 2 | STAA ext:2 | 0xBB37, 0xBC02 |
| `0x20C3` | 2 | STAA ext:2 | 0xBAE0, 0xBBF9 |
| `0x20C4` | 2 | STAA ext:2 | 0xBAFD, 0xBBFC |
| `0x20C5` | 2 | STAA ext:2 | 0xBB1A, 0xBBFF |
| `0x20D3` | 7 | LDAA ext:3, STAA ext:3, LDAB ext:1 | 0xB087, 0xB0EE, 0xB134, 0xB13A, 0xB1AC, 0xB1C8, 0xBBB3 |
| `0x20D4` | 7 | LDAA ext:5, STAA ext:2 | 0xB0FF, 0xB156, 0xB16F, 0xB188, 0xB1A1, 0xBA8E, 0xBBE0 |
| `0x20D5` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB198, 0xB1A4, 0xB1A9 |
| `0x20D6` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB14D, 0xB159, 0xB15E |
| `0x20D7` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB166, 0xB172, 0xB177 |
| `0x20D8` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB17F, 0xB18B, 0xB190 |
| `0x20D9` | 5 | LDAA ext:2, STAA ext:2, STX ext:1 | 0x9E48, 0xB193, 0xB19E, 0xB1C0, 0xBBB0 |
| `0x20DA` | 4 | LDAA ext:2, STAA ext:2 | 0xB148, 0xB153, 0xB1B1, 0xBBA7 |
| `0x20DB` | 4 | LDAA ext:2, STAA ext:2 | 0xB161, 0xB16C, 0xB1B6, 0xBBAA |
| `0x20DC` | 4 | LDAA ext:2, STAA ext:2 | 0xB17A, 0xB185, 0xB1BB, 0xBBAD |
| `0x20DD` | 2 | STAA ext:2 | 0xBA67, 0xBBF2 |
| `0x20DE` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4858, 0xB24D, 0xB269, 0xBBBF, 0xE5B3, 0xE5B8 |
| `0x20DF` | 6 | STAA ext:3, LDAB ext:1, ADDD ext:1, LDAA ext:1 | 0x4849, 0xA52D, 0xB1E1, 0xB260, 0xBBB6, 0xE5A0 |
| `0x20E0` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x484E, 0xB205, 0xB263, 0xBBB9, 0xE5A3, 0xE5A8 |
| `0x20E1` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4853, 0xB229, 0xB266, 0xBBBC, 0xE5AB, 0xE5B0 |
| `0x20E2` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48D2, 0x7D5D, 0x7D66, 0x95E8, 0xB258 |
| `0x20E3` | 7 | LDAB ext:2, LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48B4, 0x7A8E, 0x7B16, 0x7CFD, 0x7D06, 0x95DF, 0xB1EC |
| `0x20E4` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48BE, 0x7D3D, 0x7D46, 0x95E2, 0xB210 |
| `0x20E5` | 6 | LDAA ext:2, STAA ext:2, STAB ext:1, LDAB ext:1 | 0x48C8, 0x7A89, 0x7D1D, 0x7D26, 0x95E5, 0xB234 |
| `0x20E6` | 13 | LDAA ext:6, CMPA ext:5, STAA ext:2 | 0xB115, 0xB11A, 0xB1D9, 0xB1DE, 0xB1FD, 0xB202, 0xB221, 0xB226, 0xB245, 0xB24A |
| `0x20E7` | 3 | STAA ext:2, LDAA ext:1 | 0xBA74, 0xBBD4, 0xBD1E |
| `0x20E8` | 4 | STAA ext:2, LDAB ext:2 | 0xBA81, 0xBBDA, 0xBD40, 0xBD46 |
| `0x20E9` | 23 | LDAA ext:14, LDAB ext:6, STAA ext:3 | 0x7563, 0x7576, 0x75EA, 0x75FD, 0x7719, 0x7723, 0x7730, 0x7773, 0x778A, 0x7851 |
| `0x20EB` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9A, 0xBC67, 0xBC7A, 0xBD39 |
| `0x20ED` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9D, 0xBCB1, 0xBCC1, 0xBD4F |
| `0x2132` | 6 | STD ext:3, LDD ext:2, SUBD ext:1 | 0x4427, 0x4653, 0x465E, 0x4675, 0x467F, 0x4690 |
| `0x2134` | 2 | STD ext:2 | 0x442B, 0x49C5 |
| `0x2147` | 21 | STD ext:10, ADDD ext:6, LDY ext:1, LDX ext:1, STY ext:1, STX ext:1, LDD ext:1 | 0x4481, 0x454E, 0x4551, 0x45C4, 0x45DB, 0x45DC, 0x45E1, 0x45E2, 0x4602, 0x4605 |
| `0x2148` | 6 | LDAA ext:3, STAA ext:2, STAB ext:1 | 0x468C, 0x4756, 0x476A, 0x4862, 0x4874, 0x4936 |
| `0x2149` | 4 | STAB ext:1, TST ext:1, LDAA ext:1, DEC ext:1 | 0x46E5, 0x4702, 0x4772, 0x4777 |
| `0x214C` | 3 | LDAA ext:2, STAA ext:1 | 0x48DD, 0x48E6, 0x496D |
| `0x2122` | 3 | STD ext:2, LDAA ext:1 | 0x40E1, 0x433D, 0x4346 |
| `0x2124` | 3 | STD ext:2, LDAA ext:1 | 0x40C3, 0x438D, 0x4396 |
| `0x21C6` | 5 | STD ext:2, LDD ext:1, SUBD ext:1, STX ext:1 | 0x6FC0, 0x6FD1, 0x724C, 0x7298, 0x72A9 |
| `0x21C8` | 9 | LDD ext:4, STD ext:3, SUBD ext:2 | 0x6F65, 0x6FB0, 0x7024, 0x7075, 0x708A, 0x709C, 0x70CD, 0x70DF, 0x70F0 |
| `0x21CB` | 6 | ADDD ext:4, STD ext:1, SUBD ext:1 | 0x7062, 0x707C, 0x7090, 0x70C4, 0x70E5, 0x70F6 |
| `0x21CD` | 3 | STD ext:2, SUBD ext:1 | 0x704A, 0x70A7, 0x70ED |
| `0x21CF` | 4 | STD ext:2, LDD ext:1, ADDD ext:1 | 0x6FF1, 0x7034, 0x712C, 0x7219 |
| `0x2312` | 3 | LDY imm:2, STAA ext:1 | 0x7583, 0x7CF9, 0x9587 |
| `0x231E` | 3 | LDY imm:2, STAA ext:1 | 0x7570, 0x7D39, 0x958A |
| `0x232A` | 3 | LDY imm:2, STAA ext:1 | 0x757D, 0x7D19, 0x958D |
| `0x2336` | 3 | LDY imm:2, STAA ext:1 | 0x756A, 0x7D59, 0x9590 |
| `0x2348` | 14 | STD ext:6, LDD ext:6, ADDD ext:2 | 0x7CF6, 0x7D16, 0x7D36, 0x7D56, 0x7D74, 0x7D7E, 0x7DF4, 0x7E04, 0x7E55, 0x7E60 |
| `0x234A` | 9 | DEC ext:3, STD ext:2, STAA ext:1, CLR ext:1, ADDD ext:1, SUBD ext:1 | 0x7D84, 0x7DA9, 0x7DAC, 0x7DC3, 0x7E01, 0x7E12, 0x7E1D, 0x7E52, 0x7E58 |
| `0x234C` | 2 | STAA ext:1, DEC ext:1 | 0x7E4B, 0x7E5B |
| `0x234D` | 5 | STD ext:3, LDX ext:1, LDD ext:1 | 0x7DF0, 0x7DFD, 0x7E29, 0x7E3A, 0x7E68 |
| `0x2354` | 4 | LDAB ext:2, LDAA ext:1, STAB ext:1 | 0x7A07, 0x7A0F, 0x7F0C, 0x7F2E |
| `0x235C` | 13 | STD ext:2, SUBD ext:2, LDX ext:2, INC ext:2, LDD ext:1, STX ext:1, CLR ext:1, TST ext:1, DEC ext:1 | 0x78C9, 0x78EF, 0x7912, 0x7924, 0x7945, 0x7998, 0x7EBF, 0x7ED2, 0x7EDD, 0x7EF5 |
| `0x235E` | 4 | STX ext:1, LDAB ext:1, STD ext:1, ADDD ext:1 | 0x790F, 0x796C, 0x7EE8, 0x7EF2 |
| `0x2369` | 3 | STD ext:2, SUBD ext:1 | 0x7E88, 0x7EAB, 0x7F02 |
| `0x2376` | 2 | STD ext:1, LDX ext:1 | 0x7DE1, 0x7E6E |
| `0x2380` | 8 | LDD ext:4, STD ext:3, ADDD ext:1 | 0x7763, 0x7B74, 0x7B8B, 0x7D7A, 0x7DED, 0x7E4E, 0x7F08, 0x7F14 |
| `0x2382` | 7 | STX ext:3, LDD ext:2, LDAB ext:1, ADDD ext:1 | 0x7766, 0x7B77, 0x7B8E, 0x7DE4, 0x7ECD, 0x7EE4, 0x7EFA |
| `0x242B` | 3 | LDD ext:1, SUBD ext:1, STD ext:1 | 0xBC64, 0xBC76, 0xBD1B |
| `0x242D` | 2 | STD ext:1, SUBD ext:1 | 0xBCAE, 0xBCBD |
| `0x242F` | 5 | STD ext:2, ADDD ext:2, LDAA ext:1 | 0xBAB5, 0xBABE, 0xBAC6, 0xBB49, 0xBB53 |
| `0x2431` | 2 | STAA ext:2 | 0xBB68, 0xBB79 |
| `0x243C` | 10 | STD ext:2, CMPA ext:2, INC ext:1, STAA ext:1, LDD ext:1, CPX ext:1, STX ext:1, LDAA ext:1 | 0xC260, 0xC2C1, 0xC2D9, 0xC2DC, 0xC2E1, 0xC2EE, 0xC2F9, 0xC2FC, 0xC301, 0xC304 |
| `0x243E` | 3 | STAA ext:1, LDAA ext:1, LDAB ext:1 | 0xC2AC, 0xC31A, 0xC31F |
| `0x243F` | 6 | LDAA ext:4, STAA ext:2 | 0xC0A3, 0xC0B5, 0xC131, 0xC1E9, 0xC938, 0xC93E |
| `0x244C` | 2 | STAA ext:1, LDAA ext:1 | 0xC13E, 0xC1F8 |
| `0x245E` | 3 | STAA ext:2, DEC ext:1 | 0xC141, 0xC1F3, 0xC1FB |
| `0x2462` | 6 | LDAA ext:3, STAA ext:2, DEC ext:1 | 0xC4CC, 0xC4D1, 0xC546, 0xC54B, 0xC941, 0xC946 |
| `0x2463` | 6 | TST ext:2, DEC ext:2, STAA ext:2 | 0xC099, 0xC09E, 0xC0D8, 0xC0DD, 0xC110, 0xC190 |
| `0x2464` | 4 | LDAA ext:2, STAA ext:2 | 0xC1B8, 0xC1DC, 0xC927, 0xC92E |
| `0x2465` | 4 | STAA ext:2, LDAA ext:2 | 0xC1D4, 0xC779, 0xC918, 0xC924 |
| `0x249B` | 6 | STD ext:4, LDD ext:1, SUBD ext:1 | 0xCBB4, 0xCBCA, 0xCC9B, 0xCE04, 0xCE14, 0xCE5B |
| `0x24AB` | 2 | LDAA ext:1, STAA ext:1 | 0xCD51, 0xD134 |
| `0x24AC` | 2 | LDAA ext:1, STAA ext:1 | 0xCD04, 0xD140 |
| `0x24AD` | 2 | LDD ext:1, STD ext:1 | 0xCD0A, 0xD151 |
| `0x24AF` | 2 | LDAB ext:1, STAA ext:1 | 0xCD8C, 0xD15D |
| `0x24B0` | 6 | STD ext:4, ADDD ext:1, SUBD ext:1 | 0xCDB9, 0xCDC3, 0xCDCB, 0xCDDA, 0xCDE2, 0xCDFE |
| `0x2483` | 4 | STAB ext:1, LDAB ext:1, DEC ext:1, STAA ext:1 | 0xBEEA, 0xBEF2, 0xBEFC, 0xCB8C |
| `0x2484` | 3 | STAA ext:2, LDAB ext:1 | 0xBE93, 0xBEAF, 0xCB86 |
| `0x2486` | 2 | STAA ext:2 | 0xBEA0, 0xCB7D |
| `0x2488` | 1 | STAA ext:1 | 0xBECB |
| `0x248D` | 3 | STAA ext:2, LDAA ext:1 | 0xBF19, 0xBF20, 0xBF49 |
| `0x248E` | 2 | STAA ext:2 | 0xBF3F, 0xBF46 |
| `0x2584` | 3 | STD ext:2, SUBD ext:1 | 0xE4F9, 0xE58D, 0xE663 |
| `0x2590` | 3 | STD ext:2, ADDD ext:1 | 0xE3F4, 0xE4DB, 0xE65E |
| `0x2596` | 6 | ADDD ext:3, STD ext:2, SUBD ext:1 | 0xE780, 0xE903, 0xE913, 0xE921, 0xE924, 0xE92E |
| `0x25A3` | 6 | LDY imm:2, STD ext:2, ADDD ext:2 | 0xE84B, 0xE86C, 0xE931, 0xE93B, 0xE93F, 0xE953 |
| `0x2610` | 10 | STAB ext:4, LDAB ext:3, STX ext:2, CLR ext:1 | 0x4EDC, 0x6A37, 0x6B2C, 0x6B37, 0x6B46, 0x6B96, 0x6BA1, 0x6BB0, 0xCB10, 0xE948 |

### `peugeot_mod2`

| Address | Count | Operations | First sites |
| --- | ---: | --- | --- |
| `0x0060` | 1 | LDY imm:1 | 0xCB46 |
| `0x0069` | 6 | LDY imm:3, LDAA dir:2, CMPA dir:1 | 0x63DD, 0xCB50, 0xCC21, 0xD89E, 0xD8FE, 0xD910 |
| `0x005D` | 14 | LDAA dir:4, CMPA dir:3, STAA dir:3, STAB dir:2, INC ext:1, DEC ext:1 | 0x56BD, 0x63AA, 0x642C, 0x643F, 0x6CD4, 0x6DB5, 0xC1B1, 0xC1C6, 0xC6FD, 0xC787 |
| `0x005E` | 12 | STAA dir:3, LDAA dir:2, LDAB dir:2, CMPA dir:1, INC ext:1, DEC ext:1, STAB dir:1, CLR ext:1 | 0x6020, 0x639B, 0x642F, 0x6435, 0x643B, 0x6442, 0x6446, 0x644D, 0xC9EE, 0xCA91 |
| `0x005F` | 8 | STAB dir:2, STAA dir:1, LDX dir:1, CLR ext:1, LDAA dir:1, LDAB dir:1, LDD dir:1 | 0x63A8, 0x6423, 0x6CC7, 0xA2BE, 0xCA10, 0xCB0D, 0xD14B, 0xD6E1 |
| `0x00B6` | 20 | LDAA dir:6, STAB dir:3, STAA dir:2, ADDD dir:2, LDD dir:2, CMPA dir:1, STX ext:1, STX dir:1, LDAB dir:1, SUBD dir:1 | 0x41E2, 0x4424, 0x46D0, 0x48AA, 0x67F1, 0x96D7, 0x9733, 0xB0F0, 0xB13C, 0xB160 |
| `0x00BC` | 24 | STD dir:11, SUBD dir:6, LDD dir:5, ADDD dir:2 | 0x6F6F, 0x6F84, 0x6F89, 0x6F91, 0x6F9F, 0x6FA6, 0x6FF4, 0x7014, 0x702C, 0x7032 |
| `0x00BF` | 7 | LDD dir:3, SUBD dir:2, STD dir:2 | 0x6E9A, 0x6F7D, 0x6F86, 0x6F9D, 0x721D, 0xD5D5, 0xD5FE |
| `0x00C1` | 39 | STD dir:14, LDD dir:8, LDAA dir:6, ADDD dir:5, SUBD dir:4, CMPB dir:1, LDX dir:1 | 0x58DA, 0x6E9E, 0x6ED6, 0x6EDD, 0x6EE8, 0x9989, 0xAE2B, 0xE5F1, 0xE605, 0xE611 |
| `0x00C3` | 11 | LDD dir:5, STD dir:4, STX dir:2 | 0x6EEA, 0x6F6C, 0x6F73, 0x6FA3, 0x7010, 0x7029, 0x79B5, 0x9B46, 0xDFC8, 0xE6D3 |
| `0x00C5` | 11 | STAA dir:4, LDAA dir:4, STD dir:2, LDAB dir:1 | 0x9676, 0xE647, 0xE7D7, 0xE9C7, 0xEA21, 0xEA26, 0xEA49, 0xEA78, 0xEA7D, 0xEA8B |
| `0x00C6` | 10 | LDAA dir:2, LDX dir:2, CLR ext:2, SUBD dir:1, STX dir:1, ADDD dir:1, LDAB dir:1 | 0x5C55, 0x63EE, 0xA2B1, 0xA2D1, 0xA52F, 0xA53B, 0xE7D9, 0xE9C9, 0xEA43, 0xEA6E |
| `0x00CC` | 15 | LDAA dir:8, LDD dir:3, STD dir:2, CMPB dir:1, ADDD dir:1 | 0x43C7, 0x43D5, 0x43F3, 0x6084, 0x60DA, 0x80EA, 0x8172, 0x9224, 0x9387, 0x93A9 |
| `0x00CE` | 20 | LDD dir:12, LDX dir:2, ADDD dir:2, STX dir:1, STD dir:1, CMPB dir:1, CPX dir:1 | 0x4073, 0x409C, 0x412B, 0x41A1, 0x42E1, 0x45F3, 0x4FC1, 0x5E5E, 0x5E7C, 0x80C7 |
| `0x00D0` | 22 | LDAA dir:14, LDAB dir:4, STAB dir:2, CMPA dir:1, STX dir:1 | 0x574A, 0x57BD, 0x5E5C, 0x5E77, 0x5F07, 0x5FAA, 0x8073, 0x96DE, 0x96F7, 0x97F4 |
| `0x100B` | 3 | STAA ext:3 | 0x75B7, 0xB549, 0xD346 |
| `0x100E` | 30 | LDD ext:28, ADDD ext:2 | 0x4FA7, 0x4FD3, 0x51BE, 0x53A3, 0x5880, 0x6CEC, 0x6EF5, 0x6FC8, 0x705F, 0x71D0 |
| `0x1016` | 3 | STD ext:2, LDD ext:1 | 0x4E13, 0x6EFB, 0x6FC5 |
| `0x1018` | 18 | STD ext:13, LDD ext:2, ADDD ext:2, SUBD ext:1 | 0x75CF, 0x75E3, 0x7984, 0x79B9, 0x79FE, 0x7A24, 0x7C29, 0x7C52, 0x7F52, 0x7F57 |
| `0x101A` | 13 | STD ext:10, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x6CEF, 0x7085, 0x7096, 0x70C1, 0x70D4, 0x70D7, 0x70E8, 0x70F9, 0x71D3, 0xA939 |
| `0x101C` | 9 | STD ext:7, LDD ext:2 | 0x4FAD, 0x4FD9, 0x503F, 0x5045, 0xBC6A, 0xBC8C, 0xBCAB, 0xBCB4, 0xDEFD |
| `0x1020` | 8 | STAA ext:4, CMPB ext:1, SUBD ext:1, LDAA ext:1, CLR ext:1 | 0x4C2B, 0x5BB3, 0x6BD5, 0x6D3C, 0x6DB2, 0xB544, 0xB951, 0xD82C |
| `0x1022` | 5 | CLR ext:3, LDAA ext:1, STAA ext:1 | 0x4F1D, 0x6BCF, 0x6BF0, 0x6DAC, 0xD82F |
| `0x1023` | 39 | STAA ext:23, STAB ext:11, LDAA ext:5 | 0x4FB2, 0x4FDE, 0x504A, 0x50D6, 0x512C, 0x5145, 0x5183, 0x519A, 0x51A7, 0x5259 |
| `0x1028` | 4 | STAA ext:4 | 0x9EF4, 0x9EFC, 0xA01B, 0xA01E |
| `0x1029` | 20 | LDAA ext:18, LDAB ext:2 | 0x9EEC, 0x9F06, 0x9F1C, 0x9F34, 0x9F44, 0x9F52, 0x9F60, 0x9F6E, 0x9F7C, 0x9F8A |
| `0x102A` | 19 | STAB ext:13, STAA ext:3, LDAA ext:2, CMPA ext:1 | 0x9EEF, 0x9F37, 0x9F47, 0x9F55, 0x9F63, 0x9F71, 0x9F7F, 0x9F8D, 0x9F9B, 0x9FAA |
| `0x1030` | 16 | STAA ext:16 | 0x40E8, 0x4133, 0x51EF, 0x52D1, 0xB82C, 0xB8C0, 0xBC23, 0xBCD0, 0xDA6B, 0xDA88 |
| `0x1031` | 8 | LDAA ext:6, LDY imm:2 | 0x401E, 0x4113, 0x53CC, 0xBC2B, 0xBCD8, 0xDAB8, 0xDE48, 0xE116 |
| `0x1032` | 5 | LDAA ext:4, LDY imm:1 | 0x403B, 0x4140, 0x52A8, 0x53D9, 0xDE31 |
| `0x1033` | 7 | LDAA ext:6, LDY imm:1 | 0x4024, 0x4041, 0x4119, 0x4146, 0x52B5, 0x53E6, 0xDE17 |
| `0x1034` | 7 | LDAA ext:6, LDY imm:1 | 0x402D, 0x405A, 0x411F, 0x414C, 0x52C2, 0x53F3, 0xDE5F |
| `0x1050` | 40 | STAA ext:24, LDAA ext:15, CLR ext:1 | 0x4F3E, 0x50E3, 0x50E8, 0x50EB, 0x50F0, 0x5148, 0x514D, 0x51AE, 0x51B3, 0x51C3 |
| `0x2001` | 8 | STX ext:5, STAA ext:2, STAB ext:1 | 0x4687, 0x4693, 0x476D, 0x5270, 0x5482, 0x5C4F, 0x5ECE, 0xD7BC |
| `0x2002` | 4 | STX ext:3, STAA ext:1 | 0x4892, 0x7E44, 0xA9C1, 0xC710 |
| `0x2007` | 5 | LDAA ext:3, STAA ext:2 | 0x4044, 0x4149, 0x5E97, 0x5EEC, 0x96D3 |
| `0x2008` | 7 | LDAA ext:4, STAA ext:2, STX ext:1 | 0x4021, 0x40CE, 0x4116, 0x4322, 0x5C19, 0x96E9, 0xBB8A |
| `0x2009` | 6 | LDAA ext:3, STAA ext:2, CLR ext:1 | 0x40D7, 0x432B, 0x5BA0, 0x5BC4, 0x5CE9, 0xC61B |
| `0x200A` | 7 | LDAA ext:4, STAA ext:3 | 0x4030, 0x40B0, 0x4123, 0x4372, 0x5D1F, 0x6D25, 0x96F3 |
| `0x200B` | 5 | STAA ext:2, LDD ext:1, LDAA ext:1, STX ext:1 | 0x40B9, 0x437B, 0x47F1, 0x5D5D, 0x9554 |
| `0x200C` | 4 | STAA ext:2, LDAA ext:2 | 0x403E, 0x4143, 0x5B1B, 0x5B8E |
| `0x200D` | 4 | STAA ext:2, LDAA ext:1, CMPA ext:1 | 0x4027, 0x411C, 0x415D, 0x6933 |
| `0x200E` | 7 | LDAA ext:5, STAA ext:2 | 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x5DA8, 0x96DA |
| `0x2013` | 11 | CMPA ext:5, STAA ext:3, CMPB ext:2, LDAB ext:1 | 0x404D, 0x4128, 0x5F20, 0x9792, 0x97AF, 0x98FF, 0x997E, 0x99A9, 0x99EB, 0x9CC4 |
| `0x202B` | 10 | LDAA ext:5, STAA ext:2, LDAB ext:2, STAB ext:1 | 0x9714, 0x9728, 0xBE5F, 0xBED8, 0xBEE7, 0xCB89, 0xCE67, 0xCF0B, 0xE8E9, 0xE8F9 |
| `0x202C` | 2 | STAA ext:1, CLR ext:1 | 0xBEEF, 0xBEF7 |
| `0x2030` | 5 | LDAA ext:2, STAA ext:1, STAB ext:1, LDAB ext:1 | 0xC36C, 0xD6BB, 0xD7C0, 0xEACF, 0xEB16 |
| `0x2034` | 8 | LDD ext:7, STD ext:1 | 0x41AD, 0x4913, 0x495F, 0x6EA9, 0x7258, 0xBA34, 0xBE78, 0xE3CF |
| `0x2036` | 19 | LDD ext:17, STD ext:2 | 0x45BC, 0x48FC, 0x4919, 0x49AD, 0x635A, 0x6EB9, 0x725E, 0x9B9D, 0x9D13, 0xBE7E |
| `0x2038` | 5 | LDD ext:3, STD ext:1, LDAB ext:1 | 0x43B1, 0x4E49, 0x5C9F, 0xE84F, 0xE870 |
| `0x203A` | 2 | STD ext:1, LDD ext:1 | 0x43B5, 0x4953 |
| `0x203C` | 12 | LDD ext:9, LDAB ext:2, STD ext:1 | 0x4361, 0x44B1, 0x55F8, 0x720F, 0x72BC, 0x9B61, 0xC2A2, 0xC819, 0xC824, 0xE7F0 |
| `0x203E` | 17 | LDD ext:16, STD ext:1 | 0x4365, 0x4947, 0x49BE, 0x7129, 0x7140, 0x716B, 0xBE9A, 0xC01E, 0xC11A, 0xC127 |
| `0x2040` | 6 | LDD ext:5, STD ext:1 | 0x4400, 0x9525, 0xD5DF, 0xD5EF, 0xD6F5, 0xE83E |
| `0x2042` | 6 | LDD ext:5, STD ext:1 | 0x41EC, 0x5758, 0x97DA, 0xE3FD, 0xE4FF, 0xE97A |
| `0x2049` | 4 | STAA ext:2, CPX ext:1, LDAA ext:1 | 0x6F70, 0xE6A6, 0xE79E, 0xE848 |
| `0x204A` | 3 | STAA ext:2, LDAB ext:1 | 0xE786, 0xE869, 0xE928 |
| `0x204B` | 2 | LDD ext:1, STD ext:1 | 0xE5E8, 0xE959 |
| `0x204D` | 3 | STAA ext:2, LDAB ext:1 | 0xE78C, 0xE88A, 0xE95D |
| `0x204E` | 3 | LDAB ext:2, STD ext:1 | 0xE5FF, 0xE607, 0xE96D |
| `0x204F` | 2 | LDAB ext:2 | 0xE5F3, 0xE613 |
| `0x2050` | 2 | STAA ext:1, LDAB ext:1 | 0xE7ED, 0xE935 |
| `0x2051` | 4 | STD ext:2, CPX ext:1, LDD ext:1 | 0x6582, 0x6F48, 0xE6A1, 0xE7AE |
| `0x2053` | 5 | LDAB ext:2, LDAA ext:1, STAB ext:1, STAA ext:1 | 0xCC57, 0xE5E5, 0xE684, 0xE68A, 0xE7B4 |
| `0x2055` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xE654, 0xE7A6, 0xEAA7, 0xEAB5, 0xEAC4 |
| `0x2057` | 4 | STD ext:3, ADDD ext:1 | 0xE659, 0xE7A9, 0xEB02, 0xEB0E |
| `0x2059` | 15 | LDAA ext:8, STAA ext:4, LDAB ext:2, STAB ext:1 | 0x5B7D, 0x5B95, 0x7101, 0x713D, 0x729F, 0x9818, 0x999A, 0x9A9B, 0x9CA5, 0xBE14 |
| `0x2060` | 4 | STAA ext:3, LDAA ext:1 | 0x7153, 0xE9F9, 0xE9FC, 0xEA02 |
| `0x2062` | 3 | STAA ext:2, LDAA ext:1 | 0xE792, 0xE9D5, 0xE9DB |
| `0x2084` | 2 | STAA ext:2 | 0xE3E1, 0xE798 |
| `0x2085` | 3 | STAA ext:2, LDAA ext:1 | 0xE63B, 0xE79B, 0xE83B |
| `0x2086` | 6 | STD ext:3, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x706C, 0x707F, 0x70A4, 0xD5D7, 0xD60A, 0xD6DC |
| `0x2090` | 10 | LDAA ext:7, STAA ext:2, STAB ext:1 | 0x5685, 0xC03D, 0xC0E4, 0xC19E, 0xC1AA, 0xC1DF, 0xC86C, 0xC931, 0xC97C, 0xCAFE |
| `0x2091` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xC0F6, 0xC7AC, 0xC7AF, 0xC7C1, 0xC807 |
| `0x2093` | 1 | STAA ext:1 | 0xC03A |
| `0x2094` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC588, 0xC734, 0xCB4D |
| `0x2095` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC594, 0xC744, 0xCB57 |
| `0x2096` | 9 | LDAA ext:5, STAA ext:2, DEC ext:1, TST ext:1 | 0xC08B, 0xC0C0, 0xC0F3, 0xC124, 0xC1EE, 0xC1FE, 0xC361, 0xC5A8, 0xC8E7 |
| `0x2097` | 3 | STAA ext:2, TST ext:1 | 0x566C, 0x56F7, 0xC5C2 |
| `0x2098` | 11 | LDAA ext:7, INC ext:1, DEC ext:1, TST ext:1, STAA ext:1 | 0xC0CF, 0xC0FF, 0xC34D, 0xC398, 0xC3BB, 0xC3CA, 0xC3EA, 0xC400, 0xC43D, 0xC5CF |
| `0x2099` | 2 | STAA ext:1, TST ext:1 | 0xC227, 0xC5B5 |
| `0x209A` | 5 | STAA ext:3, LDAA ext:1, TST ext:1 | 0xC255, 0xC263, 0xC32F, 0xC5DC, 0xCAE3 |
| `0x209B` | 16 | STAA ext:9, LDAA ext:4, TST ext:1, DEC ext:1, INC ext:1 | 0xC0EA, 0xC187, 0xC457, 0xC4A3, 0xC4BB, 0xC4F2, 0xC510, 0xC53A, 0xC56B, 0xC5E9 |
| `0x209C` | 4 | LDD ext:2, STD ext:1, ADDD ext:1 | 0xC6F1, 0xC702, 0xC8A8, 0xC8B5 |
| `0x209E` | 4 | STD ext:3, LDD ext:1 | 0x6394, 0xC199, 0xC6E5, 0xC6E8 |
| `0x20A0` | 3 | STD ext:2, ADDD ext:1 | 0xC605, 0xC6C9, 0xC6EB |
| `0x20A2` | 3 | LDAA ext:2, STAB ext:1 | 0xC1BD, 0xC5F6, 0xC77E |
| `0x20A4` | 12 | STAA ext:5, LDAA ext:3, STAB ext:3, CLR ext:1 | 0x56BA, 0x6CD8, 0x6DB7, 0x96EC, 0x975C, 0xC1C3, 0xC5F9, 0xC731, 0xC784, 0xC9FA |
| `0x20A6` | 7 | STAA ext:3, LDAB ext:2, STD ext:1, STAB ext:1 | 0xC106, 0xC1C0, 0xC705, 0xC71A, 0xC72E, 0xC781, 0xC79A |
| `0x20A8` | 20 | LDAA ext:9, LDAB ext:5, CMPA ext:5, STAA ext:1 | 0x4A3A, 0x4A51, 0x5626, 0x984A, 0x9887, 0x998E, 0x9A60, 0x9A7A, 0x9ABB, 0xC086 |
| `0x20B1` | 9 | TST ext:5, LDAA ext:3, STAA ext:1 | 0x460A, 0x4907, 0xBF0A, 0xBF30, 0xCBA9, 0xCBFC, 0xE39E, 0xE3C0, 0xE942 |
| `0x20B9` | 15 | STD ext:6, CMPA ext:2, LDD ext:2, SUBD ext:2, LDAB ext:2, LDAA ext:1 | 0x61CE, 0x61D6, 0xCBB1, 0xCBC7, 0xCC98, 0xCDBC, 0xCDC8, 0xCDD3, 0xCDDF, 0xCDEA |
| `0x20BC` | 2 | STAA ext:2 | 0xBAB1, 0xBBEC |
| `0x20BD` | 1 | STAB ext:1 | 0xBB3A |
| `0x20BE` | 1 | STAB ext:1 | 0xBAE3 |
| `0x20BF` | 1 | STAB ext:1 | 0xBB00 |
| `0x20C0` | 1 | STAB ext:1 | 0xBB1D |
| `0x20C1` | 5 | STAA ext:3, LDAA ext:1, LDAB ext:1 | 0xAFF8, 0xAFFD, 0xB003, 0xBB6B, 0xBBC8 |
| `0x20C2` | 2 | STAA ext:2 | 0xBB37, 0xBC02 |
| `0x20C3` | 2 | STAA ext:2 | 0xBAE0, 0xBBF9 |
| `0x20C4` | 2 | STAA ext:2 | 0xBAFD, 0xBBFC |
| `0x20C5` | 2 | STAA ext:2 | 0xBB1A, 0xBBFF |
| `0x20D3` | 7 | LDAA ext:3, STAA ext:3, LDAB ext:1 | 0xB087, 0xB0EE, 0xB134, 0xB13A, 0xB1AC, 0xB1C8, 0xBBB3 |
| `0x20D4` | 7 | LDAA ext:5, STAA ext:2 | 0xB0FF, 0xB156, 0xB16F, 0xB188, 0xB1A1, 0xBA8E, 0xBBE0 |
| `0x20D5` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB198, 0xB1A4, 0xB1A9 |
| `0x20D6` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB14D, 0xB159, 0xB15E |
| `0x20D7` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB166, 0xB172, 0xB177 |
| `0x20D8` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB17F, 0xB18B, 0xB190 |
| `0x20D9` | 5 | LDAA ext:2, STAA ext:2, STX ext:1 | 0x9E48, 0xB193, 0xB19E, 0xB1C0, 0xBBB0 |
| `0x20DA` | 4 | LDAA ext:2, STAA ext:2 | 0xB148, 0xB153, 0xB1B1, 0xBBA7 |
| `0x20DB` | 4 | LDAA ext:2, STAA ext:2 | 0xB161, 0xB16C, 0xB1B6, 0xBBAA |
| `0x20DC` | 4 | LDAA ext:2, STAA ext:2 | 0xB17A, 0xB185, 0xB1BB, 0xBBAD |
| `0x20DD` | 2 | STAA ext:2 | 0xBA67, 0xBBF2 |
| `0x20DE` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4858, 0xB24D, 0xB269, 0xBBBF, 0xE5B3, 0xE5B8 |
| `0x20DF` | 6 | STAA ext:3, LDAB ext:1, ADDD ext:1, LDAA ext:1 | 0x4849, 0xA52D, 0xB1E1, 0xB260, 0xBBB6, 0xE5A0 |
| `0x20E0` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x484E, 0xB205, 0xB263, 0xBBB9, 0xE5A3, 0xE5A8 |
| `0x20E1` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4853, 0xB229, 0xB266, 0xBBBC, 0xE5AB, 0xE5B0 |
| `0x20E2` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48D2, 0x7D5D, 0x7D66, 0x95E8, 0xB258 |
| `0x20E3` | 7 | LDAB ext:2, LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48B4, 0x7A8E, 0x7B16, 0x7CFD, 0x7D06, 0x95DF, 0xB1EC |
| `0x20E4` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48BE, 0x7D3D, 0x7D46, 0x95E2, 0xB210 |
| `0x20E5` | 6 | LDAA ext:2, STAA ext:2, STAB ext:1, LDAB ext:1 | 0x48C8, 0x7A89, 0x7D1D, 0x7D26, 0x95E5, 0xB234 |
| `0x20E6` | 13 | LDAA ext:6, CMPA ext:5, STAA ext:2 | 0xB115, 0xB11A, 0xB1D9, 0xB1DE, 0xB1FD, 0xB202, 0xB221, 0xB226, 0xB245, 0xB24A |
| `0x20E7` | 3 | STAA ext:2, LDAA ext:1 | 0xBA74, 0xBBD4, 0xBD1E |
| `0x20E8` | 4 | STAA ext:2, LDAB ext:2 | 0xBA81, 0xBBDA, 0xBD40, 0xBD46 |
| `0x20E9` | 23 | LDAA ext:14, LDAB ext:6, STAA ext:3 | 0x7563, 0x7576, 0x75EA, 0x75FD, 0x7719, 0x7723, 0x7730, 0x7773, 0x778A, 0x7851 |
| `0x20EB` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9A, 0xBC67, 0xBC7A, 0xBD39 |
| `0x20ED` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9D, 0xBCB1, 0xBCC1, 0xBD4F |
| `0x2132` | 7 | STD ext:3, LDD ext:2, SUBD ext:1, LDX ext:1 | 0x4427, 0x4653, 0x465E, 0x4675, 0x467F, 0x4690, 0x9231 |
| `0x2134` | 2 | STD ext:2 | 0x442B, 0x49C5 |
| `0x2147` | 21 | STD ext:10, ADDD ext:6, LDY ext:1, LDX ext:1, STY ext:1, STX ext:1, LDD ext:1 | 0x4481, 0x454E, 0x4551, 0x45C4, 0x45DB, 0x45DC, 0x45E1, 0x45E2, 0x4602, 0x4605 |
| `0x2148` | 6 | LDAA ext:3, STAA ext:2, STAB ext:1 | 0x468C, 0x4756, 0x476A, 0x4862, 0x4874, 0x4936 |
| `0x2149` | 4 | STAB ext:1, TST ext:1, LDAA ext:1, DEC ext:1 | 0x46E5, 0x4702, 0x4772, 0x4777 |
| `0x214C` | 3 | LDAA ext:2, STAA ext:1 | 0x48DD, 0x48E6, 0x496D |
| `0x2122` | 3 | STD ext:2, LDAA ext:1 | 0x40E1, 0x433D, 0x4346 |
| `0x2124` | 3 | STD ext:2, LDAA ext:1 | 0x40C3, 0x438D, 0x4396 |
| `0x21C6` | 5 | STD ext:2, LDD ext:1, SUBD ext:1, STX ext:1 | 0x6FC0, 0x6FD1, 0x724C, 0x7298, 0x72A9 |
| `0x21C8` | 9 | LDD ext:4, STD ext:3, SUBD ext:2 | 0x6F65, 0x6FB0, 0x7024, 0x7075, 0x708A, 0x709C, 0x70CD, 0x70DF, 0x70F0 |
| `0x21CB` | 6 | ADDD ext:4, STD ext:1, SUBD ext:1 | 0x7062, 0x707C, 0x7090, 0x70C4, 0x70E5, 0x70F6 |
| `0x21CD` | 3 | STD ext:2, SUBD ext:1 | 0x704A, 0x70A7, 0x70ED |
| `0x21CF` | 4 | STD ext:2, LDD ext:1, ADDD ext:1 | 0x6FF1, 0x7034, 0x712C, 0x7219 |
| `0x2312` | 3 | LDY imm:2, STAA ext:1 | 0x7583, 0x7CF9, 0x9587 |
| `0x231E` | 3 | LDY imm:2, STAA ext:1 | 0x7570, 0x7D39, 0x958A |
| `0x232A` | 3 | LDY imm:2, STAA ext:1 | 0x757D, 0x7D19, 0x958D |
| `0x2336` | 3 | LDY imm:2, STAA ext:1 | 0x756A, 0x7D59, 0x9590 |
| `0x2348` | 14 | STD ext:6, LDD ext:6, ADDD ext:2 | 0x7CF6, 0x7D16, 0x7D36, 0x7D56, 0x7D74, 0x7D7E, 0x7DF4, 0x7E04, 0x7E55, 0x7E60 |
| `0x234A` | 9 | DEC ext:3, STD ext:2, STAA ext:1, CLR ext:1, ADDD ext:1, SUBD ext:1 | 0x7D84, 0x7DA9, 0x7DAC, 0x7DC3, 0x7E01, 0x7E12, 0x7E1D, 0x7E52, 0x7E58 |
| `0x234C` | 2 | STAA ext:1, DEC ext:1 | 0x7E4B, 0x7E5B |
| `0x234D` | 5 | STD ext:3, LDX ext:1, LDD ext:1 | 0x7DF0, 0x7DFD, 0x7E29, 0x7E3A, 0x7E68 |
| `0x2354` | 4 | LDAB ext:2, LDAA ext:1, STAB ext:1 | 0x7A07, 0x7A0F, 0x7F0C, 0x7F2E |
| `0x235C` | 13 | STD ext:2, SUBD ext:2, LDX ext:2, INC ext:2, LDD ext:1, STX ext:1, CLR ext:1, TST ext:1, DEC ext:1 | 0x78C9, 0x78EF, 0x7912, 0x7924, 0x7945, 0x7998, 0x7EBF, 0x7ED2, 0x7EDD, 0x7EF5 |
| `0x235E` | 4 | STX ext:1, LDAB ext:1, STD ext:1, ADDD ext:1 | 0x790F, 0x796C, 0x7EE8, 0x7EF2 |
| `0x2369` | 3 | STD ext:2, SUBD ext:1 | 0x7E88, 0x7EAB, 0x7F02 |
| `0x2376` | 2 | STD ext:1, LDX ext:1 | 0x7DE1, 0x7E6E |
| `0x2380` | 8 | LDD ext:4, STD ext:3, ADDD ext:1 | 0x7763, 0x7B74, 0x7B8B, 0x7D7A, 0x7DED, 0x7E4E, 0x7F08, 0x7F14 |
| `0x2382` | 7 | STX ext:3, LDD ext:2, LDAB ext:1, ADDD ext:1 | 0x7766, 0x7B77, 0x7B8E, 0x7DE4, 0x7ECD, 0x7EE4, 0x7EFA |
| `0x242B` | 3 | LDD ext:1, SUBD ext:1, STD ext:1 | 0xBC64, 0xBC76, 0xBD1B |
| `0x242D` | 2 | STD ext:1, SUBD ext:1 | 0xBCAE, 0xBCBD |
| `0x242F` | 5 | STD ext:2, ADDD ext:2, LDAA ext:1 | 0xBAB5, 0xBABE, 0xBAC6, 0xBB49, 0xBB53 |
| `0x2431` | 2 | STAA ext:2 | 0xBB68, 0xBB79 |
| `0x243C` | 10 | STD ext:2, CMPA ext:2, INC ext:1, STAA ext:1, LDD ext:1, CPX ext:1, STX ext:1, LDAA ext:1 | 0xC260, 0xC2C1, 0xC2D9, 0xC2DC, 0xC2E1, 0xC2EE, 0xC2F9, 0xC2FC, 0xC301, 0xC304 |
| `0x243E` | 3 | STAA ext:1, LDAA ext:1, LDAB ext:1 | 0xC2AC, 0xC31A, 0xC31F |
| `0x243F` | 6 | LDAA ext:4, STAA ext:2 | 0xC0A3, 0xC0B5, 0xC131, 0xC1E9, 0xC938, 0xC93E |
| `0x244C` | 2 | STAA ext:1, LDAA ext:1 | 0xC13E, 0xC1F8 |
| `0x245E` | 3 | STAA ext:2, DEC ext:1 | 0xC141, 0xC1F3, 0xC1FB |
| `0x2462` | 6 | LDAA ext:3, STAA ext:2, DEC ext:1 | 0xC4CC, 0xC4D1, 0xC546, 0xC54B, 0xC941, 0xC946 |
| `0x2463` | 6 | TST ext:2, DEC ext:2, STAA ext:2 | 0xC099, 0xC09E, 0xC0D8, 0xC0DD, 0xC110, 0xC190 |
| `0x2464` | 4 | LDAA ext:2, STAA ext:2 | 0xC1B8, 0xC1DC, 0xC927, 0xC92E |
| `0x2465` | 4 | STAA ext:2, LDAA ext:2 | 0xC1D4, 0xC779, 0xC918, 0xC924 |
| `0x249B` | 6 | STD ext:4, LDD ext:1, SUBD ext:1 | 0xCBB4, 0xCBCA, 0xCC9B, 0xCE04, 0xCE14, 0xCE5B |
| `0x24AB` | 2 | LDAA ext:1, STAA ext:1 | 0xCD51, 0xD134 |
| `0x24AC` | 2 | LDAA ext:1, STAA ext:1 | 0xCD04, 0xD140 |
| `0x24AD` | 2 | LDD ext:1, STD ext:1 | 0xCD0A, 0xD151 |
| `0x24AF` | 2 | LDAB ext:1, STAA ext:1 | 0xCD8C, 0xD15D |
| `0x24B0` | 6 | STD ext:4, ADDD ext:1, SUBD ext:1 | 0xCDB9, 0xCDC3, 0xCDCB, 0xCDDA, 0xCDE2, 0xCDFE |
| `0x2483` | 4 | STAB ext:1, LDAB ext:1, DEC ext:1, STAA ext:1 | 0xBEEA, 0xBEF2, 0xBEFC, 0xCB8C |
| `0x2484` | 3 | STAA ext:2, LDAB ext:1 | 0xBE93, 0xBEAF, 0xCB86 |
| `0x2486` | 2 | STAA ext:2 | 0xBEA0, 0xCB7D |
| `0x2488` | 1 | STAA ext:1 | 0xBECB |
| `0x248D` | 3 | STAA ext:2, LDAA ext:1 | 0xBF19, 0xBF20, 0xBF49 |
| `0x248E` | 2 | STAA ext:2 | 0xBF3F, 0xBF46 |
| `0x2584` | 3 | STD ext:2, SUBD ext:1 | 0xE4F9, 0xE58D, 0xE663 |
| `0x2590` | 3 | STD ext:2, ADDD ext:1 | 0xE3F4, 0xE4DB, 0xE65E |
| `0x2596` | 6 | ADDD ext:3, STD ext:2, SUBD ext:1 | 0xE780, 0xE903, 0xE913, 0xE921, 0xE924, 0xE92E |
| `0x25A3` | 6 | LDY imm:2, STD ext:2, ADDD ext:2 | 0xE84B, 0xE86C, 0xE931, 0xE93B, 0xE93F, 0xE953 |
| `0x2610` | 10 | STAB ext:4, LDAB ext:3, STX ext:2, CLR ext:1 | 0x4EDC, 0x6A37, 0x6B2C, 0x6B37, 0x6B46, 0x6B96, 0x6BA1, 0x6BB0, 0xCB10, 0xE948 |

### `xantia_607c`

| Address | Count | Operations | First sites |
| --- | ---: | --- | --- |
| `0x0060` | 1 | STX dir:1 | 0xDF5C |
| `0x0069` | 3 | LDAA dir:2, LDY imm:1 | 0xD9A2, 0xDA02, 0xDA14 |
| `0x005D` | 2 | LDY imm:2 | 0xCB73, 0xCB92 |
| `0x005E` | 0 | - | - |
| `0x005F` | 2 | STAA dir:1, LDD dir:1 | 0xBD8B, 0xD7E5 |
| `0x00B6` | 19 | STAA dir:4, LDAA dir:3, STX dir:2, LDX dir:2, SUBD dir:2, CMPA dir:1, LDD dir:1, STD dir:1, STAB dir:1, CLR ext:1, ADDD dir:1 | 0x5E39, 0x5F41, 0x6C71, 0x6C77, 0x6C7D, 0x6C83, 0x6DE2, 0x73D3, 0x73E0, 0x7701 |
| `0x00BC` | 3 | CMPA dir:3 | 0x6017, 0x605F, 0xEE77 |
| `0x00BF` | 2 | LDAA dir:1, LDX dir:1 | 0x80C2, 0xDEC0 |
| `0x00C1` | 8 | LDAA dir:4, LDAB dir:2, LDX dir:1, STAB dir:1 | 0xAE25, 0xE5C8, 0xE5CF, 0xE5DD, 0xE708, 0xE82A, 0xE862, 0xE879 |
| `0x00C3` | 3 | CMPA dir:1, LDAA dir:1, LDX dir:1 | 0x604C, 0x712E, 0x7A6C |
| `0x00C5` | 8 | CMPA dir:4, CLR ext:2, LDAB dir:1, LDAA dir:1 | 0x60FB, 0x93BA, 0x93F9, 0x9420, 0xE918, 0xEB17, 0xEBBC, 0xEBE7 |
| `0x00C6` | 17 | CMPA dir:5, LDD dir:5, STD dir:3, ADDD dir:2, STAA dir:1, STX dir:1 | 0x56B4, 0x595B, 0x6151, 0x63A9, 0x6A3B, 0x9398, 0x9470, 0x9497, 0x9A4C, 0xA529 |
| `0x00CC` | 8 | CMPA dir:4, STAA dir:1, STAB dir:1, ADDD dir:1, CPX dir:1 | 0x582E, 0x6126, 0x617C, 0x9352, 0x9404, 0x947B, 0xBCDD, 0xEDEB |
| `0x00CE` | 10 | LDX dir:2, CMPA dir:2, CPX dir:2, CPY dir:1, LDAB dir:1, STAB dir:1, SUBD dir:1 | 0x5049, 0x58B2, 0x9263, 0x9264, 0xA6FE, 0xD258, 0xDBF2, 0xDECF, 0xEDBE, 0xEF12 |
| `0x00D0` | 26 | LDAA dir:10, CMPA dir:8, STAA dir:3, LDAB dir:3, STAB dir:1, CMPB dir:1 | 0x4096, 0x429D, 0x42CC, 0x5F92, 0x6227, 0x803B, 0x9828, 0x9865, 0x996C, 0x997A |
| `0x100B` | 3 | STAA ext:3 | 0x766E, 0xB2B2, 0xD448 |
| `0x100E` | 27 | LDD ext:25, ADDD ext:2 | 0x502F, 0x505B, 0x5246, 0x542B, 0x5912, 0x6D89, 0x6FA2, 0x7075, 0x710C, 0x7267 |
| `0x1016` | 2 | STD ext:2 | 0x6FA8, 0x7072 |
| `0x1018` | 18 | STD ext:13, LDD ext:2, ADDD ext:2, SUBD ext:1 | 0x7686, 0x769A, 0x7A3B, 0x7A70, 0x7AB5, 0x7ADB, 0x7CE0, 0x7D09, 0x9284, 0x9289 |
| `0x101A` | 13 | STD ext:10, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x6D8C, 0x7132, 0x7143, 0x716E, 0x7181, 0x7184, 0x7195, 0x71A6, 0x726A, 0xA933 |
| `0x101C` | 5 | STD ext:4, LDD ext:1 | 0x5035, 0x5061, 0x50C7, 0x50CD, 0xE001 |
| `0x1020` | 7 | STAA ext:4, CMPA ext:1, LDAA ext:1, CLR ext:1 | 0x57B8, 0x6C72, 0x6DD9, 0x6E4F, 0xB2AD, 0xB958, 0xD930 |
| `0x1022` | 5 | CLR ext:3, LDAA ext:1, STAA ext:1 | 0x4FA5, 0x6C6C, 0x6C8D, 0x6E49, 0xD933 |
| `0x1023` | 38 | STAA ext:23, STAB ext:10, LDAA ext:5 | 0x503A, 0x5066, 0x50D2, 0x515E, 0x51B4, 0x51CD, 0x520B, 0x5222, 0x522F, 0x52E1 |
| `0x1028` | 4 | STAA ext:4 | 0x9EEE, 0x9EF6, 0xA015, 0xA018 |
| `0x1029` | 20 | LDAA ext:18, LDAB ext:2 | 0x9EE6, 0x9F00, 0x9F16, 0x9F2E, 0x9F3E, 0x9F4C, 0x9F5A, 0x9F68, 0x9F76, 0x9F84 |
| `0x102A` | 18 | STAB ext:13, STAA ext:3, LDAA ext:2 | 0x9EE9, 0x9F31, 0x9F41, 0x9F4F, 0x9F5D, 0x9F6B, 0x9F79, 0x9F87, 0x9F95, 0x9FA4 |
| `0x1030` | 14 | STAA ext:14 | 0x40E8, 0x4133, 0x5277, 0x5359, 0xB82F, 0xB8C3, 0xDB6F, 0xDB8C, 0xDEB4, 0xDF01 |
| `0x1031` | 6 | LDAA ext:4, LDY imm:2 | 0x401E, 0x4113, 0x5454, 0xDBBC, 0xDF4C, 0xE21A |
| `0x1032` | 5 | LDAA ext:4, LDY imm:1 | 0x403B, 0x4140, 0x5330, 0x5461, 0xDF35 |
| `0x1033` | 7 | LDAA ext:6, LDY imm:1 | 0x4024, 0x4041, 0x4119, 0x4146, 0x533D, 0x546E, 0xDF1B |
| `0x1034` | 7 | LDAA ext:6, LDY imm:1 | 0x402D, 0x405A, 0x411F, 0x414C, 0x534A, 0x547B, 0xDF63 |
| `0x1050` | 40 | STAA ext:24, LDAA ext:15, CLR ext:1 | 0x4FC6, 0x516B, 0x5170, 0x5173, 0x5178, 0x51D0, 0x51D5, 0x5236, 0x523B, 0x524B |
| `0x2001` | 10 | STX ext:6, STAA ext:3, STAB ext:1 | 0x4430, 0x46AF, 0x46BB, 0x47DE, 0x52F8, 0x550A, 0x5CE1, 0x5F60, 0x9A17, 0xD8C0 |
| `0x2002` | 4 | STX ext:3, STAA ext:1 | 0x490B, 0x7EFB, 0xA9BB, 0xC748 |
| `0x2007` | 5 | LDAA ext:3, STAA ext:2 | 0x4044, 0x4149, 0x5F29, 0x5F7E, 0x96FA |
| `0x2008` | 6 | LDAA ext:4, STAA ext:2 | 0x4021, 0x40CE, 0x4116, 0x4322, 0x5CAB, 0x9710 |
| `0x2009` | 7 | LDAA ext:3, STAA ext:2, CLR ext:1, LDX ext:1 | 0x40D7, 0x432B, 0x5C32, 0x5C56, 0x5D7B, 0xC653, 0xEA49 |
| `0x200A` | 8 | LDAA ext:4, STAA ext:2, CMPB ext:1, STX ext:1 | 0x4030, 0x40B0, 0x4123, 0x4372, 0x5DB1, 0x66CB, 0x971A, 0xD08F |
| `0x200B` | 4 | STAA ext:2, LDAA ext:1, STX ext:1 | 0x40B9, 0x437B, 0x5DEF, 0x956F |
| `0x200C` | 4 | STAA ext:2, LDAA ext:2 | 0x403E, 0x4143, 0x5BAD, 0x5C20 |
| `0x200D` | 3 | STAA ext:2, LDAA ext:1 | 0x4027, 0x411C, 0x415D |
| `0x200E` | 10 | LDAA ext:5, STAA ext:2, TST ext:2, SUBD ext:1 | 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x4D46, 0x5E3A, 0x9701, 0xBB18, 0xD4A0 |
| `0x2013` | 13 | CMPA ext:6, STAA ext:3, CMPB ext:2, LDAB ext:1, TST ext:1 | 0x404D, 0x4128, 0x5756, 0x5FBF, 0x9776, 0x9793, 0x98E3, 0x9962, 0x998D, 0x99CF |
| `0x202B` | 4 | STAA ext:2, LDAA ext:1, DEC ext:1 | 0xB358, 0xBA23, 0xBAB7, 0xBAC5 |
| `0x202C` | 9 | LDAA ext:6, STAA ext:2, LDAB ext:1 | 0xBA6D, 0xBB56, 0xBB93, 0xBBBE, 0xBBFE, 0xC069, 0xCFD9, 0xD065, 0xE760 |
| `0x2030` | 0 | - | - |
| `0x2034` | 3 | STD ext:2, ADDD ext:1 | 0xE720, 0xE72B, 0xE8DC |
| `0x2036` | 5 | LDD ext:3, STD ext:1, SUBD ext:1 | 0xE68C, 0xE6A0, 0xE6A8, 0xE6B0, 0xE731 |
| `0x2038` | 4 | LDD ext:3, STD ext:1 | 0xE749, 0xE768, 0xE783, 0xE78B |
| `0x203A` | 2 | STD ext:1, SUBD ext:1 | 0xE69C, 0xE798 |
| `0x203C` | 18 | TST ext:10, LDAA ext:7, STAB ext:1 | 0x46F9, 0x4A07, 0x4A69, 0x568C, 0x5737, 0x589B, 0x6F3B, 0x984D, 0x988A, 0x9D31 |
| `0x203E` | 1 | CPX ext:1 | 0x92ED |
| `0x2040` | 1 | STAB ext:1 | 0xD89A |
| `0x2042` | 1 | STAB ext:1 | 0xD67D |
| `0x2049` | 2 | STD ext:1, LDD ext:1 | 0x43B5, 0x49CC |
| `0x204A` | 0 | - | - |
| `0x204B` | 14 | LDD ext:11, LDAB ext:2, STD ext:1 | 0x4361, 0x4421, 0x44D6, 0x5680, 0x72BA, 0x736A, 0x95F7, 0x9B5B, 0xC325, 0xC846 |
| `0x204D` | 16 | LDD ext:15, STD ext:1 | 0x4365, 0x49C0, 0x4A37, 0x71C0, 0x71D7, 0x7202, 0xC01E, 0xC18D, 0xC19A, 0xC1A7 |
| `0x204E` | 0 | - | - |
| `0x204F` | 5 | LDD ext:4, STD ext:1 | 0x4400, 0x9540, 0xD6E3, 0xD7F9, 0xE997 |
| `0x2050` | 0 | - | - |
| `0x2051` | 6 | LDD ext:5, STD ext:1 | 0x41EC, 0x57E0, 0x97BE, 0xE39D, 0xE49F, 0xEAB3 |
| `0x2053` | 5 | LDD ext:3, STD ext:2 | 0xC316, 0xCC58, 0xD1F9, 0xD59F, 0xD7BC |
| `0x2055` | 2 | LDD ext:1, STD ext:1 | 0x4710, 0xD5AD |
| `0x2057` | 5 | LDAB ext:1, LDAA ext:1, TST ext:1, STAA ext:1, CLR ext:1 | 0x9513, 0x951C, 0x9528, 0xD803, 0xDFB1 |
| `0x2059` | 3 | STAA ext:2, LDAB ext:1 | 0xE89B, 0xE9C2, 0xEA61 |
| `0x2060` | 3 | STD ext:2, LDD ext:1 | 0x6FF5, 0xE7A2, 0xE8C3 |
| `0x2062` | 5 | LDAB ext:2, LDAA ext:1, STAB ext:1, STAA ext:1 | 0xCC83, 0xE585, 0xE656, 0xE65C, 0xE8C9 |
| `0x2084` | 6 | STD ext:3, ADDD ext:2, SUBD ext:1 | 0xE427, 0xE455, 0xE45A, 0xE468, 0xE470, 0xEABC |
| `0x2085` | 0 | - | - |
| `0x2086` | 3 | STAA ext:2, LDAA ext:1 | 0x99BD, 0x9A41, 0x9A47 |
| `0x2090` | 1 | STD ext:1 | 0xE4D8 |
| `0x2091` | 0 | - | - |
| `0x2093` | 0 | - | - |
| `0x2094` | 2 | STAA ext:2 | 0xE381, 0xE8AD |
| `0x2095` | 3 | STAA ext:2, LDAA ext:1 | 0xE60D, 0xE8B0, 0xE994 |
| `0x2096` | 6 | STD ext:3, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x7119, 0x712C, 0x7151, 0xD6DB, 0xD70E, 0xD7E0 |
| `0x2097` | 0 | - | - |
| `0x2098` | 2 | LDAB ext:1, INC ext:1 | 0x5FC6, 0x7D6A |
| `0x2099` | 1 | INC ext:1 | 0x7B20 |
| `0x209A` | 1 | INC ext:1 | 0x7B51 |
| `0x209B` | 1 | INC ext:1 | 0x74FB |
| `0x209C` | 3 | SUBD ext:1, STX ext:1, STD ext:1 | 0x74F6, 0x77C4, 0x9596 |
| `0x209E` | 1 | INC ext:1 | 0x965F |
| `0x20A0` | 12 | LDAA ext:9, STAA ext:2, STAB ext:1 | 0x570D, 0x5886, 0xC03D, 0xC098, 0xC157, 0xC221, 0xC22D, 0xC262, 0xC899, 0xC95E |
| `0x20A2` | 0 | - | - |
| `0x20A4` | 6 | STAA ext:3, LDAB ext:1, LDAA ext:1, LDY imm:1 | 0xC056, 0xC07A, 0xC219, 0xC76B, 0xCB88, 0xCBA7 |
| `0x20A6` | 2 | STAA ext:2 | 0x56F4, 0x577F |
| `0x20A8` | 1 | STAA ext:1 | 0xC2AA |
| `0x20B1` | 3 | LDAA ext:2, STAA ext:1 | 0xC240, 0xC62E, 0xC7B5 |
| `0x20B9` | 18 | LDAA ext:15, STAB ext:2, STAA ext:1 | 0x4801, 0x4817, 0x4A0C, 0x6031, 0x6F42, 0x983D, 0x987A, 0xB427, 0xBD69, 0xC2C4 |
| `0x20BC` | 0 | - | - |
| `0x20BD` | 7 | LDD ext:3, STD ext:2, ADDD ext:1, SUBD ext:1 | 0xB3F5, 0xB3FF, 0xB405, 0xBD93, 0xBDD8, 0xBDE6, 0xEE0A |
| `0x20BE` | 0 | - | - |
| `0x20BF` | 6 | STAA ext:2, STAB ext:1, LDAA ext:1, CMPA ext:1, CLR ext:1 | 0xB455, 0xBD6F, 0xC0BA, 0xC1D4, 0xECCB, 0xED54 |
| `0x20C0` | 7 | TST ext:5, LDAA ext:1, STAA ext:1 | 0x4632, 0x4980, 0xCBBE, 0xCC1C, 0xE33E, 0xE360, 0xEA7B |
| `0x20C1` | 6 | STAA ext:4, LDAA ext:2 | 0xCCF5, 0xCD9A, 0xCDD5, 0xCE63, 0xD1B0, 0xD1B6 |
| `0x20C2` | 11 | LDX ext:7, STX ext:3, STD ext:1 | 0x62DE, 0xD1E2, 0xD1E8, 0xD2B9, 0xD341, 0xD348, 0xD368, 0xD380, 0xD3A8, 0xD3BB |
| `0x20C3` | 0 | - | - |
| `0x20C4` | 9 | DEC ext:3, STAB ext:2, LDAA ext:2, STAA ext:2 | 0xCF06, 0xCF1B, 0xCFB6, 0xCFCB, 0xCFFD, 0xD00F, 0xD0E3, 0xD0F6, 0xD14F |
| `0x20C5` | 4 | LDAA ext:1, DEC ext:1, CLR ext:1, STAA ext:1 | 0xCEDF, 0xCF23, 0xCF2E, 0xD19D |
| `0x20D3` | 0 | - | - |
| `0x20D4` | 0 | - | - |
| `0x20D5` | 0 | - | - |
| `0x20D6` | 0 | - | - |
| `0x20D7` | 0 | - | - |
| `0x20D8` | 0 | - | - |
| `0x20D9` | 0 | - | - |
| `0x20DA` | 0 | - | - |
| `0x20DB` | 0 | - | - |
| `0x20DC` | 0 | - | - |
| `0x20DD` | 0 | - | - |
| `0x20DE` | 0 | - | - |
| `0x20DF` | 1 | ADDD ext:1 | 0xA527 |
| `0x20E0` | 0 | - | - |
| `0x20E1` | 0 | - | - |
| `0x20E2` | 0 | - | - |
| `0x20E3` | 0 | - | - |
| `0x20E4` | 0 | - | - |
| `0x20E5` | 0 | - | - |
| `0x20E6` | 0 | - | - |
| `0x20E7` | 0 | - | - |
| `0x20E8` | 0 | - | - |
| `0x20E9` | 0 | - | - |
| `0x20EB` | 0 | - | - |
| `0x20ED` | 0 | - | - |
| `0x2132` | 4 | LDAA ext:3, STAA ext:1 | 0x40BF, 0x4384, 0x5D2C, 0x5E08 |
| `0x2134` | 0 | - | - |
| `0x2147` | 4 | STAA ext:4 | 0x4446, 0x4AC2, 0x4ADA, 0x4AE4 |
| `0x2148` | 4 | LDAB ext:2, STAA ext:1, STAB ext:1 | 0x4449, 0x4AF1, 0x4AFE, 0x4B0F |
| `0x2149` | 4 | STAA ext:2, LDAA ext:1, LDAB ext:1 | 0x447A, 0x4AE7, 0x4AFB, 0x4B06 |
| `0x214C` | 0 | - | - |
| `0x2122` | 5 | STD ext:4, LDD ext:1 | 0x409E, 0x42D4, 0x430A, 0xB22A, 0xD46B |
| `0x2124` | 0 | - | - |
| `0x21C6` | 0 | - | - |
| `0x21C8` | 0 | - | - |
| `0x21CB` | 6 | STAA ext:2, LDAB ext:2, STAB ext:1, LDAA ext:1 | 0x69CE, 0x6CBB, 0x6CC4, 0x6D2D, 0x6DC5, 0x6F0F |
| `0x21CD` | 2 | STAA ext:2 | 0x6B67, 0x6F2F |
| `0x21CF` | 0 | - | - |
| `0x2312` | 0 | - | - |
| `0x231E` | 0 | - | - |
| `0x232A` | 1 | SUBD ext:1 | 0x6FC2 |
| `0x2336` | 0 | - | - |
| `0x2348` | 0 | - | - |
| `0x234A` | 0 | - | - |
| `0x234C` | 0 | - | - |
| `0x234D` | 0 | - | - |
| `0x2354` | 0 | - | - |
| `0x235C` | 0 | - | - |
| `0x235E` | 0 | - | - |
| `0x2369` | 0 | - | - |
| `0x2376` | 0 | - | - |
| `0x2380` | 2 | STD ext:1, SUBD ext:1 | 0x7B72, 0x7B7F |
| `0x2382` | 2 | STD ext:1, SUBD ext:1 | 0x7A34, 0x7A5D |
| `0x242B` | 4 | STAA ext:2, LDAA ext:1, DEC ext:1 | 0x6DE3, 0x9B0B, 0xA6F2, 0xAD87 |
| `0x242D` | 2 | SUBD ext:1, STD ext:1 | 0xC288, 0xC28D |
| `0x242F` | 3 | INC ext:2, STAA ext:1 | 0xC63A, 0xC669, 0xC691 |
| `0x2431` | 0 | - | - |
| `0x243C` | 4 | CLR ext:2, LDAA ext:1, INC ext:1 | 0xC43B, 0xC455, 0xC488, 0xC498 |
| `0x243E` | 3 | STAA ext:2, LDAA ext:1 | 0xC8E7, 0xC8EC, 0xC90B |
| `0x243F` | 4 | STAA ext:2, LDAA ext:1, CLR ext:1 | 0xC880, 0xC885, 0xC893, 0xC8FD |
| `0x244C` | 0 | - | - |
| `0x245E` | 1 | STAA ext:1 | 0xC06F |
| `0x2462` | 16 | STAA ext:7, TST ext:4, LDAA ext:3, CLR ext:2 | 0x5025, 0x5045, 0x5069, 0x50A3, 0x50B4, 0x556F, 0x64EE, 0x655C, 0x657B, 0xB2CB |
| `0x2463` | 6 | STAA ext:3, LDAB ext:1, STAB ext:1, CLR ext:1 | 0xB2D0, 0xB2E6, 0xB315, 0xB322, 0xB32B, 0xB34C |
| `0x2464` | 8 | STAA ext:6, DEC ext:1, STAB ext:1 | 0x5008, 0x509E, 0x5552, 0x6540, 0x6569, 0xB2F5, 0xB310, 0xDD21 |
| `0x2465` | 11 | STX ext:7, LDX ext:2, LDY ext:1, STD ext:1 | 0x5020, 0x508E, 0x5099, 0x556A, 0x6543, 0x6570, 0xB2EE, 0xB2F2, 0xB339, 0xB33A |
| `0x249B` | 0 | - | - |
| `0x24AB` | 3 | STD ext:2, ADDD ext:1 | 0xD83A, 0xD842, 0xD845 |
| `0x24AC` | 0 | - | - |
| `0x24AD` | 5 | STD ext:3, ADDD ext:2 | 0xD852, 0xD85E, 0xD861, 0xD869, 0xD86C |
| `0x24AF` | 1 | STD ext:1 | 0xD887 |
| `0x24B0` | 0 | - | - |
| `0x2483` | 0 | - | - |
| `0x2484` | 9 | STD ext:6, ADDD ext:2, LDD ext:1 | 0xCD07, 0xCDA0, 0xCDA4, 0xCDB2, 0xCDCA, 0xCDE9, 0xCDF6, 0xCDFE, 0xCE75 |
| `0x2486` | 2 | LDY imm:1, STD ext:1 | 0xD1F5, 0xD25F |
| `0x2488` | 0 | - | - |
| `0x248D` | 2 | LDAA ext:1, STAA ext:1 | 0xCDA8, 0xD22D |
| `0x248E` | 2 | LDAA ext:1, STAA ext:1 | 0xCD5B, 0xD239 |
| `0x2584` | 4 | STAA ext:2, LDAB ext:2 | 0xE5B7, 0xE672, 0xE678, 0xE8CC |
| `0x2590` | 0 | - | - |
| `0x2596` | 4 | STAA ext:2, LDAB ext:2 | 0xEDF8, 0xEE72, 0xEF0A, 0xEF0D |
| `0x25A3` | 1 | LDAA ext:1 | 0xEE46 |
| `0x2610` | 11 | STAB ext:4, LDAB ext:3, STX ext:2, STAA ext:1, CLR ext:1 | 0x4F64, 0x6257, 0x6AD4, 0x6BC9, 0x6BD4, 0x6BE3, 0x6C33, 0x6C3E, 0x6C4D, 0xCB3D |

### `peug_106rally_org`

| Address | Count | Operations | First sites |
| --- | ---: | --- | --- |
| `0x0060` | 1 | LDY imm:1 | 0xCB46 |
| `0x0069` | 6 | LDY imm:3, LDAA dir:2, CMPA dir:1 | 0x63DD, 0xCB50, 0xCC21, 0xD89E, 0xD8FE, 0xD910 |
| `0x005D` | 14 | LDAA dir:4, CMPA dir:3, STAA dir:3, STAB dir:2, INC ext:1, DEC ext:1 | 0x56BD, 0x63AA, 0x642C, 0x643F, 0x6CD4, 0x6DB5, 0xC1B1, 0xC1C6, 0xC6FD, 0xC787 |
| `0x005E` | 12 | STAA dir:3, LDAA dir:2, LDAB dir:2, CMPA dir:1, INC ext:1, DEC ext:1, STAB dir:1, CLR ext:1 | 0x6020, 0x639B, 0x642F, 0x6435, 0x643B, 0x6442, 0x6446, 0x644D, 0xC9EE, 0xCA91 |
| `0x005F` | 8 | STAB dir:2, STAA dir:1, LDX dir:1, CLR ext:1, LDAA dir:1, LDAB dir:1, LDD dir:1 | 0x63A8, 0x6423, 0x6CC7, 0xA2BE, 0xCA10, 0xCB0D, 0xD14B, 0xD6E1 |
| `0x00B6` | 20 | LDAA dir:6, STAB dir:3, STAA dir:2, ADDD dir:2, LDD dir:2, CMPA dir:1, STX ext:1, STX dir:1, LDAB dir:1, SUBD dir:1 | 0x41E2, 0x4424, 0x46D0, 0x48AA, 0x67F1, 0x96D7, 0x9733, 0xB0F0, 0xB13C, 0xB160 |
| `0x00BC` | 24 | STD dir:11, SUBD dir:6, LDD dir:5, ADDD dir:2 | 0x6F6F, 0x6F84, 0x6F89, 0x6F91, 0x6F9F, 0x6FA6, 0x6FF4, 0x7014, 0x702C, 0x7032 |
| `0x00BF` | 7 | LDD dir:3, SUBD dir:2, STD dir:2 | 0x6E9A, 0x6F7D, 0x6F86, 0x6F9D, 0x721D, 0xD5D5, 0xD5FE |
| `0x00C1` | 39 | STD dir:14, LDD dir:8, LDAA dir:6, ADDD dir:5, SUBD dir:4, CMPB dir:1, LDX dir:1 | 0x58DA, 0x6E9E, 0x6ED6, 0x6EDD, 0x6EE8, 0x9989, 0xAE2B, 0xE5F1, 0xE605, 0xE611 |
| `0x00C3` | 11 | LDD dir:5, STD dir:4, STX dir:2 | 0x6EEA, 0x6F6C, 0x6F73, 0x6FA3, 0x7010, 0x7029, 0x79B5, 0x9B46, 0xDFC8, 0xE6D3 |
| `0x00C5` | 11 | STAA dir:4, LDAA dir:4, STD dir:2, LDAB dir:1 | 0x9676, 0xE647, 0xE7D7, 0xE9C7, 0xEA21, 0xEA26, 0xEA49, 0xEA78, 0xEA7D, 0xEA8B |
| `0x00C6` | 10 | LDAA dir:2, LDX dir:2, CLR ext:2, SUBD dir:1, STX dir:1, ADDD dir:1, LDAB dir:1 | 0x5C55, 0x63EE, 0xA2B1, 0xA2D1, 0xA52F, 0xA53B, 0xE7D9, 0xE9C9, 0xEA43, 0xEA6E |
| `0x00CC` | 13 | LDAA dir:7, LDD dir:2, STD dir:2, CMPB dir:1, ADDD dir:1 | 0x43C7, 0x43D5, 0x43F3, 0x6084, 0x60DA, 0x80EA, 0x9387, 0x93A9, 0x93E6, 0x945D |
| `0x00CE` | 19 | LDD dir:12, LDX dir:2, ADDD dir:2, STX dir:1, STD dir:1, CPX dir:1 | 0x4073, 0x409C, 0x412B, 0x41A1, 0x42E1, 0x45F3, 0x4FC1, 0x5E5E, 0x5E7C, 0x97E7 |
| `0x00D0` | 22 | LDAA dir:14, LDAB dir:4, STAB dir:2, CMPA dir:1, STX dir:1 | 0x574A, 0x57BD, 0x5E5C, 0x5E77, 0x5F07, 0x5FAA, 0x8073, 0x96DE, 0x96F7, 0x97F4 |
| `0x100B` | 3 | STAA ext:3 | 0x75B7, 0xB549, 0xD346 |
| `0x100E` | 30 | LDD ext:28, ADDD ext:2 | 0x4FA7, 0x4FD3, 0x51BE, 0x53A3, 0x5880, 0x6CEC, 0x6EF5, 0x6FC8, 0x705F, 0x71D0 |
| `0x1016` | 3 | STD ext:2, LDD ext:1 | 0x4E13, 0x6EFB, 0x6FC5 |
| `0x1018` | 18 | STD ext:13, LDD ext:2, ADDD ext:2, SUBD ext:1 | 0x75CF, 0x75E3, 0x7984, 0x79B9, 0x79FE, 0x7A24, 0x7C29, 0x7C52, 0x7F52, 0x7F57 |
| `0x101A` | 13 | STD ext:10, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x6CEF, 0x7085, 0x7096, 0x70C1, 0x70D4, 0x70D7, 0x70E8, 0x70F9, 0x71D3, 0xA939 |
| `0x101C` | 9 | STD ext:7, LDD ext:2 | 0x4FAD, 0x4FD9, 0x503F, 0x5045, 0xBC6A, 0xBC8C, 0xBCAB, 0xBCB4, 0xDEFD |
| `0x1020` | 8 | STAA ext:4, CMPB ext:1, SUBD ext:1, LDAA ext:1, CLR ext:1 | 0x4C2B, 0x5BB3, 0x6BD5, 0x6D3C, 0x6DB2, 0xB544, 0xB951, 0xD82C |
| `0x1022` | 5 | CLR ext:3, LDAA ext:1, STAA ext:1 | 0x4F1D, 0x6BCF, 0x6BF0, 0x6DAC, 0xD82F |
| `0x1023` | 39 | STAA ext:23, STAB ext:11, LDAA ext:5 | 0x4FB2, 0x4FDE, 0x504A, 0x50D6, 0x512C, 0x5145, 0x5183, 0x519A, 0x51A7, 0x5259 |
| `0x1028` | 4 | STAA ext:4 | 0x9EF4, 0x9EFC, 0xA01B, 0xA01E |
| `0x1029` | 20 | LDAA ext:18, LDAB ext:2 | 0x9EEC, 0x9F06, 0x9F1C, 0x9F34, 0x9F44, 0x9F52, 0x9F60, 0x9F6E, 0x9F7C, 0x9F8A |
| `0x102A` | 19 | STAB ext:13, STAA ext:3, LDAA ext:2, CMPA ext:1 | 0x9EEF, 0x9F37, 0x9F47, 0x9F55, 0x9F63, 0x9F71, 0x9F7F, 0x9F8D, 0x9F9B, 0x9FAA |
| `0x1030` | 16 | STAA ext:16 | 0x40E8, 0x4133, 0x51EF, 0x52D1, 0xB82C, 0xB8C0, 0xBC23, 0xBCD0, 0xDA6B, 0xDA88 |
| `0x1031` | 8 | LDAA ext:6, LDY imm:2 | 0x401E, 0x4113, 0x53CC, 0xBC2B, 0xBCD8, 0xDAB8, 0xDE48, 0xE116 |
| `0x1032` | 5 | LDAA ext:4, LDY imm:1 | 0x403B, 0x4140, 0x52A8, 0x53D9, 0xDE31 |
| `0x1033` | 7 | LDAA ext:6, LDY imm:1 | 0x4024, 0x4041, 0x4119, 0x4146, 0x52B5, 0x53E6, 0xDE17 |
| `0x1034` | 7 | LDAA ext:6, LDY imm:1 | 0x402D, 0x405A, 0x411F, 0x414C, 0x52C2, 0x53F3, 0xDE5F |
| `0x1050` | 40 | STAA ext:24, LDAA ext:15, CLR ext:1 | 0x4F3E, 0x50E3, 0x50E8, 0x50EB, 0x50F0, 0x5148, 0x514D, 0x51AE, 0x51B3, 0x51C3 |
| `0x2001` | 8 | STX ext:5, STAA ext:2, STAB ext:1 | 0x4687, 0x4693, 0x476D, 0x5270, 0x5482, 0x5C4F, 0x5ECE, 0xD7BC |
| `0x2002` | 4 | STX ext:3, STAA ext:1 | 0x4892, 0x7E44, 0xA9C1, 0xC710 |
| `0x2007` | 5 | LDAA ext:3, STAA ext:2 | 0x4044, 0x4149, 0x5E97, 0x5EEC, 0x96D3 |
| `0x2008` | 7 | LDAA ext:4, STAA ext:2, STX ext:1 | 0x4021, 0x40CE, 0x4116, 0x4322, 0x5C19, 0x96E9, 0xBB8A |
| `0x2009` | 6 | LDAA ext:3, STAA ext:2, CLR ext:1 | 0x40D7, 0x432B, 0x5BA0, 0x5BC4, 0x5CE9, 0xC61B |
| `0x200A` | 7 | LDAA ext:4, STAA ext:3 | 0x4030, 0x40B0, 0x4123, 0x4372, 0x5D1F, 0x6D25, 0x96F3 |
| `0x200B` | 5 | STAA ext:2, LDD ext:1, LDAA ext:1, STX ext:1 | 0x40B9, 0x437B, 0x47F1, 0x5D5D, 0x9554 |
| `0x200C` | 4 | STAA ext:2, LDAA ext:2 | 0x403E, 0x4143, 0x5B1B, 0x5B8E |
| `0x200D` | 4 | STAA ext:2, LDAA ext:1, CMPA ext:1 | 0x4027, 0x411C, 0x415D, 0x6933 |
| `0x200E` | 7 | LDAA ext:5, STAA ext:2 | 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x5DA8, 0x96DA |
| `0x2013` | 11 | CMPA ext:5, STAA ext:3, CMPB ext:2, LDAB ext:1 | 0x404D, 0x4128, 0x5F20, 0x9792, 0x97AF, 0x98FF, 0x997E, 0x99A9, 0x99EB, 0x9CC4 |
| `0x202B` | 10 | LDAA ext:5, STAA ext:2, LDAB ext:2, STAB ext:1 | 0x9714, 0x9728, 0xBE5F, 0xBED8, 0xBEE7, 0xCB89, 0xCE67, 0xCF0B, 0xE8E9, 0xE8F9 |
| `0x202C` | 2 | STAA ext:1, CLR ext:1 | 0xBEEF, 0xBEF7 |
| `0x2030` | 5 | LDAA ext:2, STAA ext:1, STAB ext:1, LDAB ext:1 | 0xC36C, 0xD6BB, 0xD7C0, 0xEACF, 0xEB16 |
| `0x2034` | 8 | LDD ext:7, STD ext:1 | 0x41AD, 0x4913, 0x495F, 0x6EA9, 0x7258, 0xBA34, 0xBE78, 0xE3CF |
| `0x2036` | 19 | LDD ext:17, STD ext:2 | 0x45BC, 0x48FC, 0x4919, 0x49AD, 0x635A, 0x6EB9, 0x725E, 0x9B9D, 0x9D13, 0xBE7E |
| `0x2038` | 5 | LDD ext:3, STD ext:1, LDAB ext:1 | 0x43B1, 0x4E49, 0x5C9F, 0xE84F, 0xE870 |
| `0x203A` | 2 | STD ext:1, LDD ext:1 | 0x43B5, 0x4953 |
| `0x203C` | 12 | LDD ext:9, LDAB ext:2, STD ext:1 | 0x4361, 0x44B1, 0x55F8, 0x720F, 0x72BC, 0x9B61, 0xC2A2, 0xC819, 0xC824, 0xE7F0 |
| `0x203E` | 17 | LDD ext:16, STD ext:1 | 0x4365, 0x4947, 0x49BE, 0x7129, 0x7140, 0x716B, 0xBE9A, 0xC01E, 0xC11A, 0xC127 |
| `0x2040` | 6 | LDD ext:5, STD ext:1 | 0x4400, 0x9525, 0xD5DF, 0xD5EF, 0xD6F5, 0xE83E |
| `0x2042` | 6 | LDD ext:5, STD ext:1 | 0x41EC, 0x5758, 0x97DA, 0xE3FD, 0xE4FF, 0xE97A |
| `0x2049` | 4 | STAA ext:2, CPX ext:1, LDAA ext:1 | 0x6F70, 0xE6A6, 0xE79E, 0xE848 |
| `0x204A` | 3 | STAA ext:2, LDAB ext:1 | 0xE786, 0xE869, 0xE928 |
| `0x204B` | 2 | LDD ext:1, STD ext:1 | 0xE5E8, 0xE959 |
| `0x204D` | 3 | STAA ext:2, LDAB ext:1 | 0xE78C, 0xE88A, 0xE95D |
| `0x204E` | 3 | LDAB ext:2, STD ext:1 | 0xE5FF, 0xE607, 0xE96D |
| `0x204F` | 2 | LDAB ext:2 | 0xE5F3, 0xE613 |
| `0x2050` | 2 | STAA ext:1, LDAB ext:1 | 0xE7ED, 0xE935 |
| `0x2051` | 4 | STD ext:2, CPX ext:1, LDD ext:1 | 0x6582, 0x6F48, 0xE6A1, 0xE7AE |
| `0x2053` | 5 | LDAB ext:2, LDAA ext:1, STAB ext:1, STAA ext:1 | 0xCC57, 0xE5E5, 0xE684, 0xE68A, 0xE7B4 |
| `0x2055` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xE654, 0xE7A6, 0xEAA7, 0xEAB5, 0xEAC4 |
| `0x2057` | 4 | STD ext:3, ADDD ext:1 | 0xE659, 0xE7A9, 0xEB02, 0xEB0E |
| `0x2059` | 15 | LDAA ext:8, STAA ext:4, LDAB ext:2, STAB ext:1 | 0x5B7D, 0x5B95, 0x7101, 0x713D, 0x729F, 0x9818, 0x999A, 0x9A9B, 0x9CA5, 0xBE14 |
| `0x2060` | 4 | STAA ext:3, LDAA ext:1 | 0x7153, 0xE9F9, 0xE9FC, 0xEA02 |
| `0x2062` | 3 | STAA ext:2, LDAA ext:1 | 0xE792, 0xE9D5, 0xE9DB |
| `0x2084` | 2 | STAA ext:2 | 0xE3E1, 0xE798 |
| `0x2085` | 3 | STAA ext:2, LDAA ext:1 | 0xE63B, 0xE79B, 0xE83B |
| `0x2086` | 6 | STD ext:3, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x706C, 0x707F, 0x70A4, 0xD5D7, 0xD60A, 0xD6DC |
| `0x2090` | 10 | LDAA ext:7, STAA ext:2, STAB ext:1 | 0x5685, 0xC03D, 0xC0E4, 0xC19E, 0xC1AA, 0xC1DF, 0xC86C, 0xC931, 0xC97C, 0xCAFE |
| `0x2091` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xC0F6, 0xC7AC, 0xC7AF, 0xC7C1, 0xC807 |
| `0x2093` | 1 | STAA ext:1 | 0xC03A |
| `0x2094` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC588, 0xC734, 0xCB4D |
| `0x2095` | 3 | LDAB ext:1, LDY imm:1, STAA ext:1 | 0xC594, 0xC744, 0xCB57 |
| `0x2096` | 9 | LDAA ext:5, STAA ext:2, DEC ext:1, TST ext:1 | 0xC08B, 0xC0C0, 0xC0F3, 0xC124, 0xC1EE, 0xC1FE, 0xC361, 0xC5A8, 0xC8E7 |
| `0x2097` | 3 | STAA ext:2, TST ext:1 | 0x566C, 0x56F7, 0xC5C2 |
| `0x2098` | 11 | LDAA ext:7, INC ext:1, DEC ext:1, TST ext:1, STAA ext:1 | 0xC0CF, 0xC0FF, 0xC34D, 0xC398, 0xC3BB, 0xC3CA, 0xC3EA, 0xC400, 0xC43D, 0xC5CF |
| `0x2099` | 2 | STAA ext:1, TST ext:1 | 0xC227, 0xC5B5 |
| `0x209A` | 5 | STAA ext:3, LDAA ext:1, TST ext:1 | 0xC255, 0xC263, 0xC32F, 0xC5DC, 0xCAE3 |
| `0x209B` | 16 | STAA ext:9, LDAA ext:4, TST ext:1, DEC ext:1, INC ext:1 | 0xC0EA, 0xC187, 0xC457, 0xC4A3, 0xC4BB, 0xC4F2, 0xC510, 0xC53A, 0xC56B, 0xC5E9 |
| `0x209C` | 4 | LDD ext:2, STD ext:1, ADDD ext:1 | 0xC6F1, 0xC702, 0xC8A8, 0xC8B5 |
| `0x209E` | 4 | STD ext:3, LDD ext:1 | 0x6394, 0xC199, 0xC6E5, 0xC6E8 |
| `0x20A0` | 3 | STD ext:2, ADDD ext:1 | 0xC605, 0xC6C9, 0xC6EB |
| `0x20A2` | 3 | LDAA ext:2, STAB ext:1 | 0xC1BD, 0xC5F6, 0xC77E |
| `0x20A4` | 12 | STAA ext:5, LDAA ext:3, STAB ext:3, CLR ext:1 | 0x56BA, 0x6CD8, 0x6DB7, 0x96EC, 0x975C, 0xC1C3, 0xC5F9, 0xC731, 0xC784, 0xC9FA |
| `0x20A6` | 7 | STAA ext:3, LDAB ext:2, STD ext:1, STAB ext:1 | 0xC106, 0xC1C0, 0xC705, 0xC71A, 0xC72E, 0xC781, 0xC79A |
| `0x20A8` | 20 | LDAA ext:9, LDAB ext:5, CMPA ext:5, STAA ext:1 | 0x4A3A, 0x4A51, 0x5626, 0x984A, 0x9887, 0x998E, 0x9A60, 0x9A7A, 0x9ABB, 0xC086 |
| `0x20B1` | 9 | TST ext:5, LDAA ext:3, STAA ext:1 | 0x460A, 0x4907, 0xBF0A, 0xBF30, 0xCBA9, 0xCBFC, 0xE39E, 0xE3C0, 0xE942 |
| `0x20B9` | 15 | STD ext:6, CMPA ext:2, LDD ext:2, SUBD ext:2, LDAB ext:2, LDAA ext:1 | 0x61CE, 0x61D6, 0xCBB1, 0xCBC7, 0xCC98, 0xCDBC, 0xCDC8, 0xCDD3, 0xCDDF, 0xCDEA |
| `0x20BC` | 2 | STAA ext:2 | 0xBAB1, 0xBBEC |
| `0x20BD` | 1 | STAB ext:1 | 0xBB3A |
| `0x20BE` | 1 | STAB ext:1 | 0xBAE3 |
| `0x20BF` | 1 | STAB ext:1 | 0xBB00 |
| `0x20C0` | 1 | STAB ext:1 | 0xBB1D |
| `0x20C1` | 5 | STAA ext:3, LDAA ext:1, LDAB ext:1 | 0xAFF8, 0xAFFD, 0xB003, 0xBB6B, 0xBBC8 |
| `0x20C2` | 2 | STAA ext:2 | 0xBB37, 0xBC02 |
| `0x20C3` | 2 | STAA ext:2 | 0xBAE0, 0xBBF9 |
| `0x20C4` | 2 | STAA ext:2 | 0xBAFD, 0xBBFC |
| `0x20C5` | 2 | STAA ext:2 | 0xBB1A, 0xBBFF |
| `0x20D3` | 7 | LDAA ext:3, STAA ext:3, LDAB ext:1 | 0xB087, 0xB0EE, 0xB134, 0xB13A, 0xB1AC, 0xB1C8, 0xBBB3 |
| `0x20D4` | 7 | LDAA ext:5, STAA ext:2 | 0xB0FF, 0xB156, 0xB16F, 0xB188, 0xB1A1, 0xBA8E, 0xBBE0 |
| `0x20D5` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB198, 0xB1A4, 0xB1A9 |
| `0x20D6` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB14D, 0xB159, 0xB15E |
| `0x20D7` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB166, 0xB172, 0xB177 |
| `0x20D8` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xB17F, 0xB18B, 0xB190 |
| `0x20D9` | 5 | LDAA ext:2, STAA ext:2, STX ext:1 | 0x9E48, 0xB193, 0xB19E, 0xB1C0, 0xBBB0 |
| `0x20DA` | 4 | LDAA ext:2, STAA ext:2 | 0xB148, 0xB153, 0xB1B1, 0xBBA7 |
| `0x20DB` | 4 | LDAA ext:2, STAA ext:2 | 0xB161, 0xB16C, 0xB1B6, 0xBBAA |
| `0x20DC` | 4 | LDAA ext:2, STAA ext:2 | 0xB17A, 0xB185, 0xB1BB, 0xBBAD |
| `0x20DD` | 2 | STAA ext:2 | 0xBA67, 0xBBF2 |
| `0x20DE` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4858, 0xB24D, 0xB269, 0xBBBF, 0xE5B3, 0xE5B8 |
| `0x20DF` | 6 | STAA ext:3, LDAB ext:1, ADDD ext:1, LDAA ext:1 | 0x4849, 0xA52D, 0xB1E1, 0xB260, 0xBBB6, 0xE5A0 |
| `0x20E0` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x484E, 0xB205, 0xB263, 0xBBB9, 0xE5A3, 0xE5A8 |
| `0x20E1` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4853, 0xB229, 0xB266, 0xBBBC, 0xE5AB, 0xE5B0 |
| `0x20E2` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48D2, 0x7D5D, 0x7D66, 0x95E8, 0xB258 |
| `0x20E3` | 7 | LDAB ext:2, LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48B4, 0x7A8E, 0x7B16, 0x7CFD, 0x7D06, 0x95DF, 0xB1EC |
| `0x20E4` | 5 | LDAA ext:2, STAA ext:2, STAB ext:1 | 0x48BE, 0x7D3D, 0x7D46, 0x95E2, 0xB210 |
| `0x20E5` | 6 | LDAA ext:2, STAA ext:2, STAB ext:1, LDAB ext:1 | 0x48C8, 0x7A89, 0x7D1D, 0x7D26, 0x95E5, 0xB234 |
| `0x20E6` | 13 | LDAA ext:6, CMPA ext:5, STAA ext:2 | 0xB115, 0xB11A, 0xB1D9, 0xB1DE, 0xB1FD, 0xB202, 0xB221, 0xB226, 0xB245, 0xB24A |
| `0x20E7` | 3 | STAA ext:2, LDAA ext:1 | 0xBA74, 0xBBD4, 0xBD1E |
| `0x20E8` | 4 | STAA ext:2, LDAB ext:2 | 0xBA81, 0xBBDA, 0xBD40, 0xBD46 |
| `0x20E9` | 23 | LDAA ext:14, LDAB ext:6, STAA ext:3 | 0x7563, 0x7576, 0x75EA, 0x75FD, 0x7719, 0x7723, 0x7730, 0x7773, 0x778A, 0x7851 |
| `0x20EB` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9A, 0xBC67, 0xBC7A, 0xBD39 |
| `0x20ED` | 4 | STD ext:2, ADDD ext:1, SUBD ext:1 | 0xBB9D, 0xBCB1, 0xBCC1, 0xBD4F |
| `0x2132` | 6 | STD ext:3, LDD ext:2, SUBD ext:1 | 0x4427, 0x4653, 0x465E, 0x4675, 0x467F, 0x4690 |
| `0x2134` | 2 | STD ext:2 | 0x442B, 0x49C5 |
| `0x2147` | 21 | STD ext:10, ADDD ext:6, LDY ext:1, LDX ext:1, STY ext:1, STX ext:1, LDD ext:1 | 0x4481, 0x454E, 0x4551, 0x45C4, 0x45DB, 0x45DC, 0x45E1, 0x45E2, 0x4602, 0x4605 |
| `0x2148` | 6 | LDAA ext:3, STAA ext:2, STAB ext:1 | 0x468C, 0x4756, 0x476A, 0x4862, 0x4874, 0x4936 |
| `0x2149` | 4 | STAB ext:1, TST ext:1, LDAA ext:1, DEC ext:1 | 0x46E5, 0x4702, 0x4772, 0x4777 |
| `0x214C` | 3 | LDAA ext:2, STAA ext:1 | 0x48DD, 0x48E6, 0x496D |
| `0x2122` | 3 | STD ext:2, LDAA ext:1 | 0x40E1, 0x433D, 0x4346 |
| `0x2124` | 3 | STD ext:2, LDAA ext:1 | 0x40C3, 0x438D, 0x4396 |
| `0x21C6` | 5 | STD ext:2, LDD ext:1, SUBD ext:1, STX ext:1 | 0x6FC0, 0x6FD1, 0x724C, 0x7298, 0x72A9 |
| `0x21C8` | 9 | LDD ext:4, STD ext:3, SUBD ext:2 | 0x6F65, 0x6FB0, 0x7024, 0x7075, 0x708A, 0x709C, 0x70CD, 0x70DF, 0x70F0 |
| `0x21CB` | 6 | ADDD ext:4, STD ext:1, SUBD ext:1 | 0x7062, 0x707C, 0x7090, 0x70C4, 0x70E5, 0x70F6 |
| `0x21CD` | 3 | STD ext:2, SUBD ext:1 | 0x704A, 0x70A7, 0x70ED |
| `0x21CF` | 4 | STD ext:2, LDD ext:1, ADDD ext:1 | 0x6FF1, 0x7034, 0x712C, 0x7219 |
| `0x2312` | 3 | LDY imm:2, STAA ext:1 | 0x7583, 0x7CF9, 0x9587 |
| `0x231E` | 3 | LDY imm:2, STAA ext:1 | 0x7570, 0x7D39, 0x958A |
| `0x232A` | 3 | LDY imm:2, STAA ext:1 | 0x757D, 0x7D19, 0x958D |
| `0x2336` | 3 | LDY imm:2, STAA ext:1 | 0x756A, 0x7D59, 0x9590 |
| `0x2348` | 14 | STD ext:6, LDD ext:6, ADDD ext:2 | 0x7CF6, 0x7D16, 0x7D36, 0x7D56, 0x7D74, 0x7D7E, 0x7DF4, 0x7E04, 0x7E55, 0x7E60 |
| `0x234A` | 9 | DEC ext:3, STD ext:2, STAA ext:1, CLR ext:1, ADDD ext:1, SUBD ext:1 | 0x7D84, 0x7DA9, 0x7DAC, 0x7DC3, 0x7E01, 0x7E12, 0x7E1D, 0x7E52, 0x7E58 |
| `0x234C` | 2 | STAA ext:1, DEC ext:1 | 0x7E4B, 0x7E5B |
| `0x234D` | 5 | STD ext:3, LDX ext:1, LDD ext:1 | 0x7DF0, 0x7DFD, 0x7E29, 0x7E3A, 0x7E68 |
| `0x2354` | 4 | LDAB ext:2, LDAA ext:1, STAB ext:1 | 0x7A07, 0x7A0F, 0x7F0C, 0x7F2E |
| `0x235C` | 13 | STD ext:2, SUBD ext:2, LDX ext:2, INC ext:2, LDD ext:1, STX ext:1, CLR ext:1, TST ext:1, DEC ext:1 | 0x78C9, 0x78EF, 0x7912, 0x7924, 0x7945, 0x7998, 0x7EBF, 0x7ED2, 0x7EDD, 0x7EF5 |
| `0x235E` | 4 | STX ext:1, LDAB ext:1, STD ext:1, ADDD ext:1 | 0x790F, 0x796C, 0x7EE8, 0x7EF2 |
| `0x2369` | 3 | STD ext:2, SUBD ext:1 | 0x7E88, 0x7EAB, 0x7F02 |
| `0x2376` | 2 | STD ext:1, LDX ext:1 | 0x7DE1, 0x7E6E |
| `0x2380` | 8 | LDD ext:4, STD ext:3, ADDD ext:1 | 0x7763, 0x7B74, 0x7B8B, 0x7D7A, 0x7DED, 0x7E4E, 0x7F08, 0x7F14 |
| `0x2382` | 7 | STX ext:3, LDD ext:2, LDAB ext:1, ADDD ext:1 | 0x7766, 0x7B77, 0x7B8E, 0x7DE4, 0x7ECD, 0x7EE4, 0x7EFA |
| `0x242B` | 3 | LDD ext:1, SUBD ext:1, STD ext:1 | 0xBC64, 0xBC76, 0xBD1B |
| `0x242D` | 2 | STD ext:1, SUBD ext:1 | 0xBCAE, 0xBCBD |
| `0x242F` | 5 | STD ext:2, ADDD ext:2, LDAA ext:1 | 0xBAB5, 0xBABE, 0xBAC6, 0xBB49, 0xBB53 |
| `0x2431` | 2 | STAA ext:2 | 0xBB68, 0xBB79 |
| `0x243C` | 10 | STD ext:2, CMPA ext:2, INC ext:1, STAA ext:1, LDD ext:1, CPX ext:1, STX ext:1, LDAA ext:1 | 0xC260, 0xC2C1, 0xC2D9, 0xC2DC, 0xC2E1, 0xC2EE, 0xC2F9, 0xC2FC, 0xC301, 0xC304 |
| `0x243E` | 3 | STAA ext:1, LDAA ext:1, LDAB ext:1 | 0xC2AC, 0xC31A, 0xC31F |
| `0x243F` | 6 | LDAA ext:4, STAA ext:2 | 0xC0A3, 0xC0B5, 0xC131, 0xC1E9, 0xC938, 0xC93E |
| `0x244C` | 2 | STAA ext:1, LDAA ext:1 | 0xC13E, 0xC1F8 |
| `0x245E` | 3 | STAA ext:2, DEC ext:1 | 0xC141, 0xC1F3, 0xC1FB |
| `0x2462` | 6 | LDAA ext:3, STAA ext:2, DEC ext:1 | 0xC4CC, 0xC4D1, 0xC546, 0xC54B, 0xC941, 0xC946 |
| `0x2463` | 6 | TST ext:2, DEC ext:2, STAA ext:2 | 0xC099, 0xC09E, 0xC0D8, 0xC0DD, 0xC110, 0xC190 |
| `0x2464` | 4 | LDAA ext:2, STAA ext:2 | 0xC1B8, 0xC1DC, 0xC927, 0xC92E |
| `0x2465` | 4 | STAA ext:2, LDAA ext:2 | 0xC1D4, 0xC779, 0xC918, 0xC924 |
| `0x249B` | 6 | STD ext:4, LDD ext:1, SUBD ext:1 | 0xCBB4, 0xCBCA, 0xCC9B, 0xCE04, 0xCE14, 0xCE5B |
| `0x24AB` | 2 | LDAA ext:1, STAA ext:1 | 0xCD51, 0xD134 |
| `0x24AC` | 2 | LDAA ext:1, STAA ext:1 | 0xCD04, 0xD140 |
| `0x24AD` | 2 | LDD ext:1, STD ext:1 | 0xCD0A, 0xD151 |
| `0x24AF` | 2 | LDAB ext:1, STAA ext:1 | 0xCD8C, 0xD15D |
| `0x24B0` | 6 | STD ext:4, ADDD ext:1, SUBD ext:1 | 0xCDB9, 0xCDC3, 0xCDCB, 0xCDDA, 0xCDE2, 0xCDFE |
| `0x2483` | 4 | STAB ext:1, LDAB ext:1, DEC ext:1, STAA ext:1 | 0xBEEA, 0xBEF2, 0xBEFC, 0xCB8C |
| `0x2484` | 3 | STAA ext:2, LDAB ext:1 | 0xBE93, 0xBEAF, 0xCB86 |
| `0x2486` | 2 | STAA ext:2 | 0xBEA0, 0xCB7D |
| `0x2488` | 1 | STAA ext:1 | 0xBECB |
| `0x248D` | 3 | STAA ext:2, LDAA ext:1 | 0xBF19, 0xBF20, 0xBF49 |
| `0x248E` | 2 | STAA ext:2 | 0xBF3F, 0xBF46 |
| `0x2584` | 3 | STD ext:2, SUBD ext:1 | 0xE4F9, 0xE58D, 0xE663 |
| `0x2590` | 3 | STD ext:2, ADDD ext:1 | 0xE3F4, 0xE4DB, 0xE65E |
| `0x2596` | 6 | ADDD ext:3, STD ext:2, SUBD ext:1 | 0xE780, 0xE903, 0xE913, 0xE921, 0xE924, 0xE92E |
| `0x25A3` | 6 | LDY imm:2, STD ext:2, ADDD ext:2 | 0xE84B, 0xE86C, 0xE931, 0xE93B, 0xE93F, 0xE953 |
| `0x2610` | 10 | STAB ext:4, LDAB ext:3, STX ext:2, CLR ext:1 | 0x4EDC, 0x6A37, 0x6B2C, 0x6B37, 0x6B46, 0x6B96, 0x6BA1, 0x6BB0, 0xCB10, 0xE948 |

### `rally13_ori`

| Address | Count | Operations | First sites |
| --- | ---: | --- | --- |
| `0x0060` | 4 | SUBD dir:2, LDY imm:2 | 0x636E, 0x63F8, 0xCEC9, 0xCEE8 |
| `0x0069` | 8 | LDY imm:4, LDAA dir:2, CPX dir:1, SUBD dir:1 | 0x64F8, 0x6951, 0x6E0C, 0xCED7, 0xCEF6, 0xDDA0, 0xDE00, 0xDE12 |
| `0x005D` | 14 | LDAA dir:4, CMPA dir:3, STAA dir:3, STAB dir:2, INC ext:1, DEC ext:1 | 0x578B, 0x64C5, 0x654E, 0x6561, 0x6DF6, 0x6ED7, 0xC56C, 0xC581, 0xCA8E, 0xCB14 |
| `0x005E` | 14 | SUBD dir:3, STAA dir:3, LDAA dir:2, LDAB dir:2, INC ext:1, DEC ext:1, STAB dir:1, CLR ext:1 | 0x62D8, 0x64B6, 0x6551, 0x6557, 0x655D, 0x6564, 0x6568, 0x656F, 0xB8A9, 0xCD71 |
| `0x005F` | 19 | STX dir:13, STAB dir:2, STAA dir:1, CMPB dir:1, CLR ext:1, LDAA dir:1 | 0x64C3, 0x6545, 0x6DE9, 0xBECF, 0xCD93, 0xCE90, 0xDFEC, 0xE03F, 0xE132, 0xE1BE |
| `0x00B6` | 15 | CMPA dir:3, STAB dir:3, LDD dir:3, SUBD dir:2, LDAB dir:2, STAA dir:1, STD dir:1 | 0x57B5, 0x784C, 0x9C6B, 0x9C78, 0xBBDE, 0xBBEC, 0xBC05, 0xBC29, 0xC305, 0xC360 |
| `0x00BC` | 49 | LDD dir:29, LDX dir:10, STD dir:3, LDD ext:2, SUBD dir:1, ADDD ext:1, CMPA dir:1, LDAA dir:1, STAB dir:1 | 0x42A8, 0x42AC, 0x42EB, 0x4499, 0x4658, 0x4A05, 0x4AA9, 0x4AC5, 0x5F24, 0x60B2 |
| `0x00BF` | 2 | SUBD dir:1, CMPA dir:1 | 0x7487, 0xC684 |
| `0x00C1` | 41 | STD dir:15, LDD dir:8, ADDD dir:6, LDAA dir:6, SUBD dir:5, LDX dir:1 | 0x59E8, 0x6FD1, 0x7009, 0x7010, 0x701B, 0xB07F, 0xB8D1, 0xEB46, 0xEB5A, 0xEB66 |
| `0x00C3` | 20 | LDAA dir:5, STAA dir:5, CMPA dir:4, STD dir:3, STAB dir:1, SUBD dir:1, LDAB dir:1 | 0x9563, 0x9A1D, 0x9C0F, 0xC957, 0xC95C, 0xCAB7, 0xCABC, 0xEB9C, 0xED5A, 0xEF83 |
| `0x00C5` | 12 | LDD dir:5, STD dir:3, SUBD dir:2, CMPA dir:1, STAB dir:1 | 0x59D7, 0x7D23, 0x9BB2, 0x9BBB, 0xCC01, 0xD731, 0xEA01, 0xEA1A, 0xEA8B, 0xEA9A |
| `0x00C6` | 6 | LDAA dir:2, ADDD dir:2, STX dir:1, CMPA dir:1 | 0x6509, 0xA783, 0xA78F, 0xBE90, 0xC556, 0xCC20 |
| `0x00CC` | 25 | LDD dir:13, LDX dir:2, CMPA dir:2, LDAB dir:2, ADDD dir:2, STX dir:1, STD dir:1, CPX dir:1, CMPB dir:1 | 0x4073, 0x409A, 0x4129, 0x419F, 0x42DF, 0x4639, 0x5730, 0x5F6C, 0x5F8A, 0x7AA2 |
| `0x00CE` | 26 | LDAA dir:12, LDAB dir:4, CMPA dir:2, STAB dir:2, STX dir:2, LDX dir:1, STD dir:1, CPX dir:1, LDD dir:1 | 0x508F, 0x5849, 0x58BC, 0x5F6A, 0x5F85, 0x6015, 0x6077, 0x60C5, 0x7AAF, 0x7ABB |
| `0x00D0` | 7 | CMPA dir:2, LDAA ext:2, LDAB dir:1, STAB dir:1, STAA dir:1 | 0x4B10, 0x4B28, 0x8072, 0xC767, 0xC7D6, 0xDA00, 0xDBC8 |
| `0x100B` | 3 | STAA ext:3 | 0x961F, 0xBDC2, 0xD843 |
| `0x100E` | 30 | LDD ext:28, ADDD ext:2 | 0x5075, 0x50A1, 0x528C, 0x5471, 0x598E, 0x6E0E, 0x7029, 0x7102, 0x719B, 0x72F6 |
| `0x1016` | 2 | STD ext:2 | 0x702F, 0x70FF |
| `0x1018` | 20 | STD ext:13, CMPA ext:2, LDD ext:2, ADDD ext:2, SUBD ext:1 | 0x6873, 0x6897, 0x750C, 0x7511, 0x7540, 0x7562, 0x7565, 0x7578, 0x7580, 0x7583 |
| `0x101A` | 13 | STD ext:10, LDD ext:1, ADDD ext:1, SUBD ext:1 | 0x6E11, 0x71C1, 0x71D2, 0x71FD, 0x7210, 0x7213, 0x7224, 0x7235, 0x72F9, 0xAB8D |
| `0x101C` | 9 | STD ext:7, LDD ext:2 | 0x507B, 0x50A7, 0x510D, 0x5113, 0xC248, 0xC26A, 0xC28E, 0xC297, 0xE3FF |
| `0x1020` | 7 | STAA ext:4, CMPA ext:1, LDAA ext:1, CLR ext:1 | 0x688B, 0x6CF7, 0x6E5E, 0x6ED4, 0xB95B, 0xBDBD, 0xDD2E |
| `0x1022` | 5 | CLR ext:3, LDAA ext:1, STAA ext:1 | 0x4FEB, 0x6CF1, 0x6D12, 0x6ECE, 0xDD31 |
| `0x1023` | 39 | STAA ext:23, STAB ext:11, LDAA ext:5 | 0x5080, 0x50AC, 0x5118, 0x51A4, 0x51FA, 0x5213, 0x5251, 0x5268, 0x5275, 0x5327 |
| `0x1028` | 4 | STAA ext:4 | 0xA148, 0xA150, 0xA26F, 0xA272 |
| `0x1029` | 20 | LDAA ext:18, LDAB ext:2 | 0xA140, 0xA15A, 0xA170, 0xA188, 0xA198, 0xA1A6, 0xA1B4, 0xA1C2, 0xA1D0, 0xA1DE |
| `0x102A` | 19 | STAB ext:13, STAA ext:3, LDAA ext:2, SUBD ext:1 | 0xA143, 0xA18B, 0xA19B, 0xA1A9, 0xA1B7, 0xA1C5, 0xA1D3, 0xA1E1, 0xA1EF, 0xA1FE |
| `0x1030` | 16 | STAA ext:16 | 0x40E6, 0x4131, 0x52BD, 0x539F, 0xB82F, 0xB8C3, 0xC201, 0xC2B3, 0xDF6D, 0xDF8A |
| `0x1031` | 8 | LDAA ext:6, LDY imm:2 | 0x401E, 0x4111, 0x549A, 0xC209, 0xC2BB, 0xDFBA, 0xE34A, 0xE618 |
| `0x1032` | 5 | LDAA ext:4, LDY imm:1 | 0x403B, 0x413E, 0x5376, 0x54A7, 0xE333 |
| `0x1033` | 7 | LDAA ext:6, LDY imm:1 | 0x4024, 0x4041, 0x4117, 0x4144, 0x5383, 0x54B4, 0xE319 |
| `0x1034` | 7 | LDAA ext:6, LDY imm:1 | 0x402D, 0x405A, 0x411D, 0x414A, 0x5390, 0x54C1, 0xE361 |
| `0x1050` | 40 | STAA ext:24, LDAA ext:15, CLR ext:1 | 0x500C, 0x51B1, 0x51B6, 0x51B9, 0x51BE, 0x5216, 0x521B, 0x527C, 0x5281, 0x5291 |
| `0x2001` | 7 | STX ext:6, STAA ext:1 | 0x456A, 0x533E, 0x5550, 0x5D5D, 0x5FDC, 0x7CEE, 0xDCBE |
| `0x2002` | 4 | STX ext:3, STAA ext:1 | 0x4940, 0x9EB6, 0xAC15, 0xCAA1 |
| `0x2007` | 5 | STAA ext:2, LDX ext:1, LDAA ext:1, JSR ext:1 | 0x40B7, 0x4379, 0x4539, 0x5E6B, 0xF0C2 |
| `0x2008` | 5 | STAA ext:2, LDAA ext:2, STX ext:1 | 0x403E, 0x4141, 0x5C29, 0x5C9C, 0xC156 |
| `0x2009` | 5 | STAA ext:2, LDAA ext:1, CLR ext:1, LDX ext:1 | 0x4027, 0x411A, 0x415B, 0xC98B, 0xEEB2 |
| `0x200A` | 9 | LDAA ext:5, STAA ext:2, CPX ext:1, CLR ext:1 | 0x405D, 0x414E, 0x4171, 0x418C, 0x42F5, 0x5EB6, 0x6E47, 0x7995, 0x9136 |
| `0x200B` | 4 | STD ext:2, LDD ext:1, STX ext:1 | 0x4061, 0x416C, 0x4183, 0x77F7 |
| `0x200C` | 1 | CMPA ext:1 | 0x6761 |
| `0x200D` | 4 | STAA ext:2, LDAA ext:2 | 0x409F, 0x5EC7, 0x6A55, 0xD8D3 |
| `0x200E` | 3 | STAA ext:2, CLR ext:1 | 0x42F8, 0x430B, 0x6A94 |
| `0x2013` | 10 | LDAA ext:5, LDAB ext:4, STAB ext:1 | 0x41DB, 0x41E1, 0x645F, 0x7BCB, 0x7C1A, 0xC5E9, 0xC632, 0xED4B, 0xEF74, 0xEFF1 |
| `0x202B` | 0 | - | - |
| `0x202C` | 5 | LDAA ext:2, STAA ext:1, STAB ext:1, LDAB ext:1 | 0xC727, 0xDBBD, 0xDCC2, 0xF0B9, 0xF100 |
| `0x2030` | 8 | LDD ext:7, STD ext:1 | 0x41AB, 0x49D0, 0x4A2C, 0x6FDC, 0x7396, 0xC000, 0xCF96, 0xE8F2 |
| `0x2034` | 3 | LDD ext:2, STD ext:1 | 0x43AF, 0xEE07, 0xEE28 |
| `0x2036` | 2 | STD ext:1, LDD ext:1 | 0x43B3, 0x4A20 |
| `0x2038` | 14 | LDD ext:11, LDAB ext:2, STD ext:1 | 0x435F, 0x441F, 0x44EE, 0x56C6, 0x7349, 0x740E, 0x787F, 0x7E2E, 0xC65D, 0xCB9C |
| `0x203A` | 20 | LDD ext:18, STD ext:1, CLR ext:1 | 0x4363, 0x44C1, 0x49F5, 0x4A14, 0x4A8B, 0x724F, 0x7266, 0x7291, 0xBE1B, 0xC374 |
| `0x203C` | 5 | LDD ext:4, STD ext:1 | 0x43FE, 0x77C8, 0xDAE0, 0xDBF7, 0xEDF6 |
| `0x203E` | 6 | LDD ext:5, STD ext:1 | 0x41EA, 0x5857, 0x7A95, 0xE920, 0xEA22, 0xEF21 |
| `0x2040` | 11 | LDD ext:9, STD ext:2 | 0xC029, 0xC036, 0xC043, 0xC050, 0xC05D, 0xC073, 0xC64E, 0xD121, 0xD603, 0xD998 |
| `0x2042` | 3 | LDD ext:2, STD ext:1 | 0x473B, 0xC012, 0xD9A6 |
| `0x2049` | 3 | STAA ext:2, LDAB ext:1 | 0xECFC, 0xEE42, 0xEF04 |
| `0x204A` | 3 | LDAB ext:2, STD ext:1 | 0xEB54, 0xEB5C, 0xEF14 |
| `0x204B` | 2 | LDAB ext:2 | 0xEB48, 0xEB68 |
| `0x204D` | 3 | STD ext:2, LDD ext:1 | 0x707C, 0xEC15, 0xED1C |
| `0x204E` | 0 | - | - |
| `0x204F` | 6 | LDD ext:5, STD ext:1 | 0x701D, 0x70A0, 0x70A8, 0x70DC, 0x714A, 0x7164 |
| `0x2050` | 0 | - | - |
| `0x2051` | 7 | LDD ext:3, SUBD ext:2, STD ext:2 | 0x6FCC, 0x70B3, 0x70BD, 0x70D5, 0x735A, 0xDAD5, 0xDAFF |
| `0x2053` | 5 | LDAB ext:2, LDAA ext:1, STAB ext:1, STAA ext:1 | 0xD14C, 0xEB08, 0xEBD9, 0xEBDF, 0xED22 |
| `0x2055` | 5 | STD ext:3, ADDD ext:1, LDD ext:1 | 0xEBA9, 0xED16, 0xF091, 0xF09F, 0xF0AE |
| `0x2057` | 4 | STD ext:3, ADDD ext:1 | 0xEBAE, 0xED19, 0xF0EC, 0xF0F8 |
| `0x2059` | 15 | LDAA ext:8, STAA ext:4, LDAB ext:2, STAB ext:1 | 0x5C8B, 0x5CA3, 0x723D, 0x7263, 0x73DD, 0x7AD3, 0x7C55, 0x7D6C, 0x7ECE, 0xCF32 |
| `0x2060` | 1 | STAA ext:1 | 0x7403 |
| `0x2062` | 4 | STAA ext:2, LDAA ext:1, DEC ext:1 | 0x727F, 0x728A, 0x7312, 0x7406 |
| `0x2084` | 0 | - | - |
| `0x2085` | 4 | STAA ext:2, CMPA ext:1, LDAA ext:1 | 0xE89B, 0xE8A0, 0xE904, 0xED08 |
| `0x2086` | 3 | STAA ext:2, LDAA ext:1 | 0xEB90, 0xED0B, 0xEDF3 |
| `0x2090` | 4 | STAA ext:3, LDAA ext:1 | 0x790C, 0xC371, 0xCE8D, 0xCF10 |
| `0x2091` | 12 | LDAA ext:9, STAA ext:2, STAB ext:1 | 0x5753, 0x58FD, 0xC393, 0xC3D0, 0xC48F, 0xC559, 0xC565, 0xC59A, 0xCBEF, 0xCCB4 |
| `0x2093` | 0 | - | - |
| `0x2094` | 2 | STAA ext:1, LDAA ext:1 | 0xC3CD, 0xC933 |
| `0x2095` | 6 | STAA ext:3, LDAB ext:1, LDAA ext:1, LDY imm:1 | 0xC3AC, 0xC3B2, 0xC551, 0xCAC4, 0xCEDE, 0xCEFD |
| `0x2096` | 5 | STAA ext:2, LDX ext:1, CMPA ext:1, LDAA ext:1 | 0x73E5, 0xC3A4, 0xC3A9, 0xC554, 0xCEE1 |
| `0x2097` | 8 | LDAA ext:5, STAA ext:2, DEC ext:1 | 0xC426, 0xC467, 0xC49E, 0xC4CF, 0xC5A9, 0xC5B9, 0xC71C, 0xCC6A |
| `0x2098` | 2 | STAA ext:2 | 0x573A, 0x57C6 |
| `0x2099` | 11 | LDAA ext:7, INC ext:1, DEC ext:1, LDAB ext:1, STAA ext:1 | 0xC476, 0xC4AA, 0xC708, 0xC753, 0xC776, 0xC785, 0xC7A5, 0xC7BB, 0xC7F8, 0xC936 |
| `0x209A` | 1 | STAA ext:1 | 0xC5E2 |
| `0x209B` | 4 | STAA ext:3, LDAA ext:1 | 0xC610, 0xC61E, 0xC6EA, 0xCE66 |
| `0x209C` | 15 | STAA ext:9, LDAA ext:4, DEC ext:1, INC ext:1 | 0xC495, 0xC53C, 0xC812, 0xC85E, 0xC876, 0xC8AD, 0xC8CB, 0xC8F5, 0xC926, 0xCD1D |
| `0x209E` | 0 | - | - |
| `0x20A0` | 0 | - | - |
| `0x20A2` | 0 | - | - |
| `0x20A4` | 0 | - | - |
| `0x20A6` | 2 | LDAA ext:1, STAA ext:1 | 0xCA99, 0xCAA6 |
| `0x20A8` | 3 | CLR ext:2, LDAB ext:1 | 0xC583, 0xCA90, 0xCB16 |
| `0x20B1` | 6 | STAA ext:2, STAB ext:1, LDAA ext:1, CMPA ext:1, CLR ext:1 | 0xBE9F, 0xBEB3, 0xC3F2, 0xC50C, 0xF136, 0xF1BF |
| `0x20B9` | 5 | LDAA ext:2, INC ext:2, CLR ext:1 | 0xD6D8, 0xD6EF, 0xD6FC, 0xD710, 0xD71D |
| `0x20BC` | 2 | LDAA ext:1, STAA ext:1 | 0xBA41, 0xC026 |
| `0x20BD` | 2 | STAA ext:2 | 0xC07D, 0xC1CA |
| `0x20BE` | 1 | STAB ext:1 | 0xC106 |
| `0x20BF` | 1 | STAB ext:1 | 0xC0AF |
| `0x20C0` | 1 | STAB ext:1 | 0xC0CC |
| `0x20C1` | 1 | STAB ext:1 | 0xC0E9 |
| `0x20C2` | 5 | STAA ext:3, LDAA ext:1, LDAB ext:1 | 0xBA76, 0xBA7B, 0xBA81, 0xC137, 0xC1A6 |
| `0x20C3` | 2 | STAA ext:2 | 0xC103, 0xC1E0 |
| `0x20C4` | 2 | STAA ext:2 | 0xC0AC, 0xC1D7 |
| `0x20C5` | 2 | STAA ext:2 | 0xC0C9, 0xC1DA |
| `0x20D3` | 5 | STAA ext:3, LDAA ext:2 | 0xBB52, 0xBB5C, 0xBB9D, 0xBBA3, 0xC182 |
| `0x20D4` | 7 | LDAA ext:3, STAA ext:3, LDAB ext:1 | 0xBB05, 0xBB6C, 0xBBB2, 0xBBB8, 0xBC2A, 0xBC46, 0xC191 |
| `0x20D5` | 7 | LDAA ext:5, STAA ext:2 | 0xBB7D, 0xBBD4, 0xBBED, 0xBC06, 0xBC1F, 0xC05A, 0xC1BE |
| `0x20D6` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xBC16, 0xBC22, 0xBC27 |
| `0x20D7` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xBBCB, 0xBBD7, 0xBBDC |
| `0x20D8` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xBBE4, 0xBBF0, 0xBBF5 |
| `0x20D9` | 3 | TST ext:1, STAA ext:1, DEC ext:1 | 0xBBFD, 0xBC09, 0xBC0E |
| `0x20DA` | 4 | LDAA ext:2, STAA ext:2 | 0xBC11, 0xBC1C, 0xBC3E, 0xC18E |
| `0x20DB` | 4 | LDAA ext:2, STAA ext:2 | 0xBBC6, 0xBBD1, 0xBC2F, 0xC185 |
| `0x20DC` | 4 | LDAA ext:2, STAA ext:2 | 0xBBDF, 0xBBEA, 0xBC34, 0xC188 |
| `0x20DD` | 4 | LDAA ext:2, STAA ext:2 | 0xBBF8, 0xBC03, 0xBC39, 0xC18B |
| `0x20DE` | 2 | STAA ext:2 | 0xC033, 0xC1D0 |
| `0x20DF` | 7 | STAA ext:3, LDAB ext:1, ADDD ext:1, CMPA ext:1, LDAA ext:1 | 0x4906, 0xA781, 0xBCCB, 0xBCE7, 0xC19D, 0xEAD6, 0xEADB |
| `0x20E0` | 5 | STAA ext:3, LDAB ext:1, LDAA ext:1 | 0x48F7, 0xBC5F, 0xBCDE, 0xC194, 0xEAC3 |
| `0x20E1` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x48FC, 0xBC83, 0xBCE1, 0xC197, 0xEAC6, 0xEACB |
| `0x20E2` | 6 | STAA ext:3, LDAB ext:1, CMPA ext:1, LDAA ext:1 | 0x4901, 0xBCA7, 0xBCE4, 0xC19A, 0xEACE, 0xEAD3 |
| `0x20E3` | 5 | STAA ext:2, LDAA ext:2, STAB ext:1 | 0x498C, 0x7895, 0x9DCF, 0x9DD8, 0xBCD6 |
| `0x20E4` | 7 | STAA ext:2, LDAB ext:2, LDAA ext:2, STAB ext:1 | 0x496E, 0x788C, 0x9AF6, 0x9B7E, 0x9D6F, 0x9D78, 0xBC6A |
| `0x20E5` | 5 | STAA ext:2, LDAA ext:2, STAB ext:1 | 0x4978, 0x788F, 0x9DAF, 0x9DB8, 0xBC8E |
| `0x20E6` | 6 | STAA ext:2, LDAA ext:2, STAB ext:1, LDAB ext:1 | 0x4982, 0x7892, 0x9AF1, 0x9D8F, 0x9D98, 0xBCB2 |
| `0x20E7` | 13 | LDAA ext:6, CMPA ext:5, STAA ext:2 | 0xBB93, 0xBB98, 0xBC57, 0xBC5C, 0xBC7B, 0xBC80, 0xBC9F, 0xBCA4, 0xBCC3, 0xBCC8 |
| `0x20E8` | 3 | STAA ext:2, LDAA ext:1 | 0xC040, 0xC1B2, 0xC306 |
| `0x20E9` | 4 | STAA ext:2, LDAB ext:2 | 0xC04D, 0xC1B8, 0xC328, 0xC32E |
| `0x20EB` | 2 | LDAA ext:1, STAA ext:1 | 0xE415, 0xE61B |
| `0x20ED` | 0 | - | - |
| `0x2132` | 0 | - | - |
| `0x2134` | 0 | - | - |
| `0x2147` | 6 | STAA ext:3, LDAA ext:3 | 0x442E, 0x4567, 0x47F2, 0x4806, 0x4910, 0x4922 |
| `0x2148` | 4 | STAB ext:1, TST ext:1, LDAA ext:1, DEC ext:1 | 0x4738, 0x4755, 0x480B, 0x4810 |
| `0x2149` | 5 | STAA ext:2, TST ext:1, LDAA ext:1, DEC ext:1 | 0x4463, 0x478C, 0x479C, 0x4813, 0x4818 |
| `0x214C` | 3 | LDAA ext:2, STAA ext:1 | 0x4997, 0x49A3, 0x4A3A |
| `0x2122` | 2 | STD ext:1, SUBD ext:1 | 0x434A, 0x435C |
| `0x2124` | 2 | STD ext:1, SUBD ext:1 | 0x439A, 0x43AC |
| `0x21C6` | 2 | STAA ext:1, LDAA ext:1 | 0x6D0C, 0x6EE8 |
| `0x21C8` | 2 | STAA ext:1, LDAA ext:1 | 0x6D06, 0x6EE2 |
| `0x21CB` | 3 | STAA ext:2, DEC ext:1 | 0x79DB, 0x79DE, 0x79EC |
| `0x21CD` | 3 | TST ext:1, DEC ext:1, STAA ext:1 | 0x7A25, 0x7A2A, 0x7A3A |
| `0x21CF` | 7 | STAA ext:3, TST ext:2, STAB ext:1, LDAA ext:1 | 0xA01F, 0xA031, 0xA06C, 0xA0C8, 0xA0D7, 0xA0E2, 0xA0E8 |
| `0x2312` | 0 | - | - |
| `0x231E` | 0 | - | - |
| `0x232A` | 1 | CPX ext:1 | 0x4659 |
| `0x2336` | 0 | - | - |
| `0x2348` | 0 | - | - |
| `0x234A` | 0 | - | - |
| `0x234C` | 0 | - | - |
| `0x234D` | 0 | - | - |
| `0x2354` | 0 | - | - |
| `0x235C` | 0 | - | - |
| `0x235E` | 0 | - | - |
| `0x2369` | 0 | - | - |
| `0x2376` | 0 | - | - |
| `0x2380` | 2 | STD ext:1, SUBD ext:1 | 0x9B23, 0x9B30 |
| `0x2382` | 2 | STD ext:1, SUBD ext:1 | 0x99E5, 0x9A0E |
| `0x242B` | 9 | LDD ext:6, LDX ext:2, STD ext:1 | 0xAA35, 0xAB2E, 0xAB87, 0xAC76, 0xAC8D, 0xAD8D, 0xAE80, 0xAEA2, 0xAEFB |
| `0x242D` | 2 | STX ext:1, STD ext:1 | 0xAB38, 0xAC79 |
| `0x242F` | 2 | STX ext:2 | 0xAB42, 0xAC90 |
| `0x2431` | 7 | STAA ext:2, LDAA ext:2, CLR ext:2, STAB ext:1 | 0x5032, 0x564D, 0xAB5F, 0xAB63, 0xABB4, 0xAEB6, 0xAEEF |
| `0x243C` | 5 | STAA ext:3, CLR ext:1, CMPA ext:1 | 0xB117, 0xB175, 0xB17B, 0xB19C, 0xB1AF |
| `0x243E` | 4 | STD ext:2, LDX ext:1, STX ext:1 | 0x6827, 0xABD5, 0xABEC, 0xABFB |
| `0x243F` | 0 | - | - |
| `0x244C` | 2 | SUBD ext:1, STD ext:1 | 0xC5C0, 0xC5C5 |
| `0x245E` | 4 | STAA ext:2, LDAA ext:1, CLR ext:1 | 0xCBD6, 0xCBDB, 0xCBE9, 0xCC53 |
| `0x2462` | 3 | CLR ext:1, TST ext:1, STAA ext:1 | 0x79AA, 0xCD99, 0xCF01 |
| `0x2463` | 3 | STAA ext:2, LDAA ext:1 | 0xC76A, 0xC7C3, 0xC7D9 |
| `0x2464` | 9 | STD ext:4, ADDD ext:3, STX ext:2 | 0xC4A7, 0xC9C4, 0xC9F2, 0xCA06, 0xCA09, 0xCA15, 0xCA1D, 0xCA39, 0xCA41 |
| `0x2465` | 0 | - | - |
| `0x249B` | 5 | STAA ext:3, LDAA ext:1, LDAB ext:1 | 0x7FB9, 0x7FDD, 0x7FE7, 0xCF48, 0xCFD3 |
| `0x24AB` | 5 | LDAA ext:3, STAA ext:2 | 0xD1B8, 0xD2E0, 0xD2F2, 0xD5E1, 0xD5F1 |
| `0x24AC` | 0 | - | - |
| `0x24AD` | 0 | - | - |
| `0x24AF` | 6 | STD ext:4, LDD ext:1, SUBD ext:1 | 0xD097, 0xD0AD, 0xD195, 0xD2FE, 0xD30E, 0xD355 |
| `0x24B0` | 0 | - | - |
| `0x2483` | 0 | - | - |
| `0x2484` | 3 | STX ext:2, LDX ext:1 | 0xBDE8, 0xBE3E, 0xBE44 |
| `0x2486` | 6 | STD ext:3, STAA ext:2, LDY imm:1 | 0x5054, 0x50D1, 0x50DB, 0x55A2, 0x65FB, 0xE119 |
| `0x2488` | 2 | STD ext:1, STAA ext:1 | 0x5060, 0x55AA |
| `0x248D` | 0 | - | - |
| `0x248E` | 0 | - | - |
| `0x2584` | 0 | - | - |
| `0x2590` | 1 | STAA ext:1 | 0xE749 |
| `0x2596` | 4 | STD ext:2, LDD ext:1, ADDD ext:1 | 0xEA03, 0xEA95, 0xEA9C, 0xEAAB |
| `0x25A3` | 3 | STD ext:2, ADDD ext:1 | 0xE917, 0xE9FE, 0xEBB3 |
| `0x2610` | 10 | STAB ext:4, LDAB ext:3, STX ext:2, CLR ext:1 | 0x4FAA, 0x6B59, 0x6C4E, 0x6C59, 0x6C68, 0x6CB8, 0x6CC3, 0x6CD2, 0xCE93, 0xEEEF |

## Targeted Trace Notes

- `0x802B` `24x9` (signed8): Peugeot immediate word-reference hits `3`.
  - `peugeot_mod2` differs in `75/216` cells (`+4..+6`, avg `+5.4`).
  - `xantia_607c` differs in `216/216` cells (`-76..+82`, avg `-11.4`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `133/216` cells (`-14..+68`, avg `+0.4`).
- `0x802E` `21x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `57/189` cells (`+4..+6`, avg `+5.6`).
  - `xantia_607c` differs in `189/189` cells (`-76..+62`, avg `-14.9`).
  - `peug_106rally_org` differs in `0/189` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `116/189` cells (`-13..+38`, avg `+0.5`).
- `0x802E` `24x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `75/216` cells (`+4..+6`, avg `+5.4`).
  - `xantia_607c` differs in `216/216` cells (`-76..+82`, avg `-11.8`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `133/216` cells (`-25..+68`, avg `-0.1`).
- `0x80EB` `21x9` (signed8): Peugeot immediate word-reference hits `0`.
  - `peugeot_mod2` differs in `60/189` cells (`+5..+5`, avg `+5.0`).
  - `xantia_607c` differs in `189/189` cells (`-91..+100`, avg `+24.6`).
  - `peug_106rally_org` differs in `0/189` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `126/189` cells (`-50..+146`, avg `+0.5`).
- `0x80F1` `25x9` (signed8): Peugeot immediate word-reference hits `0`.
  - `peugeot_mod2` differs in `90/225` cells (`+5..+18`, avg `+5.9`).
  - `xantia_607c` differs in `225/225` cells (`-91..+100`, avg `+21.2`).
  - `peug_106rally_org` differs in `0/225` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `150/225` cells (`-50..+146`, avg `+1.2`).
- `0x8103` `24x9` (signed8): Peugeot immediate word-reference hits `19`.
  - `peugeot_mod2` differs in `72/216` cells (`+5..+18`, avg `+6.1`).
  - `xantia_607c` differs in `216/216` cells (`-92..+100`, avg `+17.9`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `145/216` cells (`-50..+146`, avg `+0.3`).
- `0x81A8` `5x9` (raw): Peugeot immediate word-reference hits `0`.
  - `peugeot_mod2` differs in `30/45` cells (`-251..+18`, avg `-60.7`).
  - `xantia_607c` differs in `45/45` cells (`-245..+239`, avg `-46.0`).
  - `peug_106rally_org` differs in `0/45` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `30/45` cells (`-161..+254`, avg `+1.5`).
- `0x81F8` `4x9` (signed8 low-rpm): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/36` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `36/36` cells (`-18..+52`, avg `+9.2`).
  - `peug_106rally_org` differs in `0/36` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `30/36` cells (`-37..+23`, avg `+0.1`).
- `0x821C` `24x9` (signed8): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `214/216` cells (`-119..+114`, avg `+3.4`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `206/216` cells (`-131..+129`, avg `-0.9`).
- `0x82F4` `4x9` (signed8 low-rpm): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/36` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `36/36` cells (`-18..+80`, avg `+3.7`).
  - `peug_106rally_org` differs in `0/36` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `30/36` cells (`-37..+52`, avg `+2.6`).
- `0x8318` `24x9` (signed8): Peugeot immediate word-reference hits `6`.
  - `peugeot_mod2` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `210/216` cells (`-70..+123`, avg `+30.9`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `166/216` cells (`-74..+76`, avg `+0.3`).
- `0x83F0` `1x24` (signed8): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `24/24` cells (`-35..+38`, avg `-0.1`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `23/24` cells (`-93..+38`, avg `-11.5`).
- `0x81E0` `1x24` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `19/24` cells (`-32..+18`, avg `+13.2`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `8/24` cells (`-32..+150`, avg `+18.1`).
- `0x8408` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `13/17` cells (`-65..+41`, avg `+0.8`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `16/17` cells (`-83..+65`, avg `+16.4`).
- `0x841B` `1x17` (word16 raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-6059..+59860`, avg `+36042.5`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-8652..+27166`, avg `+4688.6`).
- `0x843D` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `15/17` cells (`-45..+57`, avg `+7.0`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-174..+86`, avg `-9.9`).
- `0x8452` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-45..+24`, avg `-27.3`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-19..+117`, avg `+26.3`).
- `0x845B` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `11/17` cells (`-239..+143`, avg `+7.7`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-231..+228`, avg `-22.1`).
- `0x846C` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-185..+117`, avg `-4.3`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-159..+164`, avg `-0.6`).
- `0x847D` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-173..+69`, avg `+28.1`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-173..+74`, avg `-25.3`).
- `0x848E` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-140..+52`, avg `+3.2`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-223..+31`, avg `-27.7`).
- `0x849F` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `1/17` cells (`+78..+78`, avg `+78.0`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`+46..+255`, avg `+120.4`).
- `0x84B0` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `3/17` cells (`+47..+47`, avg `+47.0`).
- `0x84C1` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `15/17` cells (`-161..-2`, avg `-92.0`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-225..-40`, avg `-141.6`).
- `0x84D2` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `15/17` cells (`-26..+134`, avg `+28.6`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `14/17` cells (`-16..+209`, avg `+64.1`).
- `0x84E3` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `6/9` cells (`+1..+145`, avg `+25.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`+13..+221`, avg `+90.3`).
- `0x84EC` `1x1` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/1` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `1/1` cells (`-187..-187`, avg `-187.0`).
  - `peug_106rally_org` differs in `0/1` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `1/1` cells (`-148..-148`, avg `-148.0`).
- `0x84ED` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`+28..+84`, avg `+60.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-140..+41`, avg `-19.7`).
- `0x84F6` `1x9` (word16 raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-5451..-2008`, avg `-4143.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-10042..+41857`, avg `+6023.2`).
- `0x8508` `1x9` (raw): Peugeot immediate word-reference hits `15`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-160..+149`, avg `-31.4`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `8/9` cells (`-151..+52`, avg `-3.5`).
- `0x8511` `1x24` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `24/24` cells (`-32..+14`, avg `-15.5`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `24/24` cells (`-39..+160`, avg `+38.5`).
- `0x8529` `1x9` (word16 raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-4928..+19276`, avg `+219.9`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-1860..+9509`, avg `+4847.3`).
- `0x853B` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `8/9` cells (`-136..+92`, avg `+13.8`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `8/9` cells (`-124..+96`, avg `-32.1`).
- `0x8546` `1x9` (word16 raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `7/9` cells (`+828..+6300`, avg `+1609.9`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-2649..+41391`, avg `+10135.8`).
- `0x8558` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `7/9` cells (`-102..+71`, avg `-41.4`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-174..+76`, avg `-61.8`).
- `0x8561` `1x24` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `10/24` cells (`-5..+249`, avg `+40.9`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `24/24` cells (`-13..+236`, avg `+71.4`).
- `0x8579` `1x9` (word16 raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-1374..+11142`, avg `+8664.2`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-4715..+4626`, avg `-633.1`).
- `0x858B` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `8/9` cells (`+2..+105`, avg `+28.5`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`+2..+144`, avg `+43.0`).
- `0x8596` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-87..+26`, avg `-42.2`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-160..+157`, avg `-34.2`).
- `0x859F` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `8/9` cells (`-19..+81`, avg `+40.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `7/9` cells (`-179..+6`, avg `-74.0`).
- `0x85AF` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-122..+26`, avg `-53.6`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-138..+74`, avg `-2.8`).
- `0x85BA` `24x5` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/120` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `19/120` cells (`-25..+40`, avg `-11.8`).
  - `peug_106rally_org` differs in `0/120` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `46/120` cells (`-25..+202`, avg `+28.0`).
- `0x8636` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-101..+51`, avg `-5.6`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-115..-93`, avg `-102.6`).
- `0x863F` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-63..+62`, avg `+3.7`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-163..-83`, avg `-123.7`).
- `0x8648` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-71..+34`, avg `-9.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-175..+3`, avg `-63.4`).
- `0x8652` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-34..+89`, avg `+9.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`+42..+146`, avg `+88.1`).
- `0x8671` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `8/9` cells (`-2..+253`, avg `+32.2`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-2..+253`, avg `+32.4`).
- `0x8689` `1x9` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `7/9` cells (`-68..+55`, avg `-7.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-78..-56`, avg `-63.2`).
- `0x869A` `24x9` (raw countdown ticks): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `141/216` cells (`-48..+255`, avg `+23.0`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `155/216` cells (`-48..+255`, avg `+7.7`).
- `0x877E` `1x9` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-37..+44`, avg `-9.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-37..-37`, avg `-37.0`).
- `0x8787` `1x1` (word16 raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/1` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `1/1` cells (`+7242..+7242`, avg `+7242.0`).
  - `peug_106rally_org` differs in `0/1` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `1/1` cells (`-725..-725`, avg `-725.0`).
- `0x8789` `1x9` (word16 raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`+6882..+7728`, avg `+7467.1`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-1085..+50674`, avg `+8095.9`).
- `0x87A6` `1x5` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/5` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `5/5` cells (`-2..+215`, avg `+43.0`).
  - `peug_106rally_org` differs in `0/5` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `5/5` cells (`+35..+36`, avg `+35.4`).
- `0x87AB` `1x6` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/6` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `6/6` cells (`-9..+165`, avg `+65.0`).
  - `peug_106rally_org` differs in `0/6` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `6/6` cells (`-8..+211`, avg `+54.7`).
- `0x87B1` `24x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `19/216` cells (`+2..+214`, avg `+33.8`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `38/216` cells (`+1..+246`, avg `+56.0`).
- `0x888E` `24x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `213/216` cells (`-38..+254`, avg `+40.3`).
  - `peug_106rally_org` differs in `0/216` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `208/216` cells (`-38..+99`, avg `-4.9`).
- `0x8970` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-254..+4`, avg `-128.8`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-253..+38`, avg `-139.4`).
- `0x899A` `1x24` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `24/24` cells (`-140..+144`, avg `-36.1`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `23/24` cells (`-112..+223`, avg `+85.4`).
- `0x8C31` `1x24` (raw/2 deg): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `24/24` cells (`-52..+244`, avg `+138.0`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `24/24` cells (`-18..+32`, avg `+8.9`).
- `0x8C49` `1x24` (raw/2 deg): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `24/24` cells (`-79..+240`, avg `+139.0`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `24/24` cells (`-35..+40`, avg `-4.8`).
- `0x8C61` `1x24` (raw/2 deg): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `23/24` cells (`-72..+246`, avg `+87.5`).
  - `peug_106rally_org` differs in `0/24` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `24/24` cells (`-26..+52`, avg `+4.8`).
- `0x8C7C` `17x9` (signed8): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/153` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `19/153` cells (`-12..+48`, avg `+13.2`).
  - `peug_106rally_org` differs in `0/153` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `29/153` cells (`-110..+124`, avg `+40.2`).
- `0x8D15` `17x9` (signed8): Peugeot immediate word-reference hits `3`.
  - `peugeot_mod2` differs in `0/153` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `120/153` cells (`-138..+123`, avg `+21.9`).
  - `peug_106rally_org` differs in `0/153` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `30/153` cells (`-10..+9`, avg `+0.2`).
- `0x8DAE` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`+29..+162`, avg `+95.0`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `11/17` cells (`-30..-5`, avg `-15.7`).
- `0x8DD9` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-234..+20`, avg `-50.7`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-255..-1`, avg `-71.4`).
- `0x8E04` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-81..+21`, avg `-68.3`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `8/9` cells (`-100..-100`, avg `-100.0`).
- `0x8E0D` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-109..-43`, avg `-100.3`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-128..-64`, avg `-117.6`).
- `0x8E18` `1x9` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`+19..+21`, avg `+20.6`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `3/9` cells (`+10..+10`, avg `+10.0`).
- `0x8E36` `1x7` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/7` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `7/7` cells (`-201..+16`, avg `-46.4`).
  - `peug_106rally_org` differs in `0/7` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `5/7` cells (`-217..-10`, avg `-87.4`).
- `0x8E3D` `1x7` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/7` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `7/7` cells (`-74..+16`, avg `-21.9`).
  - `peug_106rally_org` differs in `0/7` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `5/7` cells (`-90..-11`, avg `-53.0`).
- `0x8E46` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-151..-31`, avg `-49.7`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-167..-47`, avg `-65.7`).
- `0x8E57` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-114..-26`, avg `-42.8`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-42..+209`, avg `+103.1`).
- `0x8E6F` `17x5` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `30/85` cells (`+6..+6`, avg `+6.0`).
  - `peug_106rally_org` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `83/85` cells (`-16..+245`, avg `+17.5`).
- `0x8EC7` `17x5` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `76/85` cells (`-16..-16`, avg `-16.0`).
  - `peug_106rally_org` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `82/85` cells (`-16..+239`, avg `+52.9`).
- `0x8F1C` `17x5` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `75/85` cells (`-21..+250`, avg `+69.6`).
  - `peug_106rally_org` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `81/85` cells (`-16..+242`, avg `+32.1`).
- `0x8F71` `17x5` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `80/85` cells (`+1..+254`, avg `+46.4`).
  - `peug_106rally_org` differs in `0/85` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `85/85` cells (`+10..+64`, avg `+16.6`).
- `0x89C7` `1x19` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `19/19` cells (`+1..+22`, avg `+11.1`).
  - `peug_106rally_org` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `19/19` cells (`+15..+126`, avg `+36.8`).
- `0x89DA` `1x19` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `16/19` cells (`-14..+24`, avg `+3.6`).
  - `peug_106rally_org` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `18/19` cells (`-31..+215`, avg `+21.1`).
- `0x89F3` `1x19` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `16/19` cells (`+2..+18`, avg `+7.0`).
  - `xantia_607c` differs in `19/19` cells (`-142..-17`, avg `-77.2`).
  - `peug_106rally_org` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `19/19` cells (`-138..-48`, avg `-94.7`).
- `0x8A23` `1x4` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/4` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `4/4` cells (`-76..+38`, avg `-27.2`).
  - `peug_106rally_org` differs in `0/4` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `4/4` cells (`-118..+156`, avg `-22.5`).
- `0x8A52` `1x19` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `19/19` cells (`+21..+84`, avg `+60.2`).
  - `peug_106rally_org` differs in `0/19` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `18/19` cells (`-12..+12`, avg `+0.4`).
- `0x9000` `1x17` (raw): Peugeot immediate word-reference hits `3`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-63..+54`, avg `+1.5`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-80..-5`, avg `-47.1`).
- `0x9011` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-87..+62`, avg `+4.1`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-141..-7`, avg `-52.6`).
- `0x9022` `1x17` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-103..+208`, avg `+52.2`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-141..-9`, avg `-53.8`).
- `0x9033` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`-32..+191`, avg `+20.4`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `15/17` cells (`-33..+16`, avg `-3.0`).
- `0x9044` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`+2..+142`, avg `+20.1`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`-8..-2`, avg `-4.4`).
- `0x9068` `1x11` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/11` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `8/11` cells (`-3..+144`, avg `+41.8`).
  - `peug_106rally_org` differs in `0/11` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `2/11` cells (`-8..-3`, avg `-5.5`).
- `0x9073` `11x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/99` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `95/99` cells (`+1..+255`, avg `+39.3`).
  - `peug_106rally_org` differs in `0/99` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `46/99` cells (`+1..+255`, avg `+77.9`).
- `0x90D6` `1x9` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `5/9` cells (`-215..-19`, avg `-100.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `8/9` cells (`-255..-175`, avg `-218.1`).
- `0x90EF` `1x17` (raw): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `17/17` cells (`+93..+244`, avg `+183.3`).
  - `peug_106rally_org` differs in `0/17` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `17/17` cells (`+19..+145`, avg `+55.6`).
- `0x92CF` `1x9` (raw): Peugeot immediate word-reference hits `3`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-122..+23`, avg `-31.6`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-195..+78`, avg `+21.6`).
- `0x92D9` `1x9` (raw): Peugeot immediate word-reference hits `3`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-230..+223`, avg `-11.9`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-192..+121`, avg `+14.6`).
- `0x92FA` `1x9` (raw): Peugeot immediate word-reference hits `2`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/9` cells (`-100..+158`, avg `-10.8`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `9/9` cells (`-53..+198`, avg `+46.9`).
- `0x9303` `1x10` (signed8): Peugeot immediate word-reference hits `1`.
  - `peugeot_mod2` differs in `0/10` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `9/10` cells (`-75..+48`, avg `+9.7`).
  - `peug_106rally_org` differs in `0/10` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `10/10` cells (`-75..+85`, avg `+16.7`).
- `0x400E` `1x9` (raw): Peugeot immediate word-reference hits `5`.
  - `peugeot_mod2` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `xantia_607c` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `peug_106rally_org` differs in `0/9` cells (`+0..+0`, avg `+0.0`).
  - `rally13_ori` differs in `0/9` cells (`+0..+0`, avg `+0.0`).

Sensor-axis split note: `0x200A -> 0x2124 -> 0x92D9` builds runtime `0x2038/0x203A`, while `0x2008 -> 0x2122 -> 0x92CF` builds runtime `0x203C/0x203E`. Both raw helper vectors carry the NTC-matching ADC breakpoints `12,20,34,57,93,142,191,227,246`; the adjacent count bytes `0x92E2` and `0x92D8` are both `0x09`. Shared vector `0x400E` stores `160,140,120,100,80,60,40,20,0`, best interpreted as temperature raw output `deg C + 40`, so raw helper labels stay hot-to-cold as `120,100,80,60,40,20,0,-20,-40 deg C`. Runtime consumer maps use the firmware-inverted axis and display cold-to-hot labels. By consumers, `0x2038/0x203A` is now the best likely IAT/air-temperature axis and `0x203C/0x203E` is the best likely CTS/coolant axis; pin or bench proof is still pending.
Signed IAT/RPM fuel correction axis note: `0x802B` and `0x8103` use the `0x92D9 -> 0x2038` likely IAT axis and RPM labels from `0x929E -> 0x2036`; their XDF X labels now display the firmware-inverted consumer order `-40..120 deg C` rather than raw ADC breakpoints. Outputs are `0x204A`/`0x204D`.
Retired boundary-probe note: `0x80EB` is `0x802B + 0xC0`, starts at a non-row-aligned offset inside signed table A, and the old 21x9 view crosses into signed table B at `0x8103`. It has no Peugeot immediate word-reference hits and is historical evidence only, not an active XDF table.

Fuel/charge path note: `0x9187 -> 0x00D0/0x00CE` remains the upstream load/air-charge model; `0x802B/0x8103 -> 0x204B/0x204E` supplies signed likely IAT/RPM corrections; `0x821C/0x8318` signed fuel quantity trims, guarded low-RPM `0x81F8/0x82F4` 4x9 trims, or `0x83F0` RPM-only trim feed `0x2084 -> 0x00C1` through `0xE715`; and `0x00C1 -> 0x2051/0x00C3 -> 0x00BC` is the current strongest software fuel pulse-width / event-width path. `0xE715` scale is roughly fuel += fuel * signed_trim / 256, so raw 64 is about +25%.
Fast closed-loop fuel-correction note: `0x200C -> 0x5B1B -> 0x43DC -> 0x00CC -> 0x2040 -> 0x84E3 -> 0x2049 -> 0x00C1` is a code-traced fuel correction path, with `$2040 = max($00CC - 0x8000, 0) >> 4`. DHC11 labels prove `0x84E3` is a separate 1x9 vector, `0x84EC` is a standalone threshold byte, and `0x84ED` begins the CTS scheduler threshold vector. The software closed-loop role is strong, but the `0x200C` physical O2/lambda channel assignment still needs scope or harness proof.
Closed-loop/adaptive note: `0x9000-0x912B` is now best grouped as lambda / closed-loop / adaptive calibration. `0x9000/0x9011/0x9022` are CTS-like base vectors, `0x9033/0x9044/0x90EF` are delay/timer vectors, `0x9068` is dynamic load-change correction, and `0x9073` is a ramp/target table compared with `0x243C`.
Adaptive trim note: `0x20B9` is a slow closed-loop/adaptive fuel trim centred at `0x8000`. RAM cells `0x0060/0x0069` are learned adaptive trim cells interpolated by `0xC94B`; the `0x8E6F/0x8EC7/0x8F1C/0x8F71` 17x5 cluster feeds `0x24AB/0x24AF/0x24AC/0x24AD`, which are consumed by the `0xCC00-0xD0C6` adaptive state machine.
Warmup/transient note: `0x2059` is the warmup/afterstart state, with `0x00C5/0x00C6` active correction terms. `0x8408-0x84D2` are CTS warmup/afterstart fuel support maps. DHC11 adds exact warmup/startup helpers `0x841B`, `0x843D`, `0x8452`, and `0x84ED`. `0x84F6`, `0x853B`, `0x8546`, `0x858B`, and `0x859F` are CTS `$203C` transient support vectors/word tables feeding `$2588`, `$206B`, `$2586`, `$2079`, and `$2054`; `0x8508`, `0x8529`, `0x8558`, and `0x8579` are `$2042` transient support vectors/word tables feeding `$206D`, `$206E/$2070`, `$207B`, and `$207E/$207C`; `0x8511` and `0x8561` are RPM transient gain vectors feeding `$206C/$207A`; `0x8596/0x85AF` feed additive transient fuel terms `0x2055/0x2057` via the `0xEB16` helper.
Fuel-cut/state-delay note: `0x869A` is a code-confirmed `24x9` B2D6 table used by routine `0x9B79`. Its X axis is positive load rise since state entry: `$2394` snapshots `$00CE`, then the lookup uses clamped `$2014 - $2394`, scaled to internal index `0.00..8.00` with the final column saturated at `>=512` raw counts. Its Y axis is RPM `$2036`. Output stores to `$2391`, which the surrounding state machine decrements; when the delay expires, that path sets `$00A3=0x04`, clears `$00AB`, and zeros `$00C3`. Treat Z values as raw countdown ticks, not fuel quantity, spark, VE, or a limiter threshold.
Idle/actuator note: `0x888E` is best treated as an idle-air / idle-bypass target table, not fuel. It combines with likely CTS vector `0x8970` into `0x2484/0x2486`, shapes `0x202B`, and toggles external bit `0x1050.04`; actuator hardware proof remains open. DHC11 exact lookup views `0x8636/0x863F/0x8648` feed `$20A8` from `$203C`, `0x8652/0x8671` feed `$210E/$2110` from `$2042`, `0x8689` feeds `$20F6` from `$203C`, and `0x899A` feeds closed-loop entry offset `$20F5` from RPM.
SPI frame note: `0x8010-0x8027` is a pointer frame consumed by `0x9F02-0xA001` to stream live RAM/status bytes through SPI data register `0x102A`. It is not calibration; the signed fuel correction table starts at `0x802B`.
Fuel output timing note: `0x87B1 -> 0x00BE -> 0x21C6` is injector/event phase. OC1 schedules the interrupt at `TOC1=0x00B8+0x21C6` (`0x1016`), then vector `0x6FE4` configures OC3/PA5 action bits at `0x1020`, forces an OC3 edge through `0x100B`, and schedules the opposite edge at `0x101A`. `0x00C3 -> 0x00BC` is pulse width / scheduled event width, while `0x85BA -> 0x2063 -> 0x00C3` is high-load duration support.
Fuel output support-vector note: `$2040 = max($00CC - 0x8000, 0) >> 4` indexes scheduler support at `0x92FA`, `0x877E`, and `0x8789`; DHC11 also uses exact signed subvector base `0x9303` to feed `$2048`. XDF axes use decimal `$00CC` display labels `32768..65535` for the human hex mapping `0x8000, 0x9000, 0xA000, 0xB000, 0xC000, 0xD000, 0xE000, 0xF000, 0xFFFF/end`; `0x9303` uses `65536` only as a numeric display sentinel for its guard/unproven final cell. `0x92FA` is a separate unsigned 1x9 table whose interpolated byte is multiplied by 40 and stored to `$2388`; `0x9303` begins immediately afterward but is not part of that table. `0x877E` feeds `$00BF`; `0x8787` is the OC3 period-fit guard word; `0x8789` is a provisional 1x9 word vector that feeds `$2086`, an OC3 edge-offset/deadline-style term, not fuel quantity and not normal injector battery deadtime. Normal inactive-output edge timing is best summarized as `TOC3 = $21CB + $2086 + $00BC + 5`. The optional 0x8789 ms display assumes 2 us/tick; crank-degree conversion remains documented-only until E-clock and timer prescaler are proven.
Ignition event note: `0x7CDA` and `0x7CEA` are compact event selector data tables, not executable code and not tune maps. They feed four 12-byte ignition event records at `0x2312/0x231E/0x232A/0x2336`, built from final per-event spark values `0x20E2-0x20E5`.
Ignition output note: `0x2147 -> 0x2001 -> 0x00B6 -> 0x20E2-0x20E5 -> 0x2312/0x231E/0x232A/0x2336` is the current best software spark command/event chain. `0x89C7 -> 0x20E7 -> 0x20EB` looks like ignition phase, `0x89DA -> 0x20E8 -> 0x20ED` like width/dwell-window, `0x89F3 -> 0x20BC` is per-event retard/gain candidate, and `0x8A23-0x8A51` holds retard strategy scalars. DHC11 exact lookup views `0x87A6/0x87AB` feed spark transition output `$214F`, while `0x8E04/0x8E0D/0x8E18` feed `$2146` in spark-state decay branches. OC2/OC4 at `0x1018/0x101C` are the strongest software ignition-output candidates; exact coil driver/pin proof remains open.
Adaptive entry note: DHC11 exact lookup views `0x8E36/0x8E3D` are mixed byte/word threshold records used by the `0xCC00` closed-loop/adaptive entry gate, while `0x8E46/0x8E57` are `$2044`-indexed RPM-offset vectors added to `$00C9` before the same entry comparison. Values are raw because the threshold fields are heterogeneous and the state-machine naming is still provisional.

Main fuel status: a pure VE/base table is still not proven, but `0x821C/0x8318` are now the strongest signed fuel quantity trim tables. `0x81F8/0x82F4` are guarded low-RPM 4x9 trims selected by `0xE38B`, and `0x83F0` is an RPM-only trim/bypass vector. Fuel quantity/duration and fuel timing/phase are now separated: `$00C3/$00BC` is duration, `$21C6` is phase, and `$2086` is edge-offset support. The exact injector driver/pin remains a hardware-level proof item. The old `0x802E` VE-looking surface remains a legacy misaligned slice inside the signed `0x802B` table.

Spark alignment scan against Peugeot stock 24x9+24x9+1x24 bundle:

| ROM | Best high-bank start | Shift vs 0x8A69 | RMSE high | RMSE low | RMSE WOT | Notes |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `peugeot_stock` | `0x8A69` | `+0` | 0.0 | 0.0 | 0.0 | same-offset |
| `peugeot_stok` | `0x8A69` | `+0` | 0.0 | 0.0 | 0.0 | same-offset |
| `peugeot_mod2` | `0x8A69` | `+0` | 3.6 | 6.9 | 0.0 | same-offset |
| `xantia_607c` | `0x89BB` | `-174` | 19.8 | 16.7 | 12.7 | same-family offset candidate only |
| `peug_106rally_org` | `0x8A69` | `+0` | 23.8 | 27.7 | 0.0 | same-offset but heavily altered spark banks; WOT vector unchanged |
| `rally13_ori` | `0x8A84` | `+27` | 0.0 | 0.0 | 0.0 | exact stock spark bundle shifted +0x1B |

- `0x00B6`: `20` scanned refs; stores/clears at 0x4424, 0x46D0, 0x48AA, 0x67F1, 0x96D7, 0x9733, 0xB179; loads/math at 0xB0F0, 0xB13C, 0xB160, 0xB187, 0xB1E4, 0xB208, 0xB22C, 0xB250, 0xC03C, 0xD0E6.
- `0x00BC`: `24` scanned refs; stores/clears at 0x6F6F, 0x6F84, 0x6F9F, 0x6FA6, 0x6FF4, 0x7014, 0x702C, 0x7037, 0x7052, 0x7057; loads/math at 0x6F89, 0x6F91, 0x7032, 0x703C, 0x7048, 0x7072, 0x707A, 0x70A2, 0x70CA, 0x70D2.
- `0x00BF`: `7` scanned refs; stores/clears at 0xD5D5, 0xD5FE; loads/math at 0x6E9A, 0x6F7D, 0x6F86, 0x6F9D, 0x721D.
- `0x00C1`: `39` scanned refs; stores/clears at 0xE5F1, 0xE617, 0xE625, 0xE645, 0xE650, 0xE676, 0xE67F, 0xE69F, 0xE6B9, 0xE6C2; loads/math at 0x58DA, 0x6E9E, 0x6ED6, 0x6EDD, 0x6EE8, 0xAE2B, 0xE605, 0xE611, 0xE61A, 0xE637.
- `0x00C3`: `11` scanned refs; stores/clears at 0x6EEA, 0x79B5, 0x9B46, 0xDFC8, 0xE6D3, 0xE7AC; loads/math at 0x6F6C, 0x6F73, 0x6FA3, 0x7010, 0x7029.
- `0x00C5`: `11` scanned refs; stores/clears at 0x9676, 0xE7D7, 0xE9C7, 0xEA26, 0xEA8B, 0xEA92; loads/math at 0xE647, 0xEA21, 0xEA49, 0xEA78, 0xEA7D.
- `0x00C6`: `10` scanned refs; stores/clears at 0xA52F, 0xE7D9, 0xE9C9; loads/math at 0x5C55, 0x63EE, 0xA2B1, 0xA2D1, 0xA53B, 0xEA43, 0xEA6E.
- `0x00CC`: `13` scanned refs; stores/clears at 0x43D5, 0xD6E3; loads/math at 0x43C7, 0x43F3, 0x6084, 0x60DA, 0x9387, 0x93A9, 0x93E6, 0x945D, 0xB898, 0xE302.
- `0x2001`: `8` scanned refs; stores/clears at 0x4687, 0x4693, 0x476D, 0x5270, 0x5482, 0x5C4F, 0x5ECE, 0xD7BC; loads/math at -.
- `0x2002`: `4` scanned refs; stores/clears at 0x4892, 0x7E44, 0xA9C1, 0xC710; loads/math at -.
- `0x202B`: `10` scanned refs; stores/clears at 0x9714, 0xBEE7, 0xCB89; loads/math at 0x9728, 0xBE5F, 0xBED8, 0xCE67, 0xCF0B, 0xE8E9, 0xE8F9.
- `0x202C`: `2` scanned refs; stores/clears at 0xBEEF, 0xBEF7; loads/math at -.
- `0x2040`: `6` scanned refs; stores/clears at 0x4400; loads/math at 0x9525, 0xD5DF, 0xD5EF, 0xD6F5, 0xE83E.
- `0x2049`: `4` scanned refs; stores/clears at 0xE79E, 0xE848; loads/math at 0x6F70, 0xE6A6.
- `0x204A`: `3` scanned refs; stores/clears at 0xE786, 0xE869; loads/math at 0xE928.
- `0x204B`: `2` scanned refs; stores/clears at 0xE959; loads/math at 0xE5E8.
- `0x204D`: `3` scanned refs; stores/clears at 0xE78C, 0xE88A; loads/math at 0xE95D.
- `0x204E`: `3` scanned refs; stores/clears at 0xE96D; loads/math at 0xE5FF, 0xE607.
- `0x204F`: `2` scanned refs; stores/clears at -; loads/math at 0xE5F3, 0xE613.
- `0x2050`: `2` scanned refs; stores/clears at 0xE7ED; loads/math at 0xE935.
- `0x2051`: `4` scanned refs; stores/clears at 0xE6A1, 0xE7AE; loads/math at 0x6582, 0x6F48.
- `0x2053`: `5` scanned refs; stores/clears at 0xE5E5, 0xE7B4; loads/math at 0xCC57, 0xE684, 0xE68A.
- `0x2055`: `5` scanned refs; stores/clears at 0xE7A6, 0xEAA7, 0xEAC4; loads/math at 0xE654, 0xEAB5.
- `0x2057`: `4` scanned refs; stores/clears at 0xE7A9, 0xEB02, 0xEB0E; loads/math at 0xE659.
- `0x2059`: `15` scanned refs; stores/clears at 0x713D, 0x729F, 0xE9E3, 0xEA0A, 0xEA96; loads/math at 0x5B7D, 0x5B95, 0x7101, 0x9818, 0x999A, 0x9A9B, 0x9CA5, 0xBE14, 0xCC14, 0xE9A8.
- `0x2060`: `4` scanned refs; stores/clears at 0x7153, 0xE9F9, 0xEA02; loads/math at 0xE9FC.
- `0x2062`: `3` scanned refs; stores/clears at 0xE792, 0xE9DB; loads/math at 0xE9D5.
- `0x2084`: `2` scanned refs; stores/clears at 0xE3E1, 0xE798; loads/math at -.
- `0x2085`: `3` scanned refs; stores/clears at 0xE79B, 0xE83B; loads/math at 0xE63B.
- `0x2086`: `6` scanned refs; stores/clears at 0xD5D7, 0xD60A, 0xD6DC; loads/math at 0x706C, 0x707F, 0x70A4.
- `0x2090`: `10` scanned refs; stores/clears at 0xC0E4, 0xC19E, 0xCAFE; loads/math at 0x5685, 0xC03D, 0xC1AA, 0xC1DF, 0xC86C, 0xC931, 0xC97C.
- `0x2093`: `1` scanned refs; stores/clears at 0xC03A; loads/math at -.
- `0x2094`: `3` scanned refs; stores/clears at 0xCB4D; loads/math at 0xC588, 0xC734.
- `0x2095`: `3` scanned refs; stores/clears at 0xCB57; loads/math at 0xC594, 0xC744.
- `0x2096`: `9` scanned refs; stores/clears at 0xC0F3, 0xC124; loads/math at 0xC08B, 0xC0C0, 0xC1EE, 0xC361, 0xC8E7.
- `0x2099`: `2` scanned refs; stores/clears at 0xC227; loads/math at -.
- `0x209A`: `5` scanned refs; stores/clears at 0xC263, 0xC32F, 0xCAE3; loads/math at 0xC255.
- `0x209B`: `16` scanned refs; stores/clears at 0xC0EA, 0xC187, 0xC457, 0xC4A3, 0xC4BB, 0xC510, 0xC53A, 0xC9B1, 0xCAE6; loads/math at 0xC4F2, 0xC56B, 0xC99A, 0xC9A8.
- `0x20A2`: `3` scanned refs; stores/clears at 0xC5F6; loads/math at 0xC1BD, 0xC77E.
- `0x20A4`: `12` scanned refs; stores/clears at 0x6CD8, 0x6DB7, 0x96EC, 0xC1C3, 0xC5F9, 0xC731, 0xC784, 0xCA2F, 0xCB5E; loads/math at 0x56BA, 0x975C, 0xC9FA.
- `0x20A6`: `7` scanned refs; stores/clears at 0xC106, 0xC1C0, 0xC705, 0xC72E, 0xC781; loads/math at 0xC71A, 0xC79A.
- `0x20B9`: `15` scanned refs; stores/clears at 0xCBB1, 0xCBC7, 0xCC98, 0xCDC8, 0xCDDF, 0xCDFB; loads/math at 0xCDBC, 0xCDD3, 0xCDEA, 0xCE0E, 0xCF89, 0xD04C, 0xE62D.
- `0x20D3`: `7` scanned refs; stores/clears at 0xB0EE, 0xB13A, 0xBBB3; loads/math at 0xB087, 0xB134, 0xB1AC, 0xB1C8.
- `0x20D4`: `7` scanned refs; stores/clears at 0xBA8E, 0xBBE0; loads/math at 0xB0FF, 0xB156, 0xB16F, 0xB188, 0xB1A1.
- `0x20D9`: `5` scanned refs; stores/clears at 0x9E48, 0xB19E, 0xBBB0; loads/math at 0xB193, 0xB1C0.
- `0x20DA`: `4` scanned refs; stores/clears at 0xB153, 0xBBA7; loads/math at 0xB148, 0xB1B1.
- `0x20DB`: `4` scanned refs; stores/clears at 0xB16C, 0xBBAA; loads/math at 0xB161, 0xB1B6.
- `0x20DC`: `4` scanned refs; stores/clears at 0xB185, 0xBBAD; loads/math at 0xB17A, 0xB1BB.
- `0x20DE`: `6` scanned refs; stores/clears at 0xB24D, 0xB269, 0xBBBF; loads/math at 0x4858, 0xE5B8.
- `0x20DF`: `6` scanned refs; stores/clears at 0xB1E1, 0xB260, 0xBBB6; loads/math at 0x4849, 0xA52D, 0xE5A0.
- `0x20E0`: `6` scanned refs; stores/clears at 0xB205, 0xB263, 0xBBB9; loads/math at 0x484E, 0xE5A8.
- `0x20E1`: `6` scanned refs; stores/clears at 0xB229, 0xB266, 0xBBBC; loads/math at 0x4853, 0xE5B0.
- `0x20E2`: `5` scanned refs; stores/clears at 0x48D2, 0x95E8, 0xB258; loads/math at 0x7D5D, 0x7D66.
- `0x20E3`: `7` scanned refs; stores/clears at 0x48B4, 0x95DF, 0xB1EC; loads/math at 0x7A8E, 0x7B16, 0x7CFD, 0x7D06.
- `0x20E4`: `5` scanned refs; stores/clears at 0x48BE, 0x95E2, 0xB210; loads/math at 0x7D3D, 0x7D46.
- `0x20E5`: `6` scanned refs; stores/clears at 0x48C8, 0x95E5, 0xB234; loads/math at 0x7A89, 0x7D1D, 0x7D26.
- `0x20E6`: `13` scanned refs; stores/clears at 0xBA9B, 0xBBE6; loads/math at 0xB11A, 0xB1DE, 0xB202, 0xB226, 0xB24A, 0xB25D.
- `0x20E7`: `3` scanned refs; stores/clears at 0xBA74, 0xBBD4; loads/math at 0xBD1E.
- `0x20E8`: `4` scanned refs; stores/clears at 0xBA81, 0xBBDA; loads/math at 0xBD40, 0xBD46.
- `0x20EB`: `4` scanned refs; stores/clears at 0xBB9A, 0xBD39; loads/math at 0xBC67, 0xBC7A.
- `0x20ED`: `4` scanned refs; stores/clears at 0xBB9D, 0xBD4F; loads/math at 0xBCB1, 0xBCC1.
- `0x2132`: `6` scanned refs; stores/clears at 0x4427, 0x467F, 0x4690; loads/math at 0x4653, 0x465E, 0x4675.
- `0x2134`: `2` scanned refs; stores/clears at 0x442B, 0x49C5; loads/math at -.
- `0x21C6`: `5` scanned refs; stores/clears at 0x724C, 0x7298, 0x72A9; loads/math at 0x6FC0, 0x6FD1.
- `0x21C8`: `9` scanned refs; stores/clears at 0x6F65, 0x6FB0, 0x7024; loads/math at 0x7075, 0x708A, 0x709C, 0x70CD, 0x70DF, 0x70F0.
- `0x21CB`: `6` scanned refs; stores/clears at 0x7062; loads/math at 0x707C, 0x7090, 0x70C4, 0x70E5, 0x70F6.
- `0x21CD`: `3` scanned refs; stores/clears at 0x70A7, 0x70ED; loads/math at 0x704A.
- `0x21CF`: `4` scanned refs; stores/clears at 0x712C, 0x7219; loads/math at 0x6FF1, 0x7034.
- `0x2312`: `3` scanned refs; stores/clears at 0x9587; loads/math at 0x7583, 0x7CF9.
- `0x231E`: `3` scanned refs; stores/clears at 0x958A; loads/math at 0x7570, 0x7D39.
- `0x232A`: `3` scanned refs; stores/clears at 0x958D; loads/math at 0x757D, 0x7D19.
- `0x2336`: `3` scanned refs; stores/clears at 0x9590; loads/math at 0x756A, 0x7D59.
- `0x243C`: `10` scanned refs; stores/clears at 0xC260, 0xC2E1, 0xC2F9, 0xC301; loads/math at 0xC2EE, 0xC2FC, 0xC304.
- `0x243E`: `3` scanned refs; stores/clears at 0xC2AC; loads/math at 0xC31A, 0xC31F.
- `0x243F`: `6` scanned refs; stores/clears at 0xC131, 0xC93E; loads/math at 0xC0A3, 0xC0B5, 0xC1E9, 0xC938.
- `0x244C`: `2` scanned refs; stores/clears at 0xC13E; loads/math at 0xC1F8.
- `0x245E`: `3` scanned refs; stores/clears at 0xC141, 0xC1FB; loads/math at -.
- `0x2483`: `4` scanned refs; stores/clears at 0xBEEA, 0xCB8C; loads/math at 0xBEF2.
- `0x2484`: `3` scanned refs; stores/clears at 0xBE93, 0xCB86; loads/math at 0xBEAF.
- `0x2486`: `2` scanned refs; stores/clears at 0xBEA0, 0xCB7D; loads/math at -.
- `0x2488`: `1` scanned refs; stores/clears at 0xBECB; loads/math at -.
- `0x248D`: `3` scanned refs; stores/clears at 0xBF19, 0xBF20; loads/math at 0xBF49.
- `0x248E`: `2` scanned refs; stores/clears at 0xBF3F, 0xBF46; loads/math at -.
- `0x249B`: `6` scanned refs; stores/clears at 0xCBB4, 0xCBCA, 0xCC9B, 0xCE14; loads/math at 0xCE04, 0xCE5B.
- `0x24AB`: `2` scanned refs; stores/clears at 0xD134; loads/math at 0xCD51.
- `0x24AC`: `2` scanned refs; stores/clears at 0xD140; loads/math at 0xCD04.
- `0x24AD`: `2` scanned refs; stores/clears at 0xD151; loads/math at 0xCD0A.
- `0x24AF`: `2` scanned refs; stores/clears at 0xD15D; loads/math at 0xCD8C.
- `0x24B0`: `6` scanned refs; stores/clears at 0xCDB9, 0xCDCB, 0xCDE2, 0xCDFE; loads/math at 0xCDC3, 0xCDDA.
- `0x2584`: `3` scanned refs; stores/clears at 0xE4F9, 0xE58D; loads/math at 0xE663.
- `0x2590`: `3` scanned refs; stores/clears at 0xE3F4, 0xE4DB; loads/math at 0xE65E.
- `0x2596`: `6` scanned refs; stores/clears at 0xE780, 0xE924; loads/math at 0xE903, 0xE913, 0xE921, 0xE92E.
- `0x25A3`: `6` scanned refs; stores/clears at 0xE931, 0xE93F; loads/math at 0xE84B, 0xE86C, 0xE93B, 0xE953.
- `0x2610`: `10` scanned refs; stores/clears at 0x4EDC, 0x6A37, 0x6B37, 0x6B46, 0x6BA1, 0x6BB0, 0xCB10; loads/math at 0x6B2C, 0x6B96, 0xE948.
- `0x100B`: `3` scanned refs; stores/clears at 0x75B7, 0xB549, 0xD346; loads/math at -.
- `0x100E`: `30` scanned refs; stores/clears at -; loads/math at 0x4FA7, 0x4FD3, 0x51BE, 0x53A3, 0x5880, 0x6CEC, 0x6EF5, 0x6FC8, 0x705F, 0x71D0.
- `0x1016`: `3` scanned refs; stores/clears at 0x6EFB, 0x6FC5; loads/math at 0x4E13.
- `0x1018`: `18` scanned refs; stores/clears at 0x75CF, 0x75E3, 0x7984, 0x79B9, 0x79FE, 0x7A24, 0x7C29, 0x7C52, 0x7F57, 0x7F86; loads/math at 0x7F52, 0x7FA8, 0x7FBE, 0x7FC6, 0x7FD9.
- `0x101A`: `13` scanned refs; stores/clears at 0x6CEF, 0x7085, 0x7096, 0x70D7, 0x70F9, 0x71D3, 0xA939, 0xAC32, 0xAC54, 0xACAD; loads/math at 0x70C1, 0x70D4, 0x70E8.
- `0x101C`: `9` scanned refs; stores/clears at 0x4FAD, 0x4FD9, 0x5045, 0xBC6A, 0xBC8C, 0xBCB4, 0xDEFD; loads/math at 0x503F, 0xBCAB.
- `0x1020`: `8` scanned refs; stores/clears at 0x6D3C, 0x6DB2, 0xB544, 0xB951, 0xD82C; loads/math at 0x5BB3, 0x6BD5.
- `0x1022`: `5` scanned refs; stores/clears at 0x4F1D, 0x6BF0, 0x6DAC, 0xD82F; loads/math at 0x6BCF.
- `0x1023`: `39` scanned refs; stores/clears at 0x4FB2, 0x4FDE, 0x504A, 0x50D6, 0x5145, 0x519A, 0x51A7, 0x538C, 0x54B2, 0x5561; loads/math at 0x512C, 0x5183, 0x5259, 0x546B, 0x54A3.
- `0x1028`: `4` scanned refs; stores/clears at 0x9EF4, 0x9EFC, 0xA01B, 0xA01E; loads/math at -.
- `0x1029`: `20` scanned refs; stores/clears at -; loads/math at 0x9EEC, 0x9F06, 0x9F1C, 0x9F34, 0x9F44, 0x9F52, 0x9F60, 0x9F6E, 0x9F7C, 0x9F8A.
- `0x102A`: `19` scanned refs; stores/clears at 0x9F37, 0x9F47, 0x9F55, 0x9F63, 0x9F71, 0x9F7F, 0x9F8D, 0x9F9B, 0x9FAA, 0x9FB8; loads/math at 0x9EEF, 0xA009.
- `0x1050`: `40` scanned refs; stores/clears at 0x4F3E, 0x50E8, 0x50F0, 0x514D, 0x51B3, 0x51C8, 0x51F7, 0x530A, 0x531C, 0x5398; loads/math at 0x50E3, 0x50EB, 0x5148, 0x51AE, 0x51C3, 0x51F2, 0x5305, 0x5317, 0x5393, 0x5408.
- `0x242B`: `3` scanned refs; stores/clears at 0xBD1B; loads/math at 0xBC64, 0xBC76.
- `0x242D`: `2` scanned refs; stores/clears at 0xBCAE; loads/math at 0xBCBD.
- `0x20BC`: `2` scanned refs; stores/clears at 0xBAB1, 0xBBEC; loads/math at -.
- `0x242F`: `5` scanned refs; stores/clears at 0xBAB5, 0xBAC6; loads/math at 0xBABE, 0xBB49, 0xBB53.
- `0x2431`: `2` scanned refs; stores/clears at 0xBB68, 0xBB79; loads/math at -.

- `0x1030` ADC/load path: `16` scanned refs; first sites 0x40E8, 0x4133, 0x51EF, 0x52D1, 0xB82C, 0xB8C0, 0xBC23, 0xBCD0, 0xDA6B, 0xDA88, 0xDDB0, 0xDDFD.
- `0x1031` ADC/load path: `8` scanned refs; first sites 0x401E, 0x4113, 0x53CC, 0xBC2B, 0xBCD8, 0xDAB8, 0xDE48, 0xE116.
- `0x1032` ADC/load path: `5` scanned refs; first sites 0x403B, 0x4140, 0x52A8, 0x53D9, 0xDE31.
- `0x1033` ADC/load path: `7` scanned refs; first sites 0x4024, 0x4041, 0x4119, 0x4146, 0x52B5, 0x53E6, 0xDE17.
- `0x1034` ADC/load path: `7` scanned refs; first sites 0x402D, 0x405A, 0x411F, 0x414C, 0x52C2, 0x53F3, 0xDE5F.
- `0x2007` ADC/load path: `5` scanned refs; first sites 0x4044, 0x4149, 0x5E97, 0x5EEC, 0x96D3.
- `0x2008` ADC/load path: `7` scanned refs; first sites 0x4021, 0x40CE, 0x4116, 0x4322, 0x5C19, 0x96E9, 0xBB8A.
- `0x2009` ADC/load path: `6` scanned refs; first sites 0x40D7, 0x432B, 0x5BA0, 0x5BC4, 0x5CE9, 0xC61B.
- `0x200A` ADC/load path: `7` scanned refs; first sites 0x4030, 0x40B0, 0x4123, 0x4372, 0x5D1F, 0x6D25, 0x96F3.
- `0x200B` ADC/load path: `5` scanned refs; first sites 0x40B9, 0x437B, 0x47F1, 0x5D5D, 0x9554.
- `0x200C` ADC/load path: `4` scanned refs; first sites 0x403E, 0x4143, 0x5B1B, 0x5B8E.
- `0x200D` ADC/load path: `4` scanned refs; first sites 0x4027, 0x411C, 0x415D, 0x6933.
- `0x200E` ADC/load path: `7` scanned refs; first sites 0x405D, 0x4150, 0x4173, 0x418E, 0x42F7, 0x5DA8, 0x96DA.
- `0x2013` ADC/load path: `11` scanned refs; first sites 0x404D, 0x4128, 0x5F20, 0x9792, 0x97AF, 0x98FF, 0x997E, 0x99A9, 0x99EB, 0x9CC4, 0x9D03.
- `0x2122` ADC/load path: `3` scanned refs; first sites 0x40E1, 0x433D, 0x4346.
- `0x2124` ADC/load path: `3` scanned refs; first sites 0x40C3, 0x438D, 0x4396.
- `0x2038` ADC/load path: `5` scanned refs; first sites 0x43B1, 0x4E49, 0x5C9F, 0xE84F, 0xE870.
- `0x203A` ADC/load path: `2` scanned refs; first sites 0x43B5, 0x4953.
- `0x203C` ADC/load path: `12` scanned refs; first sites 0x4361, 0x44B1, 0x55F8, 0x720F, 0x72BC, 0x9B61, 0xC2A2, 0xC819, 0xC824, 0xE7F0, 0xE817, 0xE824.
- `0x203E` ADC/load path: `17` scanned refs; first sites 0x4365, 0x4947, 0x49BE, 0x7129, 0x7140, 0x716B, 0xBE9A, 0xC01E, 0xC11A, 0xC127, 0xC134, 0xE7C4.
- `0x2040` ADC/load path: `6` scanned refs; first sites 0x4400, 0x9525, 0xD5DF, 0xD5EF, 0xD6F5, 0xE83E.
- `0x2042` ADC/load path: `6` scanned refs; first sites 0x41EC, 0x5758, 0x97DA, 0xE3FD, 0xE4FF, 0xE97A.
- `0x00CE` ADC/load path: `19` scanned refs; first sites 0x4073, 0x409C, 0x412B, 0x41A1, 0x42E1, 0x45F3, 0x4FC1, 0x5E5E, 0x5E7C, 0x97E7, 0x98C1, 0x992C.
- `0x00D0` ADC/load path: `22` scanned refs; first sites 0x574A, 0x57BD, 0x5E5C, 0x5E77, 0x5F07, 0x5FAA, 0x8073, 0x96DE, 0x96F7, 0x97F4, 0x9800, 0x9953.
- `0x2034` ADC/load path: `8` scanned refs; first sites 0x41AD, 0x4913, 0x495F, 0x6EA9, 0x7258, 0xBA34, 0xBE78, 0xE3CF.
<!-- END GENERATED ANALYSIS -->
