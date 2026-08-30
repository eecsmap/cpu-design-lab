---
layout: default
title: 译码表与数据通路
parent: FAQ
nav_order: 6
---

# 译码表与数据通路

## 译码表里的 `OP1_X` / `OP2_X` 是不是让操作数取 0?

**答:不是。`X` 是 `RS1` / `RS2` 的别名,同一个编码。**

```scala
val OP1_RS1 = 0.asUInt(2.W)
val OP1_IMU = 1.asUInt(2.W)
val OP1_IMZ = 2.asUInt(2.W)
val OP1_X   = 0.asUInt(2.W)     // ← 和 OP1_RS1 相同
```

所以 `alu_op1 = MuxCase(0.U, ...)` 里那个默认值 `0.U` **永远走不到** —— `OP1_X === OP1_RS1`
第一条就命中了。

后果:`BEQ` 那行虽然写着 `OP1_X, OP2_X`,硬件上 `alu_op1` 实际是 `rs1_data`、`alu_op2`
是 `rs2_data`,ALU 照常算一个加法,只是结果没人要(`WB_X` + `REN_0`)。

这么设计是为了省 mux 宽度:2 bit 刚好覆盖 3 个真实来源,不必为"不关心"再留一个编码。
**代价是 op1 没有"零"这条路**,所以 `LUI` 只能靠 `ALU_COPY1` 直通,不能写成 `0 + imm_u`。

> 相关:设计笔记 [操作数 mux 的自由度,与 CSRRW 的约束]({{ site.baseurl }}/notes/01-operand-mux-and-copy.html)

## 为什么 ALU 只有 `COPY1` 没有 `COPY2`?

**答:因为 op1 反正必须接 `rs1`,COPY 走 op1 可以完全寄生在已有的 mux 上,一分钱不花。**

op1 的三路输入全部身兼两职:`rs1` 既是算术操作数又是 `CSRRW` 的源,`imm_u` 既是
`AUIPC` 的加数又是 `LUI` 的源。而 op2 那边 `rs2` 和 CSR 完全不搭界(CSR 要的是 `rs1`),
copy 走 op2 搭不到便车,还得把 `rs1` 额外挂一份到 op2 上。

**但注意:这个"寄生"的解释是定性的,不要用它去估算代价。** 实测把 `imm_u` 和 `PC`
对调、`LUI` 改用新增的 `ALU_COPY2` 之后,DatPath **少了 79 个 LUT(−6.5%)**、
Fmax 高 2.5% —— 和"数 mux 输入个数"的推演正好相反。

原因是那个模型有三处站不住:ALU 结果 mux 本来就是 16 项数组(多一个操作码接近免费);
mux 规模由选择信号位宽而非输入个数决定;单路输入的代价取决于其中有多少位是常量或与
其它输入共享(`imm_i_sext` 和 `imm_s_sext` 的高 20 位是同一根线,`imm_u_sext` 低 12 位
恒零,而 `pc_reg` 32 位全任意)。

> 相关:设计笔记 [操作数 mux 的自由度,与 CSRRW 的约束]({{ site.baseurl }}/notes/01-operand-mux-and-copy.html)、
> [实测数据](https://github.com/eecsmap/cpu-design-lab/blob/main/measurements/2026-08-30-operand-mux-variants.md)

## 跳转目标为什么不用 ALU 算,要另外三个加法器?

**答:分支必须在同一拍里同时算"比较"和"目标",一个 ALU 做不到。**

`BEQ` 需要 `rs1 == rs2`(决定跳不跳)和 `pc + imm_b`(跳到哪),两个算术结果同一个周期
都要。一个 ALU 一周期只能算一次。

`JAL` / `JALR` 技术上可以用 ALU(`JALR` 的操作数 `OP1_RS1, OP2_IMI` 本来就摆好了),
但那会把专用加法器这条短路径串进 ALU 这条长路径再进 PC mux,**牺牲 Fmax 去省几十个
LUT**,不划算。

> 相关:设计笔记 [操作数 mux 的自由度,与 CSRRW 的约束]({{ site.baseurl }}/notes/01-operand-mux-and-copy.html)
