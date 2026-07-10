#!/usr/bin/env python3
"""Conservative recursive 68HC11 disassembler for the Peugeot IAW 8P.40 image.

This reproduces the core generic listing and basic code-range CSV. The reviewed
annotations, symbols, call graph, vector report, binary-difference report, and
prose report in this folder are snapshot artifacts produced by a separate
annotation/reporting process that is not included here.

Requires:
    pip install capstone>=5

The default executable spans and evidence-backed seeds are specific to the
Peugeot 106 image whose reset vector is 0xB800. Other IAW 8P.40 builds should
be mapped independently rather than assuming identical addresses.
"""
from __future__ import annotations
import argparse
import collections
import csv
import hashlib
import re
from pathlib import Path
try:
    from capstone import Cs, CS_ARCH_M680X, CS_MODE_M680X_6811
except ModuleNotFoundError as exc:
    raise SystemExit(
        "capstone>=5 is required; install it with: python -m pip install 'capstone>=5'"
    ) from exc

ALLOWED = ((0x4000, 0x8000), (0x9315, 0xB600), (0xB800, 0xFFD6))
EXTRA_SEEDS = {
    0x4017,0x4034,0x4079,0x409C,0x40A8,0x431A,0x436A,0x4421,0x48EE,
    0x4F10,0x4FE1,0x506A,0x50F4,0x515C,0x51CC,0x51FB,0x5224,0x5243,
    0x5290,0x52DD,0x5320,0x5361,0x53A9,0x5419,0x545F,0x546B,0x5497,
    0x54A3,0x54B6,0x54C8,0x54EB,0x54FE,0x5652,0x5AD6,0x67A3,
    0x6E96,0x6EEE,0x6F01,0x7392,0x7660,0x956B,
    0x9F02,0xA696,0xA6E5,0xAAD0,0xAAE0,0xB26E,0xB2AB,0xB2BA,0xB2D6,0xB32B,
    0xB383,0xB3B9,0xB447,0xB555,0xB800,0xBA5D,0xBB98,0xBE65,0xC000,
    0xC94B,0xCBEF,0xCC00,0xD17D,0xD2D9,0xD46D,0xD482,0xD6AC,0xE38B,
    0xE5E8,0xE652,0xE715,0xE748,0xE84B,0xE927,0xE9A8,
}
CALLS={"jsr","bsr"}
CONDS={"bhi","bne","bls","bvs","brclr","ble","bcc","brn","bgt","blt",
       "blo","bmi","bpl","beq","bhs","bge","bcs","bvc","brset"}
RETURNS={"rts","rti","swi","wai","stop"}
HEX_RE=re.compile(r"\$([0-9a-fA-F]+)")

def allowed(addr:int)->bool:
    return any(lo <= addr < hi for lo,hi in ALLOWED)

def target(ins):
    vals=HEX_RE.findall(ins.op_str)
    return int(vals[-1],16) if vals else None

def disassemble(data:bytes, seeds:set[int]):
    md=Cs(CS_ARCH_M680X, CS_MODE_M680X_6811)
    md.detail=True
    q=collections.deque(sorted(seeds))
    inst={}
    starts=set(seeds)
    xrefs=collections.defaultdict(set)
    while q:
        pc=q.popleft()
        if not allowed(pc):
            continue
        while allowed(pc) and pc not in inst:
            got=list(md.disasm(data[pc:pc+8],pc,count=1))
            if not got:
                break
            ins=got[0]
            if not allowed(pc+ins.size-1):
                break
            inst[pc]=ins
            nxt=pc+ins.size
            m=ins.mnemonic.lower()
            if m in CALLS:
                t=target(ins)
                if t is not None and allowed(t):
                    xrefs[t].add((pc,"call"))
                    if t not in starts:
                        starts.add(t); q.append(t)
                pc=nxt; continue
            if m=="jmp" or m=="bra":
                t=target(ins)
                if t is not None and allowed(t):
                    xrefs[t].add((pc,"jump" if m=="jmp" else "branch"))
                    if t not in starts:
                        starts.add(t); q.append(t)
                break
            if m in CONDS:
                t=target(ins)
                if t is not None and allowed(t):
                    xrefs[t].add((pc,"branch"))
                    if t not in starts:
                        starts.add(t); q.append(t)
                pc=nxt; continue
            if m in RETURNS:
                break
            pc=nxt
    return inst,xrefs

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("bin",type=Path)
    ap.add_argument("--asm",type=Path,default=Path("reachable.asm"))
    ap.add_argument("--ranges",type=Path,default=Path("code_ranges.csv"))
    ns=ap.parse_args()
    data=ns.bin.read_bytes()
    if len(data)!=0x10000:
        raise SystemExit(f"expected 65536 bytes, got {len(data)}")
    vectors={int.from_bytes(data[a:a+2],"big") for a in range(0xFFD6,0x10000,2)}
    inst,xrefs=disassemble(data,vectors|EXTRA_SEEDS)
    code=set()
    for a,i in inst.items():
        code.update(range(a,a+i.size))
    labels={}
    for t,refs in xrefs.items():
        labels[t]=("sub" if any(k=="call" for _,k in refs) else "loc")+f"_{t:04X}"
    out=[
        "; conservative recursive 68HC11 listing",
        f"; SHA-256 {hashlib.sha256(data).hexdigest().upper()}",
        f"; {len(inst)} instructions, {len(code)} bytes",
        ""
    ]
    previous=None
    for a,i in sorted(inst.items()):
        if previous is None or a!=previous:
            out.append(f"\n        .org ${a:04X}")
        if a in labels:
            out.append(labels[a]+":")
        out.append(f"{a:04X}:  {i.bytes.hex(' ').upper():<17} {i.mnemonic:<8} {i.op_str}")
        previous=a+i.size
    ns.asm.write_text("\n".join(out)+"\n",encoding="utf-8")
    vals=sorted(code)
    ranges=[]
    if vals:
        s=p=vals[0]
        for x in vals[1:]:
            if x==p+1: p=x
            else: ranges.append((s,p)); s=p=x
        ranges.append((s,p))
    with ns.ranges.open("w",newline="",encoding="utf-8") as f:
        w=csv.writer(f); w.writerow(["start","end","size"])
        for s,e in ranges:w.writerow([f"0x{s:04X}",f"0x{e:04X}",e-s+1])
    print(f"wrote {ns.asm} and {ns.ranges}")

if __name__=="__main__":
    main()
