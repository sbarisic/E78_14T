using System.Globalization;
using System.Text;

namespace Iaw8p40.Calculator;

public static class SweepCsvWriter
{
    private static readonly string[] Header =
    {
        "rpm",
        "pedal_proxy_percent",
        "load_delta_byte",
        "base_rpm_axis_index",
        "base_load_factor_raw",
        "base_load_axis_index",
        "base_spark_table_address",
        "base_spark_raw",
        "base_cts_spark_correction_raw",
        "base_iat_spark_correction_raw",
        "base_spark_core_deg",
        "base_spark_command_deg",
        "base_fuel_trim_address",
        "base_fuel_iat_correction_a_raw",
        "base_fuel_iat_correction_b_raw",
        "base_fuel_trim_percent",
        "base_fuel_duration_raw",
        "base_fuel_duration_ms_assumed",
        "comparison_load_factor_raw",
        "comparison_load_axis_index",
        "comparison_spark_table_address",
        "comparison_spark_raw",
        "comparison_cts_spark_correction_raw",
        "comparison_iat_spark_correction_raw",
        "comparison_spark_core_deg",
        "comparison_spark_command_deg",
        "comparison_fuel_trim_address",
        "comparison_fuel_iat_correction_a_raw",
        "comparison_fuel_iat_correction_b_raw",
        "comparison_fuel_trim_percent",
        "comparison_fuel_duration_raw",
        "comparison_fuel_duration_ms_assumed",
        "delta_spark_core_deg",
        "delta_spark_command_deg",
        "delta_fuel_iat_correction_a_raw",
        "delta_fuel_iat_correction_b_raw",
        "delta_fuel_trim_percent",
        "delta_fuel_duration_raw",
        "delta_fuel_duration_ms_assumed"
    };

    public static void Write(SweepRunResult result, string path)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path) ?? Directory.GetCurrentDirectory());
        using StreamWriter writer = new(path, false, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
        writer.WriteLine(string.Join(',', Header));

        foreach (SweepPointResult point in result.Points)
        {
            SweepMetrics baseline = point.Base;
            SweepMetrics? comparison = point.Comparison;
            ResultDelta? delta = point.Delta;
            writer.WriteLine(JoinCells(
                point.Rpm,
                point.PedalProxyPercent,
                point.LoadDeltaByte,
                baseline.RpmAxisIndex,
                baseline.LoadAirchargeFactorRaw,
                baseline.LoadAxisIndex,
                HexAddress(baseline.SparkBaseAddress),
                baseline.SparkBaseRaw,
                baseline.SparkCtsCorrectionRaw,
                baseline.SparkIatCorrectionRaw,
                baseline.SparkCoreDegrees,
                baseline.SparkCommandDegrees,
                HexAddress(baseline.FuelTrimAddress),
                baseline.FuelIatCorrectionARaw,
                baseline.FuelIatCorrectionBRaw,
                baseline.FuelQuantityTrimPercent,
                baseline.FuelFinalDurationRaw,
                baseline.FuelFinalDurationMilliseconds,
                comparison?.LoadAirchargeFactorRaw,
                comparison?.LoadAxisIndex,
                comparison is null ? null : HexAddress(comparison.SparkBaseAddress),
                comparison?.SparkBaseRaw,
                comparison?.SparkCtsCorrectionRaw,
                comparison?.SparkIatCorrectionRaw,
                comparison?.SparkCoreDegrees,
                comparison?.SparkCommandDegrees,
                comparison is null ? null : HexAddress(comparison.FuelTrimAddress),
                comparison?.FuelIatCorrectionARaw,
                comparison?.FuelIatCorrectionBRaw,
                comparison?.FuelQuantityTrimPercent,
                comparison?.FuelFinalDurationRaw,
                comparison?.FuelFinalDurationMilliseconds,
                delta?.SparkCoreDegrees,
                delta?.SparkCommandDegrees,
                delta?.FuelIatCorrectionA,
                delta?.FuelIatCorrectionB,
                delta?.FuelQuantityTrimPercent,
                delta?.FuelFinalDurationRaw,
                delta?.FuelFinalDurationMilliseconds
            ));
        }
    }

    private static string JoinCells(params object?[] values)
    {
        return string.Join(',', values.Select(FormatCell));
    }

    private static string FormatCell(object? value)
    {
        if (value is null)
        {
            return string.Empty;
        }

        string text = value is IFormattable formattable
            ? formattable.ToString(null, CultureInfo.InvariantCulture)
            : value.ToString() ?? string.Empty;
        if (text.IndexOfAny(new[] { ',', '"', '\r', '\n' }) >= 0)
        {
            return $"\"{text.Replace("\"", "\"\"")}\"";
        }
        return text;
    }

    private static string HexAddress(int address) => $"0x{address:X4}";
}

public static class SweepConsoleReport
{
    public static void Print(SweepRunResult result, string? csvPath, string? jsonPath)
    {
        SweepConfig settings = result.Settings;
        Console.WriteLine("=== RPM / PEDAL-PROXY SWEEP ===");
        Console.WriteLine($"Points: {result.Points.Count}");
        Console.WriteLine($"RPM: {settings.RpmStart}..{settings.RpmEnd}, step {settings.RpmStep}");
        Console.WriteLine(
            $"Pedal proxy: {settings.PedalProxyStartPercent}..{settings.PedalProxyEndPercent}%, " +
            $"step {settings.PedalProxyStepPercent}%"
        );
        Console.WriteLine(
            $"Proxy mapping: 0% -> loadDeltaByte {settings.LoadDeltaByteAt0Percent}; " +
            $"100% -> {settings.LoadDeltaByteAt100Percent}"
        );
        Console.WriteLine($"Fuel mode: {result.FuelMode}");
        Console.WriteLine($"Base: {result.BaseBinPath}");
        if (result.ComparisonBinPath is not null)
        {
            Console.WriteLine($"Comparison: {result.ComparisonBinPath}");
            PrintDeltaRange(result.Points);
        }

        Console.WriteLine();
        Console.WriteLine($"Model boundary: {result.LoadInputWarning}");
        if (result.FuelMode == "apply-trim-only")
        {
            Console.WriteLine(
                "Fuel note: apply-trim-only sweeps the selected quantity-trim tables; reported IAT/RPM corrections are not folded into final duration."
            );
        }
        if (csvPath is not null)
        {
            Console.WriteLine($"CSV written to: {csvPath}");
        }
        if (jsonPath is not null)
        {
            Console.WriteLine($"JSON written to: {jsonPath}");
        }
    }

    private static void PrintDeltaRange(IReadOnlyList<SweepPointResult> points)
    {
        List<ResultDelta> deltas = points
            .Where(point => point.Delta is not null)
            .Select(point => point.Delta!)
            .ToList();
        if (deltas.Count == 0)
        {
            return;
        }

        Console.WriteLine(
            $"Spark core delta range: {deltas.Min(delta => delta.SparkCoreDegrees):+0.00;-0.00;0.00} " +
            $"to {deltas.Max(delta => delta.SparkCoreDegrees):+0.00;-0.00;0.00} deg"
        );
        Console.WriteLine(
            $"Fuel-duration delta range: {deltas.Min(delta => delta.FuelFinalDurationRaw):+0;-0;0} " +
            $"to {deltas.Max(delta => delta.FuelFinalDurationRaw):+0;-0;0} raw ticks"
        );
    }
}
