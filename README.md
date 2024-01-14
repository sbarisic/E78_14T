# E78_14T

Delphi E78 ECU and GM/Chevrolet/Opel 1.4T engine A14NET LUJ LUV information
Original injectors: 0280158205

# BOSCH 0 280 158 117
Note - none of these are confirmed as of yet

```
43.50 PSI (3 bar) 510cc / min = 49 lb / h
58.00 PSI (4 bar) 588cc / min = 56 lb / h


PSID = 58.0151 psi - 400 kPa

ALOSL = 0.015913 * 1.2170382347140039 = 0.01936672942 lb/s = 8.784600696766525 g/s
AHISL = 0.013497 * 1.228104952662722 = 0.01657573254 lb/s = 7.518625807304719 g/s
FUEL_BKPT = 0.0000144400 * 1.1556683491124258 = 0.00001668785 lb = 0.0075694814317 g
FUEL_BKPT = @ 0.11127137704599 g/cyl
MINPW = 0.711 ms

FNPW_OFFSET
v - ms * 1.1853002149901382
6 - 5.202 = 6.1640625
8 - 2.184 = 2.59375
10 - 1.435 = 1.703125
11 - 1.210 = 1.4375
12 - 1.041 = 1.234375
13 - 0.907 = 1.0703125
14 - 0.789 = 0.9375
15 - 0.699 = 0.8203125
```


# A14NET

```
Default fuel pressure: 340 kPa?

Default injector: 55565970 - Bosch 0 280 158 205 
Flow rate: 31.4946703964619 lb/h
```


# Maths, uuuuuh

```
((Airmass Per Cylinder [g/cyl] / Air Fuel Ratio [AFR]) / Injector Static Flow Rate [g/s]) * 1000 = Injector Open Time [ms] (ideal)


BMEP_BAR = (4 * Pi * MOMENT_NM) / (KUBIKAZA_LITRE * 100)
HP = (MOMENT_NM * RPM) / 7127
MOMENT_NM = (7127 * HP) / RPM
MOMENT_NM = (BMEP_BAR * (KUBIKAZA_LITRE * 100)) / (4 * Pi)


```


# Engine specs

```
Bore - 72.5 mm 
Stroke - 82.6 mm

Intake Valve
Head diameter - 28 mm

Exhaust Valve
Head diameter - 25 mm

Cams - Lift in inches, duration at .050" (1.27 mm)

* Intake

Lift - .330" - 8.382 mm
Duration - 180 degrees

* Exhaust

Lift - .247" - 6.2738 mm
Duration - 165 degrees

```