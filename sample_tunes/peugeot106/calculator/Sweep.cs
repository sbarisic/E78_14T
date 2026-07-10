namespace Iaw8p40.Calculator;

public sealed class SweepRunResult
{
    public SweepConfig Settings { get; init; } = new();
    public string BaseBinPath { get; init; } = string.Empty;
    public string BaseBinSha256 { get; init; } = string.Empty;
    public string? ComparisonBinPath { get; init; }
    public string? ComparisonBinSha256 { get; init; }
    public string FuelMode { get; init; } = string.Empty;
    public string LoadInputWarning { get; init; } = string.Empty;
    public List<SweepPointResult> Points { get; init; } = new();
}

public sealed class SweepPointResult
{
    public int Rpm { get; init; }
    public int PedalProxyPercent { get; init; }
    public byte LoadDeltaByte { get; init; }
    public SweepMetrics Base { get; init; } = new();
    public SweepMetrics? Comparison { get; init; }
    public ResultDelta? Delta { get; init; }
}

public sealed class SweepMetrics
{
    public ushort RpmAxisQ8_8 { get; init; }
    public double RpmAxisIndex { get; init; }
    public byte? LoadAirchargeFactorRaw { get; init; }
    public ushort LoadAxisQ8_8 { get; init; }
    public double LoadAxisIndex { get; init; }
    public int SparkBaseAddress { get; init; }
    public int SparkBaseRaw { get; init; }
    public int SparkCtsCorrectionRaw { get; init; }
    public int SparkIatCorrectionRaw { get; init; }
    public int SparkCoreRaw { get; init; }
    public double SparkCoreDegrees { get; init; }
    public int SparkCommandRaw { get; init; }
    public double SparkCommandDegrees { get; init; }
    public int FuelTrimAddress { get; init; }
    public sbyte FuelIatCorrectionARaw { get; init; }
    public sbyte FuelIatCorrectionBRaw { get; init; }
    public sbyte FuelQuantityTrimRaw { get; init; }
    public double FuelQuantityTrimPercent { get; init; }
    public ushort FuelFinalDurationRaw { get; init; }
    public double? FuelFinalDurationMilliseconds { get; init; }
}

public static class SweepRunner
{
    public const string LoadInputWarning =
        "Pedal proxy percent is a linear command mapped to loadDeltaByte, not a decoded TPS angle or a dynamic engine-load model.";

    public static SweepRunResult Run(
        RomImage baseRom,
        RomImage? comparisonRom,
        CalculationInputs templateInputs,
        CalculationAssumptions assumptions,
        SweepConfig settings)
    {
        CalibrationCalculator baseCalculator = new(baseRom, assumptions);
        CalibrationCalculator? comparisonCalculator = comparisonRom is null
            ? null
            : new CalibrationCalculator(comparisonRom, assumptions);
        List<SweepPointResult> points = new();

        foreach (int rpm in BuildRange(settings.RpmStart, settings.RpmEnd, settings.RpmStep))
        {
            foreach (int pedal in BuildRange(
                settings.PedalProxyStartPercent,
                settings.PedalProxyEndPercent,
                settings.PedalProxyStepPercent))
            {
                byte loadDelta = MapPedalProxyToLoadDelta(pedal, settings);
                CalculationInputs inputs = BuildInputs(templateInputs, rpm, loadDelta);
                CalculationResult baseResult = baseCalculator.Calculate(inputs);
                CalculationResult? comparisonResult = comparisonCalculator?.Calculate(inputs);

                points.Add(new SweepPointResult
                {
                    Rpm = rpm,
                    PedalProxyPercent = pedal,
                    LoadDeltaByte = loadDelta,
                    Base = Summarize(baseResult),
                    Comparison = comparisonResult is null ? null : Summarize(comparisonResult),
                    Delta = comparisonResult is null
                        ? null
                        : ResultComparer.Compare(baseResult, comparisonResult)
                });
            }
        }

        return new SweepRunResult
        {
            Settings = settings,
            BaseBinPath = baseRom.SourcePath,
            BaseBinSha256 = baseRom.Sha256,
            ComparisonBinPath = comparisonRom?.SourcePath,
            ComparisonBinSha256 = comparisonRom?.Sha256,
            FuelMode = templateInputs.FuelMode,
            LoadInputWarning = LoadInputWarning,
            Points = points
        };
    }

    internal static IReadOnlyList<int> BuildRange(int start, int end, int step)
    {
        List<int> values = new();
        for (int value = start; value <= end; value = checked(value + step))
        {
            values.Add(value);
            if (value > end - step)
            {
                break;
            }
        }

        if (values[^1] != end)
        {
            values.Add(end);
        }
        return values;
    }

    internal static byte MapPedalProxyToLoadDelta(int pedalProxyPercent, SweepConfig settings)
    {
        double fraction = pedalProxyPercent / 100.0;
        double value = settings.LoadDeltaByteAt0Percent
            + ((settings.LoadDeltaByteAt100Percent - settings.LoadDeltaByteAt0Percent) * fraction);
        return (byte)Math.Clamp(
            (int)Math.Round(value, MidpointRounding.AwayFromZero),
            byte.MinValue,
            byte.MaxValue
        );
    }

    private static CalculationInputs BuildInputs(
        CalculationInputs template,
        int rpm,
        byte loadDelta)
    {
        CalculationInputs inputs = template.CloneForSweep();
        inputs.Rpm = rpm;
        inputs.EnginePeriodTicks = null;
        inputs.RpmAxisQ8_8 = null;
        inputs.LoadAxisQ8_8 = null;
        inputs.LoadIndex = null;
        inputs.LoadAirchargeWord00CE = null;
        inputs.LoadDeltaByte = loadDelta;
        inputs.Validate();
        return inputs;
    }

    private static SweepMetrics Summarize(CalculationResult result)
    {
        return new SweepMetrics
        {
            RpmAxisQ8_8 = result.Axes.RpmAxisQ8_8,
            RpmAxisIndex = result.Axes.RpmAxisIndex,
            LoadAirchargeFactorRaw = result.Axes.LoadAirchargeFactorRaw,
            LoadAxisQ8_8 = result.Axes.LoadAxisQ8_8,
            LoadAxisIndex = result.Axes.LoadAxisIndex,
            SparkBaseAddress = result.Spark.SelectedBaseAddress,
            SparkBaseRaw = result.Spark.BaseTableRaw,
            SparkCtsCorrectionRaw = result.Spark.CtsLoadCorrectionRaw,
            SparkIatCorrectionRaw = result.Spark.IatLoadCorrectionRaw,
            SparkCoreRaw = result.Spark.CoreAccumulatorRaw,
            SparkCoreDegrees = result.Spark.CoreAccumulatorDegrees,
            SparkCommandRaw = result.Spark.CommandRaw,
            SparkCommandDegrees = result.Spark.CommandDegrees,
            FuelTrimAddress = result.Fuel.SelectedTrimAddress,
            FuelIatCorrectionARaw = result.Fuel.IatRpmCorrectionARaw,
            FuelIatCorrectionBRaw = result.Fuel.IatRpmCorrectionBRaw,
            FuelQuantityTrimRaw = result.Fuel.SignedQuantityTrimRaw,
            FuelQuantityTrimPercent = result.Fuel.SignedQuantityTrimPercent,
            FuelFinalDurationRaw = result.Fuel.FinalDurationRaw,
            FuelFinalDurationMilliseconds = result.Fuel.FinalDurationMilliseconds
        };
    }
}
