/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/19/2022
 * ---------------------------------------------------------------
 * SDRAM Controller
 * ---------------------------------------------------------------
 */

module avalon_sdram_controller #(
    parameter CMD_FIFO_SIZE     = 4,
    parameter WRITE_FIFO_SIZE   = 4,
    parameter READ_FIFO_SIZE    = 4
) (
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

    localparam CMD_FIFO_WIDTH = 1 + AVS_AW + AVS_BYTE;
    localparam WRITE_FIFO_WIDTH = SDRAM_DATA_WIDTH;
    localparam READ_FIFO_WIDTH = SDRAM_DATA_WIDTH;

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


    logic [SDRAM_DATA_WIDTH-1:0]        access_sdram_dq_read;
    logic [SDRAM_ADDR_WIDTH-1:0]        access_sdram_addr;
    logic [SDRAM_BANK_WIDTH-1:0]        access_sdram_ba;
    logic		                        access_sdram_cas_n;
    logic		                        access_sdram_cke;
    logic		                        access_sdram_cs_n;
    logic		                        access_sdram_dq_en;
    logic [SDRAM_DATA_WIDTH-1:0]        access_sdram_dq_write;
    logic [SDRAM_DQM_WIDTH-1:0]         access_sdram_dqm;
    logic		                        access_sdram_ras_n;
    logic		                        access_sdram_we_n;

    logic [AVS_AW-1:0]	                bus_req_address;
    logic [AVS_BYTE-1:0]                bus_req_byteenable;
    logic		                        bus_req_valid;
    logic		                        bus_req_write;
    logic [AVS_DW-1:0]	                bus_req_writedata;
    logic		                        bus_req_ready;

    logic [AVS_DW-1:0]	                bus_resp_readdata;
    logic		                        bus_resp_valid;

    logic                               cmd_push;
    logic                               cmd_pop;
    logic [CMD_FIFO_WIDTH-1:0]          cmd_fifo_din;
    logic [CMD_FIFO_WIDTH-1:0]          cmd_fifo_dout;
    logic                               cmd_fifo_full;
    logic                               cmd_fifo_empty;
    logic                               cmd_fifo_push;
    logic                               cmd_fifo_pop;

    logic [READ_FIFO_WIDTH-1:0]         read_fifo_dout;
    logic                               read_fifo_empty;
    logic                               read_fifo_full;
    logic [READ_FIFO_WIDTH-1:0]         read_fifo_din;
    logic                               read_fifo_pop;
    logic                               read_fifo_push;

    logic [WRITE_FIFO_WIDTH-1:0]        write_fifo_din;
    logic                               write_fifo_pop;
    logic                               write_fifo_push;
    logic [WRITE_FIFO_WIDTH-1:0]        write_fifo_dout;
    logic                               write_fifo_empty;
    logic                               write_fifo_full;

    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [AVS_DW-1:0]    avs_readdata;
    reg                 avs_readdatavalid;
    reg                 avs_waitrequest;
    // End of automatics

    /*AUTOWIRE*/

    /*AUTOREGINPUT*/

    // --------------------------------
    // main Logic
    // --------------------------------

    assign cmd_fifo_push = (avs_write | avs_read) & ~cmd_fifo_full;
    assign cmd_fifo_pop = bus_req_ready & ~cmd_fifo_empty;
    assign cmd_fifo_din = {avs_write, avs_address, avs_byteenable};

    assign write_fifo_push = cmd_fifo_push;
    assign write_fifo_pop = cmd_fifo_pop;
    assign write_fifo_din = avs_writedata;
    assign bus_req_writedata = write_fifo_dout;

    assign read_fifo_push = bus_resp_valid & ~read_fifo_full;   // data will be lost if the FIFO is full
    assign read_fifo_pop = ~read_fifo_empty;
    assign read_fifo_din = bus_resp_readdata;

    assign bus_req_valid = ~cmd_fifo_empty;
    assign {bus_req_write, bus_req_address, bus_req_byteenable} = cmd_fifo_dout;

    assign avs_readdatavalid = read_fifo_pop;
    assign avs_waitrequest = cmd_fifo_full;
    assign avs_readdata = read_fifo_dout;

    // Select between the initialzation logic and control logic
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
                sdram_cs_n      <= access_sdram_cs_n;
                sdram_ras_n     <= access_sdram_ras_n;
                sdram_cas_n     <= access_sdram_cas_n;
                sdram_we_n      <= access_sdram_we_n;
                sdram_cke       <= access_sdram_cke;
                sdram_addr      <= access_sdram_addr;
                sdram_ba        <= access_sdram_ba;
                sdram_dq_write  <= access_sdram_dq_write;
                sdram_dqm       <= access_sdram_dqm;
                sdram_dq_en     <= access_sdram_dq_en;
            end
            else begin
                sdram_cas_n     <= init_sdram_cas_n;
                sdram_cke       <= init_sdram_cke;
                sdram_cs_n      <= init_sdram_cs_n;
                sdram_ras_n     <= init_sdram_ras_n;
                sdram_we_n      <= init_sdram_we_n;
                sdram_addr      <= init_sdram_addr;
            end
        end
    end


    // --------------------------------
    // Module initialization
    // --------------------------------

    // SDRAM initialization module
    /* sdram_init AUTO_TEMPLATE (
            .\(sdram_.*\)   (init_\1[]),
        );
    */
    sdram_init
    u_sdram_init
    (/*AUTOINST*/
     // Outputs
     .init_done                         (init_done),
     .sdram_cs_n                        (init_sdram_cs_n),       // Templated
     .sdram_ras_n                       (init_sdram_ras_n),      // Templated
     .sdram_cas_n                       (init_sdram_cas_n),      // Templated
     .sdram_we_n                        (init_sdram_we_n),       // Templated
     .sdram_cke                         (init_sdram_cke),        // Templated
     .sdram_addr                        (init_sdram_addr[SDRAM_ADDR_WIDTH-1:0]), // Templated
     // Inputs
     .reset                             (reset),
     .clk                               (clk));


    // SDRAM read/write module
    /* sdram_access AUTO_TEMPLATE (
            .\(sdram_.*\)   (access_\1[]),
        );
    */
    sdram_access
    u_sdram_access
    (/*AUTOINST*/
     // Outputs
     .sdram_cs_n                        (access_sdram_cs_n),     // Templated
     .sdram_ras_n                       (access_sdram_ras_n),    // Templated
     .sdram_cas_n                       (access_sdram_cas_n),    // Templated
     .sdram_we_n                        (access_sdram_we_n),     // Templated
     .sdram_cke                         (access_sdram_cke),      // Templated
     .sdram_addr                        (access_sdram_addr[SDRAM_ADDR_WIDTH-1:0]), // Templated
     .sdram_ba                          (access_sdram_ba[SDRAM_BANK_WIDTH-1:0]), // Templated
     .sdram_dq_write                    (access_sdram_dq_write[SDRAM_DATA_WIDTH-1:0]), // Templated
     .sdram_dqm                         (access_sdram_dqm[SDRAM_DQM_WIDTH-1:0]), // Templated
     .sdram_dq_en                       (access_sdram_dq_en),    // Templated
     .bus_req_ready                     (bus_req_ready),
     .bus_resp_valid                    (bus_resp_valid),
     .bus_resp_readdata                 (bus_resp_readdata[AVS_DW-1:0]),
     // Inputs
     .reset                             (reset),
     .clk                               (clk),
     .init_done                         (init_done),
     .sdram_dq_read                     (access_sdram_dq_read[SDRAM_DATA_WIDTH-1:0]), // Templated
     .bus_req_valid                     (bus_req_valid),
     .bus_req_write                     (bus_req_write),
     .bus_req_address                   (bus_req_address[AVS_AW-1:0]),
     .bus_req_writedata                 (bus_req_writedata[AVS_DW-1:0]),
     .bus_req_byteenable                (bus_req_byteenable[AVS_BYTE-1:0]));


    /* sdram_fifo AUTO_TEMPLATE "u_\(\w+\)" (
            .clk        (clk),
            .reset      (reset),
            .\(.*\)     (@_\1),
        );
    */

   // command FIFO
    sdram_fifo #(
        .WIDTH (CMD_FIFO_WIDTH),
        .DEPTH (CMD_FIFO_SIZE)
    )
    u_cmd_fifo
    (/*AUTOINST*/
     // Outputs
     .dout                              (cmd_fifo_dout),         // Templated
     .full                              (cmd_fifo_full),         // Templated
     .empty                             (cmd_fifo_empty),        // Templated
     // Inputs
     .reset                             (reset),                 // Templated
     .clk                               (clk),                   // Templated
     .push                              (cmd_fifo_push),         // Templated
     .pop                               (cmd_fifo_pop),          // Templated
     .din                               (cmd_fifo_din));          // Templated


   // write data FIFO
    sdram_fifo #(
        .WIDTH (WRITE_FIFO_WIDTH),
        .DEPTH (WRITE_FIFO_SIZE)
    )
    u_write_fifo
    (/*AUTOINST*/
     // Outputs
     .dout                              (write_fifo_dout),       // Templated
     .full                              (write_fifo_full),       // Templated
     .empty                             (write_fifo_empty),      // Templated
     // Inputs
     .reset                             (reset),                 // Templated
     .clk                               (clk),                   // Templated
     .push                              (write_fifo_push),       // Templated
     .pop                               (write_fifo_pop),        // Templated
     .din                               (write_fifo_din));        // Templated


    // read data FIFO
    sdram_fifo #(
        .WIDTH (READ_FIFO_WIDTH),
        .DEPTH (READ_FIFO_SIZE)
    )
    u_read_fifo
    (/*AUTOINST*/
     // Outputs
     .dout                              (read_fifo_dout),        // Templated
     .full                              (read_fifo_full),        // Templated
     .empty                             (read_fifo_empty),       // Templated
     // Inputs
     .reset                             (reset),                 // Templated
     .clk                               (clk),                   // Templated
     .push                              (read_fifo_push),        // Templated
     .pop                               (read_fifo_pop),         // Templated
     .din                               (read_fifo_din));         // Templated

    // --------------------------------
    // Others
    // --------------------------------

    `ifndef SYNTHESIS
        initial begin
            display_parameter();
        end
    `endif

endmodule
