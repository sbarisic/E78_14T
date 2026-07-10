namespace Iaw8p40.Calculator;

public sealed class CalculationResult
{
    public string BinPath { get; init; } = string.Empty;
    public string BinSha256 { get; init; } = string.Empty;
    public ResolvedAxes Axes { get; init; } = new();
    public SparkResult Spark { get; init; } = new();
    public FuelResult Fuel { get; init; } = new();
    public List<AxisTrace> AxisTraces { get; init; } = new();
    public List<LookupTrace> LookupTraces { get; init; } = new();
    public List<string> Warnings { get; init; } = new();
}

public sealed class ResolvedAxes
{
    public int Rpm { get; init; }
    public ushort EnginePeriodTicks { get; init; }
    public ushort RpmAxisQ8_8 { get; init; }
    public double RpmAxisIndex { get; init; }

    public byte? LoadDeltaByte { get; init; }
    public byte? LoadAirchargeFactorRaw { get; init; }
    public ushort LoadAirchargeWord00CE { get; init; }
    public ushort LoadAxisQ8_8 { get; init; }
    public double LoadAxisIndex { get; init; }

    public byte? IatProcessedByte { get; init; }
    public ushort IatAxis2038Q8_8 { get; init; }
    public ushort IatSparkAxis203AQ8_8 { get; init; }
    public double IatAxisIndex { get; init; }

    public byte? CtsProcessedByte { get; init; }
    public ushort CtsAxis203CQ8_8 { get; init; }
    public ushort CtsSparkAxis203EQ8_8 { get; init; }
    public double CtsAxisIndex { get; init; }
}

public sealed class SparkResult
{
    public string SelectedBaseTable { get; init; } = string.Empty;
    public int SelectedBaseAddress { get; init; }
    public bool RpmOnlyBypassMode { get; init; }
    public int BaseTableRaw { get; init; }
    public int OptionalSignedOffsetRaw { get; init; }
    public int BaseWithOffsetRaw { get; init; }
    public int CtsLoadCorrectionRaw { get; init; }
    public int IatLoadCorrectionRaw { get; init; }
    public int CoreAccumulatorRaw { get; init; }
    public double CoreAccumulatorDegrees { get; init; }
    public int AdditionalSparkRaw { get; init; }
    public int UnclampedCommandRaw { get; init; }
    public int CommandRaw { get; init; }
    public double CommandDegrees { get; init; }
    public bool CommandWasClamped { get; init; }
}

public sealed class FuelResult
{
    public string Mode { get; init; } = string.Empty;
    public string SelectedTrimTable { get; init; } = string.Empty;
    public int SelectedTrimAddress { get; init; }
    public sbyte IatRpmCorrectionARaw { get; init; }
    public sbyte IatRpmCorrectionBRaw { get; init; }
    public sbyte SignedQuantityTrimRaw { get; init; }
    public double SignedQuantityTrimPercent { get; init; }

    public ushort InputBasePulseRaw { get; init; }
    public ushort SummedFuelCorrection204B { get; init; }
    public short SummedFuelCorrection204BSigned { get; init; }
    public ushort FuelBlendWord204E { get; init; }
    public ushort BaseBeforeBlendRaw { get; init; }
    public ushort BaseAfterBlendRaw { get; init; }
    public ushort AfterSignedTrimRaw { get; init; }
    public ushort AfterAdaptiveTrimRaw { get; init; }
    public ushort AfterWarmupRaw { get; init; }
    public ushort AfterAfterstartRaw { get; init; }
    public ushort AfterTransientStackRaw { get; init; }
    public ushort AfterPeriodLimitRaw { get; init; }
    public ushort AfterFuelMultiplierRaw { get; init; }
    public ushort CorrectedFuelCharge2051Raw { get; init; }
    public ushort AfterFastLambdaRaw { get; init; }
    public ushort BeforeHighLoadSupportRaw { get; init; }
    public byte HighLoadSupportTableRaw { get; init; }
    public ushort FinalDurationRaw { get; init; }
    public double? FinalDurationMilliseconds { get; init; }
}

public sealed class ComparisonResult
{
    public CalculationResult Base { get; init; } = new();
    public CalculationResult? Comparison { get; init; }
    public ResultDelta? Delta { get; init; }
}

public sealed class ResultDelta
{
    public int SparkBaseRaw { get; init; }
    public int SparkCtsCorrectionRaw { get; init; }
    public int SparkIatCorrectionRaw { get; init; }
    public int SparkCoreRaw { get; init; }
    public double SparkCoreDegrees { get; init; }
    public int SparkCommandRaw { get; init; }
    public double SparkCommandDegrees { get; init; }

    public int FuelIatCorrectionA { get; init; }
    public int FuelIatCorrectionB { get; init; }
    public int FuelQuantityTrimRaw { get; init; }
    public double FuelQuantityTrimPercent { get; init; }
    public int FuelFinalDurationRaw { get; init; }
    public double? FuelFinalDurationMilliseconds { get; init; }
}
