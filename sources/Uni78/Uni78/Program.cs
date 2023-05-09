using UnicornEngine;
using UnicornEngine.Binding;
using UnicornEngine.Const;
using System.IO;
using System;

namespace Uni78 {
	static class Program {
		static byte[] Firmware;

		static void Main(string[] args) {
			Console.WriteLine("Hello, World!");
			Firmware = File.ReadAllBytes("data/firm.bin");

			uint StartAddr = 0x20000; 
			uint EndAddr = 0x300000;

			Unicorn UC = new Unicorn(Common.UC_ARCH_PPC, Common.UC_MODE_PPC32 | Common.UC_MODE_BIG_ENDIAN);
			UC.MemMap(0, EndAddr, Common.UC_PROT_ALL);
			UC.MemWrite(0, Firmware);

			UC.AddCodeHook((uc, address, size, user_data) => {
				Console.WriteLine("CODE 0x{0:X} - {1}", address, size);
			}, null, 0, EndAddr);

			UC.EmuStart(StartAddr, 0, 0, 0);

			Console.WriteLine("Done!");
			Console.ReadLine();
		}
	}
}