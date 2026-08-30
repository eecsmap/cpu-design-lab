---
layout: default
title: "Lab 5 — the micro-coded core"
parent: Lab guide
nav_order: 7
---

# Lab 5 — the micro-coded core

`rv32_ucode/`. A single bus, a handful of registers, and a **microcode ROM** that
sequences multi-cycle micro-operations to implement each macro-instruction.

`microcode.scala` opens with a tutorial in its header comment. An `ADD` becomes
three micro-ops: `A <- Reg[rs1]`, `B <- Reg[rs2]`, `Reg[rd] <- A + B`, then a
micro-jump back to `FETCH`.

`microcodecompiler.scala` turns that table into a ROM. Read it — it is 150 lines
and it will teach you more about how control is really implemented than any
textbook diagram.

### Exercise 5.1
Implement one instruction purely in microcode — no datapath change at all. Then
appreciate exactly what microcode bought early machines: new instructions without
new silicon.

---
