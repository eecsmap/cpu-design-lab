---
layout: default
title: 写测试程序
parent: FAQ
nav_order: 5
---

# 写测试程序

对应指南 §7.5。

## 为什么 Makefile 里要写 `-march=rv32i_zicsr_zifencei`?

**答:** 新版 binutils 不再把 CSR 指令和 `fence.i` 算进基础 `rv32i` 了,而 riscv-tests
的 trap handler 两个都要用。

只写 `-march=rv32i` 会得到一堆:

```
Error: unrecognized opcode `csrr t5,mcause', extension `zicsr' required
```

这和 EECS151 项目里遇到的是同一个问题。

## 自己写的测试怎么让仿真器知道过没过?

**答:** 用 riscv-tests 的环境,它自带 `tohost` 协议和 trap handler。

`custom-tests/Makefile` 已经配好了 include 路径和链接脚本,`.S` 文件里
`#include "riscv_test.h"` + `RVTEST_PASS` 就行。照着 `mytest.S` 改。

```bash
cd $LAB/custom-tests && make        # 编译所有 .S,顺带生成 .dump 反汇编
```

## 怎么让 `benchcycles.sh` 认识我的程序?

**答:** 在你要测量的区间前后放两个全局符号。

```asm
  .global bench_start
bench_start:
  # ... 被测代码 ...
  .global bench_end
bench_end:
```

脚本用 `riscv64-unknown-elf-nm` 找这两个符号的地址,再去 trace 里定位。符号名可以改,
作为第 3、4 个参数传进去。

> 相关:指南 [§7.5 Writing your own test programs]({{ site.baseurl }}/guide/08-custom-tests.html)
