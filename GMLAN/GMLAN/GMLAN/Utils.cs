using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GMLAN {
	static class Utils {
		public static string PadRight(string In, int Len) {
			if (Len - In.Length < 0)
				return "";

			return In + new string(' ', Len - In.Length);
		}
	}
}
