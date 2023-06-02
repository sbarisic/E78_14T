using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Globalization;

namespace FirmwareScanner {
    class RangeScanner {
        byte[] Bytes;
        byte[] BytesToScan;

        double RangeMinInclusive;
        double RangeMaxInclusive;
        double Step;
        ulong Range;
        ulong MaxVal;
        uint Bits;

        public RangeScanner() {
        }

        public void SetOptions(double RangeMinInclusive, double RangeMaxInclusive, double MinValue, double MaxValue) {
            this.RangeMinInclusive = RangeMinInclusive;
            this.RangeMaxInclusive = RangeMaxInclusive;
            Range = (ulong)(RangeMaxInclusive - RangeMinInclusive);
            Step = RangeMaxInclusive - MaxValue;
            MaxVal = (uint)(Range / Step);
            Bits = (uint)(Math.Log(MaxVal) / Math.Log(2));

            // ConvertToBytes(0, out byte[] ValBytes1);
            // ConvertToBytes(255.9921875f, out byte[] ValBytes2);
            // ConvertToBytes(-256, out byte[] ValBytes3);
        }

        public void SetOptions2(double RangeMinInclusive, double RangeMaxInclusive, double Step) {
            this.RangeMinInclusive = RangeMinInclusive;
            this.RangeMaxInclusive = RangeMaxInclusive;
            Range = (ulong)(RangeMaxInclusive - RangeMinInclusive);

            this.Step = Step;
            MaxVal = (uint)(Range / Step);
            Bits = (uint)(Math.Log(MaxVal) / Math.Log(2));
        }

        byte[] ConvertToBytes(double Val) {
            double UVal = Val - RangeMinInclusive;
            uint UIntVal = (uint)(UVal / Range * MaxVal);
            double CheckNumber = (UIntVal * Step) + RangeMinInclusive;

            byte[] Ret = null;

            if (Bits == 8) {
                Ret = new byte[] { (byte)UIntVal };
            } else if (Bits == 16) {
                Ret = BitConverter.GetBytes((ushort)UIntVal);
            } else if (Bits == 32) {
                Ret = BitConverter.GetBytes((uint)UIntVal);
            } else {
                throw new NotImplementedException();
            }

            return Ret.Reverse().ToArray();
        }

        double ParseNumber(string Num) {
            return double.Parse(Num, CultureInfo.InvariantCulture);
        }

        public void SetBytes(byte[] Bytes) {
            this.Bytes = Bytes;
        }

        public void SetData(string Data) {
            string[] StringNumbers = Data.Split(new char[] { '\t' }, StringSplitOptions.RemoveEmptyEntries);
            double[] DoubleNumbers = StringNumbers.Select(ParseNumber).ToArray();

            string ExcelString = string.Join("\t", DoubleNumbers.Select(DN => DN.ToString()));

            if (Data != ExcelString) {
                Console.WriteLine("[WARN] Data does not match");
            }

            BytesToScan = DoubleNumbers.SelectMany(F => ConvertToBytes(F)).ToArray();
        }


        public void FindAll() {
            int[] Offsets = PatternAt(0, Bytes, BytesToScan).ToArray();

            for (int i = 0; i < Offsets.Length; i++) {
                Console.WriteLine("0x{0:X4} ({0}) - MATCH (len {1})", Offsets[i], BytesToScan.Length);
            }
        }

        static IEnumerable<int> PatternAt(int Start, byte[] Src, byte[] Pattern) {
            for (int i = Start; i < Src.Length; i++) {
                bool Matches = true;

                for (int j = 0; j < Pattern.Length; j++) {
                    int Idx = i + j;

                    if (Idx >= Src.Length) {
                        Matches = false;
                        break;
                    }

                    if (Src[Idx] != Pattern[j]) {
                        Matches = false;
                        break;
                    }
                }

                if (Matches) {
                    yield return i;
                }


                /*if (Src.Skip(i).Take(Pattern.Length).SequenceEqual(Pattern)) {
					yield return i;
				}*/
            }
        }
    }
}
