# CPU Design Lab

用动手的方式学处理器微架构:把核构建出来,在上面跑真实程序,测出它到底做了什么,
再回去读源码解释这个数字。

主线是 **Berkeley Sodor** —— 五个 RV32I 核,实现同一套指令集但微架构完全不同,
从一个读起来像规范的单周期核,到一个微码机器。它们跑在
[Chipyard](https://github.com/ucb-bar/chipyard) 里,同一棵树后面还有 Rocket 和 BOOM。

📖 **网站(含全文搜索):<https://eecsmap.github.io/cpu-design-lab/>**

## 快速开始

```bash
export LAB=~/github/cpu-design-lab      # 你 clone 这个仓库的位置
cd ~/github/chipyard && source env.sh   # 进入工具链环境

cd $LAB/custom-tests && make            # 编译测试程序
$LAB/tools/benchcycles.sh Sodor5StageConfig $LAB/custom-tests/hazard_bench
```

环境还没搭好的话,从 [docs/setup.md](docs/setup.md) 开始。

## 目录

| 路径 | 内容 |
|---|---|
| [`docs/setup.md`](docs/setup.md) | 环境搭建。换机器时只读这一篇就够 |
| [`docs/guide/`](docs/guide/) | 实验指南 §1–§9,按顺序做 |
| [`docs/faq/`](docs/faq/) | 问答,**按指南章节归类**而不是按时间 |
| [`docs/notes/`](docs/notes/) | 设计笔记:完整的设计空间探索,保留推进顺序 |
| [`measurements/`](measurements/) | 实测数据,每份都带 commit 和方法 |
| [`tools/`](tools/) | `benchcycles.sh`(区间周期测量)、`cycles.sh` |
| [`custom-tests/`](custom-tests/) | 能在核上跑的汇编测试程序 |
| [`docs/reference-pdfs/`](docs/reference-pdfs/) | Sodor 原始 CS152 框图和实验讲义 |

## 为什么是这几个核

五个 Sodor 核实现同一套 ISA,**只有**微架构不同,所以在其他条件全部固定的情况下
能看清设计空间。而且它们小到能整个装进脑子:

| 核 | Scala 行数 |
|---|---:|
| 1-stage | 690 |
| 2-stage | 694 |
| 3-stage | 1,098 |
| 5-stage | 1,063 |
| micro-coded | 1,237 |

作为对照:Rocket 核本体 1,388 行(算上 cache 和 MMU 是 13,865),
BOOM v4 是 19,376 行,而且是建立在整个 rocket-chip 之上。
三者里只有 Sodor 你能完整读完。

## 已经踩过的坑

- **Sodor 是 Chipyard 的可选 submodule**,`build-setup.sh` 默认跳过它
- **`Completed after N cycles` 不能用来比较微架构** —— 它被程序装载主导,在每个核上都一样
- **5 级流水线的 CPI 比单周期差**(1.18 vs 1.00),这是对的,流水线买的是时钟周期不是 CPI

详见 [FAQ](docs/faq/)。

## 语言

指南正文是英文(术语本来就是英文,也方便和源码对照),FAQ 和这个 README 是中文。
