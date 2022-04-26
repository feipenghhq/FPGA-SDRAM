# ---------------------------------------------------------------
# Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
#
# Author: Heqing Huang
# Date Created: 04/19/2022
# ---------------------------------------------------------------
# SDRAM Controller - testbench env
# ---------------------------------------------------------------


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from avalon_bfm import AvalonBFM

async def clockGen(dut, period=10):
    """ Generate Clock """
    c = Clock(dut.clk, period, units="ns")
    await cocotb.start(c.start())

async def resetGen(dut, time=100):
    """ Reset the design """
    dut.reset.value = 1
    await Timer(time, units="ns")
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)
    dut.log.info("Reset Done!")

class Env:

    def __init__(self, entity, clock, dw=16, aw=25):
        self.clock = clock
        self.entity = entity
        self.avalon = AvalonBFM(entity, "avs", clock, dw, aw)

    async def setup(self, period=10):
        await clockGen(self.entity, period=period)
        await resetGen(self.entity)
        await RisingEdge(self.clock)
        await self.avalon.setup()
