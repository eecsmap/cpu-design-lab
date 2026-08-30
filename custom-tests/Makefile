# Build custom RV32I tests against the riscv-tests environment that
# Chipyard installed. Run `source ~/github/chipyard/env.sh` first.

CHIPYARD ?= $(HOME)/github/chipyard
RVTESTS  ?= $(CHIPYARD)/toolchains/riscv-tools/riscv-tests

GCC      := riscv64-unknown-elf-gcc
OBJDUMP  := riscv64-unknown-elf-objdump

INCS  := -I$(RVTESTS)/env/p -I$(RVTESTS)/isa/macros/scalar
CFLAGS := -march=rv32i_zicsr_zifencei -mabi=ilp32 -static -mcmodel=medany \
          -fvisibility=hidden -nostdlib -nostartfiles
LDFLAGS := -T$(RVTESTS)/env/p/link.ld

SRCS := $(wildcard *.S)
ELFS := $(SRCS:.S=)

all: $(ELFS)

%: %.S
	$(GCC) $(CFLAGS) $(INCS) $(LDFLAGS) $< -o $@
	$(OBJDUMP) -d -M no-aliases $@ > $@.dump

clean:
	rm -f $(ELFS) *.dump

.PHONY: all clean
