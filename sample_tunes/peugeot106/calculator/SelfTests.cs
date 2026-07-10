namespace Iaw8p40.Calculator;

public static class SelfTests
{
    public static void Run()
    {
        byte[] bytes = new byte[RomImage.ExpectedSize];
        RomImage rom = RomImage.FromBytes(bytes);

        TestAxisLookup(bytes);
        TestPeriodAxisLookup(bytes);
        TestOneDimensionalInterpolation(bytes);
        TestTwoDimensionalInterpolation(bytes);
        TestLookupBoundaries(bytes);
        TestFuelMath();
        TestInputValidation();
        TestFuelTrimSelection();
        TestSweepRangesAndMapping();

        Console.WriteLine("All self-tests passed.");
    }

    private static void TestAxisLookup(byte[] shared)
    {
        byte[] bytes = (byte[])shared.Clone();
        const int address = 0x1000;
        bytes[address] = 0;
        bytes[address + 1] = 100;
        bytes[address + 2] = 200;
        RomImage rom = RomImage.FromBytes(bytes);

        ushort result = RomLookup.AxisLookupU8(rom, address, 3, 50, out _, "test");
        Equal(0x0080, result, "u8 axis midpoint");
        Equal(0x0000, RomLookup.AxisLookupU8(rom, address, 3, 0, out _, "test"), "u8 axis lower clamp");
        Equal(0x0200, RomLookup.AxisLookupU8(rom, address, 3, 255, out _, "test"), "u8 axis upper clamp");
    }

    private static void TestPeriodAxisLookup(byte[] shared)
    {
        byte[] bytes = (byte[])shared.Clone();
        const int address = 0x1100;
        WriteWord(bytes, address, 30_000);
        WriteWord(bytes, address + 2, 15_000);
        WriteWord(bytes, address + 4, 7_500);
        RomImage rom = RomImage.FromBytes(bytes);

        ushort result = RomLookup.PeriodAxisLookup(rom, address, 3, 22_500, out _, "period");
        Equal(0x0080, result, "period axis midpoint");
        Equal(0x0000, RomLookup.PeriodAxisLookup(rom, address, 3, 40_000, out _, "period"), "period lower-rpm clamp");
        Equal(0x0200, RomLookup.PeriodAxisLookup(rom, address, 3, 5_000, out _, "period"), "period upper-rpm clamp");
    }

    private static void TestOneDimensionalInterpolation(byte[] shared)
    {
        byte[] bytes = (byte[])shared.Clone();
        const int address = 0x1200;
        bytes[address] = 10;
        bytes[address + 1] = 20;
        bytes[address + 2] = 10;
        bytes[address + 3] = unchecked((byte)-20);
        bytes[address + 4] = 20;
        RomImage rom = RomImage.FromBytes(bytes);

        Equal(15, RomLookup.Interp1DU8(rom, address, 2, 0x0080, out _, "u8"), "u8 interpolation up");
        Equal(15, RomLookup.Interp1DU8(rom, address + 1, 2, 0x0080, out _, "u8"), "u8 interpolation down");
        Equal(0, RomLookup.Interp1DS8(rom, address + 3, 2, 0x0080, out _, "s8"), "s8 interpolation");
    }

    private static void TestTwoDimensionalInterpolation(byte[] shared)
    {
        byte[] bytes = (byte[])shared.Clone();
        const int address = 0x1300;
        bytes[address] = 0;
        bytes[address + 1] = 10;
        bytes[address + 2] = 20;
        bytes[address + 3] = 30;
        RomImage rom = RomImage.FromBytes(bytes);

        byte result = RomLookup.Interp2DU8(rom, address, 2, 2, 2, 0x0080, 0x0080, out _, "2d");
        Equal(15, result, "2d bilinear interpolation");
    }

    private static void TestLookupBoundaries(byte[] shared)
    {
        byte[] bytes = (byte[])shared.Clone();
        const int address = 0x1400;
        bytes[address] = 10;
        bytes[address + 1] = 20;
        bytes[address + 2] = 30;
        bytes[address + 3] = 40;
        RomImage rom = RomImage.FromBytes(bytes);

        Equal(20, RomLookup.Interp1DU8(rom, address, 2, 0x0100, out LookupTrace oneDimensional, "1d endpoint"), "1d endpoint value");
        EqualSequence(new[] { address + 1 }, oneDimensional.SourceAddresses, "1d endpoint source");

        Equal(40, RomLookup.Interp2DU8(rom, address, 2, 2, 2, 0x0100, 0x0100, out LookupTrace twoDimensional, "2d endpoint"), "2d endpoint value");
        EqualSequence(new[] { address + 3 }, twoDimensional.SourceAddresses, "2d endpoint source");

        Throws<InvalidDataException>(
            () => RomLookup.Interp1DU8(rom, address, 2, 0x0101, out _, "invalid endpoint"),
            "1d out-of-range axis"
        );
    }

    private static void TestFuelMath()
    {
        Equal(1_000, FixedPoint.MultiplyQ8_8Rounded(1_000, 0x0100), "Q8.8 multiply identity");
        Equal(1_500, FixedPoint.MultiplyQ8_8Rounded(1_000, 0x0180), "Q8.8 multiply 1.5");
        Equal(1_250, FixedPoint.ApplySignedByteFraction(1_000, 64), "+25 percent signed trim");
        Equal(750, FixedPoint.ApplySignedByteFraction(1_000, -64), "-25 percent signed trim");
        Equal(1_031, FixedPoint.ApplyAdaptiveHighByteTrim(1_000, 0x9000), "adaptive high-byte trim");
        Equal(100, FixedPoint.ApplyAdaptiveHighByteTrim(100, 0x8300), "adaptive round then halve");
        Equal(1_500, FixedPoint.ApplyScaledPositiveFactor(1_000, 64, 3), "scale argument 3");
        Equal(1_250, FixedPoint.ApplyScaledPositiveFactor(1_000, 64, 2), "scale argument 2");
        Equal(1_125, FixedPoint.ApplyFuelMultiplier2053(1_000, 64), "fuel multiplier /512");
        Equal(100, FixedPoint.ApplyFuelMultiplier2053(100, 3), "fuel multiplier round then halve");
    }

    private static void TestInputValidation()
    {
        Throws<InvalidDataException>(
            () => new CalculationInputs { Rpm = 4_000, RpmAxisQ8_8 = 0x1701 }.Validate(),
            "RPM axis upper bound"
        );
        Throws<InvalidDataException>(
            () => new CalculationInputs { Rpm = 4_000, LoadAxisQ8_8 = 0x0800 }.Validate(),
            "load axis upper bound"
        );
        Throws<InvalidDataException>(
            () => new CalculationInputs { Rpm = 4_000, IatAxis2038Q8_8 = 0x0801 }.Validate(),
            "IAT axis upper bound"
        );
        Throws<InvalidDataException>(
            () => new CalculationInputs { Rpm = 4_000, CtsAxis203CQ8_8 = 0x0801 }.Validate(),
            "CTS axis upper bound"
        );
        Throws<InvalidDataException>(
            () => new CalculationInputs { Rpm = 0, RpmAxisQ8_8 = 0x1000 }.Validate(),
            "RPM override still requires period"
        );

        new CalculationInputs { Rpm = 0, EnginePeriodTicks = 15_000, RpmAxisQ8_8 = 0x0200 }.Validate();
    }

    private static void TestFuelTrimSelection()
    {
        CalculationInputs input = new()
        {
            BankSelector20B1 = 0xFF,
            LowRpmFuelTrimGuardsSatisfied = true
        };

        Equal(0x821C, CalibrationCalculator.ResolveFuelTrimAddress(input, 0x0200), "low-RPM mode gate absent");

        input.OperatingModeFlagsA9 = 0x40;
        Equal(0x81F8, CalibrationCalculator.ResolveFuelTrimAddress(input, 0x0200), "low-RPM bank A");

        input.BankSelector20B1 = 0;
        Equal(0x82F4, CalibrationCalculator.ResolveFuelTrimAddress(input, 0x0200), "low-RPM bank B");

        input.OperatingModeFlagsA9 = 0x20;
        Equal(0x83F0, CalibrationCalculator.ResolveFuelTrimAddress(input, 0x0200), "RPM-only trim");
    }

    private static void TestSweepRangesAndMapping()
    {
        EqualSequence(
            new[] { 1_500, 1_750, 2_000, 2_250, 2_500, 2_750, 3_000, 3_250, 3_500, 3_750, 4_000, 4_250, 4_500, 4_750, 5_000 },
            SweepRunner.BuildRange(1_500, 5_000, 250).ToArray(),
            "sweep RPM range"
        );
        EqualSequence(
            new[] { 0, 30, 60, 90, 100 },
            SweepRunner.BuildRange(0, 100, 30).ToArray(),
            "sweep includes non-divisible endpoint"
        );

        SweepConfig settings = new();
        Equal(0, SweepRunner.MapPedalProxyToLoadDelta(0, settings), "pedal proxy lower mapping");
        Equal(101, SweepRunner.MapPedalProxyToLoadDelta(50, settings), "pedal proxy midpoint mapping");
        Equal(201, SweepRunner.MapPedalProxyToLoadDelta(100, settings), "pedal proxy upper mapping");

        Throws<InvalidDataException>(
            () => new SweepConfig { RpmStep = 0 }.Validate(),
            "sweep rejects zero RPM step"
        );
    }

    private static void WriteWord(byte[] bytes, int address, int value)
    {
        bytes[address] = (byte)(value >> 8);
        bytes[address + 1] = (byte)value;
    }

    private static void Equal(int expected, int actual, string name)
    {
        if (expected != actual)
        {
            throw new InvalidOperationException($"Self-test '{name}' failed: expected {expected}, got {actual}.");
        }
    }

    private static void EqualSequence(int[] expected, int[] actual, string name)
    {
        if (!expected.SequenceEqual(actual))
        {
            throw new InvalidOperationException(
                $"Self-test '{name}' failed: expected [{string.Join(", ", expected)}], got [{string.Join(", ", actual)}]."
            );
        }
    }

    private static void Throws<TException>(Action action, string name)
        where TException : Exception
    {
        try
        {
            action();
        }
        catch (TException)
        {
            return;
        }

        throw new InvalidOperationException(
            $"Self-test '{name}' failed: expected {typeof(TException).Name}."
        );
    }
}
