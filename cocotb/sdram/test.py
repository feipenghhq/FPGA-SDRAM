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

from env import Env

@cocotb.test()
async def test_initialization(dut):
    env = Env(dut, dut.clk)
    await env.setup()
    await Timer(200, units = "us")
