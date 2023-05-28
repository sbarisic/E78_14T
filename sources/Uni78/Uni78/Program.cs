using UnicornEngine;
using UnicornEngine.Binding;
using UnicornEngine.Const;
using System.IO;
using System;

namespace Uni78 {
    static class Program {
        static byte[] Firmware;

        static string FmtInstr(long Addr, long Size) {
            string Txt = "";

            for (int i = 0; i < Size; i++) {
                Txt += string.Format("{0:X2} ", Firmware[Addr + i]);
            }

            return Txt.Trim();
        }

        static void Main(string[] args) {
            Console.WriteLine("Hello, World!");
            Firmware = File.ReadAllBytes("data/firm.bin");

            uint StartAddr = 0xCB560; // 0x002FDFE8; // 0x20000;
            uint EndAddr =   0x300000;

            Unicorn UC = new Unicorn(Common.UC_ARCH_PPC, Common.UC_MODE_PPC32 | Common.UC_MODE_BIG_ENDIAN);

            UC.MemMap(0, EndAddr, Common.UC_PROT_ALL);
            UC.MemMap(0xFFF00000, 0xFFF0000, Common.UC_PROT_ALL);

            UC.MemWrite(0, Firmware);

            UC.AddInterruptHook((uc, instr, user_data) => {
                Console.WriteLine("INTER 0x{0:X}", instr);
            }, null, 0, EndAddr);


            UC.AddCodeHook((uc, address, size, user_data) => {
                Console.WriteLine("CODE  0x{0:X} - {1}", address, FmtInstr(address, size));
            }, null, 0, EndAddr);


            UC.AddBlockHook((uc, address, size, user_data) => {
                Console.WriteLine("BLOCK 0x{0:X} - {1}", address, size);
            }, null, 0, EndAddr);


            UC.AddMemReadHook((uc, address, size, user_data) => {
                Console.WriteLine("READ  0x{0:X} - {1}", address, size);
            }, null, 0, long.MaxValue);


            UC.AddMemWriteHook((uc, address, size, val, user_data) => {
                Console.WriteLine("WRITE 0x{0:X} - sz({1}) val({2})", address, size, val);
            }, null, 0, long.MaxValue);


            UC.EmuStart(StartAddr, 0, 0, 0);

            Console.WriteLine("Done!");
            Console.ReadLine();
        }
    }
}