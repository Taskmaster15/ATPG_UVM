`include "uvm_macros.svh"
import uvm_pkg::*;

`include "atpg_item.sv"
`include "atpg_seq.sv"
`include "atpg_vseq.sv"
`include "atpg_seqr.sv"
`include "atpg_drv.sv"
`include "atpg_mon.sv"
`include "atpg_cov.sv"
`include "atpg_sb.sv"
`include "atpg_agt.sv"
`include "atpg_env.sv"
`include "atpg_test.sv"

module tb_top;
  bit clk;
  initial clk = 0;
  always #5 clk = ~clk;
  
  bas_if bif(clk);
  bas DUT(bif);
  
  logic [1:0] algo_obs;
  assign algo_obs = bif.algo_sel;
  
  initial begin
    uvm_config_db #(virtual bas_if)::set(null,"*","bif",bif);
    run_test("atpg_test");
  end
endmodule