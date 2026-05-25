# IAW8P40 Evidence Status

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
| `0x802E-0x80EA` | `21x9` | Likely Fuel/VE/Air-Charge Correction Candidate | No | Yes, `57 / 189`, `+4..+6` | Xantia differs all cells; Peug public file same as stock; RALLY13 differs `116 / 189` | Raw; `raw / 2.55` visualization only | Medium fuel-side | Find Peugeot-local consumer into fuel, lambda, air-charge, or injection math. |
| `0x802E-0x8105` | `24x9` | Alternate Boundary View for `0x802E` Candidate | No | Yes, `75 / 216`, `+4..+6` | Xantia differs all cells; Peug public file same as stock; RALLY13 differs `133 / 216` | Raw | Boundary/debug only | Prove whether rows `21-23` are tail data or adjacent calibration. |
| `0x80EB-0x81A7` | `21x9` | Public-Index Alignment Probe B | No | Yes, `60 / 189`, includes wraps | Xantia differs all cells; Peug public file same as stock; RALLY13 differs `126 / 189` | Raw | Low | Find code reference or table consumer; explain modulo wraps. |
| `0x81A8-0x81D4` | `5x9` | Public-Index Alignment Probe Tail | No | Yes, `30 / 45`, includes wraps | Xantia differs all cells; Peug public file same as stock; RALLY13 differs `30 / 45` | Raw | Low | Prove tail/alignment role or remove from normal inspection priority. |
| `0x80F1-0x81D1` | `25x9` | Likely Signed Fuel/Enrichment Adjacent Candidate | No | Yes, `90 / 225`; old `0x8106` was a mid-row slice | Same-offset comparison only; overlaps the lower part of the broader `0x802E-0x81D4` region | Signed 8-bit via TunerPro native data flag | Low | Prove axis and whether this is continuation, enrichment, or unrelated data. |
| `0x8A69-0x8B40` | `24x9` | Likely Spark Advance High Octane / Default | Yes, Peugeot stock/MOD2; XDF `Confirmed` category | Yes | Peug public file uses same offset but altered; RALLY13 shifted to `0x8A84` | Z `raw / 2` degrees; X rounded display-only `0-100 kPa` from runtime `0x2034` | High working label for Peugeot stock/MOD2 | Finish knock/fallback selector trace before removing likely qualifier; prove exact MAP ADC transfer. |
| `0x8B41-0x8C18` | `24x9` | Likely Spark Advance Low Octane / Alternate | Yes, Peugeot stock/MOD2; XDF `Confirmed` category | Yes | Peug public file uses same offset but altered; RALLY13 shifted to `0x8B5C` | Z `raw / 2` degrees; X rounded display-only `0-100 kPa` from runtime `0x2034` | High working label for Peugeot stock/MOD2 | Finish knock/fallback selector trace before removing likely qualifier; prove exact MAP ADC transfer. |
| `0x8C19-0x8C30` | `1x24` | Likely WOT Spark Advance Vector | Yes, Peugeot stock/MOD2; XDF `Confirmed` category | No | Peug public file unchanged at same offset; RALLY13 shifted to `0x8C34`; Xantia differs strongly | `raw / 2` degrees, RPM-only axis `0x2036` | Medium-high | Prove WOT/bypass condition and final spark scheduling path. |
| `0x9187-0x925E` | `24x9` | Load Model / Correction Factor Candidate | Yes | Yes, `62 / 216` | Yes, but strategy differs | `raw / 230` hypothesis | Medium-high structural | Prove exact physical role: air density, VE, fuel, or load-model correction. |
| `0x89F3-0x8A05` | `1x19` | Likely Speed/Transient Correction Vector | Yes | Yes, `16 / 19` | Same offset not authoritative | Raw | Medium | Name `0x2044` axis and trace output into enrichment/limit/transient logic. |
| `0x879E/0x87A0` | `2x16-bit` | Likely RPM Limiter Set/Clear Thresholds | Code-referenced | Yes | No | `15000000 / period` local hypothesis | Medium | Verify limiter behavior in code or logs; public `21000000 / value` remains a lead only. |
| `RAM 0x2034` | runtime `8.8` axis | MAP/load kPa estimate axis | Yes, runtime axis | Not directly a ROM table | Physical comparison only | XDF spark display rounded integer `0-100 kPa`; raw axis still `0-0x0800` style | Medium-high MAP/load | Prove exact ADC channel and transfer curve. |
| `RAM 0x2036` | runtime `8.8` axis | RPM-normalized axis | Yes, runtime axis | Not directly a ROM table | Physical comparison only | Produced from `0x929E` period table | High | Confirm exact timer clock basis if live RPM logging becomes available. |
| `0x929E-0x92CD` | `1x24` | Code-Confirmed RPM Axis | Yes; XDF `Confirmed` category | No | Xantia comparable only as family pattern | `15000000 / raw period` | High | Confirm exact timer clock basis if live RPM logging becomes available. |
| `0x9291-0x9299` | `1x9` | Code-Referenced Axis Vector A | Yes; XDF `Confirmed` category | No | Same-family comparison only | Raw | High structural | Name physical units from consumers and live data. |
| `0x92CF-0x92D7` | `1x9` | Code-Referenced Axis Vector B | Yes; XDF `Confirmed` category | No | Same-family comparison only | Raw | Medium structural | Finish caller grouping and name physical units. |
| `0x55A0-0x55B1` | `1x18` | Diagnostic Event-Code Table | Yes, diagnostic queue | No | Not a tune map | Raw | High diagnostic | Decode external event meanings from callers and service protocol. |
| `0x9131-0x9169` | `19x3` | State Descriptor Triples | Yes, descriptor subsystem | No | Not a tune map | Raw | High diagnostic/state | Decode descriptor fields and event/state semantics. |
