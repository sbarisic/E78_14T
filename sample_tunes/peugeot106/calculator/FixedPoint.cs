namespace Iaw8p40.Calculator;

public static class FixedPoint
{
    public static ushort FromIndex(double index)
    {
        if (double.IsNaN(index) || double.IsInfinity(index) || index < 0 || index > 255.99609375)
        {
            throw new ArgumentOutOfRangeException(nameof(index), "Q8.8 index must be between 0 and 255.99609375.");
        }

        int raw = checked((int)Math.Round(index * 256.0, MidpointRounding.AwayFromZero));
        return (ushort)Math.Clamp(raw, 0, 65_535);
    }

    public static double ToIndex(ushort q8_8) => q8_8 / 256.0;

    public static int Integer(ushort q8_8) => q8_8 >> 8;

    public static byte Fraction(ushort q8_8) => (byte)(q8_8 & 0xFF);

    // Matches the 68HC11 interpolation helper's high-byte result with the MUL
    // carry used as a half-up rounding bit.
    public static int RoundedFraction(int magnitude, byte fraction)
    {
        if (magnitude < 0 || magnitude > 255)
        {
            throw new ArgumentOutOfRangeException(nameof(magnitude));
        }

        int product = magnitude * fraction;
        return (product >> 8) + ((product & 0x80) != 0 ? 1 : 0);
    }

    public static byte InterpolateUnsignedByte(byte start, byte end, byte fraction)
    {
        if (end >= start)
        {
            int step = RoundedFraction(end - start, fraction);
            return unchecked((byte)(start + step));
        }

        int negativeStep = RoundedFraction(start - end, fraction);
        return unchecked((byte)(start - negativeStep));
    }

    public static sbyte InterpolateSignedByte(sbyte start, sbyte end, byte fraction)
    {
        // The firmware subtracts raw bytes and tests the signed 8-bit result.
        byte startRaw = unchecked((byte)start);
        byte endRaw = unchecked((byte)end);
        byte deltaRaw = unchecked((byte)(endRaw - startRaw));
        sbyte deltaSigned = unchecked((sbyte)deltaRaw);

        int step;
        if (deltaSigned >= 0)
        {
            step = RoundedFraction(deltaRaw, fraction);
        }
        else
        {
            byte magnitude = unchecked((byte)(-deltaRaw));
            step = -RoundedFraction(magnitude, fraction);
        }

        return unchecked((sbyte)(startRaw + step));
    }

    public static ushort MultiplyQ8_8Rounded(ushort value, ushort multiplierQ8_8)
    {
        uint product = (uint)value * multiplierQ8_8;
        return unchecked((ushort)((product + 0x80u) >> 8));
    }

    public static ushort ApplySignedByteFraction(ushort value, sbyte raw)
    {
        int magnitude = Math.Abs((int)raw);
        int correction = (int)(((uint)value * (uint)magnitude + 0x80u) >> 8);
        int result = raw >= 0 ? value + correction : value - correction;
        return unchecked((ushort)Math.Clamp(result, 0, 65_535));
    }

    public static ushort ApplyAdaptiveHighByteTrim(ushort value, ushort adaptiveWord)
    {
        int delta = ((adaptiveWord >> 8) & 0xFF) - 0x80;
        int correction = RoundedByteProductThenHalve(value, Math.Abs(delta));
        int result = delta >= 0 ? value + correction : value - correction;
        return unchecked((ushort)Math.Clamp(result, 0, 65_535));
    }

    public static ushort ApplyScaledPositiveFactor(ushort value, byte factor, int firmwareScaleArgument)
    {
        if (firmwareScaleArgument < 2 || firmwareScaleArgument > 9)
        {
            throw new ArgumentOutOfRangeException(nameof(firmwareScaleArgument));
        }

        uint scale = 1u << (firmwareScaleArgument - 2);
        uint correction = ((uint)value * factor * scale + 0x80u) >> 8;
        uint result = (uint)value + correction;
        return result > 65_535u ? ushort.MaxValue : (ushort)result;
    }

    public static ushort ApplyFuelMultiplier2053(ushort value, byte factor)
    {
        uint correction = (uint)RoundedByteProductThenHalve(value, factor);
        uint result = (uint)value + correction;
        return result > 65_535u ? ushort.MaxValue : (ushort)result;
    }

    private static int RoundedByteProductThenHalve(ushort value, int factor)
    {
        uint product = (uint)value * (uint)factor;
        return (int)(((product + 0x80u) >> 8) >> 1);
    }

    public static ushort SaturatingAddTo32000(ushort value, params ushort[] additions)
    {
        uint result = value;
        foreach (ushort addition in additions)
        {
            result += addition;
            if (result > 65_535u)
            {
                return 32_000;
            }
        }

        return (ushort)Math.Min(result, 32_000u);
    }
}
