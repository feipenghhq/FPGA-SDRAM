
module sdram_top (
  output     [0:0]    sdram_cs_n,
  output              sdram_ras_n,
  output              sdram_cas_n,
  output              sdram_we_n,
  output     [12:0]   sdram_addr,
  output     [1:0]    sdram_ba,
  inout      [15:0]   sdram_dq,
  output     [1:0]    sdram_dqm,
  output              sdram_cke,
  input               avs_read,
  input               avs_write,
  output              avs_waitrequest,
  input      [24:0]   avs_address,
  input      [3:0]    avs_byteenable,
  input      [15:0]   avs_writedata,
  output              avs_readdatavalid,
  output     [15:0]   avs_readdata,
  input               clk,
  input               reset
);

  logic     [15:0]   sdram_dq_read;
  logic     [15:0]   sdram_dq_write;
  logic              sdram_dq_en;


  assign sdram_dq      = sdram_dq_en ? sdram_dq_write : 16'bz;
  assign sdram_dq_read = sdram_dq;

  avalon_sdram_controller u_avalon_sdram_controller(.*);

endmodule

module sdram_tb_top (
  input               avs_read,
  input               avs_write,
  output              avs_waitrequest,
  input      [24:0]   avs_address,
  input      [3:0]    avs_byteenable,
  input      [15:0]   avs_writedata,
  output              avs_readdatavalid,
  output     [15:0]   avs_readdata,
  input               clk,
  input               reset
);

  logic [0:0]    sdram_cs_n;
  logic          sdram_ras_n;
  logic          sdram_cas_n;
  logic          sdram_we_n;
  logic [12:0]   sdram_addr;
  logic [1:0]    sdram_ba;
  wire  [15:0]   sdram_dq;
  logic [1:0]    sdram_dqm;
  logic          sdram_cke;

 `include "sdr_parameters.vh"

  logic                      Clk;
  logic                      Cke;
  logic                      Cs_n;
  logic                      Ras_n;
  logic                      Cas_n;
  logic                      We_n;
  logic  [ADDR_BITS - 1 : 0] Addr;
  logic    [BA_BITS - 1 : 0] Ba;
  logic    [DM_BITS - 1 : 0] Dqm;

  assign Addr    = sdram_addr;
  assign Ba      = sdram_ba;
  assign Cas_n   = sdram_cas_n;
  assign Cke     = sdram_cke;
  assign Cs_n    = sdram_cs_n;
  assign Dqm     = sdram_dqm;
  assign Ras_n   = sdram_ras_n;
  assign We_n    = sdram_we_n;
  assign Clk     = clk;


  sdram_top sdram_top(.*);
  sdr sdr(.Dq(sdram_dq), .*);

  `ifdef DUMP
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, sdram_tb_top);
  end
  `endif

endmodule
