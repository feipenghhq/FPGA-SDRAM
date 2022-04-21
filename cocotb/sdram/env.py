import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

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

    def __init__(self, entity, clock):
        self.clock = clock
        self.entity = entity

    async def setup(self, period=10):
        await clockGen(self.entity, period=period)
        await resetGen(self.entity)
        await RisingEdge(self.clock)