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
    parameter AVS_DW = 16;
    parameter AVS_AW = 25;

    localparam AVS_BW = AVS_DW/8;

    // SDRAM Architecture

    parameter SDRAM_DATA = 16;
    parameter SDRAM_BANK = 4;
    parameter SDRAM_ROW  = 13;
    parameter SDRAM_COL  = 9;

    parameter BURST_LENGTH      = 0;
    parameter BURST_TYPE        = 0;
    parameter WRITE_BURST_MODE  = 0;

    localparam SDRAM_BYTE       = SDRAM_DATA / 8;

    localparam SDRAM_DATA_WIDTH = SDRAM_DATA;
    localparam SDRAM_ADDR_WIDTH = SDRAM_ROW;
    localparam SDRAM_BANK_WIDTH = $clog2(SDRAM_BANK);
    localparam SDRAM_DQM_WIDTH  = SDRAM_BYTE;


    // Timing Configuration

    parameter CLK_PERIOD    = 10;       // Clock period in ns
    parameter INIT_REF_CNT  = 2;        // Refresh count in initialization process
    parameter CL            = 2;
    parameter tINIT         = 100;      // Initialization time in us
    parameter tRAS          = 42;       // ACTIVE-to-PRECHARGE command (ns)
    parameter tRC           = 60;       // ACTIVE-to-ACTIVE command period (ns)
    parameter tRCD          = 18;       // ACTIVE-to-READ or WRITE delay (ns)
    parameter tRFC          = 60;       // AUTO REFRESH period (ns)
    parameter tRP           = 18;       // PRECHARGE command period (ns)
    parameter tRRD          = 12;       // ACTIVE bank a to ACTIVE bank b command (ns)
    parameter tREF          = 64;       // Refresh period (ms)

    localparam tINIT_OVER  = 100;
    localparam tINIT_CYCLE = calculate_cycle(tINIT * 1000) + tINIT_OVER;    // Give some overhead cycle for initizaltion
    localparam tRAS_CYCLE  = calculate_cycle(tRAS);
    localparam tRC_CYCLE   = calculate_cycle(tRC);
    localparam tRCD_CYCLE  = calculate_cycle(tRCD);
    localparam tRFC_CYCLE  = calculate_cycle(tRFC);
    localparam tRP_CYCLE   = calculate_cycle(tRP);
    localparam tRRD_CYCLE  = calculate_cycle(tRRD);
    localparam tREF_CYCLE  = calculate_cycle(tREF * 10000000 / (1 << SDRAM_ROW) / CLK_PERIOD);
    localparam tMRD_cycle  = 3;   // load mode register cycle

    localparam INIT_CYCLE_WIDTH   = $clog2(tINIT_CYCLE+1);
    localparam CMD_CYCLE_WIDTH    = 4;
    localparam INIT_REF_CNT_WIDTH = $clog2(INIT_REF_CNT);

    function automatic integer calculate_cycle;
        input integer param;
        calculate_cycle = $ceil(param * 1.0/CLK_PERIOD);
    endfunction

    // Report the parameters
    `ifndef SYNTHESIS
        initial begin
            $display("%m :    SDRAM Timing:");
            $display("%m :    tINIT_CYCLE = %d", tINIT_CYCLE);
            $display("%m :    tRAS_CYCLE  = %d", tRAS_CYCLE);
            $display("%m :    tRC_CYCLE   = %d", tRC_CYCLE);
            $display("%m :    tRCD_CYCLE  = %d", tRCD_CYCLE);
            $display("%m :    tRFC_CYCLE  = %d", tRFC_CYCLE);
            $display("%m :    tRP_CYCLE   = %d", tRP_CYCLE);
            $display("%m :    tRRD_CYCLE  = %d", tRRD_CYCLE);
            $display("%m :    tREF_CYCLE  = %d", tREF_CYCLE);
        end
    `endif


`endif