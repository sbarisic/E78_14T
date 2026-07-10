# Implemented equations and firmware correspondence

## Q8.8 interpolation

The 68HC11 helpers use the high byte as the cell index and the low byte as the interpolation fraction. Products are rounded half-up using the carry generated from bit 7 of the low product byte.

For a positive difference:

```text
step = floor((difference * fraction + 128) / 256)
result = start + step
```

Negative slopes are handled by interpolating the magnitude and subtracting it. Signed helpers perform the slope decision using the signed wrapped 8-bit subtraction used by the original code.

Every lookup is dimensioned. Direct Q8.8 inputs outside a table's final index are rejected, and an exact endpoint reads only that endpoint cell rather than tracing bytes from the following table.

## Load path

When `loadDeltaByte` is used:

```text
loadHelperAxis = axis_lookup_u8(0x9291, count byte 0x929A, loadDeltaByte)
factor          = interp2d_u8(0x9187, x=loadHelperAxis, y=rpmAxis, stride=9)
RAM 0x00CE      = factor << 2
RAM 0x2034      = min(RAM 0x00CE << 1, 0x07FF)
```

## RPM/load sweep

Sweep mode evaluates a Cartesian grid. RPM replaces the template physical RPM input, while the pedal proxy is converted to a processed load byte:

```text
fraction = pedalProxyPercent / 100
loadDeltaByte = round(loadAt0Percent +
                      (loadAt100Percent - loadAt0Percent) * fraction)
```

Direct RPM/load axis overrides and `enginePeriodTicks` are cleared for each sweep point so every row passes through the decoded period and load paths. Temperature inputs and all operating-state/intermediate RAM settings remain fixed at their configured values.

The pedal proxy is not physical TPS. No manifold dynamics, transient state, or acceleration-enrichment history is synthesized.

## Temperature paths

```text
forward = axis_lookup_u8(axis, count, processedByte)
normalized = ((count - 1) << 8) - forward
sparkAxis = normalized << 1
```

IAT-like uses `0x92D9`; CTS-like uses `0x92CF`.

## Core spark

```text
if A9 & 0x20:
    base = interp1d_u8(0x8C19, rpmAxis)
else:
    baseAddress = (0x20B1 != 0) ? 0x8A69 : 0x8B41
    base = interp2d_u8(baseAddress, loadAxis, rpmAxis, stride=9)
    if A2 & 0x02:
        base += sign_extend(byte[0x8A68])

ctsCorr = interp2d_s8(0x8D15, loadAxis, ctsAxis<<1, stride=9)
iatCorr = interp2d_s8(0x8C7C, loadAxis, iatAxis<<1, stride=9)
coreSparkRaw = base + ctsCorr + iatCorr
```

## Signed fuel trim

Selection follows the decoded gate:

```text
if A9.20:
    table = 0x83F0
else if rpmAxis <= 0x0300 and A9.40 and RAM[0x0090] != 0 and RAM[0x202D] == 0:
    table = RAM[0x20B1] != 0 ? 0x81F8 : 0x82F4
else:
    table = RAM[0x20B1] != 0 ? 0x821C : 0x8318
```

`lowRpmFuelTrimGuardsSatisfied` represents the two RAM predicates; the calculator checks the RPM and `A9.40` predicates separately.

```text
correction = round(pulse * abs(raw) / 256)
result = raw >= 0 ? pulse + correction : pulse - correction
```

## `from-intermediates` fuel path

### Correction sum `0x204B`

```text
sum = sign_extend(corrA) + RAM[0x2596] + sign_extend(RAM[0x2050])
sum <<= 1

if RAM[0x20B1] == 0:
    extra = sign_extend(RAM[0x2610])
    if A9 & 0x40:
        extra <<= 1
    sum += extra

sum += RAM[0x24D9]
```

All arithmetic is wrapped to 16 bits like the MCU.

### Blend `0x204E`

```text
blend = sign_extend(corrB) + RAM[0x0006] + word[0x8028]
if signed16(blend) < 0:
    blend = 0
```

### Base accumulator

```text
base = RAM[0x00CE] + RAM[0x204B]
if signed16(base) < 0:
    base = 0

base = round(base * RAM[0x204E] / 256)
base = min(base, 3000)
```

Then the signed quantity trim, adaptive trim, warmup/afterstart factors, transient stack, period cap, `0x2053` multiplier and fast lambda factor are applied in firmware order.

The adaptive-high-byte and `$2053` multiplier corrections use the firmware's round-then-halve order:

```text
roundedByteProduct = floor((value * factor + 128) / 256)
correction = floor(roundedByteProduct / 2)
```

This is intentionally not simplified to a single rounded division by 512 because the two expressions differ at boundary values.
