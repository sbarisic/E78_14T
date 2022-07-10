using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using System.IO;

namespace WindowsFormsApp1 {
    public partial class MainForm : Form {
        List<CustomSeries> AllSeries = new List<CustomSeries>();
        int MinRPM;
        int MaxRPM;

        public MainForm() {
            InitializeComponent();
        }

        void ClearSeries() {
            AllSeries.Clear();
            chart1.Series.Clear();
        }

        void LoadGraph(DynoDataPoint[] DynoPoints, string Name, Color ColorA, Color ColorB, Color ColorC) {
            foreach (DynoDataPoint Pt in DynoPoints) {
                if (Pt.RPM < MinRPM)
                    MinRPM = Pt.RPM;

                if (Pt.RPM > MaxRPM)
                    MaxRPM = Pt.RPM;
            }

            CustomSeries PowerSeries = CreateSeries(chart1, Name + " HP", ColorA, SeriesType.RPM);
            CustomSeries TorqueSeries = CreateSeries(chart1, Name + " Nm", ColorB, SeriesType.RPM);
            CustomSeries BoostSeries = CreateSeries(chart1, Name + " Boost x 100", ColorC, SeriesType.RPM);

            for (int i = 0; i < DynoPoints.Length; i++) {
                PowerSeries.Series.Points.AddXY(DynoPoints[i].RPM, DynoPoints[i].HP);
                TorqueSeries.Series.Points.AddXY(DynoPoints[i].RPM, DynoPoints[i].Nm);

                BoostSeries.Series.Points.AddXY(DynoPoints[i].RPM, DynoPoints[i].Boost * 100);
            }

            EnableSeries(SeriesType.RPM);
        }

        CustomSeries CreateSeries(Chart chrt, string Name, Color Clr, SeriesType SType) {
            Series series = chrt.Series.Add(Name);
            series.ChartType = SeriesChartType.Line; //SeriesChartType.Spline;
            series.Color = Clr;
            series.BorderWidth = 1;
            series.MarkerStyle = MarkerStyle.Circle;
            //series.SetCustomProperty("LineTension", "0.1");

            CustomSeries S = new CustomSeries(chrt, series, SType);
            AllSeries.Add(S);

            return S;
        }

        void EnableSeries(SeriesType SType) {
            foreach (CustomSeries S in AllSeries) {
                S.Series.Enabled = S.SeriesType == SType;
            }

            double XMin = 0;
            double XMax = 0;
            double XInterval = 0;

            switch (SType) {
                /*case SeriesType.Time:
					XMin = MinTime;
					XMax = MaxTime;
					XInterval = 1;
					break;*/

                case SeriesType.RPM:
                    XMin = MinRPM;
                    XMax = MaxRPM;
                    XInterval = 500;

                    break;

                default:
                    throw new NotImplementedException();
            }

            SetChart(chart1, XMin, XMax, XInterval, 10);
        }

        void SetChart(Chart Chrt, double XMin, double XMax, double XInterval, double YInterval) {
            Chrt.ChartAreas[0].AxisX.Minimum = XMin;
            Chrt.ChartAreas[0].AxisX.Maximum = XMax;
            Chrt.ChartAreas[0].AxisX.Interval = XInterval;
            Chrt.ChartAreas[0].AxisY.Interval = YInterval;
            Chrt.ResetAutoValues();
        }

        private void MainForm_Load(object sender, EventArgs e) {
            MinRPM = 99999;
            MaxRPM = 0;

            ColorScheme[] ColorSchemes = new[] {
                new ColorScheme(Color.Red,Color.Blue,Color.DarkCyan),
                new ColorScheme(Color.DarkRed,Color.DarkBlue,Color.Cyan),
            };

            int ColorIdx = 0;

            foreach (string InFiles in Program.InFiles) {
                string FileName = Path.GetFileNameWithoutExtension(InFiles);

                ColorScheme CS = ColorSchemes[ColorIdx++];
                LoadGraph(Program.ParseEntriesHPT(InFiles), FileName, CS.ColorA, CS.ColorB, CS.ColorC);
            }

            //LoadGraph(Program.ParseEntriesHPT("a.csv"), "a", Color.Red, Color.Blue, Color.DarkCyan);
            //LoadGraph(Program.ParseEntriesHPT("b.csv"), "b", Color.FromArgb(200, 50, 60), Color.FromArgb(50, 160, 200), Color.FromArgb(150, 50, 200));

            /*DynoDataPoint[] Hypothetical = Program.ParseEntriesHPT("corsa2019_run1.csv");
			Program.TamperNM(Hypothetical, 4500, 260);

			LoadGraph(Hypothetical, "Hyp", Color.FromArgb(200, 50, 60), Color.FromArgb(50, 160, 200), Color.DarkCyan);*/
        }
    }

    class CustomSeries {
        public Chart Chart;
        public Series Series;
        public SeriesType SeriesType;

        public CustomSeries(Chart Chart, Series Series, SeriesType SeriesType) {
            this.Chart = Chart;
            this.Series = Series;
            this.SeriesType = SeriesType;
        }
    }

    enum SeriesType {
        Time,
        RPM
    }

    class ColorScheme {
        public Color ColorA;
        public Color ColorB;
        public Color ColorC;

        public ColorScheme(Color ColorA, Color ColorB, Color ColorC) {
            this.ColorA = ColorA;
            this.ColorB = ColorB;
            this.ColorC = ColorC;
        }
    }
}
