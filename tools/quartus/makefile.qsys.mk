#########################################################
# Makefile for quartus flow
#########################################################

#########################################################
# Common variable
#########################################################

GIT_ROOT 	= $(shell git rev-parse --show-toplevel)
SCRIPT_DIR  = $(GIT_ROOT)/tools/quartus

#########################################################
# Project specific variable
#########################################################

# device part
PART ?= EP2C35F672C7
# device family
FAMILY ?= Cyclone II
# project name
PROJECT ?=
# top level name
TOP ?=
# verilog source files
VERILOG ?=
# sdc files
SDC	?=
# pin assignment files
PIN ?=
# qsys file
QSYS ?=
# qsys directory
QSYS_DIR ?=
# qsys synthesis language
QSYS_SYN_LANG ?= verilog
# qsys search path
QSYS_SEARCH += ,$
# project output directory
OUT_DIR ?= quartus

#########################################################
# Export the variables to the tcl script
#########################################################

export QUARTUS_PART 	= $(PART)
export QUARTUS_FAMILY 	= $(FAMILY)
export QUARTUS_PRJ 		= $(PROJECT)
export QUARTUS_TOP    	= $(TOP)
export QUARTUS_VERILOG  = $(VERILOG)
export QUARTUS_SDC		= $(SDC)
export QUARTUS_QIP		= $(QIP)
export QUARTUS_PIN		= $(PIN)

QIP	= $(OUT_DIR)/$(QSYS)/synthesis/$(QSYS).qip
SOF = $(OUT_DIR)/$(PROJECT).sof

#########################################################
# Build process
#########################################################

build: sof
sof : $(SOF)
qip : $(QIP)

pgm: $(SOF)
	quartus_pgm --mode JTAG -o "p;$(SOF)"

pgmonly:
	quartus_pgm --mode JTAG -o "p;$(SOF)"

qsys-edit:
	qsys-edit $(QSYS_DIR)/$(QSYS).qsys --search-path="$(QSYS_SEARCH)"

clean: clean_qsys
	rm -rf $(OUT_DIR)

$(QIP):
	qsys-generate $(QSYS_DIR)/$(QSYS).qsys --search-path="$(QSYS_SEARCH)"  --family=$(FAMILY)  --part=$(PART) --synthesis=$(QSYS_SYN_LANG) --output-directory=$(OUT_DIR)/$(QSYS) --clear-output-directory

$(SOF): $(QIP)
	cd $(OUT_DIR) && quartus_sh --64bit -t $(SCRIPT_DIR)/quartus_build.tcl

clean_qsys:
	rm -rf $(QSYS_DIR)/$(QSYS)*.rpt $(QSYS_DIR)/$(QSYS).cmp $(QSYS_DIR)/$(QSYS).html $(QSYS_DIR)/$(QSYS).sopcinfo
