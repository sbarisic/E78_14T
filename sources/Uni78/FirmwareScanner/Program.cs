using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace FirmwareScanner {
	internal class Program {
		static void Main(string[] args) {
			byte[] Firm = File.ReadAllBytes("data/firm.bin");

			RangeScanner RS = new RangeScanner("", "");
			

		}
	}
}
