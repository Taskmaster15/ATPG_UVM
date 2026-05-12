class atpg_cov extends uvm_subscriber #(atpg_item);
  `uvm_component_utils(atpg_cov)
  atpg_item seq;

  covergroup cg;
    cp_a:          coverpoint seq.a         { bins a_bins[]   = {[0:15]}; }
    cp_b:          coverpoint seq.b         { bins b_bins[]   = {[0:15]}; }
    cp_k:          coverpoint seq.k         { bins add = {0}; bins sub = {1}; }
    cp_out:        coverpoint seq.out       { bins out_bins[] = {[0:15]}; }
    cp_fault_en:   coverpoint seq.fault_en  { bins off = {0}; bins on  = {1}; }
    cp_fault_type: coverpoint seq.fault_type{ bins sa0 = {0}; bins sa1 = {1}; }
    
    cp_algo: 	   coverpoint seq.algo_sel  { bins prng = {atpg_item::PRNG};
  											  bins fdg  = {atpg_item::FDG};
  											  bins wpg  = {atpg_item::WPG};}
    
    cp_ext:        coverpoint seq.ext       { bins no_carry   = {4'b0000};
                                              bins full_carry = {4'b1111};
                                              bins partial[]  = {[1:14]}; }

  
    cross_algo_fault: cross cp_algo, cp_fault_en, cp_fault_type {
      ignore_bins fdg_no_fault = binsof(cp_algo.fdg)     && binsof(cp_fault_en.off);
      ignore_bins no_fault_sa1 = binsof(cp_fault_en.off) && binsof(cp_fault_type.sa1);
    }
    cross_fault_output: cross cp_fault_en, cp_fault_type, cp_out {
      ignore_bins no_fault_sa1 = binsof(cp_fault_en.off) && binsof(cp_fault_type.sa1);
    }
    cross_algo_output: cross cp_algo, cp_out;
    cross_algo_carry:  cross cp_algo, cp_ext;
  endgroup

  function new(string name = "atpg_cov", uvm_component parent = null);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(atpg_item t);
    this.seq = t;
    cg.sample();
  endfunction
endclass