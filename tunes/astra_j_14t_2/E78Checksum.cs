using System.Buffers.Binary;

const int ExpectedFileSize = 0x300000;

var segments = new[]
{
    new CalibrationSegment("Vehicle System", 0x020000, 0x022FFF),
    new CalibrationSegment("Fuel System", 0x023000, 0x027FFF),
    new CalibrationSegment("Vehicle Speed Sensor", 0x028000, 0x028FFF),
    new CalibrationSegment("Engine Diagnostic", 0x029000, 0x03FFFF),
    new CalibrationSegment("Engine Operation", 0x040000, 0x07FFFF),
};

var torqueSecuritySections = new[]
{
    new TorqueSecuritySection("Interface True", 0x040034, 0x043157, 0x043158),
    new TorqueSecuritySection("Interface False / AFM", 0x04315C, 0x0464EB, 0x0464EC),
    new TorqueSecuritySection("Common", 0x0464F0, 0x04BB77, 0x04BB78),
};

try
{
    return Run(args);
}
catch (Exception ex)
{
    Console.Error.WriteLine($"error: {ex.Message}");
    return 1;
}

int Run(string[] commandLine)
{
    if (commandLine.Length < 2 || IsHelp(commandLine[0]))
    {
        PrintUsage();
        return commandLine.Length == 0 ? 1 : 0;
    }

    var command = commandLine[0].ToLowerInvariant();
    return command switch
    {
        "verify" => VerifyCommand(commandLine),
        "fix" => FixCommand(commandLine),
        _ => throw new ArgumentException($"unknown command '{commandLine[0]}'"),
    };
}

int VerifyCommand(string[] commandLine)
{
    if (commandLine.Length is < 2 or > 3)
    {
        PrintUsage();
        return 1;
    }

    var inputPath = Path.GetFullPath(commandLine[1]);
    var image = ReadImage(inputPath);
    byte[]? reference = null;

    if (commandLine.Length == 3)
    {
        var referencePath = Path.GetFullPath(commandLine[2]);
        reference = ReadImage(referencePath);
        Console.WriteLine($"Reference: {referencePath}");
        var referenceAudit = Audit(reference);
        PrintAudit("Reference checksum audit", referenceAudit);
        if (!referenceAudit.IsValid)
        {
            throw new InvalidDataException("reference BIN does not pass the Astra E78 checksum layout");
        }

        Console.WriteLine($"Byte differences from reference: {CountDifferences(image, reference):N0}");
        Console.WriteLine();
    }

    Console.WriteLine($"Input: {inputPath}");
    var audit = Audit(image);
    PrintAudit("Input checksum audit", audit);
    return audit.IsValid ? 0 : 2;
}

int FixCommand(string[] commandLine)
{
    if (commandLine.Length is < 3 or > 5)
    {
        PrintUsage();
        return 1;
    }

    var positional = new List<string>();
    var overwrite = false;
    foreach (var arg in commandLine.Skip(1))
    {
        if (arg.Equals("--overwrite", StringComparison.OrdinalIgnoreCase))
        {
            overwrite = true;
        }
        else
        {
            positional.Add(arg);
        }
    }

    if (positional.Count is < 2 or > 3)
    {
        PrintUsage();
        return 1;
    }

    var inputPath = Path.GetFullPath(positional[0]);
    var outputPath = Path.GetFullPath(positional[1]);
    var samePath = string.Equals(inputPath, outputPath, StringComparison.OrdinalIgnoreCase);

    if (samePath && !overwrite)
    {
        throw new InvalidOperationException("refusing an in-place write without --overwrite");
    }

    if (!samePath && File.Exists(outputPath) && !overwrite)
    {
        throw new IOException($"output already exists: {outputPath}. Use --overwrite to replace it");
    }

    var image = ReadImage(inputPath);
    if (positional.Count == 3)
    {
        var referencePath = Path.GetFullPath(positional[2]);
        var reference = ReadImage(referencePath);
        var referenceAudit = Audit(reference);
        if (!referenceAudit.IsValid)
        {
            throw new InvalidDataException("reference BIN does not pass the Astra E78 checksum layout");
        }

        Console.WriteLine($"Reference verified: {referencePath}");
        Console.WriteLine($"Input differences from reference: {CountDifferences(image, reference):N0}");
    }

    var before = Audit(image);
    PrintAudit("Before correction", before);

    var corrected = BuildCorrectedImage(image);
    var after = Audit(corrected);
    if (!after.IsValid)
    {
        throw new InvalidDataException("internal verification failed after checksum correction");
    }

    var outputDirectory = Path.GetDirectoryName(outputPath);
    if (!string.IsNullOrEmpty(outputDirectory))
    {
        Directory.CreateDirectory(outputDirectory);
    }

    var temporaryPath = outputPath + ".tmp";
    File.WriteAllBytes(temporaryPath, corrected);
    File.Move(temporaryPath, outputPath, true);

    Console.WriteLine();
    Console.WriteLine($"Wrote: {outputPath}");
    Console.WriteLine($"Checksum bytes changed: {CountDifferences(image, corrected):N0}");
    PrintAudit("After correction", after);
    return 0;
}

ChecksumAudit Audit(byte[] image)
{
    var required = BuildCorrectedImage(image);
    var torqueResults = torqueSecuritySections.Select(section =>
    {
        var stored = ReadUInt32BigEndian(image, section.ChecksumAddress);
        var expected = ReadUInt32BigEndian(required, section.ChecksumAddress);
        return new TorqueSecurityResult(section, stored, expected);
    }).ToArray();

    var segmentResults = segments.Select(segment =>
    {
        var storedCrcBytes = image.AsSpan(segment.CrcAddress, 2).ToArray();
        var requiredCrcBytes = required.AsSpan(segment.CrcAddress, 2).ToArray();
        var storedMod16 = ReadUInt16BigEndian(image, segment.Mod16Address);
        var requiredMod16 = ReadUInt16BigEndian(required, segment.Mod16Address);
        return new SegmentResult(segment, storedCrcBytes, requiredCrcBytes, storedMod16, requiredMod16);
    }).ToArray();

    return new ChecksumAudit(torqueResults, segmentResults);
}

byte[] BuildCorrectedImage(byte[] source)
{
    var corrected = (byte[])source.Clone();

    // TorqueSecurity markers are covered by the Engine Operation segment CRC.
    foreach (var section in torqueSecuritySections)
    {
        var checksum = CalculateTorqueSecurity(corrected, section.DataStart, section.DataEnd);
        WriteUInt32BigEndian(corrected, section.ChecksumAddress, checksum);
    }

    // Segment Mod16 includes the stored CRC bytes, so CRC must be written first.
    foreach (var segment in segments)
    {
        var crc = CalculateSegmentCrc16(corrected, segment);
        corrected[segment.CrcAddress] = (byte)(crc & 0xFF);
        corrected[segment.CrcAddress + 1] = (byte)(crc >> 8);

        var mod16 = CalculateSegmentMod16(corrected, segment);
        WriteUInt16BigEndian(corrected, segment.Mod16Address, mod16);
    }

    return corrected;
}

uint CalculateTorqueSecurity(byte[] image, int start, int end)
{
    ValidateEvenInclusiveRange(start, end);
    uint sum = 0;
    for (var address = start; address <= end; address += 2)
    {
        sum = unchecked(sum + ReadUInt16BigEndian(image, address));
    }

    return unchecked(0u - sum);
}

ushort CalculateSegmentMod16(byte[] image, CalibrationSegment segment)
{
    var start = segment.Start + 2;
    ValidateEvenInclusiveRange(start, segment.End);
    uint sum = 0;
    for (var address = start; address <= segment.End; address += 2)
    {
        sum = (sum + ReadUInt16BigEndian(image, address)) & 0xFFFF;
    }

    return unchecked((ushort)(0u - sum));
}

ushort CalculateSegmentCrc16(byte[] image, CalibrationSegment segment)
{
    ushort crc = 0;
    crc = UpdateCrc16Arc(crc, image.AsSpan(segment.Start + 2, 0x1E));
    crc = UpdateCrc16Arc(crc, image.AsSpan(segment.Start + 0x22, segment.End - (segment.Start + 0x22) + 1));
    return crc;
}

ushort UpdateCrc16Arc(ushort crc, ReadOnlySpan<byte> data)
{
    foreach (var value in data)
    {
        crc ^= value;
        for (var bit = 0; bit < 8; bit++)
        {
            crc = (ushort)((crc & 1) != 0 ? (crc >> 1) ^ 0xA001 : crc >> 1);
        }
    }

    return crc;
}

void PrintAudit(string heading, ChecksumAudit audit)
{
    Console.WriteLine(heading);
    Console.WriteLine("TorqueSecurity:");
    foreach (var result in audit.TorqueSecurity)
    {
        Console.WriteLine(
            $"  {Status(result.IsValid),-4} {result.Section.Name,-23} " +
            $"stored=0x{result.Stored:X8} required=0x{result.Required:X8} " +
            $"marker=0x{result.Section.ChecksumAddress:X6}");
    }

    Console.WriteLine("Calibration segments:");
    foreach (var result in audit.Segments)
    {
        Console.WriteLine(
            $"  {Status(result.IsValid),-4} {result.Segment.Name,-23} " +
            $"CRC={FormatBytes(result.StoredCrc)}/{FormatBytes(result.RequiredCrc)} " +
            $"Mod16=0x{result.StoredMod16:X4}/0x{result.RequiredMod16:X4}");
    }

    Console.WriteLine($"Overall: {(audit.IsValid ? "VALID" : "INVALID")}");
    Console.WriteLine();
}

byte[] ReadImage(string path)
{
    var image = File.ReadAllBytes(path);
    if (image.Length != ExpectedFileSize)
    {
        throw new InvalidDataException(
            $"expected a 0x{ExpectedFileSize:X} byte Astra E78 full BIN, got 0x{image.Length:X}: {path}");
    }

    return image;
}

ushort ReadUInt16BigEndian(byte[] data, int address) =>
    BinaryPrimitives.ReadUInt16BigEndian(data.AsSpan(address, 2));

uint ReadUInt32BigEndian(byte[] data, int address) =>
    BinaryPrimitives.ReadUInt32BigEndian(data.AsSpan(address, 4));

void WriteUInt16BigEndian(byte[] data, int address, ushort value) =>
    BinaryPrimitives.WriteUInt16BigEndian(data.AsSpan(address, 2), value);

void WriteUInt32BigEndian(byte[] data, int address, uint value) =>
    BinaryPrimitives.WriteUInt32BigEndian(data.AsSpan(address, 4), value);

void ValidateEvenInclusiveRange(int start, int end)
{
    if (start < 0 || end < start || ((end - start + 1) & 1) != 0)
    {
        throw new ArgumentOutOfRangeException(nameof(start), $"invalid 16-bit range 0x{start:X}-0x{end:X}");
    }
}

int CountDifferences(byte[] left, byte[] right)
{
    if (left.Length != right.Length)
    {
        throw new ArgumentException("BIN lengths differ");
    }

    var count = 0;
    for (var index = 0; index < left.Length; index++)
    {
        if (left[index] != right[index])
        {
            count++;
        }
    }

    return count;
}

string Status(bool valid) => valid ? "OK" : "BAD";
string FormatBytes(byte[] bytes) => Convert.ToHexString(bytes).Insert(2, " ");
bool IsHelp(string value) => value is "-h" or "--help" or "help";

void PrintUsage()
{
    Console.WriteLine("Astra E78 calibration and TorqueSecurity checksum tool");
    Console.WriteLine();
    Console.WriteLine("Usage:");
    Console.WriteLine("  dotnet run --file E78Checksum.cs -- verify <bin> [original-reference-bin]");
    Console.WriteLine("  dotnet run --file E78Checksum.cs -- fix <input-bin> <output-bin> [original-reference-bin] [--overwrite]");
    Console.WriteLine();
    Console.WriteLine("verify never writes. fix applies TorqueSecurity, segment CRC16, then segment Mod16.");
}

sealed record CalibrationSegment(string Name, int Start, int End)
{
    public int Mod16Address => Start;
    public int CrcAddress => Start + 0x20;
}

sealed record TorqueSecuritySection(string Name, int DataStart, int DataEnd, int ChecksumAddress);

sealed record TorqueSecurityResult(TorqueSecuritySection Section, uint Stored, uint Required)
{
    public bool IsValid => Stored == Required;
}

sealed record SegmentResult(
    CalibrationSegment Segment,
    byte[] StoredCrc,
    byte[] RequiredCrc,
    ushort StoredMod16,
    ushort RequiredMod16)
{
    public bool IsValid => StoredCrc.SequenceEqual(RequiredCrc) && StoredMod16 == RequiredMod16;
}

sealed record ChecksumAudit(TorqueSecurityResult[] TorqueSecurity, SegmentResult[] Segments)
{
    public bool IsValid => TorqueSecurity.All(result => result.IsValid) && Segments.All(result => result.IsValid);
}
