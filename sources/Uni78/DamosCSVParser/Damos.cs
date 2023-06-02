using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Reflection.Emit;

namespace DamosCSVParser {
	class DamosEntry {
		string[] Entries;

		public DamosEntry() {

		}

		int TitleToIdx(string Title) {
			for (int i = 0; i < Damos.Titles.Length; i++) {
				if (Damos.Titles[i] == Title)
					return i;
			}

			throw new KeyNotFoundException();
		}

		public string this[string Title] {
			get {
				return Entries[TitleToIdx(Title)];
			}

			set {
				Entries[TitleToIdx(Title)] = value;
			}
		}

		public void SetAll(string[] Entries) {
			this.Entries = Entries;
		}

		public override string ToString() {
			return Entries[TitleToIdx(DamosNames.Name)];
		}
	}


	class Damos {
		public static string[] Titles;

		string[] SrcLines;
		DamosEntry[] Entries;



		public Damos(string SrcFile) {
			SrcLines = File.ReadAllLines(SrcFile);
			Titles = SrcLines[0].Split(new[] { ';' });

			List<DamosEntry> DamosEntries = new List<DamosEntry>();

			for (int i = 1; i < SrcLines.Length; i++) {
				DamosEntry Ent = new DamosEntry();
				Ent.SetAll(SrcLines[i].Split(new[] { ';' }));
				DamosEntries.Add(Ent);
			}

			Entries = DamosEntries.ToArray();
		}
	}
}
