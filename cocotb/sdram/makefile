# ==================================================================================
# Makefile
# ==================================================================================


GIT_ROOT ?= $(shell git rev-parse --show-toplevel)
PWD = $(shell pwd)

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(GIT_ROOT)/rtl/sdram/core/avalon_sdram_controller.v

TOPLEVEL = avalon_sdram_controller

MODULE  = test

# Macros for Micron SDRAM
COMPILE_ARGS += -Dden256Mb
COMPILE_ARGS += -Dsg6a
COMPILE_ARGS += -Dx16

# Include path
COMPILE_ARGS += -I$(GIT_ROOT)/cocotb/sdr_sdram
COMPILE_ARGS += -I$(GIT_ROOT)/rtl/sdram/core

DUMP ?= 0
ifeq ($(DUMP), 1)
	COMPILE_ARGS += -DDUMP
endif

# Other variable
export COCOTB_RESOLVE_X=RANDOM
export PYTHONPATH = $(GIT_ROOT)/cocotb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
