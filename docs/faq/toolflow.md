---
layout: default
title: 构建与运行流程
parent: FAQ
nav_order: 3
---

# 构建与运行流程

对应指南 §2 和 §8。

## 为什么 `make run-asm-tests-fast` 不打印 PASSED?

**答:** `-fast` 系列目标不打每个测试的横幅。**退出码 0 就是通过报告。**

每个通过的测试会在输出目录留一个 `<test>.run` 戳记文件,`make` 遇到第一个失败就中止。
所以判断方式是:

```bash
make CONFIG=Sodor1StageConfig run-asm-tests-fast   # 退出码 0 = 全过
ls output/chipyard.harness.TestHarness.Sodor1StageConfig/*.run | wc -l
```

想看某个测试的完整 trace,单独用 `run-binary` 跑它。

## 生成的 Verilog 在哪?

**答:** `sims/verilator/generated-src/<harness>.<CONFIG>/gen-collateral/`。

```bash
ls ~/github/chipyard/sims/verilator/generated-src/\
chipyard.harness.TestHarness.Sodor1StageConfig/gen-collateral/
```

Sodor 的三个关键文件是 `Core.sv`(112 行)、`CtlPath.sv`(191)、`DatPath.sv`(269)。
拿 `DatPath.sv` 和 `dpath.scala`(296 行)对照 —— 这么简单的核,映射几乎是一对一的。
目录里其余的都是外围 SoC(TileLink、debug module、UART)。

## 构建为什么这么慢?什么时候会重新 elaborate?

**答:** 首次构建任何 config 都慢(sbt elaborate 整个 SoC + Verilator 编译 C++)。

- 改了 Scala 源码 → 增量重编,快得多,而且**会自动重新 elaborate**(改 `USE_FULL_BYPASSING` 这种常量也会)
- 换 `CONFIG` → 完整重新 elaborate

## 怎么导出波形?

**答:** 把 `run-binary` 换成 `run-binary-debug`。

```bash
make CONFIG=Sodor1StageConfig run-binary-debug \
  BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/isa/rv32ui-p-add
```

VCD 落在 `output/chipyard.harness.TestHarness.<CONFIG>/`。用 GTKWave 打开。

> 相关:指南 [§2 Lab 0]({{ site.baseurl }}/guide/02-lab0-flow.html)、[§8 Waveforms]({{ site.baseurl }}/guide/09-waveforms.html)
