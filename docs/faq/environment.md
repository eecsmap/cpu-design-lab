---
layout: default
title: 环境与安装
parent: FAQ
nav_order: 1
---

# 环境与安装

## Sodor 能不能脱离 Chipyard 单独用?

**答:** 现在的版本不行。必须在 Chipyard 里构建。

`ucb-bar/riscv-sodor` 的 README 明确写着仓库 **NOT** self-contained。老的自包含版本
被冻结在 `sodor-old` 分支,已经不维护(用的是很旧的 Chisel 和 riscv-tools)。

好处是:走 Chipyard 这条路,你顺带得到了 Rocket 和 BOOM,以及一套统一的工具链。

## 为什么 `build-setup.sh` 跑完之后 `generators/riscv-sodor` 是空的?

**答:** Sodor 是**可选** submodule,默认不初始化。

它在 `scripts/init-submodules-no-riscv-tools-nolog.sh` 的排除列表里。手动初始化:

```bash
cd ~/github/chipyard
git submodule update --init generators/riscv-sodor
```

`build-setup.sh` 也接受 `--sodor` 参数。任何时候重新 clone Chipyard 都要重做这一步。

## 为什么 chipyard 的 `git status` 里有一个改动?

**答:** `conda-reqs/chipyard-base.yaml` 里的 `sysroot_linux-64` 被有意改成了 2.39。

上游 pin 的是 2.34。`build-setup.sh` 会拿这个值和系统 glibc 比,不一样就把所有 conda
lockfile 从头重新求解 —— 很慢而且容易失败。Ubuntu 24.04 是 glibc 2.39,pin 成一样就
直接用 Chipyard 自己测过的 lockfile。

这个 pin 只影响链接商业仿真器(VCS),我们没有。

**注意:** 版本号必须**独占一行**。脚本是用 `awk -F=` 取值的,后面跟 `#` 注释会把注释
一起取进去,导致比较永远不相等。

## `source env.sh` 报错说找不到 conda

**答:** `env.sh` 要求 `conda` 已经在 PATH 里,它自己不负责找。

conda 装在 `~/tools/miniforge3`,已经写进 `~/.bashrc`(base 环境不自动激活,所以你的
普通 shell 不受影响)。如果是新开的 shell 还不行,先 `source ~/.bashrc`。

> 相关:[Setup]({{ site.baseurl }}/setup.html)
