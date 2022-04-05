using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GMLAN {
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

}
