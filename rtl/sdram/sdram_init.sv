/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/23/2022
 * ---------------------------------------------------------------
 * SDRAM Controller - initialization process control
 * ---------------------------------------------------------------
 */

module sdram_init(
    // SDRAM signal
    sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n, sdram_cke, sdram_addr,
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
    output logic                            init_done;

    // sdram ports
    output logic                            sdram_cs_n;
    output logic                            sdram_ras_n;
    output logic                            sdram_cas_n;
    output logic                            sdram_we_n;
    output logic                            sdram_cke;
    output logic [SDRAM_ADDR_WIDTH-1:0]     sdram_addr;


    // --------------------------------
    // Signal Declaration
    // --------------------------------

    reg [INIT_CYCLE_WIDTH-1:0]  counter;
    reg [INIT_REF_CNT_WIDTH]    refresh_counter;

    logic counter_fire;
    logic refresh_counter_fire;

    logic                        counter_load;
    logic [INIT_CYCLE_WIDTH-1:0] counter_value;

    // --------------------------------
    // State Machine Declaration
    // --------------------------------
    localparam S_INIT_IDLE      = 0,
               S_INIT_POWER_UP  = 1,
               S_INIT_PRECHARGE = 2,
               S_INIT_REFRESH   = 3,
               S_INIT_LMR       = 4,
               S_INIT_DONE      = 5;
    localparam STATE_WIDTH      = S_INIT_DONE + 1;
    reg [STATE_WIDTH-1:0]   state;
    logic [STATE_WIDTH-1:0] state_next;

    // --------------------------------
    // Main logic
    // --------------------------------

    assign counter_fire = counter == 0;
    assign refresh_counter_fire = refresh_counter == 0;
    assign init_done = state[S_INIT_DONE];

    always @(posedge clk) begin
        if (reset) counter <= tINIT_CYCLE;
        else begin
            if (counter_load) counter <= counter_value;
            else if (!counter_fire) counter <= counter - 1'b1;
        end
    end

    always @(posedge clk) begin
        if (reset) refresh_counter <= INIT_REF_CNT - 1;
        else begin
            if (!refresh_counter_fire && counter_fire) refresh_counter <= refresh_counter - 1'b1;
        end
    end

    always @(posedge clk) begin
        if (reset)  state <= 'b1;   // IDLE
        else        state <= state_next;
    end

    // state transition
    always @* begin
        state_next = 0;
        // One-hot state machine
        case(1)
            state[S_INIT_IDLE]: begin
                                    state_next[S_INIT_POWER_UP] = 1'b1;
            end
            state[S_INIT_POWER_UP]: begin
                if (counter_fire)   state_next[S_INIT_PRECHARGE] = 1'b1;
                else                state_next[S_INIT_POWER_UP] = 1'b1;
            end
            state[S_INIT_PRECHARGE]: begin
                if (counter_fire)   state_next[S_INIT_REFRESH] = 1'b1;
                else                state_next[S_INIT_PRECHARGE] = 1'b1;
            end
            state[S_INIT_REFRESH]: begin
                if (counter_fire && refresh_counter_fire)
                                    state_next[S_INIT_LMR] = 1'b1;
                else                state_next[S_INIT_REFRESH] = 1'b1;
            end
            state[S_INIT_LMR]: begin
                if (counter_fire)   state_next[S_INIT_DONE] = 1'b1;
                else                state_next[S_INIT_LMR] = 1'b1;
            end
            state[S_INIT_DONE]: begin
                                    state_next[S_INIT_DONE] = 1'b1;
            end
        endcase
    end

    // output function logic
    always @* begin
        counter_load = 0;
        counter_value = 0;
        sdram_addr = 0;
        {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_NOP; // NOP
        case(1)
            // S_INIT_IDLE
            state[S_INIT_IDLE]: begin
                {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_INH; // INH
                sdram_cke = 1'b0;
            end
            state[S_INIT_POWER_UP]: begin
                if (counter_fire) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_PRECHARGE;   // PRECHARGE
                    sdram_addr[10] = 1'b1; // precharge all
                    counter_load = 1'b1;
                    counter_value = tRP_CYCLE - 1;
                end
            end
            state[S_INIT_PRECHARGE]: begin
                if (counter_fire && refresh_counter_fire) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_REFRESH;   // REFRESH
                    counter_load = 1'b1;
                    counter_value = tRP_CYCLE - 1;
                end
            end
            state[S_INIT_REFRESH]: begin
                if (counter_fire && !refresh_counter_fire)  begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_REFRESH;   // REFRESH
                end
                else if (counter_fire && refresh_counter_fire) begin
                    {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = SDRAM_CMD_REFRESH;   // LMR
                    sdram_addr[2:0] = MR_BURST_LENGTH;
                    sdram_addr[3]   = MR_BURST_TYPE;
                    sdram_addr[6:4] = CL;
                    sdram_addr[8:7] = 0;
                    sdram_addr[9]   = MR_WRITE_BURST_MODE;
                end
            end
        endcase
    end

endmodule


