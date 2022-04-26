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
    assert golden == env.avalon.readdata

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