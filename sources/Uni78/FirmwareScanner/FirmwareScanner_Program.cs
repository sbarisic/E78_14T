using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace FirmwareScanner {
	internal class Program {
		static void FindBinaryPattern(byte[] Binary, string Pattern) {
		
		
		}

		static void Main(string[] args) {
			byte[] Firm = File.ReadAllBytes("data/firm.bin");

			FindBinaryPattern(Firm, "00AD00AD--KEK--WAT");


			Console.WriteLine("Done!");
			Console.ReadLine();



			RangeScanner RS = new RangeScanner();
			RS.SetBytes(Firm);

			// Stoich AFR
			//RS.SetOptions(0, 32, 0, 31.99951171875f);
			//RS.SetData("14.1298828125\t14.1298828125\t13.9853515625\t13.62744140625\t13.27001953125\t12.91259765625\t12.55517578125\t12.19775390625\t11.84033203125\t11.482421875\t11.125\t10.767578125\t10.41015625\t10.052734375\t9.69482421875\t9.33740234375\t8.97998046875");

			//RS.SetOptions(0, 256, 0, 255.9921875);
			//RS.SetData("0.67610204633553\t0.67610204633553\t0.67610204633553");

			// Offset vs Press vs IGNV
			//RS.SetOptions(0, 512, 0, 511.9921875);
			//RS.SetData("13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875\t13.96875");



			// Stoich AFR
			//RS.SetOptions(0, 32, 0, 31.99951171875f);
			//RS.SetData("14.1298828125\t14.1298828125\t13.9853515625\t13.62744140625\t13.27001953125\t12.91259765625\t12.55517578125\t12.19775390625\t11.84033203125\t11.482421875\t11.125\t10.767578125\t10.41015625\t10.052734375\t9.69482421875\t9.33740234375\t8.97998046875");

			


			//RS.SetOptions(0, 256, 0, 255.9921875f);
			//RS.SetData("0.75\t0.75\t0.75\t0.75\t0.75\t0.75\t0.75\t0.75");

			RS.FindAll();

			Console.WriteLine("Done!");
			Console.ReadLine();
		}
	}
}
