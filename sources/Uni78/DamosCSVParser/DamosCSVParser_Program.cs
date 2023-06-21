using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Windows.Forms;

namespace DamosCSVParser {
	internal class Program {

		[STAThread]
		static void Main(string[] args) {
			Damos D = new Damos("data/winols_astra.csv");

			File.WriteAllLines("Lines.txt", D.Entries.Select(E => E.ToString()).ToArray());
		}
	}
}
