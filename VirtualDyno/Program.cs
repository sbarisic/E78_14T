using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Globalization;

namespace WindowsFormsApp1 {
	internal static class Program {
		public static string[] InFiles;

		[STAThread]
		static void Main(string[] Args) {
			InFiles = Args;
			Application.EnableVisualStyles();
			Application.SetCompatibleTextRenderingDefault(false);
			Application.Run(new MainForm());
		}

		public static void TamperNM(DynoDataPoint[] Points, int FromRPM, int NewNM) {
			for (int i = 0; i < Points.Length; i++) {
				if (Points[i].RPM >= FromRPM) {
					Points[i].Nm = NewNM;
				}
			}
		}

		public static DynoDataPoint[] ParseEntriesHPT(string CSVFile) {
			string[] Lines = File.ReadAllText(CSVFile).Trim().Split(new[] { '\n' }).Select(L => L.Trim()).ToArray();

			int ChannelInfoIdx = FindIndex(Lines, "[Channel Information]");
			int ChannelDataIdx = FindIndex(Lines, "[Channel Data]");

			string[] ChannelInfo = Lines.Skip(ChannelInfoIdx + 1).Take(ChannelDataIdx - ChannelInfoIdx - 1).ToArray();
			string[] InfoNames = ChannelInfo[1].Split(new[] { ',' }).ToArray();

			int RPMIdx = -1;
			int AirflowIdx = -1;
			int BoostIdx = -1;
			int BaroIdx = -1;

			for (int i = 0; i < InfoNames.Length; i++) {
				if (InfoNames[i].Contains("Engine RPM"))
					RPMIdx = i;

				if (InfoNames[i].Contains("Mass Airflow (SAE)"))
					AirflowIdx = i;

				if (InfoNames[i].Contains("Boost Pressure"))
					BoostIdx = i;

				if (InfoNames[i].Contains("Barometric"))
					BaroIdx = i;
			}

			List<DynoDataPoint> DynoPointsList = new List<DynoDataPoint>();

			string[][] DataLines = Lines.Skip(ChannelDataIdx + 1).Select(L => L.Split(',')).ToArray();
			for (int i = 0; i < DataLines.Length; i++) {
				DynoDataPoint Point = new DynoDataPoint(DataLines[i][RPMIdx], DataLines[i][AirflowIdx], DataLines[i][BoostIdx], DataLines[i][BaroIdx]);
				bool Appended = false;

				foreach (DynoDataPoint ExPoint in DynoPointsList) {
					if (ExPoint.RPM == Point.RPM) {
						ExPoint.AppendAverage(Point);
						Appended = true;
						break;
					}
				}

				if (!Appended) {
					DynoPointsList.Add(Point);
				}
			}

			return DynoPointsList.OrderBy(P => P.RPM).ToArray();
		}

		static int FindIndex(string[] Lines, string Src) {
			for (int i = 0; i < Lines.Length; i++) {
				if (Lines[i] == Src)
					return i;
			}

			return 0;
		}
	}

	class DynoDataPoint {
		const float SomeConstant = 0.76f;

		public int RPM;
		public float Airflow;
		public float Boost;
		public float Baro;

		public float Nm {
			get {
				return (float)Math.Round(((CalcHP * 5252) / RPM) * 1.35581795f);
			}

			set {
				float FTLBS = value / 1.35581795f;
				float A = FTLBS * RPM;
				float NewHP = A / 5252;
				Airflow = NewHP * SomeConstant;
			}
		}

		public float HP {
			get {
				return (float)Math.Round(CalcHP);
			}
		}

		float CalcHP {
			get {
				return Airflow / SomeConstant;
			}
		}

		public DynoDataPoint(string RPM, string Airflow, string Boost, string Baro) {
			this.RPM = (int)double.Parse(RPM, CultureInfo.InvariantCulture);

			this.Airflow = (float)double.Parse(Airflow, CultureInfo.InvariantCulture);
			this.Baro = (float)(double.Parse(Baro, CultureInfo.InvariantCulture) / 100);
			this.Boost = (float)Math.Round((double.Parse(Boost, CultureInfo.InvariantCulture) / 100) - this.Baro, 2);
		}

		public void AppendAverage(DynoDataPoint Other) {
			Airflow = (Airflow + Other.Airflow) / 2;
			Boost = (Boost + Other.Boost) / 2;
			Baro = (Baro + Other.Baro) / 2;
		}

		public override string ToString() {
			return string.Format("{0} - {1} g/s, {2} bar; {3} Hp, {4} Nm", RPM, Airflow, Boost, HP, Nm);
		}
	}
}