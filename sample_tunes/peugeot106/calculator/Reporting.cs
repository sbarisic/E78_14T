namespace Iaw8p40.Calculator;

public static class ResultComparer
{
    public static ResultDelta Compare(CalculationResult baseline, CalculationResult comparison)
    {
        return new ResultDelta
        {
            SparkBaseRaw = comparison.Spark.BaseTableRaw - baseline.Spark.BaseTableRaw,
            SparkCtsCorrectionRaw = comparison.Spark.CtsLoadCorrectionRaw - baseline.Spark.CtsLoadCorrectionRaw,
            SparkIatCorrectionRaw = comparison.Spark.IatLoadCorrectionRaw - baseline.Spark.IatLoadCorrectionRaw,
            SparkCoreRaw = comparison.Spark.CoreAccumulatorRaw - baseline.Spark.CoreAccumulatorRaw,
            SparkCoreDegrees = comparison.Spark.CoreAccumulatorDegrees - baseline.Spark.CoreAccumulatorDegrees,
            SparkCommandRaw = comparison.Spark.CommandRaw - baseline.Spark.CommandRaw,
            SparkCommandDegrees = comparison.Spark.CommandDegrees - baseline.Spark.CommandDegrees,
            FuelIatCorrectionA = comparison.Fuel.IatRpmCorrectionARaw - baseline.Fuel.IatRpmCorrectionARaw,
            FuelIatCorrectionB = comparison.Fuel.IatRpmCorrectionBRaw - baseline.Fuel.IatRpmCorrectionBRaw,
            FuelQuantityTrimRaw = comparison.Fuel.SignedQuantityTrimRaw - baseline.Fuel.SignedQuantityTrimRaw,
            FuelQuantityTrimPercent = comparison.Fuel.SignedQuantityTrimPercent - baseline.Fuel.SignedQuantityTrimPercent,
            FuelFinalDurationRaw = comparison.Fuel.FinalDurationRaw - baseline.Fuel.FinalDurationRaw,
            FuelFinalDurationMilliseconds = comparison.Fuel.FinalDurationMilliseconds is not null && baseline.Fuel.FinalDurationMilliseconds is not null
                ? comparison.Fuel.FinalDurationMilliseconds.Value - baseline.Fuel.FinalDurationMilliseconds.Value
                : null
        };
    }
}

public static class ConsoleReport
{
    public static void Print(ComparisonResult result)
    {
        PrintSingle("BASE", result.Base);

        if (result.Comparison is not null)
        {
            Console.WriteLine();
            PrintSingle("COMPARISON", result.Comparison);
            Console.WriteLine();
            PrintDelta(result.Delta!);
        }
    }

    private static void PrintSingle(string heading, CalculationResult result)
    {
        Console.WriteLine($"=== {heading} ===");
        Console.WriteLine($"BIN: {result.BinPath}");
        Console.WriteLine($"SHA-256: {result.BinSha256}");
        Console.WriteLine();

        Console.WriteLine("Axes");
        Console.WriteLine($"  RPM: {result.Axes.Rpm} rpm; period={result.Axes.EnginePeriodTicks} ticks; axis=0x{result.Axes.RpmAxisQ8_8:X4} ({result.Axes.RpmAxisIndex:0.000})");
        Console.WriteLine($"  Load: 0x{result.Axes.LoadAxisQ8_8:X4} ({result.Axes.LoadAxisIndex:0.000}); 0x00CE={result.Axes.LoadAirchargeWord00CE}; factor={FormatNullable(result.Axes.LoadAirchargeFactorRaw)}");
        Console.WriteLine($"  IAT-like: 0x{result.Axes.IatAxis2038Q8_8:X4} ({result.Axes.IatAxisIndex:0.000}); spark-axis 0x{result.Axes.IatSparkAxis203AQ8_8:X4}");
        Console.WriteLine($"  CTS-like: 0x{result.Axes.CtsAxis203CQ8_8:X4} ({result.Axes.CtsAxisIndex:0.000}); spark-axis 0x{result.Axes.CtsSparkAxis203EQ8_8:X4}");
        Console.WriteLine();

        SparkResult spark = result.Spark;
        Console.WriteLine("Spark");
        Console.WriteLine($"  Table: {spark.SelectedBaseTable}");
        Console.WriteLine($"  Base: {spark.BaseTableRaw:+0;-0;0} raw; offset {spark.OptionalSignedOffsetRaw:+0;-0;0}");
        Console.WriteLine($"  CTS correction: {spark.CtsLoadCorrectionRaw:+0;-0;0}; IAT correction: {spark.IatLoadCorrectionRaw:+0;-0;0}");
        Console.WriteLine($"  Core accumulator: {spark.CoreAccumulatorRaw} raw = {spark.CoreAccumulatorDegrees:0.00} deg");
        Console.WriteLine($"  Command: {spark.CommandRaw} raw = {spark.CommandDegrees:0.00} deg{(spark.CommandWasClamped ? " (clamped)" : string.Empty)}");
        Console.WriteLine();

        FuelResult fuel = result.Fuel;
        Console.WriteLine("Fuel");
        Console.WriteLine($"  Mode: {fuel.Mode}");
        Console.WriteLine($"  Trim table: {fuel.SelectedTrimTable}");
        Console.WriteLine($"  IAT/RPM corrections: A={fuel.IatRpmCorrectionARaw:+0;-0;0}, B={fuel.IatRpmCorrectionBRaw:+0;-0;0}");
        Console.WriteLine($"  Quantity trim: {fuel.SignedQuantityTrimRaw:+0;-0;0} raw = {fuel.SignedQuantityTrimPercent:+0.000;-0.000;0.000}%");
        if (fuel.Mode == "from-intermediates")
        {
            Console.WriteLine($"  0x204B: 0x{fuel.SummedFuelCorrection204B:X4} ({fuel.SummedFuelCorrection204BSigned:+0;-0;0}); 0x204E: 0x{fuel.FuelBlendWord204E:X4}");
            Console.WriteLine($"  Base before/after blend: {fuel.BaseBeforeBlendRaw} -> {fuel.BaseAfterBlendRaw}");
            Console.WriteLine($"  After trim/adaptive/warmup/afterstart: {fuel.AfterSignedTrimRaw} -> {fuel.AfterAdaptiveTrimRaw} -> {fuel.AfterWarmupRaw} -> {fuel.AfterAfterstartRaw}");
            Console.WriteLine($"  After transient/period/multiplier/lambda: {fuel.AfterTransientStackRaw} -> {fuel.AfterPeriodLimitRaw} -> {fuel.AfterFuelMultiplierRaw} -> {fuel.AfterFastLambdaRaw}");
            if (fuel.HighLoadSupportTableRaw != 0)
            {
                Console.WriteLine($"  High-load support: +{fuel.HighLoadSupportTableRaw * 2} ticks (table raw {fuel.HighLoadSupportTableRaw})");
            }
        }
        Console.WriteLine($"  Final duration: {fuel.FinalDurationRaw} raw ticks{FormatMilliseconds(fuel.FinalDurationMilliseconds)}");

        if (result.Warnings.Count > 0)
        {
            Console.WriteLine();
            Console.WriteLine("Model boundaries");
            foreach (string warning in result.Warnings)
            {
                Console.WriteLine($"  - {warning}");
            }
        }
    }

    private static void PrintDelta(ResultDelta delta)
    {
        Console.WriteLine("=== COMPARISON - BASE DELTA ===");
        Console.WriteLine($"Spark base: {delta.SparkBaseRaw:+0;-0;0} raw");
        Console.WriteLine($"Spark CTS/IAT corrections: {delta.SparkCtsCorrectionRaw:+0;-0;0} / {delta.SparkIatCorrectionRaw:+0;-0;0} raw");
        Console.WriteLine($"Spark core: {delta.SparkCoreRaw:+0;-0;0} raw = {delta.SparkCoreDegrees:+0.00;-0.00;0.00} deg");
        Console.WriteLine($"Spark command: {delta.SparkCommandRaw:+0;-0;0} raw = {delta.SparkCommandDegrees:+0.00;-0.00;0.00} deg");
        Console.WriteLine($"Fuel IAT corrections A/B: {delta.FuelIatCorrectionA:+0;-0;0} / {delta.FuelIatCorrectionB:+0;-0;0}");
        Console.WriteLine($"Fuel quantity trim: {delta.FuelQuantityTrimRaw:+0;-0;0} raw = {delta.FuelQuantityTrimPercent:+0.000;-0.000;0.000}%");
        Console.WriteLine($"Fuel final duration: {delta.FuelFinalDurationRaw:+0;-0;0} raw ticks{FormatMilliseconds(delta.FuelFinalDurationMilliseconds)}");
    }

    private static string FormatNullable(byte? value) => value is null ? "n/a" : value.Value.ToString();

    private static string FormatMilliseconds(double? value)
    {
        return value is null ? string.Empty : $" = {value.Value:0.000} ms (assumed)";
    }
}
