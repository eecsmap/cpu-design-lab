# 操作数 mux 重排的实际代价(Sodor 1-stage)

**日期:** 2026-08-30
**Chipyard:** 1.14.0 / **riscv-sodor:** 910a2e8
**综合:** Vivado 2024.1,目标器件 `xc7z020clg400-1`(PYNQ-Z1)
**变体补丁:** `tools/synth/variants/{A-imm_u-to-op2,B-csr-off-alu}.patch`

检验设计笔记
[操作数 mux 的自由度,与 CSRRW 的约束](../docs/notes/01-operand-mux-and-copy.md)
里的纸面推演。**结论:两个预测都错了,方向还相反。**

---

## 变体

| 变体 | 改动 |
|---|---|
| **baseline** | 原样 |
| **A** | `imm_u` 与 `PC` 在两个操作数 mux 之间对调;`LUI` 改用新增的 `ALU_COPY2` |
| **B** | CSR 写数据走专用通路 `Mux(inst(14), imm_z, rs1_data)`,不再借用 ALU;6 条 CSR 指令 `alu_fun` 改为 `ALU_X`;`imm_z` 从 op1 mux 移除 |

变体 B 有个附带发现:**不需要新增控制信号**。CSR 指令的 funct3 在立即数形式
(`CSRRWI/SI/CI` = `1xx`)和寄存器形式(`CSRRW/S/C` = `0xx`)之间只差最高位,
所以 `inst(14)` 就能区分,改动完全局限在 dpath 内。

## 功能验证

三个变体都跑了完整的 RV32 汇编测试集:

| 变体 | ISA 测试 |
|---|---|
| baseline | 51 / 51 |
| A | 51 / 51 |
| B | 51 / 51 |

**面积数字只有在功能正确时才有意义**,所以这一步在综合之前做。

## 面积:隔离综合

`DatPath` 和 `CtlPath` 各自单独综合,`regfile_32x32` 和 `CSRFile` 用端口匹配的
黑盒桩替代(见"方法学"一节说明为什么必须这样)。

| 变体 | DatPath LUT | CtlPath LUT | 合计 | 相对 baseline |
|---|---:|---:|---:|---|
| baseline | 1098 | 120 | **1218** | — |
| **A** | 1019 | 120 | **1139** | **−79(−6.5%)** |
| **B** | 1128 | 121 | **1249** | **+31(+2.5%)** |

触发器数三个变体一致(DatPath 66,CtlPath 1),符合预期——这些改动不涉及状态。

### 预测 vs 实测

| | 纸面预测 | 实测面积 | 实测时序 | |
|---|---|---|---|---|
| A | "mux 输入数不变,只多一个 ALU 操作 → 接近零成本或略差" | **−79 LUT** | **+2.5% Fmax** | ✗ 错 |
| B | "op1 少一路、ALU 少一个用户 → 应该省" | **+31 LUT** | **−2.5% Fmax** | ✗ 错 |

变体 B 的结果格外值得记住:设计笔记里把"质疑接口本身"当成整条推理链**最深刻的一步**,
而那个方案在面积和时序两个维度上都输给了原设计。**推理的深度不保证结论的正确。**

## 时序:布局布线后

综合阶段的时序不可用(见"方法学"),所以跑完整的 `opt → place → phys_opt → route`。
两个目标周期各跑一遍:20 ns 三个都达标有余量,14 ns 三个都轻微超时。
**后者更有参考价值** —— 目标达标之后工具就停止优化,留有余量时的 Fmax 只是下界。

| 变体 | WNS@20ns | Fmax | WNS@14ns | Fmax | 相对 baseline |
|---|---:|---:|---:|---:|---|
| baseline | +1.858 | 55.1 MHz | −0.486 | 69.0 MHz | — |
| **A** | +2.251 | 56.3 MHz | −0.143 | **70.7 MHz** | **+2.5%** |
| **B** | +0.855 | 52.2 MHz | −0.858 | **67.3 MHz** | **−2.5%** |

**两个目标周期下排序完全一致**(A > baseline > B),说明差异不是单点综合的偶然。
20 ns 那一列的绝对值确实是下界 —— 收紧到 14 ns 之后三个的 Fmax 都涨了约 14 MHz。

### 面积与时序方向一致

| 变体 | 面积 | 时序 | 结论 |
|---|---|---|---|
| **A** | −6.5% | +2.5% | **两项都更好** |
| **B** | +2.5% | −2.5% | **两项都更差** |

没有出现"用面积换时序"的取舍 —— 两个变体都是单方向的改善或退化。

---

## 为什么纸面模型是错的

原来的推演靠**数 mux 输入数**。看生成的 Verilog 就知道这个模型为什么不成立。

### 一、ALU 结果 mux 本来就是 16 路的

```verilog
wire [15:0][31:0] _GEN_2 = {{32'h0}, {32'h0}, {32'h0}, {32'h0}, {_GEN[op1_sel]}, ...};
```

`alu_fun` 是 4 bit,Chisel 的 `MuxCase` 生成一个**完整的 16 项数组**,没用到的槽位
填 `32'h0`。加一个 `ALU_COPY2` 只是把其中一个常量槽换成 `_GEN_0[op2_sel]`。

所以"多一个 ALU 操作码要多花代价"这个前提是错的 —— **在译码空间没有用满之前,
增加一个操作是接近免费的**。

### 二、mux 的规模由选择信号位宽决定,不是由输入个数决定

baseline 的 op1 是 4 项数组(2 bit 选择信号):

```verilog
wire [3:0][31:0] _GEN = {{32'h0}, {{27'h0, inst[19:15]}}, {{inst[31:12], 12'h0}}, {rs1_data}};
```

变体 B 把 `imm_z` 拿掉之后,只剩 2 个真实输入,firtool 塌缩成了三元链:

```verilog
op1_sel == 2'h0 ? rs1_data : op1_sel == 2'h1 ? {inst[31:12], 12'h0} : 32'h0
```

**从 3 路减到 2 路会真的省**,但从 4 路减到 3 路可能一点都不省 —— 因为数组的大小
是 `2^选择位宽`。纸面上"少一路 / 多一路"的加减法和硬件对不上。

### 三、每一路输入的代价差异极大,取决于有多少位是常量或共享的

不是所有 32 位输入都等价:

| 信号 | 结构 | 有效位 |
|---|---|---|
| `rs1_data` / `rs2_data` / `pc_reg` | 任意 | 32 |
| `imm_i_sext` | `{{20{inst[31]}}, inst[31:20]}` | 高 20 位是**同一根线**复制 |
| `imm_s_sext` | `{{20{inst[31]}}, ...}` | 高 20 位**和 imm_i 完全相同** |
| `imm_u_sext` | `{inst[31:12], 12'h0}` | 低 12 位是**常量 0** |
| `imm_z` | `{27'h0, inst[19:15]}` | 高 27 位是**常量 0** |

`imm_i_sext` 和 `imm_s_sext` 的高 20 位是同一个信号,所以在 op2 上它们那一段
mux 是免费的。把 `imm_u`(低 12 位恒零)换到 op2、把 `pc_reg`(32 位全任意)换到
op1,改变的是**每个 mux 里可被优化掉的位数**,而不是输入的个数。

这大概是变体 A 省下 79 个 LUT 的主要来源。

---

## 诚实的缺口

**我没有把变体 A 的 −79 和变体 B 的 +31 完整解释清楚。**

上面三条机制说明了纸面模型为什么不可靠,也给出了方向上说得通的理由,但我没有做到
把这两个数字**定量地**归因到具体的逻辑上。特别是变体 B:它的 op1 确实塌缩成了更便宜
的三元链,新增的 CSR 专用 mux 也很便宜(27 位是常量),按理不该变贵 31 个 LUT。

能定案的后续实验:

- 用 `report_utilization -hierarchical` 之外的手段做网表级归因,比如对比两个变体里
  ALU 各个运算单元的 LUT 数
- 构造只包含单一改动的最小变体(目前变体 A 同时含"mux 对调"和"新增 COPY2"两个改动,
  没有拆开)
- 换一个综合工具(Yosys)交叉验证,排除 Vivado 特定的优化行为

在做完之前,**这两个数字是观测事实,机制是未验证的假说**。

---

## 方法学:三个踩过的坑

这次测量本身返工了三次,记下来。

### 坑一:综合阶段的时序数字不能用

第一版流程只跑 `synth_design` 就报 WNS。结果:

```
Data Path Delay: 15.244ns  (logic 3.289ns (21.6%)  route 11.955ns (78.4%))
net (fo=159, unplaced)
```

**78% 的延迟是未布局的走线估计**,纯粹是猜测。而且报出来的关键路径是
`reg_dmiss → CSR mepc 使能`,**根本不经过被改动的 ALU 和操作数 mux**。

时序必须跑到布局布线之后才有意义。

### 坑二:层次化利用率报告在展平之后是假的

用 `-flatten_hierarchy rebuilt`(默认)综合整个 `Core`,分模块报告是这样的:

| 模块 | baseline | variantA |
|---|---:|---:|
| CSRFile | 438 | 590 |
| regfile_32x32 | 1101 | 920 |

**这两个模块的 RTL 在两个变体里逐字节相同**(regfile 的 md5 已核对),报出来却差
150~180 个 LUT。展平优化之后再重建层次,逻辑的归属是任意的。

只有顶层总数可信 —— 而顶层总数被 1100 LUT 的寄存器堆淹没,正是要测的那部分被埋在
噪声里。所以改成隔离综合。

### 坑三:Vivado 不会自动把缺失模块当黑盒

直接单独综合 `DatPath` 会报 `ERROR: [Synth 8-439] module 'regfile_32x32' not found`。
需要生成端口匹配的桩(`tools/synth/make_blackbox.py`),标 `(* black_box *)`。

验证桩没有把设计优化掉:`DatPath` 综合后保留 66 个触发器
(`pc_reg` 32 + `if_inst_buffer` 32 + `reg_dmiss` + `reg_interrupt_edge`),数目吻合。

### 确定性

同一份输入重跑一次综合,`DatPath` 两次都是 1098 LUT。所以变体之间的差异不是工具的
运行间噪声,是 RTL 差异导致的真实结果(尽管仍然是"不同 RTL 的优化彩票"的一部分)。

---

## 复现

```bash
cd ~/github/chipyard/generators/riscv-sodor
git apply $LAB/tools/synth/variants/A-imm_u-to-op2.patch

cd ~/github/chipyard/sims/verilator
make -j12 CONFIG=Sodor1StageConfig
make -j1 CONFIG=Sodor1StageConfig run-asm-tests-fast    # 必须 51/51

GEN=generated-src/chipyard.harness.TestHarness.Sodor1StageConfig/gen-collateral
python3 $LAB/tools/synth/make_blackbox.py $GEN/regfile_32x32.sv regfile_32x32 > /tmp/v/stub_regfile.sv
python3 $LAB/tools/synth/make_blackbox.py $GEN/CSRFile.sv CSRFile > /tmp/v/stub_csrfile.sv
cp $GEN/DatPath.sv $GEN/CtlPath.sv /tmp/v/
vivado -mode batch -source $LAB/tools/synth/synth_isolated.tcl -tclargs /tmp/v /tmp/v DatPath
```
