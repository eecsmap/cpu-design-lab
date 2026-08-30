---
layout: default
title: 核的规模与选型
parent: FAQ
nav_order: 2
---

# 核的规模与选型

对应指南 §1。

## 五个 Sodor 核各有多少行 Scala?Rocket 和 BOOM 呢?

**答:** Sodor 每个核 690–1,240 行;Rocket 核本体 1,388 行;BOOM v4 是 19,376 行。

Sodor(`generators/riscv-sodor/src/main/scala/sodor/`):

| 核 | 行数 | 文件数 | 最大的文件 |
|---|---:|---:|---|
| 1-stage | 690 | 5 | `dpath.scala` 296 |
| 2-stage | 694 | 5 | `dpath.scala` 320 |
| 3-stage | 1,098 | 8 | `dpath.scala` 355 |
| 5-stage | 1,063 | 6 | `dpath.scala` 543 |
| micro-coded | 1,237 | 7 | `microcode.scala` 429 |
| `common/`(共享) | 3,181 | 12 | `dm_registers.scala` 861 |
| **仓库合计** | **7,963** | 43 | |

两点值得注意:

1. **真正要读的比这还少。** 1-stage 你实际要读的是 `cpath.scala`(189)+ `dpath.scala`(296)= **485 行**,一个完整的 RV32I 处理器。
2. **`common/` 大部分不是 CPU。** 3,181 行里 `dm_registers.scala`(861)和 `instructions.scala`(845)是表格式的定义,其余是 Chipyard 接入用的胶水(TileLink 适配、scratchpad、tile 封装),几乎没有微架构内容。

Rocket(`generators/rocket-chip/`)取决于你怎么划边界:

| 范围 | 行数 |
|---|---:|
| `RocketCore.scala` 本体 | 1,388 |
| `rocket/` 目录(核 + cache + MMU + CSR) | 13,865 |
| 整个 rocket-chip 仓库 | 54,689 |

`rocket/` 里核本身是少数派:`Instructions.scala` 1,732、`CSR.scala` 1,672、`DCache.scala` 1,211、`NBDcache.scala` 1,075、`ICache.scala` 900、`PTW.scala` 827、`TLB.scala` 759。

BOOM(`generators/boom/`):v3 是 18,798 行,v4 是 19,376 行。v4 按单元拆:

| 单元 | 行数 | 是什么 |
|---|---:|---|
| `exu/` | 7,258 | 重命名、ROB、发射队列、执行 |
| `ifu/` | 4,758 | 取指 + 分支预测 |
| `lsu/` | 4,577 | 访存单元、D$、MSHR |
| `common/` | 1,742 | 参数、bundle |
| `util/` | 1,041 | |

而且 BOOM 是**建立在** rocket-chip 之上的,不是替代它 —— 它直接用了 rocket 的 `ALU`、`Instructions`、`CSRFile`、FPU 和整套 tile/TileLink 基础设施。

**结论:从 Sodor 5 级到 BOOM 差不多 18 倍,而这些增长几乎没有一点是"流水线更深"。** 增长来自投机执行、寄存器重命名、乱序恢复,以及一个会 miss 的存储系统。这正是先读 Sodor 的理由 —— 三者里只有它能整个装进脑子。

复现命令:

```bash
cd ~/github/chipyard/generators/riscv-sodor/src/main/scala/sodor
for d in rv32_1stage rv32_2stage rv32_3stage rv32_5stage rv32_ucode common; do
  printf "%-14s %6d\n" "$d" "$(find $d -name '*.scala' | xargs cat | wc -l)"
done
```

> 相关:指南 [§1 The five cores]({{ site.baseurl }}/guide/01-five-cores.html)、[§9 Where this goes next]({{ site.baseurl }}/guide/10-next.html)
