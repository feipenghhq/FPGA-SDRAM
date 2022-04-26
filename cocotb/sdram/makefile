# ==================================================================================
# Makefile
# ==================================================================================


GIT_ROOT ?= $(shell git rev-parse --show-toplevel)
PWD = $(shell pwd)

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# source file
VERILOG_SOURCES += $(GIT_ROOT)/rtl/sdram/sdram_init.sv
VERILOG_SOURCES += $(GIT_ROOT)/rtl/sdram/sdram_access.sv
VERILOG_SOURCES += $(GIT_ROOT)/rtl/sdram/sdram_fifo.sv
VERILOG_SOURCES += $(GIT_ROOT)/rtl/sdram/avalon_sdram_controller.sv
# testbench file
VERILOG_SOURCES += $(GIT_ROOT)/cocotb/sdr_sdram/sdr_parameters.vh
VERILOG_SOURCES += $(GIT_ROOT)/cocotb/sdr_sdram/sdr.v
VERILOG_SOURCES += $(GIT_ROOT)/cocotb/sv/sdram_tb_top.sv

TOPLEVEL = sdram_tb_top

MODULE  = test

# Macros for Micron SDRAM
COMPILE_ARGS += -Dden256Mb
COMPILE_ARGS += -Dsg6a
COMPILE_ARGS += -Dx16

# Include path
COMPILE_ARGS += -I$(GIT_ROOT)/cocotb/sdr_sdram
COMPILE_ARGS += -I$(GIT_ROOT)/rtl/sdram

DUMP ?= 0
ifeq ($(DUMP), 1)
	COMPILE_ARGS += -DDUMP
endif

# Other variable
export COCOTB_RESOLVE_X=RANDOM
export PYTHONPATH = $(GIT_ROOT)/cocotb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
