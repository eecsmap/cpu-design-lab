---
layout: default
title: "Debugging: waveforms"
parent: Lab guide
nav_order: 9
---

# Debugging: waveforms

Any run can produce a VCD:

```bash
cd ~/github/chipyard/sims/verilator
make CONFIG=Sodor1StageConfig run-binary-debug \
  BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/isa/rv32ui-p-add
```

The dump lands in `output/chipyard.harness.TestHarness.<CONFIG>/`. Open with
GTKWave (`sudo apt install gtkwave`), or use the waveform viewer you already know
from Vivado.

Signals worth adding to every trace: `pc_reg`, `inst`, the decoded control
signals, `rf_wen`, `wb_data`. That set alone explains almost every bug.

---
