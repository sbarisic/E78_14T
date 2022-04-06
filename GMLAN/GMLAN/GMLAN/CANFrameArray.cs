using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GMLAN {
    class CANFrameArray {
        public int HitCounter;

        CANFrame[] Frames;
        int Count;

        // 1 if difference in data, 0 else
        int Diff = 0;

        public CANFrameArray() {
            Frames = new CANFrame[4096];
            Count = 0;
            HitCounter = 0;
        }

        public void Push(CANFrame Frame) {
            HitCounter++;

            if (Count >= Frames.Length) {
                Array.Copy(Frames, 1, Frames, 0, Frames.Length - 1);
                Frames[Frames.Length - 1] = Frame;
            } else {
                Frames[Count++] = Frame;
            }

            if (CalcDiff() > 0)
                Diff = 1;
        }

        int CalcDiff() {
            byte[] SampleData = Frames[0].Data;

            for (int i = 1; i < Count; i++) {
                byte[] CurData = Frames[i].Data;

                if (SampleData.Length != CurData.Length)
                    return 1;

                for (int j = 0; j < CurData.Length; j++) {
                    if (CurData[j] != SampleData[j])
                        return 1;
                }
            }

            return 0;
        }

        public CANFrame GetLast() {
            return Frames[Count - 1];
        }

        public int HasDif() {
            return Diff;
        }
    }

}
