# ---------------------------------------------------------------
# Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
# Author: Heqing Huang
# Date Created: 04/19/2022
# ---------------------------------------------------------------
# Tcl Script for Quartus
# ---------------------------------------------------------------

# ------------------------------------------
# Create project and read in rtl files
# ------------------------------------------

set QUARTUS_PART        $::env(QUARTUS_PART)
set QUARTUS_FAMILY      $::env(QUARTUS_FAMILY)
set QUARTUS_PRJ         $::env(QUARTUS_PRJ)
set QUARTUS_TOP         $::env(QUARTUS_TOP)
set QUARTUS_VERILOG     $::env(QUARTUS_VERILOG)
set QUARTUS_SDC         $::env(QUARTUS_SDC)
set QUARTUS_QIP         $::env(QUARTUS_QIP)
set QUARTUS_PIN         $::env(QUARTUS_PIN)


# Load Quartus II Tcl Project package
package require ::quartus::project
project_new $QUARTUS_PRJ -overwrite -part $QUARTUS_PART -family $QUARTUS_FAMILY

# Porject Assignment
set_global_assignment -name VERILOG_MACRO "SYNTHESIS=1"
set_global_assignment -name TOP_LEVEL_ENTITY $QUARTUS_TOP

# Read in RTL
foreach vlog $QUARTUS_VERILOG {
    set pre "Reading RTL file: "
    puts [append pre $vlog]
    set_global_assignment -name SYSTEMVERILOG_FILE $vlog
}

# Read in QIP
if { [llength $QUARTUS_QIP] > 0 } {
    foreach qip $QUARTUS_QIP {
        set_global_assignment -name QIP_FILE $qip
    }
}

# Read in SDC
if { [llength $QUARTUS_SDC] > 0 } {
    foreach sdc $QUARTUS_SDC {
        set_global_assignment -name SDC_FILE $sdc
    }
}

set_global_assignment -name TOP_LEVEL_ENTITY $QUARTUS_TOP

# source pin assignment
source $QUARTUS_PIN

# additional assignment for CYCLONE II
if { $QUARTUS_FAMILY eq "Cyclone II" } {
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name USE_CONFIGURATION_DEVICE ON
}

export_assignments

# ------------------------------------------
# Synthesis(map), Implementation(fit), and assemble
# ------------------------------------------

package require ::quartus::flow
execute_module -tool map
execute_module -tool fit
execute_module -tool asm

project_close
