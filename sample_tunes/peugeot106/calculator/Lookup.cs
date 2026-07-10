namespace Iaw8p40.Calculator;

public sealed record AxisTrace(
    string Name,
    int Address,
    int Count,
    int Input,
    ushort ResultQ8_8,
    int LowerIndex,
    int UpperIndex,
    byte Fraction,
    int LowerValue,
    int UpperValue,
    bool Inverted
);

public sealed record LookupTrace(
    string Name,
    int BaseAddress,
    string ValueType,
    ushort XQ8_8,
    ushort? YQ8_8,
    int XIndex,
    byte XFraction,
    int? YIndex,
    byte? YFraction,
    int[] SourceAddresses,
    int[] SourceValues,
    int Result
);

public static class RomLookup
{
    public static ushort AxisLookupU8(RomImage rom, int axisAddress, int count, byte input, out AxisTrace trace, string name)
    {
        if (count <= 0)
        {
            trace = new AxisTrace(name, axisAddress, count, input, 0, 0, 0, 0, 0, 0, false);
            return 0;
        }

        byte first = rom.ReadByte(axisAddress);
        if (input <= first)
        {
            trace = new AxisTrace(name, axisAddress, count, input, 0, 0, Math.Min(1, count - 1), 0, first,
                count > 1 ? rom.ReadByte(axisAddress + 1) : first, false);
            return 0;
        }

        int lastIndex = count - 1;
        byte last = rom.ReadByte(axisAddress + lastIndex);
        if (input >= last)
        {
            ushort result = (ushort)(lastIndex << 8);
            trace = new AxisTrace(name, axisAddress, count, input, result, lastIndex, lastIndex, 0, last, last, false);
            return result;
        }

        int lower = 0;
        for (int i = 0; i < lastIndex; i++)
        {
            byte a = rom.ReadByte(axisAddress + i);
            byte b = rom.ReadByte(axisAddress + i + 1);
            if (input >= a && input < b)
            {
                lower = i;
                int denominator = b - a;
                int numerator = input - a;
                byte fraction = denominator == 0 ? (byte)0 : (byte)Math.Clamp((numerator << 8) / denominator, 0, 255);
                ushort result = (ushort)((i << 8) | fraction);
                trace = new AxisTrace(name, axisAddress, count, input, result, i, i + 1, fraction, a, b, false);
                return result;
            }
        }

        // The firmware expects a monotonic axis. Treat a malformed axis as an error
        // instead of silently returning a misleading index.
        throw new InvalidDataException($"Axis {name} at 0x{axisAddress:X4} is not monotonic for input {input}.");
    }

    public static ushort PeriodAxisLookup(
        RomImage rom,
        int axisAddress,
        int count,
        ushort period,
        out AxisTrace trace,
        string name)
    {
        if (count <= 0)
        {
            trace = new AxisTrace(name, axisAddress, count, period, 0, 0, 0, 0, 0, 0, false);
            return 0;
        }

        ushort first = rom.ReadUInt16BigEndian(axisAddress);
        ushort last = rom.ReadUInt16BigEndian(axisAddress + (count - 1) * 2);

        // Period decreases as RPM rises. Values at or below the final breakpoint
        // clamp to the final Q8.8 cell.
        if (period <= last)
        {
            int lastIndex = count - 1;
            ushort result = (ushort)(lastIndex << 8);
            trace = new AxisTrace(name, axisAddress, count, period, result, lastIndex, lastIndex, 0, last, last, false);
            return result;
        }

        // Periods larger than the first breakpoint clamp to index zero.
        if (period >= first)
        {
            trace = new AxisTrace(name, axisAddress, count, period, 0, 0, Math.Min(1, count - 1), 0, first,
                count > 1 ? rom.ReadUInt16BigEndian(axisAddress + 2) : first, false);
            return 0;
        }

        for (int i = 0; i < count - 1; i++)
        {
            ushort upperPeriod = rom.ReadUInt16BigEndian(axisAddress + i * 2);
            ushort lowerPeriod = rom.ReadUInt16BigEndian(axisAddress + (i + 1) * 2);
            if (period <= upperPeriod && period > lowerPeriod)
            {
                int denominator = upperPeriod - lowerPeriod;
                int numerator = upperPeriod - period;
                byte fraction = denominator == 0 ? (byte)0 : (byte)Math.Clamp((numerator << 8) / denominator, 0, 255);
                ushort result = (ushort)((i << 8) | fraction);
                trace = new AxisTrace(name, axisAddress, count, period, result, i, i + 1, fraction, upperPeriod, lowerPeriod, false);
                return result;
            }
        }

        throw new InvalidDataException($"Period axis {name} at 0x{axisAddress:X4} is not strictly descending.");
    }

    public static byte Interp1DU8(
        RomImage rom,
        int baseAddress,
        int count,
        ushort axis,
        out LookupTrace trace,
        string name)
    {
        ValidateLookupAxis(axis, count, name, "X");
        int index = FixedPoint.Integer(axis);
        byte fraction = FixedPoint.Fraction(axis);
        int a0 = baseAddress + index;
        byte v0 = rom.ReadByte(a0);

        int[] sourceAddresses;
        int[] sourceValues;
        byte result;
        if (fraction == 0)
        {
            sourceAddresses = new[] { a0 };
            sourceValues = new[] { (int)v0 };
            result = v0;
        }
        else
        {
            int a1 = a0 + 1;
            byte v1 = rom.ReadByte(a1);
            sourceAddresses = new[] { a0, a1 };
            sourceValues = new[] { (int)v0, (int)v1 };
            result = FixedPoint.InterpolateUnsignedByte(v0, v1, fraction);
        }

        trace = new LookupTrace(name, baseAddress, "u8", axis, null, index, fraction, null, null,
            sourceAddresses, sourceValues, result);
        return result;
    }

    public static sbyte Interp1DS8(
        RomImage rom,
        int baseAddress,
        int count,
        ushort axis,
        out LookupTrace trace,
        string name)
    {
        ValidateLookupAxis(axis, count, name, "X");
        int index = FixedPoint.Integer(axis);
        byte fraction = FixedPoint.Fraction(axis);
        int a0 = baseAddress + index;
        sbyte v0 = rom.ReadSByte(a0);

        int[] sourceAddresses;
        int[] sourceValues;
        sbyte result;
        if (fraction == 0)
        {
            sourceAddresses = new[] { a0 };
            sourceValues = new[] { (int)v0 };
            result = v0;
        }
        else
        {
            int a1 = a0 + 1;
            sbyte v1 = rom.ReadSByte(a1);
            sourceAddresses = new[] { a0, a1 };
            sourceValues = new[] { (int)v0, (int)v1 };
            result = FixedPoint.InterpolateSignedByte(v0, v1, fraction);
        }

        trace = new LookupTrace(name, baseAddress, "s8", axis, null, index, fraction, null, null,
            sourceAddresses, sourceValues, result);
        return result;
    }

    public static byte Interp2DU8(
        RomImage rom,
        int baseAddress,
        int stride,
        int xCount,
        int yCount,
        ushort xAxis,
        ushort yAxis,
        out LookupTrace trace,
        string name)
    {
        ValidateLookupAxis(xAxis, xCount, name, "X");
        ValidateLookupAxis(yAxis, yCount, name, "Y");
        int x = FixedPoint.Integer(xAxis);
        int y = FixedPoint.Integer(yAxis);
        byte xf = FixedPoint.Fraction(xAxis);
        byte yf = FixedPoint.Fraction(yAxis);

        int a00 = baseAddress + y * stride + x;
        byte v00 = rom.ReadByte(a00);
        List<int> sourceAddresses = new() { a00 };
        List<int> sourceValues = new() { v00 };

        byte row0 = v00;
        if (xf != 0)
        {
            int a10 = a00 + 1;
            byte v10 = rom.ReadByte(a10);
            sourceAddresses.Add(a10);
            sourceValues.Add(v10);
            row0 = FixedPoint.InterpolateUnsignedByte(v00, v10, xf);
        }

        byte result = row0;
        if (yf != 0)
        {
            int a01 = a00 + stride;
            byte v01 = rom.ReadByte(a01);
            sourceAddresses.Add(a01);
            sourceValues.Add(v01);
            byte row1 = v01;
            if (xf != 0)
            {
                int a11 = a01 + 1;
                byte v11 = rom.ReadByte(a11);
                sourceAddresses.Add(a11);
                sourceValues.Add(v11);
                row1 = FixedPoint.InterpolateUnsignedByte(v01, v11, xf);
            }

            result = FixedPoint.InterpolateUnsignedByte(row0, row1, yf);
        }

        trace = new LookupTrace(name, baseAddress, "u8", xAxis, yAxis, x, xf, y, yf,
            sourceAddresses.ToArray(), sourceValues.ToArray(), result);
        return result;
    }

    public static sbyte Interp2DS8(
        RomImage rom,
        int baseAddress,
        int stride,
        int xCount,
        int yCount,
        ushort xAxis,
        ushort yAxis,
        out LookupTrace trace,
        string name)
    {
        ValidateLookupAxis(xAxis, xCount, name, "X");
        ValidateLookupAxis(yAxis, yCount, name, "Y");
        int x = FixedPoint.Integer(xAxis);
        int y = FixedPoint.Integer(yAxis);
        byte xf = FixedPoint.Fraction(xAxis);
        byte yf = FixedPoint.Fraction(yAxis);

        int a00 = baseAddress + y * stride + x;
        sbyte v00 = rom.ReadSByte(a00);
        List<int> sourceAddresses = new() { a00 };
        List<int> sourceValues = new() { v00 };

        sbyte row0 = v00;
        if (xf != 0)
        {
            int a10 = a00 + 1;
            sbyte v10 = rom.ReadSByte(a10);
            sourceAddresses.Add(a10);
            sourceValues.Add(v10);
            row0 = FixedPoint.InterpolateSignedByte(v00, v10, xf);
        }

        sbyte result = row0;
        if (yf != 0)
        {
            int a01 = a00 + stride;
            sbyte v01 = rom.ReadSByte(a01);
            sourceAddresses.Add(a01);
            sourceValues.Add(v01);
            sbyte row1 = v01;
            if (xf != 0)
            {
                int a11 = a01 + 1;
                sbyte v11 = rom.ReadSByte(a11);
                sourceAddresses.Add(a11);
                sourceValues.Add(v11);
                row1 = FixedPoint.InterpolateSignedByte(v01, v11, xf);
            }

            result = FixedPoint.InterpolateSignedByte(row0, row1, yf);
        }

        trace = new LookupTrace(name, baseAddress, "s8", xAxis, yAxis, x, xf, y, yf,
            sourceAddresses.ToArray(), sourceValues.ToArray(), result);
        return result;
    }

    private static void ValidateLookupAxis(ushort axis, int count, string name, string dimension)
    {
        if (count <= 0 || count > 256)
        {
            throw new ArgumentOutOfRangeException(nameof(count), "Lookup count must be between 1 and 256.");
        }

        ushort maximum = (ushort)((count - 1) << 8);
        if (axis > maximum)
        {
            throw new InvalidDataException(
                $"{dimension} axis 0x{axis:X4} is outside {name}'s {count}-cell range 0x0000..0x{maximum:X4}."
            );
        }
    }
}
