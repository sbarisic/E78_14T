using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace GMLAN {
	[StructLayout(LayoutKind.Explicit)]
	unsafe struct CAN_ArbID {
		[FieldOffset(0)]
		public uint ID;

		[FieldOffset(0)]
		public fixed byte Data[4];
	}

	struct CANFrame {
		public uint ID;
		public byte[] Data;

		public bool IsExtendedID;
		public bool RemoteRequest;

		public CANFrame(uint ID, byte[] Data) {
			if (Data.Length > 8)
				throw new Exception("Invalid data length");

			// Extended ID
			if ((ID & 0x80000000) == 0x80000000) {
				IsExtendedID = true;
				this.ID = ID & 0x1FFFFFFF;
			} else {
				IsExtendedID = false;
				this.ID = ID;
			}

			// Remote request frame
			RemoteRequest = (ID & 0x40000000) == 0x40000000;

			this.Data = Data;
		}

		public override string ToString() {
			if (Data == null)
				return "Empty";

			return string.Format("0x{0:X2} Len {1}", ID, Data.Length);
		}
	}
}
