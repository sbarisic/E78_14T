# Peugeot 106 1.3 Rallye Sensor References

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
| `B33` | Vehicle speed sensor | Supports speed-indexed logic and likely relates to the `0x00D4/0x2044` family. |
| `B69` | Knock sensor, marked for 1.3 | Supports the idea that dual spark banks may be knock/octane related, but bank meaning is not proven. |
| `B72` | Heated oxygen sensor | Supports closed-loop mixture/adaptation and diagnostic logic. |
| `B75` | Crankshaft speed sensor | Source for period/RPM logic, likely upstream of `0x00BA` and `0x2036`. |
| `B83` | Manifold absolute pressure sensor | Strong clue for the `0x2034` load/MAP axis. |
| `B147` | Throttle position sensor | Should correspond to one ADC channel and transient/idle/WOT logic. |

PeugeotBook also lists Magneti Marelli system service items including the
throttle potentiometer, idle-speed control stepper motor, MAP sensor, coolant
temperature sensor, inlet air temperature sensor, crankshaft sensor, knock
sensor, throttle-housing heating element, and vehicle speed sensor.

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
6. Use live data if available:
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
