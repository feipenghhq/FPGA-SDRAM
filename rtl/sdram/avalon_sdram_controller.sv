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
    avs_waitrequest, avs_readdatavalid,
    // reset and clock
    reset, clk
);

    `include "sdram_params.svh"

    // --------------------------------
    // IO Ports
    // --------------------------------

    output reg                          sdram_cs_n;
    output reg                          sdram_ras_n;
    output reg                          sdram_cas_n;
    output reg                          sdram_we_n;
    output reg                          sdram_cke;
    output reg [SDRAM_ADDR_WIDTH-1:0]   sdram_addr;
    output reg [SDRAM_BANK_WIDTH-1:0]   sdram_ba;
    output reg [SDRAM_DATA_WIDTH-1:0]   sdram_dq_write;
    output reg [SDRAM_DQM_WIDTH-1:0]    sdram_dqm;
    output reg                          sdram_dq_en;
    input [SDRAM_DATA_WIDTH-1:0]        sdram_dq_read;

    input                               avs_read;
    input                               avs_write;
    input  [AVS_AW-1:0]                 avs_address;
    input  [AVS_DW-1:0]                 avs_writedata;
    input  [AVS_BYTE-1:0]               avs_byteenable;
    output [AVS_DW-1:0]                 avs_readdata;
    output                              avs_waitrequest;
    output                              avs_readdatavalid;

    input                               reset;
    input                               clk;

    // --------------------------------
    // Signal Declaration
    // --------------------------------

    logic		                        init_done;
    logic		                        init_sdram_cas_n;
    logic		                        init_sdram_cke;
    logic		                        init_sdram_cs_n;
    logic		                        init_sdram_ras_n;
    logic		                        init_sdram_we_n;
    logic [SDRAM_ADDR_WIDTH-1:0]		init_sdram_addr;


    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [AVS_DW-1:0]	avs_readdata;
    reg			avs_readdatavalid;
    reg			avs_waitrequest;
    // End of automatics

    /*AUTOWIRE*/


    // --------------------------------
    // main Logic
    // --------------------------------

    always @(posedge clk) begin
        if(reset) begin
            sdram_cs_n      <= 1'b1;
            sdram_ras_n     <= 1'b1;
            sdram_cas_n     <= 1'b1;
            sdram_we_n      <= 1'b1;
            sdram_cke       <=  'b0;
            sdram_addr      <=  'b0;
            sdram_ba        <=  'b0;
            sdram_dq_write  <=  'b0;
            sdram_dqm       <=  'b0;
            sdram_dq_en     <= 1'b0;
        end
        else begin
            if (init_done) begin


            end
            else begin
                sdram_cas_n <= init_sdram_cas_n;
                sdram_cke   <= init_sdram_cke;
                sdram_cs_n  <= init_sdram_cs_n;
                sdram_ras_n <= init_sdram_ras_n;
                sdram_we_n  <= init_sdram_we_n;
                sdram_addr  <= init_sdram_addr;
            end
        end
    end


    // --------------------------------
    // Module initialization
    // --------------------------------

    /* sdram_init AUTO_TEMPLATE (
            .\(sdram_.*\)   (init_\1[]),
        );
    */
    sdram_init u_sdram_init(/*AUTOINST*/
			    // Outputs
			    .init_done		(init_done),
			    .sdram_cs_n		(init_sdram_cs_n), // Templated
			    .sdram_ras_n	(init_sdram_ras_n), // Templated
			    .sdram_cas_n	(init_sdram_cas_n), // Templated
			    .sdram_we_n		(init_sdram_we_n), // Templated
			    .sdram_cke		(init_sdram_cke), // Templated
			    .sdram_addr		(init_sdram_addr[SDRAM_ADDR_WIDTH-1:0]), // Templated
			    // Inputs
			    .reset		(reset),
			    .clk		(clk));


    // --------------------------------
    // Others
    // --------------------------------

    `ifndef SYNTHESIS
        initial begin
            display_parameter();
        end
    `endif
endmodule


