using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace GMLAN {
	[StructLayout(LayoutKind.Explicit)]
	unsafe struct CANHeader {
		[FieldOffset(0)]
		public uint HeaderRaw;

		[FieldOffset(0)]
		public fixed byte HeaderBytes[4];


		public uint Unused {
			get {
				return (HeaderRaw & 0b11100000000000000000000000000000) >> 29;
			}
		}

		public uint Priority {
			get {
				if (IsExtended)
					return (HeaderRaw & 0b00011100000000000000000000000000) >> 26;
				else
					return 0;
			}
		}

		public uint ArbID {
			get {
				if (IsExtended)
					return (HeaderRaw & 0b00000011111111111110000000000000) >> 13;
				else
					return HeaderRaw & 0xFF;
			}
		}

		public uint ECU {
			get {
				if (IsExtended)
					return (HeaderRaw & 0b00000000000000000001111111111111);
				else
					return 0;
			}
		}

		public uint RequestType {
			get {
				if (IsExtended)
					return 0;
				else
					return (HeaderRaw >> 8) & 0b1111;
			}
		}

		public bool IsExtended {
			get {
				return ((Unused >> 2) & 0x1) == 0x1;
			}
		}

		public string ToBinary() {
			return Utils.ToBin(HeaderRaw, 32);
		}

		public override string ToString() {
			if (IsExtended) {
				return string.Format("UNUS(0x{4:X2}) PRI(0x{5:X2}) AID(0x{6:X4}) ECU(0x{7:X4}) - {8}", Utils.ToBin(Unused, 3), Utils.ToBin(Priority, 3), Utils.ToBin(ArbID, 13), Utils.ToBin(ECU, 13), Unused, Priority, ArbID, ECU, ECUName());
			} else {
				return string.Format("UNUS(0x{0:X2}) REQT(0x{1:X2}) ID(0x{2:X2})", Unused, RequestType, ArbID);
			}

		}

		public string ECUName() {
			string NameA = "";
			string NameB = "";

			uint ECUID = ECU;

			// NameA
			if (ECUID < 0x20)
				NameA = "Powertrain";
			else if (ECUID >= 0x20 && ECUID < 0x40)
				NameA = "Chassis";
			else if (ECUID >= 0x40 && ECUID <= 0xC7)
				NameA = "Body";
			else
				NameA = "?";

			// NameB
			if (ECUID >= 0x0 && ECUID <= 0x0f)
				NameB = "Integration/Expansion";
			else if (ECUID >= 0x10 && ECUID <= 0x17)
				NameB = "Engine";
			else if (ECUID >= 0x18 && ECUID <= 0x1F)
				NameB = "Transmission";
			else if (ECUID >= 0x20 && ECUID <= 0x27)
				NameB = "Integration/Expansion";
			else if (ECUID >= 0x28 && ECUID <= 0x2F)
				NameB = "Brake";
			else if (ECUID >= 0x30 && ECUID <= 0x37)
				NameB = "Steering";
			else if (ECUID >= 0x38 && ECUID <= 0x3F)
				NameB = "Suspension";
			else if (ECUID >= 0x40 && ECUID <= 0x57)
				NameB = "Integration/Expansion";
			else if (ECUID >= 0x58 && ECUID <= 0x5F)
				NameB = "Restraints";
			else if (ECUID >= 0x60 && ECUID <= 0x6F)
				NameB = "DriverInfo/Displays";
			else if (ECUID >= 0x70 && ECUID <= 0x7F)
				NameB = "Lighting";
			else if (ECUID >= 0x80 && ECUID <= 0x8F)
				NameB = "Entertainment/Audio";
			else if (ECUID >= 0x90 && ECUID <= 0x97)
				NameB = "PersonalCommunication";
			else if (ECUID >= 0x98 && ECUID <= 0x9F)
				NameB = "HVAC";
			else if (ECUID >= 0xA0 && ECUID <= 0xBF)
				NameB = "Convenience";
			else if (ECUID >= 0xC0 && ECUID <= 0xC7)
				NameB = "Security";
			else
				NameB = "?";

			return string.Format("({0}:{1})", NameA, NameB);
		}
	}

	struct CANFrame {
		public CANHeader Header;

		public uint ArbID;
		public byte[] Data;

		public CANFrame(CANHeader Header, byte[] Data) {
			if (Data.Length > 8)
				throw new Exception("Invalid data length");

			this.Header = Header;
			this.Data = Data;

			ArbID = Header.ArbID;

			// Extended ID
			/*if ((ID & 0x80000000) == 0x80000000) {
                IsExtendedID = true;
                this.ID = ID & 0x1FFFFFFF;
            } else {
                IsExtendedID = false;
                this.ID = ID;
            }

            // Remote request frame
            RemoteRequest = (ID & 0x40000000) == 0x40000000;*/

		}

		public override string ToString() {
			if (Data == null)
				return "Empty";

			return string.Format("0x{0:X2} Len {1}", ArbID, Data.Length);
		}
	}
}
