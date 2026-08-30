---
layout: default
title: Setup
nav_order: 2
---

# Setup

Everything needed to rebuild this environment from nothing. If you only read
one page in this repo when moving to a new machine, read this one.

## The environment

| Thing | Where |
|---|---|
| Chipyard | `~/github/chipyard` (release 1.14.0) |
| Sodor sources | `~/github/chipyard/generators/riscv-sodor/src/main/scala/sodor` |
| Simulators you build | `~/github/chipyard/sims/verilator` |
| This lab dir | `$LAB` |
| Cycle-accurate measurement | `$LAB/tools/benchcycles.sh` |
| Custom test programs | `$LAB/custom-tests/` |
| Conda (Miniforge) | `~/tools/miniforge3` |

Every session starts the same way:

```bash
cd ~/github/chipyard
source env.sh
```

That activates Chipyard's private conda env, which supplies the RISC-V toolchain,
Spike, Verilator, JDK, and sbt. Check it took:

```bash
which verilator riscv64-unknown-elf-gcc spike
echo $RISCV
```

---

## Things that will bite you

**Sodor is an optional Chipyard submodule.** A plain `./build-setup.sh` does *not*
check it out; it is in the exclusion list in
`scripts/init-submodules-no-riscv-tools-nolog.sh`. It is already initialized here,
but if you ever re-clone Chipyard:

```bash
git submodule update --init generators/riscv-sodor
```

**Entering the environment.** `source env.sh` needs `conda` already on your PATH.
This machine's conda lives at `~/tools/miniforge3` and is wired into `~/.bashrc`,
with base auto-activation off, so your normal shell is untouched.

**The conda sysroot pin.** `conda-reqs/chipyard-base.yaml` here pins
`sysroot_linux-64=2.39` to match Ubuntu 24.04's glibc. Upstream pins 2.34, which
makes `build-setup.sh` re-solve every conda lockfile from scratch. The pin only
matters for linking commercial simulators (VCS), which this machine does not have.
It is a local change — expect it to show up in `git status` and `git diff`.

**First build of any config is slow** (sbt elaboration + Verilator compile).
Rebuilds after a Scala edit are much faster, but changing `CONFIG` means a fresh
elaboration.
