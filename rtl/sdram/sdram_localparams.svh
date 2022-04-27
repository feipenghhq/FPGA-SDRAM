/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/26/2022
 * ---------------------------------------------------------------
 * SDRAM local Parameter
 * ---------------------------------------------------------------
 */

    // --------------------------------
    // Internal parameters
    // --------------------------------

    localparam AVS_BYTE     = AVS_DW/8;
    localparam SDRAM_BYTE   = SDRAM_DATA / 8;
    localparam tREFS        = tREF * 1_000_000 / (1 << SDRAM_ROW); // time to issue refresh command (ns)

    // Convert Timing parameters to actual clock cycles
    localparam tINIT_OVH    = 100;       // Give some overhead cycle for initizaltion
    localparam tINIT_CYCLE  = calculate_cycle(tINIT * 1000) + tINIT_OVH;
    localparam tRAS_CYCLE   = calculate_cycle(tRAS);     // ACTIVE-to-PRECHARGE command (ns)
    localparam tRC_CYCLE    = calculate_cycle(tRC);      // ACTIVE-to-ACTIVE command period (ns)
    localparam tRCD_CYCLE   = calculate_cycle(tRCD);     // ACTIVE-to-READ or WRITE delay (ns)
    localparam tRFC_CYCLE   = calculate_cycle(tRFC);     // AUTO REFRESH period (ns)
    localparam tRP_CYCLE    = calculate_cycle(tRP);      // PRECHARGE command period (ns)
    localparam tRRD_CYCLE   = calculate_cycle(tRRD);     // ACTIVE bank a to ACTIVE bank b command (ns)
    localparam tREFS_CYCLE  = calculate_cycle(tREFS);    // Refresh period (ns)
    localparam tMRD_CYCLE   = 3;                         // load mode register cycle. fixed to 3
    localparam tWR_CYCLE    = CLK_PERIOD < 15 ? 2 : 1;
    localparam WRITE_CYCLE  = tWR_CYCLE + SDRAM_BL;      // Actual write cycle
    localparam READ_CYCLE   = CL + SDRAM_BL;             // Actual read cycle

    // Signal width
    localparam SDRAM_BYTE_WIDTH   = $clog2(SDRAM_BYTE);
    localparam INIT_CYCLE_WIDTH   = $clog2(tINIT_CYCLE+1);
    localparam CMD_CYCLE_WIDTH    = 4;
    localparam INIT_REF_CNT_WIDTH = $clog2(INIT_REF_CNT);
    localparam BURST_COUNT_WIDTH  = $clog2(SDRAM_BL+1);
    localparam REF_CYCLE_WIDTH    = $clog2(tREFS+1);

    // Mode register value
    localparam MR_BURST_TYPE        = 0;
    localparam MR_WRITE_BURST_MODE  = 0;
    localparam MR_BURST_LENGTH      = SDRAM_BL == 1 ? 0 :
                                      SDRAM_BL == 2 ? 1 :
                                      SDRAM_BL == 4 ? 2 :
                                      SDRAM_BL == 8 ? 3 : 4 ;

    localparam REF_THRESHOLD        = 20;

    // --------------------------------
    // SDRAM Command
    // --------------------------------
    // {cs_n, ras_n, cas_n, we_n} = SDRAM_CMD_XXX
    localparam SDRAM_CMD_INH        = 4'b1111;
    localparam SDRAM_CMD_NOP        = 4'b0111;
    localparam SDRAM_CMD_ACTIVE     = 4'b0011;
    localparam SDRAM_CMD_READ       = 4'b0101;
    localparam SDRAM_CMD_WRITE      = 4'b0100;
    localparam SDRAM_CMD_PRECHARGE  = 4'b0010;
    localparam SDRAM_CMD_REFRESH    = 4'b0001;
    localparam SDRAM_CMD_LMR        = 4'b0000;

    // --------------------------------
    // Other function
    // --------------------------------

    function automatic integer calculate_cycle;
        input integer param;
        integer cal;
        cal = param / CLK_PERIOD;
        if (cal * CLK_PERIOD != param)
            cal = cal + 1;
        calculate_cycle = cal;
    endfunction
