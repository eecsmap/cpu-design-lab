---
layout: default
title: "Writing your own test programs"
parent: Lab guide
nav_order: 8
---

# Writing your own test programs

`$LAB/custom-tests/` is set up and working. It builds against the
same riscv-tests environment the official ISA tests use, so your program gets the
same trap handler and `tohost` pass/fail protocol the simulator understands.

```bash
cd $LAB/custom-tests
make                    # builds every .S in the directory, plus a .dump disassembly
```

Then run it on any core:

```bash
cd ~/github/chipyard/sims/verilator
make CONFIG=Sodor1StageConfig run-binary BINARY=$LAB/custom-tests/mytest
```

`mytest.S` has a few `TEST_CASE` examples, including a RAW dependence chain that is
deliberately interesting on the 5-stage. Add your own cases there.

Note the `-march=rv32i_zicsr_zifencei` in the Makefile: current binutils no longer
folds the CSR and fence.i instructions into base `rv32i`, and the riscv-tests trap
handler needs both. (Same issue you already fixed in your EECS151 project.)

---
