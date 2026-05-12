class atpg_sb extends uvm_scoreboard;

  `uvm_component_utils(atpg_sb)

  uvm_analysis_imp #(atpg_item, atpg_sb) imp;

  function new(string name = "atpg_sb", uvm_component parent = null);

    super.new(name,parent);

    imp = new("imp",this);

  endfunction

  function void write(atpg_item seq);

    logic [3:0] b_mod;
    logic [3:0] exp_out;
    logic [3:0] exp_ext;

    // Golden Reference Model

    b_mod = seq.b ^ {4{seq.k}};

    exp_out[0] = (seq.a[0] ^ b_mod[0]) ^ seq.k;
    exp_ext[0] = (seq.a[0] & b_mod[0]) |
                 (seq.k & (seq.a[0] ^ b_mod[0]));

    exp_out[1] = (seq.a[1] ^ b_mod[1]) ^ exp_ext[0];
    exp_ext[1] = (seq.a[1] & b_mod[1]) |
                 (exp_ext[0] & (seq.a[1] ^ b_mod[1]));

    exp_out[2] = (seq.a[2] ^ b_mod[2]) ^ exp_ext[1];
    exp_ext[2] = (seq.a[2] & b_mod[2]) |
                 (exp_ext[1] & (seq.a[2] ^ b_mod[2]));

    exp_out[3] = (seq.a[3] ^ b_mod[3]) ^ exp_ext[2];
    exp_ext[3] = (seq.a[3] & b_mod[3]) |
                 (exp_ext[2] & (seq.a[3] ^ b_mod[3]));

    // Carry Status

    if(exp_ext[3])
      `uvm_info("SB",$sformatf("Carry Generated! carry=%0b",exp_ext[3]),UVM_LOW)
    else
      `uvm_info("SB",$sformatf("No Carry Generated! carry=%0b",exp_ext[3]),UVM_LOW)

    // Comparison Logic

    if((exp_out !== seq.out) || (exp_ext !== seq.ext)) begin

      if(seq.fault_en) begin

        `uvm_info("SB", $sformatf("FAULT DETECTED! a=%b b=%b k=%0b fault_type=%0b | EXP out=%b ext=%b | ACT out=%b ext=%b\n", seq.a, seq.b, seq.k, seq.fault_type, exp_out, exp_ext, seq.out, seq.ext), UVM_LOW)

      end
      else begin

        `uvm_error("SB", $sformatf("DUT ERROR! a=%b b=%b k=%0b | EXP out=%b ext=%b | ACT out=%b ext=%b", seq.a, seq.b, seq.k, exp_out, exp_ext, seq.out, seq.ext))

      end

    end
    else begin

      if(seq.fault_en) begin

        `uvm_info("SB", $sformatf("FAULT MASKED! a=%b b=%b k=%0b fault_type=%0b | out=%b ext=%b\n", seq.a, seq.b, seq.k, seq.fault_type, seq.out, seq.ext), UVM_LOW)

      end
      else begin

        `uvm_info("SB", $sformatf("MATCH! a=%b b=%b k=%0b | out=%b ext=%b\n", seq.a, seq.b, seq.k, seq.out, seq.ext), UVM_LOW)

      end

    end

  endfunction

endclass