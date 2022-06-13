
#########################################################
# Makefile
#########################################################

GIT_ROOT 	?= $(shell git rev-parse --show-toplevel)
SOPC_DIR 	?=
SOPC	    ?=

INC_RDIR	+= src
SRC_RDIR	+= src

BSP_DIR 	?= bsp
APP_DIR 	?= app

BSP_CMD    	?=

all: compile

env:
	nios2_command_shell.sh

$(BSP_DIR): $(SOPC_DIR)/$(SOPC).sopcinfo
	nios2-bsp hal $(BSP_DIR) $(SOPC_DIR)/$(SOPC).sopcinfo $(BSP_OPTION) $(BSP_CMD)

SRC_RDIR_OPTION := $(foreach dir, $(SRC_RDIR), --src-rdir $(dir))
INC_RDIR_OPTION := $(foreach dir, $(INC_RDIR), --inc-rdir $(dir))

$(APP_DIR): $(BSP_DIR)
	nios2-app-generate-makefile \
	--bsp-dir ./$(BSP_DIR) 		\
	--elf-name $(TOP).elf 		\
	$(SRC_RDIR_OPTION) 			\
	$(INC_RDIR_OPTION) 			\
	--app-dir $(APP_DIR)

compile_app: $(APP_DIR)
	cd $(APP_DIR) && $(MAKE) clean
	cd $(APP_DIR) && $(MAKE)

compile_bsp: $(BSP_DIR)
	cd $(BSP_DIR) && $(MAKE) clean
	cd $(BSP_DIR) && $(MAKE)

compile: compile_app compile_bsp

download:
	nios2-download -g -r -C $(APP_DIR) $(TOP).elf

clean:
	rm -rf $(BSP_DIR) $(APP_DIR)
