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

			RangeScanner RS = new RangeScanner();
			RS.SetBytes(Firm);

			// Short pulse adder
			//RS.SetOptions(-256, 256, -256, 255.9921875f);
			//RS.SetData("5.75\t4.375\t3.125\t1.875\t1.125\t0.625\t0.25\t0.125\t0\t-0.125\t-0.125\t-0.25\t-0.25\t-0.25\t-0.25\t-0.25\t-0.25\t-0.25\t-0.25\t-0.25\t-0.125\t-0.125\t-0.125\t-0.125\t-0.125\t-0.125");

			// Stoich AFR
			RS.SetOptions(0, 32, 0, 31.99951171875f);
			RS.SetData("14.1298828125\t14.1298828125\t13.9853515625\t13.62744140625\t13.27001953125\t12.91259765625\t12.55517578125\t12.19775390625\t11.84033203125\t11.482421875\t11.125\t10.767578125\t10.41015625\t10.052734375\t9.69482421875\t9.33740234375\t8.97998046875");


			RS.FindAll();

			Console.WriteLine("Done!");
			Console.ReadLine();
		}
	}
}
