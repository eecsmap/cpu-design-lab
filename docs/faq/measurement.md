---
layout: default
title: 测量方法
parent: FAQ
nav_order: 4
---

# 测量方法

对应指南 §6。这一页的内容是踩过坑之后总结的,优先级很高。

## 为什么 `Completed after N simulation cycles` 不能用来比较微架构?

**答:** 因为它统计的是整个仿真,而其中绝大部分是**通过串行链路把程序装进 scratchpad**
加上结束时的 host 握手 —— 这两项占主导,而且在每个核上都一样。

实测证据:同一个二进制在 1-stage 和 5-stage 上跑,这个数字**完全相同**:

```
Sodor1StageConfig  mytest  PASSED  36346 total sim cycles
Sodor5StageConfig  mytest  PASSED  36346 total sim cycles
```

两个微架构差异巨大的核给出一模一样的数,说明这个指标测的根本不是核。

**正确做法:** 测 trace 的一个**区间**。用 `tools/benchcycles.sh`,它按 ELF 符号
(`bench_start` / `bench_end`)定位,把装载和握手完全排除在外。

## 为什么 `benchcycles.sh` 只统计标记为 `[1]` 的指令?

**答:** 因为流水线核也会把**投机取指、随后被 kill 的指令**打进 trace。

如果不过滤,匹配 `bench_end` 这个 PC 时会命中循环第一次的 fall-through(分支还没解析,
下一条已经被取了),测量在第一次迭代就停了 —— 实测会得出 "11 cycles" 这种荒谬结果。

trace 行里 `[1]` 表示这一拍真的提交了指令,`[0]` 是气泡、停顿或被 kill 的取指。

## 为什么 5 级流水线的 CPI 比单周期还差?

**答:** 这不是 bug,这就是流水线的真相。

```
Sodor1StageConfig  hazard_bench  2200 cycles  2201 instructions  CPI 1.00
Sodor5StageConfig  hazard_bench  2598 cycles  2201 instructions  CPI 1.18
```

流水线没有减少指令数,也没有减少每条指令的工作量 —— 它**增加**了周期,因为每次跳转
成功的分支都要丢弃已经取出的指令。

流水线买到的是**大幅缩短的时钟周期**,整个赌注是频率的收益盖过 CPI 的损失。
**CPI 单独一个数永远说明不了一个设计是快是慢**,必须配上 Fmax。

1-stage 的 CPI 恰好是 1.00 也是对工具的一次校验:11 条指令 × 200 次迭代 = 2200 周期,
没有流水线就不可能有停顿。

> 相关:指南 [§6 Lab 4]({{ site.baseurl }}/guide/06-lab4-5stage.html)、[measurements/](https://github.com/eecsmap/cpu-design-lab/tree/main/measurements)
