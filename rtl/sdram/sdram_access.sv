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

module sdram_access (
    // SDRAM signal
    sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n, sdram_addr, sdram_ba,
    sdram_dq_read, sdram_dq_write, sdram_dq_en, sdram_dqm, sdram_cke,
    // input request signal
    bus_req_valid, bus_req_write, bus_req_address, bus_req_writedata, bus_req_byteenable, bus_req_ready,
    // input response signal
    bus_resp_valid, bus_resp_readdata,
    // other signal
    init_done,
    reset, clk
);

    `include "sdram_params.svh"

    // --------------------------------
    // IO Ports
    // --------------------------------

    input  logic                            reset;
    input  logic                            clk;
    input  logic                            init_done;

    // SDRAM signal
    output logic                            sdram_cs_n;
    output logic                            sdram_ras_n;
    output logic                            sdram_cas_n;
    output logic                            sdram_we_n;
    output logic                            sdram_cke;
    output logic [SDRAM_ADDR_WIDTH-1:0]     sdram_addr;
    output logic [SDRAM_BANK_WIDTH-1:0]     sdram_ba;
    output logic [SDRAM_DATA_WIDTH-1:0]     sdram_dq_write;
    output logic [SDRAM_DQM_WIDTH-1:0]      sdram_dqm;
    output logic                            sdram_dq_en;
    input  logic [SDRAM_DATA_WIDTH-1:0]     sdram_dq_read;

    // input request signal
    input  logic                            bus_req_valid;
    input  logic                            bus_req_write;
    input  logic [AVS_AW-1:0]               bus_req_address;
    input  logic [AVS_DW-1:0]               bus_req_writedata;
    input  logic [AVS_BYTE-1:0]             bus_req_byteenable;
    output logic                            bus_req_ready;

    // input response signal
    output logic                            bus_resp_valid;
    output logic [AVS_DW-1:0]               bus_resp_readdata;

    // --------------------------------
    // Signal Declaration
    // --------------------------------

    reg [INIT_CYCLE_WIDTH-1:0]      counter;
    logic                           counter_fire;
    logic                           counter_load;
    logic [INIT_CYCLE_WIDTH-1:0]    counter_value;

    reg                             req_is_write;
    reg [AVS_AW-1:0]                req_address;
    reg [AVS_DW-1:0]                req_writedata;
    reg [AVS_BYTE-1:0]              req_byteenable;

    logic                           req_fire;

    // --------------------------------
    // State Machine Declaration
    // --------------------------------
    localparam S_IDLE           = 0,
               S_ACTIVE         = 1,
               S_ACTIVE_WAIT    = 2,
               S_READ           = 3,
               S_READ_WAIT      = 4,
               S_WRITE          = 5,
               S_WRITE_WAIT     = 6,
               S_PRECHARGE      = 7,
               S_PRECHARGE_WAIT = 8,
               S_REFRESH        = 9,
               S_REFRESH_WAIT   = 10;
    localparam STATE_WIDTH      = S_REFRESH_WAIT + 1;
    reg [STATE_WIDTH-1:0]   state;
    logic [STATE_WIDTH-1:0] state_next;

    // --------------------------------
    // Main logic
    // --------------------------------

    assign counter_fire = counter == 0;
    assign req_fire = bus_req_valid & bus_req_ready;

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
        end
        else begin
            if (counter_load) counter <= counter_value;
            else if (counter != 0) counter <= counter - 1'b1;
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
            // S_IDLE
            state[S_IDLE]: begin
                if (bus_req_valid)      state_next[S_ACTIVE] = 1'b1;
                else                    state_next[S_IDLE] = 1'b1;
            end
            // S_ACTIVE
            state[S_ACTIVE]: begin
                if (counter_fire) begin
                    if (req_is_write)   state_next[S_WRITE] = 1'b1;
                    else                state_next[S_READ] = 1'b1;
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

        case(1)
            // S_IDLE
            state[S_IDLE]: begin
                bus_req_ready = 1'b1;
                if (bus_req_valid) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_ACTIVE; // ACTIVE
                    sdram_addr = bus_req_address[`SDRAM_ROW_RANGE];
                    sdram_ba = bus_req_address[`SDRAM_BANK_RANGE];
                    counter_load = 1'b1;
                    counter_value = tRCD_CYCLE - 1;
                end
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
                        // TBD
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
        endcase
    end

endmodule


