# ---------------------------------------------------------------
# Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
#
# Author: Heqing Huang
# Date Created: 04/19/2022
# ---------------------------------------------------------------
# Basic Testbench for sdram
# ---------------------------------------------------------------


import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_initialization(dut):
    await Timer(100, units = "ns")