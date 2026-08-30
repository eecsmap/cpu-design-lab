---
layout: default
title: "Lab 0 — prove the flow works"
parent: Lab guide
nav_order: 2
---

# Lab 0 — prove the flow works

Build the 1-stage simulator. First build is slow (sbt elaborates the whole SoC,
then Verilator compiles it); later ones are much faster.

```bash
cd ~/github/chipyard/sims/verilator
make CONFIG=Sodor1StageConfig
```

Run one RISC-V ISA test on it:

```bash
make CONFIG=Sodor1StageConfig run-binary \
  BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/isa/rv32ui-p-add
```

Then run the whole RV32 assembly suite — 51 tests, the RV32I user-level set plus
the M-mode privileged set:

```bash
make CONFIG=Sodor1StageConfig run-asm-tests-fast
```

All 51 pass on this install. Note how the `-fast` targets report: they do **not**
print a per-test banner. Each test that passes leaves a `<test>.run` stamp file in
the output directory, and `make` aborts on the first failure — so "exit code 0"
*is* the pass report. If you want the trace for a specific test, run it on its own
with `run-binary` as above.

Output lands in `output/chipyard.harness.TestHarness.Sodor1StageConfig/`. The
`.out` file is the important one — **Sodor prints a commit trace, one line per
cycle**, already disassembled:

```
Cyc=      48511 [1] pc=[8000003c] W[r30=8000103c][1] Op1=[r 0][00001000] Op2=[r 0][8000003c] inst=[00001f17]     auipc   t5, 0x1
Cyc=      48512 [1] pc=[80000040] W[r 4=80001000][0] Op1=[r30][8000103c] Op2=[r 3][ffffffc4] inst=[fc3f2223]     sw      gp, -60(t5)
...
*** PASSED *** Completed after                97836 simulation cycles
```

Read that line format now, because you will live in it:

| Field | Meaning |
|---|---|
| `Cyc=` | cycle number |
| `[1]` | instruction valid this cycle (`[0]` = bubble/stall) |
| `pc=[...]` | program counter |
| `W[rN=val][1]` | writeback: register, value, and whether the write actually happens |
| `Op1`, `Op2` | the two ALU operands, with the register they came from |
| `inst=[...]` | raw encoding, then the disassembly |

This trace is your ground truth for everything that follows.

**One trap, worth knowing before you measure anything.** The
`Completed after N simulation cycles` line is *not* a useful performance number.
It counts the whole simulation, most of which is loading the program into the
scratchpad over the serial link and the host handshake at the end. Those dominate,
and they are the same on every core — run the same binary on the 1-stage and the
5-stage and you get an identical total. To compare microarchitectures you have to
measure a region of the trace instead. §6 has the tool that does it.

**What you should take away:** a core is not a simulator binary. sbt elaborated
Chisel into Verilog, Verilator compiled that Verilog into C++, and the resulting
program loaded an ELF into a scratchpad and ran it. Find the generated Verilog:

```bash
ls ~/github/chipyard/sims/verilator/generated-src/chipyard.harness.TestHarness.Sodor1StageConfig/gen-collateral/
```

The three files that matter are in `gen-collateral/`:

```
Core.sv       112 lines
CtlPath.sv    191 lines
DatPath.sv    269 lines
```

Compare `DatPath.sv` (269 lines of Verilog) against `dpath.scala` (296 lines of
Chisel). For a core this simple the mapping is nearly one-to-one — you can find
your `pc_reg` and your ALU mux in the generated code. Do this once, early. It
demystifies Chisel permanently: Chisel is a *generator* that emits Verilog, not
an HDL that gets simulated directly.

(The rest of `gen-collateral/` is the surrounding SoC — TileLink buses, debug
module, UART. Sodor is the small part. That contrast is itself worth noticing.)

---
