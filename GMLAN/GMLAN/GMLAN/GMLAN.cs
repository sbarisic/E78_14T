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
	internal unsafe static class Program {
		static Random Rnd = new Random();
		static CANPacketList CANList;
		static SerialPort InputPort;

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

		static byte ReadByte() {
			return (byte)InputPort.ReadByte();
		}

		static void ListenThread() {
			/*string[] CapLines = File.ReadAllLines("test_capture.txt");

            for (int i = 0; i < CapLines.Length; i++) {
                string Line = CapLines[i];

                uint ID = Convert.ToUInt32(Line.Substring(15, 3), 16);
                byte[] Data = Line.Substring(39, Line.Length - 39).Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Select(B => Convert.ToByte(B.Replace("0x", ""), 16)).ToArray();

                CANList.AddFrame(new CANFrame(ID, Data));
            }

            return;*/

			/*
            uint[] IDs = new uint[] { 0x0, 0x1, 0x6, 0x3, 0xA0, 0xB5, 0x11, 0xFF, 0xA1F, 0x8F4, 0x100, 0x242, 0xFFFF, 0x51FA, 0x2612, 0xBAAB };

            while (true) {
                Thread.Sleep(1);

                byte[] Arr = new byte[Rnd.Next(1, 9)];
                Rnd.NextBytes(Arr);

                CANList.AddFrame(new CANFrame(IDs[Rnd.Next(0, IDs.Length)], Arr));
            }

            // test ^*/



			InputPort = new SerialPort("COM9", 2000000);
			Console.WriteLine("Waiting for COM9");
			bool Open = false;

			while (!Open) {
				try {
					InputPort.Open();
					Open = true;
				} catch (Exception) {
				}

				Thread.Sleep(1000);
			}

			InputPort.DiscardInBuffer();
			InputPort.DiscardOutBuffer();

			bool BinaryMode = false;

			CAN_ArbID ArbID = new CAN_ArbID();
			byte[] Buffer = new byte[256];

			while (true) {
				if (BinaryMode) {
					// Source
					byte CANSrc = ReadByte();

					// ArbID
					for (int i = 0; i < 4; i++)
						ArbID.Data[i] = ReadByte();

					// Data
					byte Len = ReadByte();
					for (int i = 0; i < Len; i++) {
						Buffer[i] = ReadByte();
					}

					CANFrame Frame = new CANFrame(ArbID.ID, Buffer.Take(Len).ToArray());

					CANList.AddFrame(Frame);

				} else {
					string Ln = InputPort.ReadLine();
					Console.WriteLine(Ln);

					if (Ln.Trim() == "READY")
						InputPort.Write(new byte[] { 0x42 }, 0, 1);

					if (Ln.Trim() == "SWITCHBIN") {
						Console.Clear();
						BinaryMode = true;
					}
				}
			}
		}
	}
}