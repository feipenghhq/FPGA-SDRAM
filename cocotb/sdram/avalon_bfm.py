# ---------------------------------------------------------------
# Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
#
# Author: Heqing Huang
# Date Created: 04/25/2022
# ---------------------------------------------------------------
# SDRAM Controller - avalon pipelined bfm
# ---------------------------------------------------------------


import cocotb
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb_bus.drivers import BusDriver


class AvalonBFM(BusDriver):

    """
    Avalon Memory Mapped Host Driver with monitor interface
    """

    _signals = [
        "read",
        "write",
        "waitrequest",
        "address",
        "byteenable",
        "writedata",
        "readdata",
        "readdatavalid",
    ]

    def __init__(self, entity, name, clock, dw, aw, **kwargs):
        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.entity = entity
        self.name = name
        self.clock = clock
        self.dw = dw
        self.aw = aw
        self.nbyte = int(self.dw / 8)
        self.readdata = []
        self.writedata = []
        self._clear()

    def _clear(self):
        """ Clear all the input signal to zero """
        self.bus.read.setimmediatevalue(0)
        self.bus.write.setimmediatevalue(0)
        self.bus.address.setimmediatevalue(0)
        self.bus.byteenable.setimmediatevalue(0)
        self.bus.writedata.setimmediatevalue(0)

    async def write(self, address, data, byteenable, sync=True):
        """ Write a data to the bus """
        if sync:
            await RisingEdge(self.clock)
        self.entity.log.debug(f"[Avalon BFM] Sending write request. Address: {hex(address):<10} Data: {hex(data):<10}")
        # send the write request
        self.bus.write.value = 1
        self.bus.address.value = address
        self.bus.writedata.value = data
        self.bus.byteenable.value = byteenable
        # wait for the waitrequest
        await self._wait_for_nsignal(self.bus.waitrequest)
        # de-assert request
        await RisingEdge(self.clock)
        self.bus.write.value = 0

    async def read(self, address, byteenable, sync=True):
        """ Read a data from the bus """
        if sync:
            await RisingEdge(self.clock)
        self.entity.log.debug(f"[Avalon BFM] Sending read request. Address: {hex(address)}")
        # send the read request
        self.bus.read.value = 1
        self.bus.address.value = address
        self.bus.byteenable = byteenable
        # wait for the waitrequest
        await self._wait_for_nsignal(self.bus.waitrequest)
        # de-assert read
        await RisingEdge(self.clock)
        self.bus.read.value = 0

    async def setup(self):
        await cocotb.start(self._monitor_read())

    async def _monitor_read(self):
        while True:
            await self._wait_for_signal(self.bus.readdatavalid)
            data = self.bus.readdata.value.integer
            self.entity.log.debug(f"[Avalon BFM] Get read data {hex(data)}")
            self.readdata.append(data)

