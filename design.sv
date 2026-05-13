import atpg_pkg::*;
interface bas_if(input bit clk);
  logic [3:0] a,b;
  logic k;
  
  algo_e      algo_sel;
  logic fault_en;
  logic fault_type; // 0 = SA0, 1 = SA1
  
  logic [3:0] out,ext;
endinterface

module FA(
  input logic a,b,
  input logic cin,
  output logic sum,cout  
);
  
  logic x1,x2,x3;
  
  always_comb begin
    x1   = a ^ b;
    sum  = cin ^ x1;
    x2   = a & b;
    x3   = x1 & cin;
    cout = x2 | x3;
  end
endmodule
    
module bas(bas_if bif);
  logic [3:0] b_mod;
  logic f;
  assign b_mod = bif.b ^ {4{bif.k}};
  
  
  FA FA0(.a(bif.a[0]), .b(b_mod[0]), .cin(bif.k), .sum(bif.out[0]), .cout(f));
  assign bif.ext[0] = (bif.fault_en) ? (bif.fault_type ? 1'b1 : 1'b0) : f;
  
  FA FA1(.a(bif.a[1]), .b(b_mod[1]), .cin(bif.ext[0]), .sum(bif.out[1]), .cout(bif.ext[1]));
  FA FA2(.a(bif.a[2]), .b(b_mod[2]), .cin(bif.ext[1]), .sum(bif.out[2]), .cout(bif.ext[2]));
  FA FA3(.a(bif.a[3]), .b(b_mod[3]), .cin(bif.ext[2]), .sum(bif.out[3]), .cout(bif.ext[3])); 
  
endmodule
