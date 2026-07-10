using System.Security.Cryptography;

namespace Iaw8p40.Calculator;

public sealed class RomImage
{
    public const int ExpectedSize = 0x10000;
    private readonly byte[] _bytes;

    public RomImage(string path)
    {
        SourcePath = Path.GetFullPath(path);
        _bytes = File.ReadAllBytes(SourcePath);
        if (_bytes.Length != ExpectedSize)
        {
            throw new InvalidDataException(
                $"BIN '{SourcePath}' is {_bytes.Length} bytes; expected exactly {ExpectedSize} bytes (64 KiB)."
            );
        }

        Sha256 = Convert.ToHexString(SHA256.HashData(_bytes));
    }

    private RomImage(byte[] bytes, string sourcePath)
    {
        if (bytes.Length != ExpectedSize)
        {
            throw new ArgumentException($"Expected {ExpectedSize} bytes.", nameof(bytes));
        }

        _bytes = bytes;
        SourcePath = sourcePath;
        Sha256 = Convert.ToHexString(SHA256.HashData(_bytes));
    }

    public string SourcePath { get; }
    public string Sha256 { get; }

    public static RomImage FromBytes(byte[] bytes, string sourcePath = "<memory>")
    {
        return new RomImage((byte[])bytes.Clone(), sourcePath);
    }

    public byte ReadByte(int address)
    {
        EnsureRange(address, 1);
        return _bytes[address];
    }

    public sbyte ReadSByte(int address)
    {
        return unchecked((sbyte)ReadByte(address));
    }

    public ushort ReadUInt16BigEndian(int address)
    {
        EnsureRange(address, 2);
        return (ushort)((_bytes[address] << 8) | _bytes[address + 1]);
    }

    public byte[] ReadBytes(int address, int length)
    {
        EnsureRange(address, length);
        byte[] result = new byte[length];
        Buffer.BlockCopy(_bytes, address, result, 0, length);
        return result;
    }

    private static void EnsureRange(int address, int length)
    {
        if (address < 0 || length < 0 || address > ExpectedSize - length)
        {
            throw new ArgumentOutOfRangeException(
                nameof(address),
                $"ROM range 0x{address:X4}+{length} is outside the 64 KiB image."
            );
        }
    }
}
