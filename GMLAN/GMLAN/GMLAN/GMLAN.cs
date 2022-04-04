using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;
using System.IO;
using System.Threading;
using System.Diagnostics;

namespace GMLAN {
    static class Utils {
        public static string PadRight(string In, int Len) {
            return In + new string(' ', Len - In.Length);
        }
    }

    struct CANFrame {
        public uint ID;
        public byte[] Data;

        public bool IsExtendedID {
            get {
                return ID > 0x7FF;
            }
        }

        public CANFrame(uint ID, byte[] Data) {
            if (Data.Length > 8)
                throw new Exception("Invalid data length");

            this.ID = ID;
            this.Data = Data;
        }

        public override string ToString() {
            if (Data == null)
                return "Empty";

            return string.Format("0x{0:X2} Len {1}", ID, Data.Length);
        }
    }

    class CANFrameArray {
        public int HitCounter;

        CANFrame[] Frames;
        int Count;

        public CANFrameArray() {
            Frames = new CANFrame[4096];
            Count = 0;
            HitCounter = 0;
        }

        public void Push(CANFrame Frame) {
            HitCounter++;

            if (Count >= Frames.Length) {
                Array.Copy(Frames, 1, Frames, 0, Frames.Length - 1);
                Frames[Frames.Length - 1] = Frame;
            } else {
                Frames[Count++] = Frame;
            }
        }

        public CANFrame GetLast() {
            return Frames[Count - 1];
        }

        public bool AllDataSame() {
            byte[] SampleData = Frames[0].Data;

            for (int i = 1; i < Count; i++) {
                byte[] CurData = Frames[i].Data;

                if (SampleData.Length != CurData.Length)
                    return false;

                for (int j = 0; j < CurData.Length; j++) {
                    if (CurData[j] != SampleData[j])
                        return false;
                }
            }

            return true;
        }
    }

    class CANPacketList {
        Dictionary<uint, CANFrameArray> Frames = new Dictionary<uint, CANFrameArray>();
        Dictionary<uint, string> Descs = new Dictionary<uint, string>();

        public bool PrintDirty;
        public uint[] FilterIDs;

        public CANPacketList() {
            Frames = new Dictionary<uint, CANFrameArray>();
            Descs = new Dictionary<uint, string>();

            uint[] ArbIDs = File.ReadAllLines("arb_id.dat").Select(L => Convert.ToUInt32(L.Replace("0x", "").Trim(), 16)).ToArray();
            string[] DescLines = File.ReadAllLines("arb_id_desc.dat");

            for (int i = 0; i < ArbIDs.Length; i++) {
                Descs.Add(ArbIDs[i], DescLines[i]);
            }
        }

        public void AddFrame(CANFrame Frame) {
            lock (this) {
                if (FilterIDs != null && FilterIDs.Contains(Frame.ID))
                    return;

                if (!Frames.ContainsKey(Frame.ID)) {
                    Frames.Add(Frame.ID, new CANFrameArray());
                }

                Frames[Frame.ID].Push(Frame);
                PrintDirty = true;
            }
        }

        List<string> SaveIDLines = new List<string>();

        public void PrettyPrint() {
            lock (this) {
                if (PrintDirty) {
                    PrintDirty = false;

                    int[] ColSizes = new int[] { 10, 30, 7, 7, 65 };
                    int ColIdx = 0;


                    Console.SetCursorPosition(0, 0);
                    SaveIDLines.Clear();

                    ConsoleWriteLine(
                        Utils.PadRight("ID", ColSizes[ColIdx++]) +
                        Utils.PadRight("Data", ColSizes[ColIdx++]) +
                        Utils.PadRight("Cnt", ColSizes[ColIdx++]) +
                        Utils.PadRight("Same", ColSizes[ColIdx++]) +
                        Utils.PadRight("Desc", ColSizes[ColIdx++])
                        );

                    ConsoleWriteLine(new string('-', ColSizes.Sum()));

                    foreach (var KV in Frames.OrderBy(KV => KV.Key)) {
                        ColIdx = 0;
                        ConsoleWrite(Utils.PadRight(string.Format("{0:X}", KV.Key), ColSizes[ColIdx++]));

                        CANFrame LastFrame = KV.Value.GetLast();

                        string DataStr = "";
                        for (int i = 0; i < LastFrame.Data.Length; i++) {
                            DataStr += string.Format("{0:X2} ", LastFrame.Data[i]);
                        }

                        // Data
                        ConsoleWrite(Utils.PadRight(DataStr, ColSizes[ColIdx++]));

                        // Hit counter
                        ConsoleWrite(Utils.PadRight(KV.Value.HitCounter.ToString(), ColSizes[ColIdx++]));

                        // Data same
                        ConsoleWrite(Utils.PadRight(KV.Value.AllDataSame().ToString(), ColSizes[ColIdx++]));

                        // Desc
                        if (Descs.ContainsKey(KV.Key))
                            ConsoleWrite(Utils.PadRight(Descs[KV.Key], ColSizes[ColIdx++]));
                        else
                            ConsoleWrite(Utils.PadRight(".", ColSizes[ColIdx++]));

                        ConsoleWriteLine();
                    }

                    ConsoleWriteLine(new string('-', ColSizes.Sum()));
                    File.WriteAllLines("output.txt", SaveIDLines.ToArray());
                }
            }
        }

        void ConsoleWrite(string Str) {
            if (SaveIDLines.Count == 0)
                SaveIDLines.Add(Str);
            else
                SaveIDLines[SaveIDLines.Count - 1] += Str;

            Console.Write(Str);
        }

        void ConsoleWriteLine(string Str = "") {
            if (SaveIDLines.Count == 0) {
                SaveIDLines.Add(Str);
                SaveIDLines.Add("");
            } else {
                SaveIDLines[SaveIDLines.Count - 1] += Str;
                SaveIDLines.Add("");
            }

            Console.WriteLine(Str);
        }
    }

    internal class Program {
        static Random Rnd = new Random();
        static CANPacketList CANList;

        static void Main(string[] args) {
            CANList = new CANPacketList();
            Stopwatch SWatch = Stopwatch.StartNew();

            if (File.Exists("filter.dat")) {
                string[] FiltLines = File.ReadAllLines("filter.dat").Select(L => L.Trim()).ToArray();
                List<uint> FiltIDs = new List<uint>();

                for (int i = 0; i < FiltLines.Length; i++) {
                    if (FiltLines[i].StartsWith("0x")) {
                        FiltIDs.Add(Convert.ToUInt32(FiltLines[i].Replace("0x", "").Trim(), 16));
                    }
                }

                if (FiltIDs.Count > 0)
                    CANList.FilterIDs = FiltIDs.ToArray();
            }

            Thread ListenThrd = new Thread(ListenThread);
            ListenThrd.IsBackground = true;
            ListenThrd.Start();

            while (true) {
                if (SWatch.ElapsedMilliseconds > 100) {
                    SWatch.Restart();

                    CANList.PrettyPrint();
                }
            }
        }

        static void ListenThread() {
            uint[] IDs = new uint[] { 0x0, 0x1, 0x6, 0x3, 0xA0, 0xB5, 0x11, 0xFF, 0xA1F, 0x8F4, 0x100, 0x242, 0xFFFF, 0x51FA, 0x2612, 0xBAAB };

            while (true) {
                Thread.Sleep(1);

                byte[] Arr = new byte[Rnd.Next(1, 9)];
                Rnd.NextBytes(Arr);

                CANList.AddFrame(new CANFrame(IDs[Rnd.Next(0, IDs.Length)], Arr));
            }
        }
    }
}