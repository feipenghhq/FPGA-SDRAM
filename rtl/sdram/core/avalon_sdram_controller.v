/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/19/2022
 * ---------------------------------------------------------------
 * SDRAM Controller
 * ---------------------------------------------------------------
 */

module avalon_sdram_controller(
    // SDRAM signal
    sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n, sdram_addr, sdram_ba,
    sdram_dq_read, sdram_dq_write, sdram_dq_en, sdram_dqm, sdram_cke,
    // Avalon interface
    avs_read, avs_write, avs_address, avs_writedata, avs_byteenable, avs_readdata,
    avs_waitrequest, avs_readdatavalid
);

    `include "sdram_params.vh"

    // --------------------------------
    // IO Ports
    // --------------------------------

    output reg  sdram_cs_n;
    output reg  sdram_ras_n;
    output reg  sdram_cas_n;
    output reg  sdram_we_n;
    output reg  sdram_cke;
    output reg [ADDR_WIDTH-1:0] sdram_addr;
    output reg [BANK_WIDTH-1:0] sdram_ba;
    output reg [DATA_WIDTH-1:0] sdram_dq_write;
    output reg [DQM_WIDTH-1:0]  sdram_dqm;
    output reg sdram_dq_en;
    input      sdram_dq_read;

    output avs_read;
    output avs_write;
    output [AVS_AW-1:0] avs_address;
    output [AVS_DW-1:0] avs_writedata;
    output [AVS_BW-1:0] avs_byteenable;
    input  [AVS_DW-1:0] avs_readdata;
    output avs_waitrequest;
    output avs_readdatavalid;

endmodule

