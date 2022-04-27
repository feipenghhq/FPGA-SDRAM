/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/23/2022
 * ---------------------------------------------------------------
 * SDRAM Controller - access (read/write) process control
 * This is a simple SDRAM controller design. Each access only
 * read/write one data matching the bus size.
 * ---------------------------------------------------------------
 */

module sdram_access #(
    `include "sdram_params.svh"
) (
    input  logic                            reset,
    input  logic                            clk,
    input  logic                            init_done,

    // SDRAM signa,
    output logic                            sdram_cs_n,
    output logic                            sdram_ras_n,
    output logic                            sdram_cas_n,
    output logic                            sdram_we_n,
    output logic                            sdram_cke,
    output logic [SDRAM_ROW-1:0]            sdram_addr,
    output logic [SDRAM_BA-1:0]   sdram_ba,
    output logic [SDRAM_DATA-1:0]           sdram_dq_write,
    output logic [SDRAM_DATA/8-1:0]         sdram_dqm,
    output logic                            sdram_dq_en,
    input  logic [SDRAM_DATA-1:0]           sdram_dq_read,

    // input request signa,
    input  logic                            bus_req_valid,
    input  logic                            bus_req_write,
    input  logic [AVS_AW-1:0]               bus_req_address,
    input  logic [AVS_DW-1:0]               bus_req_writedata,
    input  logic [AVS_BYTE-1:0]             bus_req_byteenable,
    output logic                            bus_req_ready,

    // input response signal
    output logic                            bus_resp_valid,
    output logic [AVS_DW-1:0]               bus_resp_readdata
);

    `include "sdram_localparams.svh"

    // --------------------------------
    // IO Ports
    // --------------------------------



    // --------------------------------
    // Signal Declaration
    // --------------------------------

    reg [INIT_CYCLE_WIDTH-1:0]      counter;
    logic                           counter_fire;
    logic                           counter_load;
    logic [INIT_CYCLE_WIDTH-1:0]    counter_value;

    reg [REF_CYCLE_WIDTH-1:0]       refresh_counter;
    logic                           refresh_request;
    logic                           refresh_counter_load;

    reg                             req_is_write;
    reg [AVS_AW-1:0]                req_address;
    reg [AVS_DW-1:0]                req_writedata;
    reg [AVS_BYTE-1:0]              req_byteenable;

    logic                           req_fire;

    // Address Range

    `define SDRAM_COL_RANGE         SDRAM_COL+SDRAM_BYTE_WIDTH-1:SDRAM_BYTE_WIDTH
    `define SDRAM_ROW_RANGE         SDRAM_ROW+SDRAM_COL+SDRAM_BYTE_WIDTH-1:SDRAM_COL+SDRAM_BYTE_WIDTH
    `define SDRAM_BANK_RANGE        AVS_AW-1:SDRAM_ROW+SDRAM_COL+SDRAM_BYTE_WIDTH

    // --------------------------------
    // State Machine Declaration
    // --------------------------------
    localparam S_WAIT_INIT      = 0,
               S_IDLE           = S_WAIT_INIT       + 1,
               S_ACTIVE         = S_IDLE            + 1,
               S_ACTIVE_WAIT    = S_ACTIVE          + 1,
               S_READ_WAIT      = S_ACTIVE_WAIT     + 1,
               S_READ           = S_READ_WAIT       + 1,
               S_WRITE          = S_READ            + 1,
               S_WRITE_WAIT     = S_WRITE           + 1,
               S_PRECHARGE      = S_WRITE_WAIT      + 1,
               S_REFRESH        = S_PRECHARGE       + 1,
               STATE_WIDTH      = S_REFRESH         + 1;
    reg [STATE_WIDTH-1:0]   state;
    logic [STATE_WIDTH-1:0] state_next;

    // --------------------------------
    // Main logic
    // --------------------------------

    assign counter_fire = counter == 0;
    assign req_fire = bus_req_valid & bus_req_ready;
    assign refresh_request = refresh_counter < REF_THRESHOLD;

    always @(posedge clk) begin
        if (req_fire) begin
            req_is_write <= bus_req_write;
            req_address <= bus_req_address;
            req_writedata <= bus_req_writedata;
            req_byteenable <= bus_req_byteenable;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            counter <= 'b0;
            refresh_counter <= 'b0;
        end
        else begin
            if (counter_load) counter <= counter_value;
            else if (counter != 0) counter <= counter - 1'b1;

            if (refresh_counter_load) refresh_counter <= tREFS;
            else if (refresh_counter != 0) refresh_counter <= refresh_counter - 1'b1;
        end
    end

    // state transition
    always @(posedge clk) begin
        if (reset) begin
            state <= 1;
        end
        else begin
            state <= state_next;
        end
    end

    always @* begin
        state_next = 0;
        case(1)
            // S_WAIT_INIT
            state[S_WAIT_INIT]: begin
                if (init_done)          state_next[S_IDLE] = 1'b1;
                else                    state_next[S_WAIT_INIT] = 1'b1;
            end
            // S_IDLE
            state[S_IDLE]: begin
                if (refresh_request)    state_next[S_REFRESH] = 1'b1;
                else if (bus_req_valid) state_next[S_ACTIVE] = 1'b1;
                else                    state_next[S_IDLE] = 1'b1;
            end
            // S_REFRESH
            state[S_REFRESH]: begin
                if (counter_fire)       state_next[S_IDLE] = 1'b1;
                else                    state_next[S_REFRESH] = 1'b1;
            end
            // S_ACTIVE
            state[S_ACTIVE]: begin
                if (counter_fire) begin
                    if (req_is_write)   state_next[S_WRITE] = 1'b1;
                    else                state_next[S_READ_WAIT] = 1'b1;
                end
                else                    state_next[S_ACTIVE] = 1'b1;
            end
            // S_WRITE
            state[S_WRITE]: begin
                if (tWR_CYCLE == 1) begin
                    if (counter_fire)   state_next[S_PRECHARGE] = 1'b1;
                    else                state_next[S_WRITE] = 1'b1;
                end
                else begin
                    if (counter_fire)   state_next[S_WRITE_WAIT] = 1'b1;
                    else                state_next[S_WRITE] = 1'b1;
                end
            end
            // S_WRITE_WAIT
            state[S_WRITE_WAIT]: begin
                if (counter_fire)       state_next[S_PRECHARGE] = 1'b1;
                else                    state_next[S_WRITE_WAIT] = 1'b1;
            end
            // S_READ_WAIT
            state[S_READ_WAIT]: begin
                if (counter_fire)       state_next[S_READ] = 1'b1;
                else                    state_next[S_READ_WAIT] = 1'b1;
            end
            // S_READ
            // For simplicity, we schedule the precharge at the end of the read cycle.
            // But ideally this can be optimzied based on sdram data sheet
            state[S_READ]: begin
                if (counter_fire)       state_next[S_PRECHARGE] = 1'b1;
                else                    state_next[S_READ] = 1'b1;
            end
            // S_PRECHARGE
            state[S_PRECHARGE]: begin
                if (counter_fire)       state_next[S_IDLE] = 1'b1;  // FIXME: this can be optimzied to goto S_ACTIVE
                else                    state_next[S_PRECHARGE] = 1'b1;
            end
        endcase
    end



    // output function logic
    always @* begin

        {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_NOP; // NOP

        counter_load = '0;
        counter_value = 'x;

        sdram_cke = 1'b1;
        sdram_addr = 'x;
        sdram_ba = 'x;
        sdram_dq_en = '0;
        sdram_dq_write = 'x;

        bus_req_ready = 1'b0;

        bus_resp_readdata = 'x;
        bus_resp_valid = 1'b0;

        refresh_counter_load = 1'b0;

        case(1)
            // S_WAIT_INIT
            state[S_WAIT_INIT]: begin
                if (init_done)  refresh_counter_load = 1'b1;
            end
            // S_IDLE
            state[S_IDLE]: begin
                bus_req_ready = 1'b1;
                if (refresh_request) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_REFRESH; // REFRESH
                    counter_load = 1'b1;
                    counter_value = tRFC_CYCLE - 1;
                end
                else if (bus_req_valid) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_ACTIVE; // ACTIVE
                    sdram_addr = bus_req_address[`SDRAM_ROW_RANGE];
                    sdram_ba = bus_req_address[`SDRAM_BANK_RANGE];
                    counter_load = 1'b1;
                    counter_value = tRCD_CYCLE - 1;
                end
            end
            // S_REFRESH
            state[S_REFRESH]: begin
                refresh_counter_load = counter_fire;
            end
            // S_ACTIVE
            state[S_ACTIVE]: begin
                if (counter_fire) begin
                    // common signal
                    sdram_addr = 0;
                    sdram_addr[SDRAM_COL-1:0] = req_address[`SDRAM_COL_RANGE];
                    sdram_ba = req_address[`SDRAM_BANK_RANGE];
                    sdram_dqm = ~req_byteenable;
                    counter_load = 1'b1;
                    if (req_is_write) begin // -> Write
                        {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_WRITE; // WRITE
                        sdram_dq_en = 1'b1;
                        sdram_dq_write = req_writedata; // only write 1 data
                        counter_value = SDRAM_BL - 1;
                    end
                    else begin  // -> Read
                        {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_READ; // READ
                        counter_value = CL - 1;
                    end
                end
            end
            // S_WRITE
            state[S_WRITE]: begin
                // We only have one 1 write data for now, so no write logic here
                if (tWR_CYCLE == 1) begin // goto precharge directly
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_PRECHARGE; // PRECHARGE
                    sdram_addr[10] = 1'b1; // precharge all
                    counter_load = 1'b1;
                    counter_value = tRP_CYCLE - 1;
                end
                else begin  // goto S_WRITE_WAIT to wait tWR completion
                    counter_load = 1'b1;
                    counter_value = tWR_CYCLE - 1;
                end
            end
            // S_WRITE_WAIT
            state[S_WRITE_WAIT]: begin
                if (counter_fire) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_PRECHARGE; // PRECHARGE
                    sdram_addr[10] = 1'b1; // precharge all
                    counter_load = 1'b1;
                    counter_value = tRP_CYCLE - 1;
                end
            end
            // S_READ_WAIT
            state[S_READ_WAIT]: begin
                if (counter_fire) begin
                    counter_load = 1'b1;
                    counter_value = SDRAM_BL - 1;
                end
            end
            // S_READ
            state[S_READ]: begin
                // Here we only read 1 data at a time
                bus_resp_readdata = sdram_dq_read;
                bus_resp_valid = 1'b1;
                if (counter_fire) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_PRECHARGE; // PRECHARGE
                    sdram_addr[10] = 1'b1; // precharge all
                    counter_load = 1'b1;
                    counter_value = tRP_CYCLE - 1;
                end
            end
        endcase
    end

endmodule


