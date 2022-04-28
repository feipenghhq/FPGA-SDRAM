
#########################################################
# Makefile for project
#########################################################

GIT_ROOT = $(shell git rev-parse --show-toplevel)
OUT_DIR  = $(shell pwd)/quartus
PWD		 = $(shell pwd)

PROJECT  = de2
QSYS 	 = de2
TOP		 = de2_top

VERILOG  += $(PWD)/src/de2_top.sv
SDC	     += $(PWD)/src/de2.sdc
PIN      += $(PWD)/src/DE2_pin_assignment.tcl

QSYS_DIR 	= $(PWD)/src
QSYS_SEARCH = $(GIT_ROOT)/rtl/sdram/*/**

include $(GIT_ROOT)/fpga/scripts/makefile.intel.mk
