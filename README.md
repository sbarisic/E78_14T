# E78_14T

Delphi E78 ECU and GM/Chevrolet/Opel 1.4T engine A14NET LUJ LUV information


# BOSCH 0 280 158 117
Note - none of these are confirmed as of yet

```
29.00 PSI (2 bar) 420cc / min = 40 lb / h
43.50 PSI (3 bar) 510cc / min = 49 lb / h
58.00 PSI (4 bar) 588cc / min = 56 lb / h
78.50 PSI (5 bar) 657cc / min = 63 lb / h
88.00 PSI (6 bar) 732cc / min = 70 Ib / h
101.5 PSI (7 bar) 792cc / min = 75 lb / h
```
Confirm?

Static Flow Rate @ 43.5 PSI (300 kPa): 51.72 lb/hr = 6.52 g/s = 544cc/min (+/-3%)
Confirm?

### Mustang 500 GT
```

```

### Injector voltage offset as a function of battery voltage
| VBAT (V)   | Offset (ms)   |
|------------|---------------|
| 6          | 5.203125      |
| 7          | 3.6953125     |
| 8          | 2.1875        |
| 9          | 1.8125        |
| 10         | 1.4375        |
| 11         | 1.2109375     |
| 12         | 1.0390625     |
| 13         | 0.90625       |
| 14         | 0.7890625     |
| 15         | 0.6953125     |


# Camshaft

Stock
Lift in inches, duration at .050" (1.27 mm)

### Intake

```
Lift - .330" - 8.382 mm
Duration - 180 degrees
```

### Exhaust

```
Lift - .247" - 6.2738 mm
Duration - 165 degrees
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

```