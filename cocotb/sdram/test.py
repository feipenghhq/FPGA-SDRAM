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
from random import randint, sample
from env import Env

DW = 16
AW = 25

D_LIMIT = (1 << DW) - 1
A_LIMIT = (1 << AW) - 1


@cocotb.test()
async def test_initialization(dut):
    env = Env(dut, dut.clk)
    await env.setup()
    await Timer(210, units="us")


@cocotb.test()
async def test_write(dut, it=10):
    env = Env(dut, dut.clk, DW, AW)
    await env.setup()
    await Timer(200, units="us")
    for i in range(it):
        address = randint(0, A_LIMIT)
        data = randint(0, D_LIMIT)
        await env.avalon.write(address, data, 0x3)
    await Timer(1, units="us")

@cocotb.test()
async def test_read(dut, it=10):
    env = Env(dut, dut.clk, DW, AW)
    await env.setup()
    await Timer(200, units="us")
    addresses = []
    golden = []
    for i in range(it):
        address = randint(0, A_LIMIT)
        data = randint(0, D_LIMIT)
        await env.avalon.write(address, data, 0x3)
        addresses.append(address)
        golden.append(data)
    for i in range(it):
        await env.avalon.read(addresses[i], 0x3)
    await Timer(1, units="us")
    assert golden == env.avalon.readdata, print(golden, "\n", env.avalon.readdata)

@cocotb.test()
async def test_random(dut, it=100):
    env = Env(dut, dut.clk, DW, AW)
    await env.setup()
    await Timer(200, units="us")
    addresses = []
    write_record = {}
    golden = []
    idx = 0
    for i in range(it):
        write = randint(0, 1)
        if write == 0:
            address = randint(0, A_LIMIT)
            data = randint(0, D_LIMIT)
            await env.avalon.write(address, data, 0x3)
            addresses.append(address)
            write_record[address] = data
            idx += 1
        else:
            if idx > 0:
                await env.avalon.read(addresses[idx-1], 0x3)
                golden.append(write_record[addresses[idx-1]])
    await Timer(1, units="us")
    assert golden == env.avalon.readdata

@cocotb.test()
async def memTestDataBus(dut):
    env = Env(entity=dut, clock=dut.clk)
    await env.setup()
    await Timer(200, units="us")
    pattern = 1
    for i in range(16):
        await env.avalon.write(0x0, pattern, 0x3)
        await env.avalon.read(0x0, 0x3)
        pattern = pattern << 1
    await Timer(1, units="us")
    pattern = 1
    for i in range(1):
        assert env.avalon.readdata[i] == pattern, f"{hex(env.avalon.read_data[i])} != {hex(pattern)}"
        pattern = pattern << 1

@cocotb.test()
async def memTestAddressBusStuckAtHigh(dut):
    """check for addr stuck at high"""
    env = Env(entity=dut, clock=dut.clk)
    await env.setup()
    await Timer(200, units="us")
    pattern = 0xAAAA
    antipattern = 0x5555
    # write default pattern at each of the power-of-two offsets
    offset = 4
    for i in range(23):
        await env.avalon.write(offset, pattern, 0x3)
        offset = offset << 1
    offset = 0
    await env.avalon.write(offset, antipattern, 0x3)
    offset = 4
    for i in range(23):
        await env.avalon.read(offset, 0x3)
        offset = offset << 1
    await Timer(1, units="us")
    for i in range(23):
        assert env.avalon.readdata[i] == pattern, f"stuck at high at address {hex(offset)}"

@cocotb.test()
async def memTestAddressBusStuckAtLow(dut):
    """check for addr stuck at low or shorted"""
    env = Env(entity=dut, clock=dut.clk)
    await env.setup()
    await Timer(200, units="us")
    pattern = 0xAAAA
    antipattern = 0x5555
    # write default pattern at each of the power-of-two offsets
    offset = 4
    for i in range(23):
        await env.avalon.write(offset, pattern, 0x3)
        offset = offset << 1
    # check for addr stuck at low or shorted
    await env.avalon.write(0, pattern, 0x3)
    test_offset = 4
    read_idx = []
    for i in range(23):
        await env.avalon.write(test_offset, antipattern, 0x3)
        offset = 4
        for j in range(23):
            await env.avalon.read(offset, 0x3)
            if offset != test_offset:
                read_idx.append(i * (j + 1) + j)
            offset <<= 1
        await env.avalon.write(test_offset, pattern, 0x3)
        test_offset <<= 1
    await Timer(1, units="us")
    for idx in read_idx:
        data = env.avalon.readdata[idx]
        assert data == pattern, f"idx = {idx} " + \
                                f"expected: {hex(pattern)}. actual: {hex(data)}"