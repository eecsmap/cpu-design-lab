---
layout: default
title: "Lab 1 — read the 1-stage"
parent: Lab guide
nav_order: 3
---

# Lab 1 — read the 1-stage

Files (under `generators/riscv-sodor/src/main/scala/sodor/rv32_1stage/`):

- `core.scala` — 66 lines. Wires cpath to dpath. Read first.
- `cpath.scala` — the decode table.
- `dpath.scala` — PC, regfile, ALU, mux tree.
- `consts.scala` — the control signal encodings.

### Read it in this order

1. **`cpath.scala`, the `ListLookup`.** This is the entire instruction decoder as a
   table: one row per instruction, one column per control signal
   (`pc_sel`, `op1_sel`, `op2_sel`, `alu_fun`, `wb_sel`, `rf_wen`, `mem_en`, …).
   Read three rows: `ADD`, `LW`, `BEQ`. You now know what "decode" means.

2. **`dpath.scala`, top to bottom.** It is written in datapath order: PC mux →
   fetch → decode fields → regfile read → operand muxes → ALU → writeback mux.
   Every control signal from step 1 shows up as a mux select. The correspondence
   is one-to-one and it is beautiful.

3. Note there is no pipeline register anywhere. Fetch, decode, execute, and
   writeback all happen in one cycle. That is why it is "essentially an ISA
   simulator" — and why its clock frequency would be terrible in silicon.

### Exercise 1.1 — trace an instruction by hand

Take `rv32ui-p-add`. Disassemble it:

```bash
riscv64-unknown-elf-objdump -d $RISCV/riscv64-unknown-elf/share/riscv-tests/isa/rv32ui-p-add | less
```

Pick one `add` instruction. On paper, fill in every control signal from the
decode table, then every mux select in the datapath. Then confirm with a waveform
(see §8).

### Exercise 1.2 — add an instruction

Sodor implements RV32I. Add something it lacks — a good first choice is a simple
R-type you define yourself, or implement `MUL` from RV32M the slow way.

1. Add the bit pattern to `common/instructions.scala`.
2. Add a row to the `ListLookup` in `rv32_1stage/cpath.scala`.
3. If it needs a new ALU op, add it in `consts.scala` and in the ALU block of
   `dpath.scala`.
4. Write a test in assembly, assemble it, run it.

This is the exercise. Everything before it was reading; this is where you learn
whether you actually understood the control/datapath split.

---
