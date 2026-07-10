using System.Text.Json;
using System.Text.Json.Serialization;

namespace Iaw8p40.Calculator;

internal static class Program
{
    private const string DefaultConfigFileName = "ecu-calculator.json";

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true,
        NumberHandling = JsonNumberHandling.Strict
    };

    public static int Main(string[] args)
    {
        try
        {
            if (args.Any(a => string.Equals(a, "--self-test", StringComparison.OrdinalIgnoreCase)))
            {
                SelfTests.Run();
                return 0;
            }

            string configPath = ResolveConfigPath(args);
            CalculatorConfig config = LoadConfig(configPath);
            config.Validate();

            string configDirectory = Path.GetDirectoryName(Path.GetFullPath(configPath))
                ?? Directory.GetCurrentDirectory();

            string baseBinPath = ResolveRelativePath(configDirectory, config.BaseBinPath);
            RomImage baseRom = new(baseBinPath);
            RomImage? comparisonRom = string.IsNullOrWhiteSpace(config.ComparisonBinPath)
                ? null
                : new RomImage(ResolveRelativePath(configDirectory, config.ComparisonBinPath!));

            bool runSweep = config.Sweep.Enabled
                || args.Any(a => string.Equals(a, "--sweep", StringComparison.OrdinalIgnoreCase));
            if (runSweep)
            {
                config.Sweep.Enabled = true;
                RunSweep(config, configDirectory, baseRom, comparisonRom);
                return 0;
            }

            CalculationResult baseResult = new CalibrationCalculator(baseRom, config.Assumptions)
                .Calculate(config.Inputs);

            CalculationResult? comparisonResult = null;
            ResultDelta? delta = null;
            if (comparisonRom is not null)
            {
                comparisonResult = new CalibrationCalculator(comparisonRom, config.Assumptions)
                    .Calculate(config.Inputs);
                delta = ResultComparer.Compare(baseResult, comparisonResult);
            }

            ComparisonResult output = new()
            {
                Base = baseResult,
                Comparison = comparisonResult,
                Delta = delta
            };

            ConsoleReport.Print(output);

            if (!string.IsNullOrWhiteSpace(config.OutputJsonPath))
            {
                string outputPath = ResolveRelativePath(configDirectory, config.OutputJsonPath!);
                Directory.CreateDirectory(Path.GetDirectoryName(outputPath) ?? configDirectory);
                File.WriteAllText(outputPath, JsonSerializer.Serialize(output, JsonOptions));
                Console.WriteLine();
                Console.WriteLine($"Detailed JSON written to: {outputPath}");
            }

            return 0;
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or InvalidDataException
                                   or JsonException or ArgumentException or OverflowException)
        {
            Console.Error.WriteLine($"Error: {ex.Message}");
            return 1;
        }
    }

    private static void RunSweep(
        CalculatorConfig config,
        string configDirectory,
        RomImage baseRom,
        RomImage? comparisonRom)
    {
        SweepRunResult result = SweepRunner.Run(
            baseRom,
            comparisonRom,
            config.Inputs,
            config.Assumptions,
            config.Sweep
        );

        string? csvPath = ResolveOptionalPath(configDirectory, config.Sweep.OutputCsvPath);
        if (csvPath is not null)
        {
            SweepCsvWriter.Write(result, csvPath);
        }

        string? jsonPath = ResolveOptionalPath(configDirectory, config.Sweep.OutputJsonPath);
        if (jsonPath is not null)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(jsonPath) ?? configDirectory);
            File.WriteAllText(jsonPath, JsonSerializer.Serialize(result, JsonOptions));
        }

        SweepConsoleReport.Print(result, csvPath, jsonPath);
    }

    private static string ResolveConfigPath(string[] args)
    {
        string? explicitPath = args.FirstOrDefault(a => !a.StartsWith("--", StringComparison.Ordinal));
        if (explicitPath is not null)
        {
            string resolvedPath = Path.GetFullPath(explicitPath);
            if (!File.Exists(resolvedPath))
            {
                throw new FileNotFoundException($"Configuration file not found: {resolvedPath}.");
            }

            return resolvedPath;
        }

        string workingDirectoryCandidate = Path.Combine(
            Directory.GetCurrentDirectory(),
            DefaultConfigFileName
        );
        if (File.Exists(workingDirectoryCandidate))
        {
            return Path.GetFullPath(workingDirectoryCandidate);
        }

        DirectoryInfo? directory = new(AppContext.BaseDirectory);
        while (directory is not null)
        {
            string candidate = Path.Combine(directory.FullName, DefaultConfigFileName);
            if (File.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException(
            $"Configuration file '{DefaultConfigFileName}' was not found in the working directory " +
            "or above the executable directory. Pass a config path as the first argument."
        );
    }

    private static CalculatorConfig LoadConfig(string path)
    {
        string json = File.ReadAllText(path);
        return JsonSerializer.Deserialize<CalculatorConfig>(json, JsonOptions)
            ?? throw new InvalidDataException($"Configuration '{path}' is empty or invalid.");
    }

    private static string ResolveRelativePath(string baseDirectory, string path)
    {
        return Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(baseDirectory, path));
    }

    private static string? ResolveOptionalPath(string baseDirectory, string? path)
    {
        return path is null ? null : ResolveRelativePath(baseDirectory, path);
    }
}
