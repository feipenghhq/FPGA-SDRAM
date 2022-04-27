/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/19/2022
 * ---------------------------------------------------------------
 * SDRAM Controller Parameter
 * ---------------------------------------------------------------
 */


    // Avalon Bus Parameter
    parameter AVS_DW        = 16,          // Avalon data width
    parameter AVS_AW        = 25,          // Avalon address width

    // SDRAM Architecture
    parameter SDRAM_DATA    = 16,      // SDRAM data width
    parameter SDRAM_BANK    = 4,       // SDRAM bank number
    parameter SDRAM_ROW     = 13,      // SDRAM row number
    parameter SDRAM_COL     = 9,       // SDRAM column number
    parameter SDRAM_BA      = 2,       // SDRAM BA width
    parameter SDRAM_BL      = 1,       // SDRAM burst length

    // SDRAM Timing
    parameter CLK_PERIOD    = 10,       // Clock period in ns
    parameter INIT_REF_CNT  = 2,        // Refresh count in initialization process
    parameter CL            = 2,        // CAS latency (cycle)
    parameter tINIT         = 100,      // Initialization time (us)
    parameter tRAS          = 42,       // ACTIVE-to-PRECHARGE command (ns)
    parameter tRC           = 60,       // ACTIVE-to-ACTIVE command period (ns)
    parameter tRCD          = 18,       // ACTIVE-to-READ or WRITE delay (ns)
    parameter tRFC          = 60,       // AUTO REFRESH period (ns)
    parameter tRP           = 18,       // PRECHARGE command period (ns)
    parameter tRRD          = 12,       // ACTIVE bank a to ACTIVE bank b command (ns)
    parameter tREF          = 64        // Refresh period (ms)
