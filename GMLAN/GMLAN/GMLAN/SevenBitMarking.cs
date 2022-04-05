using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GMLAN {
	static class SevenBitMarking {
		public static byte[] Encode(byte[] RawData, byte RawDataLen) {
			if (RawDataLen > 111)
				throw new Exception("Cannot handle larger size");

			byte[] FrameData = new byte[128]; // 128 encoded bytes for 111 bytes of raw data
			byte FrameIdx = 0;
			byte ExtraBitCount = 0;
			byte ExtraBits = 0;

			// Placeholder for length
			FrameData[FrameIdx++] = 0b10000000;

			for (byte i = 0; i < RawDataLen; i++) {
				// Calculate shifted byte
				int B = (RawData[i] >> 1) & 0b01111111;

				// Add shifted byte
				FrameData[FrameIdx++] = (byte)B;

				// Put extra bit aside
				ExtraBits = (byte)((ExtraBits << 1) | (RawData[i] & 0x1));
				ExtraBitCount++;

				// If enough extra bits, add extra bits
				if (ExtraBitCount == 7) {
					FrameData[FrameIdx++] = ExtraBits;

					ExtraBits = 0;
					ExtraBitCount = 0;
				}
			}

			// If leftover extra bits, add extra bits
			if (ExtraBitCount > 0) {
				FrameData[FrameIdx++] = (byte)(ExtraBits << (7 - ExtraBitCount));
			}

			FrameData[0] |= (byte)(FrameIdx - 1);
			return FrameData.Take(FrameIdx).ToArray();
		}


		public static byte[] Decode(byte[] EncodedBytes, byte EncodedBytesLen) {
			byte[] Decoded = new byte[111];
			byte DecodedIdx = 0;

			byte ExBytesIdx = 0;
			byte DataLen = 0;
			byte DataByteIdx = 0;

			for (byte i = 1; i < EncodedBytesLen; i++) {
				if (ExBytesIdx == 0 || ExBytesIdx == i - 1) {
					DataByteIdx = 0;
					ExBytesIdx += 8;

					if (ExBytesIdx >= EncodedBytesLen - 1) {
						ExBytesIdx = (byte)(EncodedBytesLen - 1);
					}
				}

				if (i == ExBytesIdx) {
					continue;
				}

				byte ExtraBytes = EncodedBytes[ExBytesIdx];
				byte DecodedByte = (byte)(EncodedBytes[i] << 0x1);

				byte ShiftAmt = (byte)(6 - ((DataByteIdx++)));
				byte ExtraBit = (byte)((ExtraBytes >> ShiftAmt) & 0x1);
				DecodedByte |= ExtraBit;

				Decoded[DecodedIdx++] = DecodedByte;
				DataLen++;
			}

			return Decoded.Take(DataLen).ToArray();
		}

		static void Print(byte B, ConsoleColor Clr = ConsoleColor.Gray) {
			ConsoleColor Old = Console.ForegroundColor;
			Console.ForegroundColor = Clr;

			Console.WriteLine("{0:X2} - {1}", B, Convert.ToString(B, 2).PadLeft(8, '0'));

			Console.ForegroundColor = Old;
		}

		public static void UnitTest() {
			Random Rnd = new Random();

			for (int j = 0; j < 100000; j++) {
				byte[] TestData = new byte[Rnd.Next(0, 112)];

				if (j <= 111)
					TestData = new byte[j];

				Rnd.NextBytes(TestData);
				Console.Write("{0} ", TestData.Length);


				byte[] Encoded = Encode(TestData, (byte)TestData.Length);
				byte[] Decoded = Decode(Encoded, (byte)Encoded.Length);


				if (TestData.Length != Decoded.Length)
					throw new Exception("Invalid!");

				for (int i = 0; i < TestData.Length; i++) {
					if (TestData[i] != Decoded[i])
						throw new Exception("Invalid!");
				}
			}

			Console.WriteLine("Pass");
			Console.ReadLine();
		}
	}
}
