using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;
using System.IO;
using System.Threading;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace GMLAN {
    static class Utils {
        public static string PadRight(string In, int Len) {
            if (Len - In.Length < 0)
                return "";

            return In + new string(' ', Len - In.Length);
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    unsafe struct CAN_ArbID {
        [FieldOffset(0)]
        public uint ID;

        [FieldOffset(0)]
        public fixed byte Data[4];
    }

    struct CANFrame {
        public uint ID;
        public byte[] Data;

        public bool IsExtendedID;
        public bool RemoteRequest;

        public CANFrame(uint ID, byte[] Data) {
            // Extended ID
            if ((ID & 0x80000000) == 0x80000000) {
                IsExtendedID = true;
                this.ID = ID & 0x1FFFFFFF;
            } else {
                IsExtendedID = false;
                this.ID = ID;
            }

            // Remote request frame
            RemoteRequest = (ID & 0x40000000) == 0x40000000;

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
                if (Frame.ID > 4008)
                    return;

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

    internal unsafe static class Program {
        static Random Rnd = new Random();
        static CANPacketList CANList;

        static void Main(string[] args) {
            CANList = new CANPacketList();
            Stopwatch SWatch = Stopwatch.StartNew();

            if (File.Exists("filter.dat")) {
                string[] FiltLines = File.ReadAllLines("filter.dat").Select(L => L.Trim()).ToArray();
                List<uint> FiltIDs = new List<uint>();

                for (int i = 0; i < FiltLines.Length; i++) {
                    if (FiltLines[i].Trim().Length > 0) {
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
            string[] CapLines = File.ReadAllLines("test_capture.txt");

            for (int i = 0; i < CapLines.Length; i++) {
                string Line = CapLines[i];

                uint ID = Convert.ToUInt32(Line.Substring(15, 3), 16);
                byte[] Data = Line.Substring(39, Line.Length - 39).Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Select(B => Convert.ToByte(B.Replace("0x", ""), 16)).ToArray();

                CANList.AddFrame(new CANFrame(ID, Data));
            }

            return;

            /*
            uint[] IDs = new uint[] { 0x0, 0x1, 0x6, 0x3, 0xA0, 0xB5, 0x11, 0xFF, 0xA1F, 0x8F4, 0x100, 0x242, 0xFFFF, 0x51FA, 0x2612, 0xBAAB };

            while (true) {
                Thread.Sleep(1);

                byte[] Arr = new byte[Rnd.Next(1, 9)];
                Rnd.NextBytes(Arr);

                CANList.AddFrame(new CANFrame(IDs[Rnd.Next(0, IDs.Length)], Arr));
            }

            // test ^*/



            SerialPort InPort = new SerialPort("COM9", 2000000);
            Console.WriteLine("Waiting for COM9");
            bool Open = false;

            while (!Open) {
                try {
                    InPort.Open();
                    Open = true;
                } catch (Exception) {
                }

                Thread.Sleep(1000);
            }

            InPort.DiscardInBuffer();
            InPort.DiscardOutBuffer();

            bool BinaryMode = false;

            CAN_ArbID ArbID = new CAN_ArbID();
            byte[] Buffer = new byte[256];

            while (true) {
                if (BinaryMode) {

                    // Source
                    byte CANSrc = (byte)InPort.ReadByte();

                    // ArbID
                    for (int i = 0; i < 4; i++)
                        ArbID.Data[i] = (byte)InPort.ReadByte();

                    // Data
                    byte Len = (byte)InPort.ReadByte();
                    for (int i = 0; i < Len; i++) {
                        Buffer[i] = (byte)InPort.ReadByte();
                    }

                    /*Console.Write("[{0}] {1:X8} - ", CANSrc, ArbID.ID);
					for (int i = 0; i < Len; i++) {
						Console.Write("{0:X2} ", Buffer[i]);
					}
					Console.WriteLine();*/

                    CANList.AddFrame(new CANFrame(ArbID.ID, Buffer.Take(Len).ToArray()));

                } else {
                    string Ln = InPort.ReadLine();
                    Console.WriteLine(Ln);

                    if (Ln.Trim() == "READY")
                        InPort.Write(new byte[] { 0x42 }, 0, 1);

                    if (Ln.Trim() == "SWITCHBIN")
                        BinaryMode = true;
                }
            }
        }
    }
}