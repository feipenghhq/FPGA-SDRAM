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

    output reg sdram_cs_n;
    output reg sdram_ras_n;
    output reg sdram_cas_n;
    output reg sdram_we_n;
    output reg sdram_cke;
    output reg [SDRAM_ADDR_WIDTH-1:0] sdram_addr;
    output reg [SDRAM_BANK_WIDTH-1:0] sdram_ba;
    output reg [SDRAM_DATA_WIDTH-1:0] sdram_dq_write;
    output reg [SDRAM_DQM_WIDTH-1:0]  sdram_dqm;
    output reg sdram_dq_en;
    input [SDRAM_DATA_WIDTH-1:0] sdram_dq_read;

    output avs_read;
    output avs_write;
    output [AVS_AW-1:0] avs_address;
    output [AVS_DW-1:0] avs_writedata;
    output [AVS_BW-1:0] avs_byteenable;
    input  [AVS_DW-1:0] avs_readdata;
    output avs_waitrequest;
    output avs_readdatavalid;

    input reset;
    input clk;

    // --------------------------------
    // Signal Declaration
    // --------------------------------

    logic sdram_cs_n_next;
    logic sdram_ras_n_next;
    logic sdram_cas_n_next;
    logic sdram_we_n_next;
    logic sdram_cke_next;
    logic [SDRAM_ADDR_WIDTH-1:0] sdram_addr_next;
    logic [SDRAM_BANK_WIDTH-1:0] sdram_ba_next;
    logic [SDRAM_DATA_WIDTH-1:0] sdram_dq_write_next;
    logic [SDRAM_DQM_WIDTH-1:0]  sdram_dqm_next;
    logic sdram_dq_en_next;

    reg [INIT_CYCLE_WIDTH-1:0] init_counter;
    reg [INIT_REF_CNT_WIDTH] init_ref_counter;
    reg [CMD_CYCLE_WIDTH-1:0] cmd_counter;

    logic init_counter_fire;
    logic cmd_counter_fire;
    logic cmd_counter_load;
    logic [CMD_CYCLE_WIDTH-1:0] cmd_counter_load_value;
    logic init_ref_counter_fire;

    // --------------------------------
    // State Machine Declaration
    // --------------------------------
    localparam S_INIT_IDLE = 0,
               S_INIT_POWER_UP = 1,
               S_INIT_PRECHARGE = 2,
               S_INIT_REFRESH = 3,
               S_INIT_LMR = 4,
               S_IDLE = 5,
               S_REFRESH = 6,
               S_ACTIVE = 7,
               S_READ = 8,
               S_WRITE = 9,
               S_PRECHARGE = 10;
    localparam STATE_WIDTH = S_PRECHARGE + 1;

    reg [STATE_WIDTH-1:0] state;
    logic [STATE_WIDTH-1:0] state_next;

    // --------------------------------
    // Main logic
    // --------------------------------

    assign init_counter_fire = init_counter == 0;
    assign cmd_counter_fire = cmd_counter == 0;
    assign init_ref_counter_fire = init_ref_counter == INIT_REF_CNT-1;

    // init counter
    always @(posedge clk) begin
        if (reset) begin
            init_counter <= tINIT_CYCLE;
        end
        else begin
            init_counter <= init_counter - 1'b1;
        end
    end

    // cmd counter
    always @(posedge clk) begin
        if (reset) begin
            cmd_counter <= 0;
        end
        else begin
            if (cmd_counter_load)
                cmd_counter <= cmd_counter_load_value;
            else
                cmd_counter <= cmd_counter - 1'b1;
        end
    end

    // init ref counter
    always @(posedge clk) begin
        if (reset) begin
            init_ref_counter <= 0;
        end
        else begin
            if (cmd_counter_fire)
                init_ref_counter <= init_ref_counter + 1'b1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= 'b1;
            sdram_cs_n <= 'b1;
            sdram_ras_n <= 'b1;
            sdram_cas_n <= 'b1;
            sdram_we_n <= 'b1;
            sdram_cke <= 'b0;
            sdram_addr <= 'b0;
            sdram_ba <= 'b0;
            sdram_dq_write <= 'b0;
            sdram_dqm <= 'b0;
            sdram_dq_en <= 'b0;
        end
        else begin
            state <= state_next;
            sdram_cs_n <= sdram_cs_n_next;
            sdram_ras_n <= sdram_ras_n_next;
            sdram_cas_n <= sdram_cas_n_next;
            sdram_we_n <= sdram_we_n_next;
            sdram_cke <= sdram_cke_next;
            sdram_addr <= sdram_addr_next;
            sdram_ba <= sdram_ba_next;
            sdram_dq_write <= sdram_dq_write_next;
            sdram_dqm <= sdram_dqm_next;
            sdram_dq_en <= sdram_dq_en_next;
        end
    end

    // state transition
    always @* begin
        state_next = 0;
        case(1)
            state[S_INIT_IDLE]: begin
                state_next[S_INIT_POWER_UP] = 1'b1;
            end
            state[S_INIT_POWER_UP]: begin
                if (init_counter_fire) state_next[S_INIT_PRECHARGE] = 1'b1;
                else state_next[S_INIT_POWER_UP] = 1'b1;
            end
            state[S_INIT_PRECHARGE]: begin
                if (cmd_counter_fire) state_next[S_INIT_REFRESH] = 1'b1;
                else state_next[S_INIT_PRECHARGE] = 1'b1;
            end
            state[S_INIT_REFRESH]: begin
                if (cmd_counter_fire && init_ref_counter_fire) state_next[S_INIT_LMR] = 1'b1;
                else state_next[S_INIT_REFRESH] = 1'b1;
            end
            state[S_INIT_LMR]: begin
                if (cmd_counter_fire) state_next[S_IDLE] = 1'b1;
                else state_next[S_INIT_LMR] = 1'b1;
            end
        endcase
    end


    // output function logic - combination
    always @* begin

        // default value
        cmd_counter_load = 1'b0;
        cmd_counter_load_value = 'bx;

        CMD_NOP();
        sdram_cke_next = 1'b1;
        sdram_addr_next = 'b0;
        sdram_ba_next = 'b0;
        sdram_dq_write_next = 'b0;
        sdram_dqm_next = 'b0;
        sdram_dq_en_next = 'b0;

        case(1)
            state[S_INIT_IDLE]: begin
                CMD_INH();
                sdram_cke_next = 1'b0;
            end
            state[S_INIT_POWER_UP]: begin
                CMD_NOP();
                if (init_counter_fire) begin
                    cmd_counter_load = 1'b1;
                    cmd_counter_load_value = tRP_CYCLE;
                    CMD_PRECHARGE();
                    sdram_addr_next[10] = 1'b1; // Precharage all
                end
            end
            state[S_INIT_PRECHARGE]: begin
                if (cmd_counter_fire && init_ref_counter_fire) begin
                    cmd_counter_load = 1'b1;
                    cmd_counter_load_value = tRFC_CYCLE;
                    CMD_REFRESH();
                end
            end
            state[S_INIT_REFRESH]: begin
                if (cmd_counter_fire && !init_ref_counter_fire)  begin
                    cmd_counter_load = 1'b1;
                    cmd_counter_load_value = tRFC_CYCLE;
                    CMD_REFRESH();
                end
                else if (cmd_counter_fire && init_ref_counter_fire) begin
                    cmd_counter_load = 1'b1;
                    cmd_counter_load_value = tMRD_cycle;
                    CMD_LMR();
                    sdram_addr_next[2:0] = BURST_LENGTH;
                    sdram_addr_next[3] = BURST_TYPE;
                    sdram_addr_next[6:4] = CL;
                    sdram_addr_next[8:7] = 0;
                    sdram_addr_next[9] = WRITE_BURST_MODE;
                    sdram_ba_next = 0;
                end
            end
        endcase
    end

    // --------------------------------
    // SDRAM command
    // --------------------------------

    function void CMD_INH();
        sdram_cs_n_next  = 1'b1;
        sdram_ras_n_next = 1'b1;
        sdram_cas_n_next = 1'b1;
        sdram_we_n_next  = 1'b1;
    endfunction

    function void CMD_NOP();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b1;
        sdram_cas_n_next = 1'b1;
        sdram_we_n_next  = 1'b1;
    endfunction

    function void CMD_ACTIVE();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b0;
        sdram_cas_n_next = 1'b1;
        sdram_we_n_next  = 1'b1;
    endfunction

    function void CMD_READ();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b1;
        sdram_cas_n_next = 1'b0;
        sdram_we_n_next  = 1'b1;
    endfunction

    function void CMD_WRITE();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b1;
        sdram_cas_n_next = 1'b0;
        sdram_we_n_next  = 1'b0;
    endfunction

    function void CMD_PRECHARGE();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b0;
        sdram_cas_n_next = 1'b1;
        sdram_we_n_next  = 1'b0;
    endfunction

    function void CMD_REFRESH();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b0;
        sdram_cas_n_next = 1'b0;
        sdram_we_n_next  = 1'b1;
    endfunction

    function void CMD_LMR();
        sdram_cs_n_next  = 1'b0;
        sdram_ras_n_next = 1'b0;
        sdram_cas_n_next = 1'b0;
        sdram_we_n_next  = 1'b0;
    endfunction

endmodule


