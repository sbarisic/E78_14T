using System.Text.Json.Serialization;

namespace Iaw8p40.Calculator;

public sealed class CalculatorConfig
{
    public string BaseBinPath { get; set; } = string.Empty;
    public string? ComparisonBinPath { get; set; }
    public string? OutputJsonPath { get; set; } = "ecu-calculator-result.json";
    public CalculationInputs Inputs { get; set; } = new();
    public CalculationAssumptions Assumptions { get; set; } = new();
    public SweepConfig Sweep { get; set; } = new();

    public void Validate()
    {
        if (string.IsNullOrWhiteSpace(BaseBinPath))
        {
            throw new InvalidDataException("baseBinPath must point to a 64 KiB IAW 8P.40 BIN file.");
        }

        Inputs.Validate();
        Assumptions.Validate();
        if (Sweep is null)
        {
            throw new InvalidDataException("sweep must be an object when supplied.");
        }
        Sweep.Validate();
    }
}

public sealed class SweepConfig
{
    public bool Enabled { get; set; }
    public int RpmStart { get; set; } = 1_500;
    public int RpmEnd { get; set; } = 5_000;
    public int RpmStep { get; set; } = 250;
    public int PedalProxyStartPercent { get; set; }
    public int PedalProxyEndPercent { get; set; } = 100;
    public int PedalProxyStepPercent { get; set; } = 10;
    public int LoadDeltaByteAt0Percent { get; set; }
    public int LoadDeltaByteAt100Percent { get; set; } = 201;
    public string? OutputCsvPath { get; set; } = "ecu-calculator-sweep.csv";
    public string? OutputJsonPath { get; set; } = "ecu-calculator-sweep.json";

    public void Validate()
    {
        ValidateRange(RpmStart, RpmEnd, RpmStep, 1, 100_000, "RPM");
        ValidateRange(
            PedalProxyStartPercent,
            PedalProxyEndPercent,
            PedalProxyStepPercent,
            0,
            100,
            "pedal proxy"
        );
        ValidateByte(LoadDeltaByteAt0Percent, nameof(LoadDeltaByteAt0Percent));
        ValidateByte(LoadDeltaByteAt100Percent, nameof(LoadDeltaByteAt100Percent));

        long rpmCount = CountRange(RpmStart, RpmEnd, RpmStep);
        long pedalCount = CountRange(
            PedalProxyStartPercent,
            PedalProxyEndPercent,
            PedalProxyStepPercent
        );
        if (rpmCount * pedalCount > 100_000)
        {
            throw new InvalidDataException("sweep contains more than 100,000 points; increase the step sizes.");
        }

        ValidateOutputPath(OutputCsvPath, nameof(OutputCsvPath));
        ValidateOutputPath(OutputJsonPath, nameof(OutputJsonPath));
    }

    private static void ValidateRange(
        int start,
        int end,
        int step,
        int minimum,
        int maximum,
        string name)
    {
        if (start < minimum || start > maximum || end < minimum || end > maximum)
        {
            throw new InvalidDataException($"sweep {name} range must be between {minimum} and {maximum}.");
        }
        if (end < start)
        {
            throw new InvalidDataException($"sweep {name} end must be greater than or equal to its start.");
        }
        if (step <= 0)
        {
            throw new InvalidDataException($"sweep {name} step must be positive.");
        }
    }

    private static long CountRange(int start, int end, int step)
    {
        return 1L + ((long)end - start + step - 1L) / step;
    }

    private static void ValidateByte(int value, string name)
    {
        if (value is < 0 or > 255)
        {
            throw new InvalidDataException($"sweep.{JsonName(name)} must be between 0 and 255.");
        }
    }

    private static void ValidateOutputPath(string? value, string name)
    {
        if (value is not null && string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidDataException($"sweep.{JsonName(name)} must be a path or null.");
        }
    }

    private static string JsonName(string name)
    {
        return char.ToLowerInvariant(name[0]) + name[1..];
    }
}

public sealed class CalculationAssumptions
{
    public int RpmClockNumerator { get; set; } = 15_000_000;
    public double SparkDegreesPerRawCount { get; set; } = 0.5;
    public double? TimerTickMicroseconds { get; set; } = 2.0;

    public void Validate()
    {
        if (RpmClockNumerator <= 0)
        {
            throw new InvalidDataException("assumptions.rpmClockNumerator must be positive.");
        }

        if (SparkDegreesPerRawCount <= 0)
        {
            throw new InvalidDataException("assumptions.sparkDegreesPerRawCount must be positive.");
        }

        if (TimerTickMicroseconds is <= 0)
        {
            throw new InvalidDataException("assumptions.timerTickMicroseconds must be positive or null.");
        }
    }
}

public sealed class CalculationInputs
{
    // Engine speed. rpmAxisQ8_8 takes precedence when supplied.
    public int Rpm { get; set; } = 3_000;
    public int? EnginePeriodTicks { get; set; }
    public int? RpmAxisQ8_8 { get; set; }

    // Load path. loadAxisQ8_8 takes precedence. Otherwise loadDeltaByte drives
    // 0x9291 -> 0x9187 -> 0x00CE -> 0x2034.
    public int? LoadAxisQ8_8 { get; set; }
    public double? LoadIndex { get; set; }
    public int? LoadDeltaByte { get; set; } = 100;
    public int? LoadAirchargeWord00CE { get; set; }

    // Temperature paths. Direct Q8.8 overrides take precedence. Otherwise the
    // processed bytes are converted through 0x92CF/0x92D9 and inverted exactly
    // like the firmware's 0x4340/0x4390 paths.
    public int? IatAxis2038Q8_8 { get; set; }
    public double? IatAxisIndex { get; set; }
    public int? IatProcessedByte { get; set; } = 100;

    public int? CtsAxis203CQ8_8 { get; set; }
    public double? CtsAxisIndex { get; set; }
    public int? CtsProcessedByte { get; set; } = 100;

    // Raw runtime mode state.
    public int OperatingModeFlagsA9 { get; set; }
    public int SparkModeFlagsA2 { get; set; }
    public int BankSelector20B1 { get; set; } = 0xFF;
    // Represents the remaining firmware guards: RAM $0090 != 0 and $202D == 0.
    // The calculator checks A9.40 separately, matching the E3AF-E3BB path.
    public bool LowRpmFuelTrimGuardsSatisfied { get; set; }

    // Spark terms outside the core 0x48D8 path can be entered here. The program
    // reports the core accumulator separately so this value is never hidden.
    public int AdditionalSparkRaw { get; set; }
    public bool ClampSparkCommandTo0Through127 { get; set; }

    // Fuel calculation mode:
    //   "apply-trim-only"      - apply 0x2084 to baseFuelPulseRaw.
    //   "from-intermediates"   - execute the currently decoded E927/E5E8/E652
    //                             arithmetic using the supplied intermediate RAM terms.
    public string FuelMode { get; set; } = "apply-trim-only";
    public int BaseFuelPulseRaw { get; set; } = 1_000;

    // Inputs needed for the decoded E927/E5E8/E652 path.
    public int Adaptive2596 { get; set; }
    public int SignedFuelCorrection2050 { get; set; }
    public int Signed2610 { get; set; }
    public int Correction24D9 { get; set; }
    public int Ram0006 { get; set; }
    public int AdaptiveTrim20B9 { get; set; } = 0x8000;
    public int WarmupFuelCorrection2085 { get; set; }
    public int AfterstartCorrectionC5 { get; set; }
    public int TransientFuelAdd2055 { get; set; }
    public int TransientFuelAdd2057 { get; set; }
    public int SlowCorrection2590 { get; set; }
    public int SubtractiveFilter2584 { get; set; }
    public int FuelMultiplier2053 { get; set; }
    public int FastLambdaFuelCorrection2049 { get; set; }

    // Optional stateless model of 0x6E96. This ignores hysteresis/history in A1.40.
    public bool ApplyStatelessHighLoadDurationSupport { get; set; }
    public int StateFlagsA3 { get; set; }
    public int FuelEventWidthLimitBF { get; set; }

    public void Validate()
    {
        if (Rpm <= 0 && EnginePeriodTicks is null)
        {
            throw new InvalidDataException("inputs.rpm must be positive unless enginePeriodTicks is supplied.");
        }

        ValidateByte(OperatingModeFlagsA9, nameof(OperatingModeFlagsA9));
        ValidateByte(SparkModeFlagsA2, nameof(SparkModeFlagsA2));
        ValidateByte(BankSelector20B1, nameof(BankSelector20B1));
        ValidateByte(LoadDeltaByte, nameof(LoadDeltaByte));
        ValidateByte(IatProcessedByte, nameof(IatProcessedByte));
        ValidateByte(CtsProcessedByte, nameof(CtsProcessedByte));
        ValidateByte(WarmupFuelCorrection2085, nameof(WarmupFuelCorrection2085));
        ValidateByte(AfterstartCorrectionC5, nameof(AfterstartCorrectionC5));
        ValidateByte(FuelMultiplier2053, nameof(FuelMultiplier2053));
        ValidateByte(FastLambdaFuelCorrection2049, nameof(FastLambdaFuelCorrection2049));
        ValidateByte(StateFlagsA3, nameof(StateFlagsA3));

        ValidateSignedByte(SignedFuelCorrection2050, nameof(SignedFuelCorrection2050));
        ValidateSignedByte(Signed2610, nameof(Signed2610));

        ValidateUInt16(EnginePeriodTicks, nameof(EnginePeriodTicks), allowZero: false);
        ValidateUInt16(RpmAxisQ8_8, nameof(RpmAxisQ8_8), maximum: 0x1700);
        ValidateUInt16(LoadAxisQ8_8, nameof(LoadAxisQ8_8), maximum: 0x07FF);
        ValidateUInt16(LoadAirchargeWord00CE, nameof(LoadAirchargeWord00CE));
        ValidateUInt16(IatAxis2038Q8_8, nameof(IatAxis2038Q8_8), maximum: 0x0800);
        ValidateUInt16(CtsAxis203CQ8_8, nameof(CtsAxis203CQ8_8), maximum: 0x0800);
        ValidateUInt16(AdaptiveTrim20B9, nameof(AdaptiveTrim20B9));
        ValidateUInt16(BaseFuelPulseRaw, nameof(BaseFuelPulseRaw));
        ValidateUInt16(TransientFuelAdd2055, nameof(TransientFuelAdd2055));
        ValidateUInt16(TransientFuelAdd2057, nameof(TransientFuelAdd2057));
        ValidateUInt16(SlowCorrection2590, nameof(SlowCorrection2590));
        ValidateUInt16(SubtractiveFilter2584, nameof(SubtractiveFilter2584));
        ValidateUInt16(FuelEventWidthLimitBF, nameof(FuelEventWidthLimitBF));
        ValidateIndex(LoadIndex, nameof(LoadIndex), 0x07FF / 256.0);
        ValidateIndex(IatAxisIndex, nameof(IatAxisIndex), 8.0);
        ValidateIndex(CtsAxisIndex, nameof(CtsAxisIndex), 8.0);

        string normalizedMode = FuelMode.Trim().ToLowerInvariant();
        if (normalizedMode is not ("apply-trim-only" or "from-intermediates"))
        {
            throw new InvalidDataException("inputs.fuelMode must be 'apply-trim-only' or 'from-intermediates'.");
        }

        if (LoadAxisQ8_8 is null && LoadIndex is null && LoadDeltaByte is null)
        {
            throw new InvalidDataException("Supply loadAxisQ8_8, loadIndex, or loadDeltaByte.");
        }

        if (IatAxis2038Q8_8 is null && IatAxisIndex is null && IatProcessedByte is null)
        {
            throw new InvalidDataException("Supply iatAxis2038Q8_8, iatAxisIndex, or iatProcessedByte.");
        }

        if (CtsAxis203CQ8_8 is null && CtsAxisIndex is null && CtsProcessedByte is null)
        {
            throw new InvalidDataException("Supply ctsAxis203CQ8_8, ctsAxisIndex, or ctsProcessedByte.");
        }
    }

    internal CalculationInputs CloneForSweep() => (CalculationInputs)MemberwiseClone();

    private static void ValidateByte(int? value, string name)
    {
        if (value.HasValue && (value.Value < 0 || value.Value > 255))
        {
            throw new InvalidDataException($"inputs.{JsonName(name)} must be between 0 and 255.");
        }
    }

    private static void ValidateSignedByte(int value, string name)
    {
        if (value is < -128 or > 127)
        {
            throw new InvalidDataException($"inputs.{JsonName(name)} must be between -128 and 127.");
        }
    }

    private static void ValidateUInt16(
        int? value,
        string name,
        bool allowZero = true,
        int maximum = 65_535)
    {
        int minimum = allowZero ? 0 : 1;
        if (value.HasValue && (value.Value < minimum || value.Value > maximum))
        {
            throw new InvalidDataException($"inputs.{JsonName(name)} must be between {minimum} and {maximum}.");
        }
    }

    private static void ValidateIndex(double? value, string name, double maximum)
    {
        if (value.HasValue
            && (double.IsNaN(value.Value)
                || double.IsInfinity(value.Value)
                || value.Value < 0
                || value.Value > maximum))
        {
            throw new InvalidDataException(
                $"inputs.{JsonName(name)} must be between 0 and {maximum:0.########}."
            );
        }
    }

    private static string JsonName(string name)
    {
        if (string.IsNullOrEmpty(name))
        {
            return name;
        }

        return char.ToLowerInvariant(name[0]) + name[1..];
    }
}
