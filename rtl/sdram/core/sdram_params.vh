/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/19/2022
 * ---------------------------------------------------------------
 * SDRAM Controller Parameter
 * ---------------------------------------------------------------
 */

`ifndef __SDRAM_PARAM__
`define __SDRAM_PARAM__

    // Avalon Bus
    parameter AVS_DW = 32;
    parameter AVS_AW = 23;
    localparam AVS_BW = AVS_DW/8;

    // SDRAM Architecture

    parameter DATA_WIDTH = 16;
    parameter CHIP_SELECT = 1;
    parameter BANK = 4;
    parameter ROW = 12;
    parameter COL = 8;

    localparam BYTE = DATA_WIDTH / 8;
    localparam ADDR_WIDTH = (ROW > COL ? ROW : COL);
    localparam BYTE_WIDTH = $clog2(BYTE);
    localparam BANK_WIDTH = $clog2(BANK);
    localparam DQM_WIDTH = BYTE;

    // Timing Configuration

    parameter CLK_PERIOD = 20;  // Clock period in ns
    parameter CL = 2;
    parameter tINIT = 100;      // Initialization time in us
    parameter tRAS = 40;        // ACTIVE-to-PRECHARGE command (ns)
    parameter tRC = 55;         // ACTIVE-to-ACTIVE command period (ns)
    parameter tRCD =  15;       // ACTIVE-to-READ or WRITE delay (ns)
    parameter tRFC = 55;        // AUTO REFRESH period (ns)
    parameter tRP = 15;         // PRECHARGE command period (ns)
    parameter tRRD = 10;        // ACTIVE bank a to ACTIVE bank b command (ns)
    parameter tREF = 64;        // Refresh period (ms)

    localparam tINIT_CYCLE = calculate_cycle(tINIT * 1000);
    localparam tRAS_CYCLE = calculate_cycle(tRAS);
    localparam tRC_CYCLE = calculate_cycle(tRC);
    localparam tRCD_CYCLE = calculate_cycle(tRCD);
    localparam tRFC_CYCLE = calculate_cycle(tRFC);
    localparam tRP_CYCLE = calculate_cycle(tRP);
    localparam tRRD_CYCLE = calculate_cycle(tRRD);
    localparam tREF_CYCLE = calculate_cycle(tREF * 10000000 / (1 << ROW) / CLK_PERIOD);

    function automatic integer calculate_cycle;
        input integer param;
        calculate_cycle = $ceil(param * 1.0/CLK_PERIOD);
    endfunction

    // Report the parameters
    `ifndef SYNTHESIS
        initial begin
            $display("tINIT_CYCLE = %d", tINIT_CYCLE);
            $display("tRAS_CYCLE  = %d", tRAS_CYCLE);
            $display("tRC_CYCLE   = %d", tRC_CYCLE);
            $display("tRCD_CYCLE  = %d", tRCD_CYCLE);
            $display("tRFC_CYCLE  = %d", tRFC_CYCLE);
            $display("tRP_CYCLE   = %d", tRP_CYCLE);
            $display("tRRD_CYCLE  = %d", tRRD_CYCLE);
            $display("tREF_CYCLE  = %d", tREF_CYCLE);
        end
    `endif

`endif