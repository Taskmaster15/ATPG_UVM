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
    
    cp_algo: coverpoint seq.algo_sel {
      bins prng = {PRNG};
      bins fdg  = {FDG};
      bins wpg  = {WPG};
    }
    
    cp_ext: coverpoint seq.ext {
      bins no_carry   = {4'b0000};
      bins full_carry = {4'b1111};
      bins partial[]  = {[1:14]};
    }

    // -- Cross 1: algo × fault_en × fault_type ------------------------------
    cross_algo_fault: cross cp_algo, cp_fault_en, cp_fault_type {
      ignore_bins fdg_no_fault = binsof(cp_algo.fdg)     && binsof(cp_fault_en.off);
      ignore_bins no_fault_sa1 = binsof(cp_fault_en.off) && binsof(cp_fault_type.sa1);
    }

    // -- Cross 2: fault_en × fault_type × out -------------------------------
    cross_fault_output: cross cp_fault_en, cp_fault_type, cp_out {
      ignore_bins no_fault_sa1 = binsof(cp_fault_en.off) && binsof(cp_fault_type.sa1);
      // SA0 stucks a node LOW — all-ones output (15) is structurally unreachable
      ignore_bins sa0_max_out  = binsof(cp_fault_en.on)  && binsof(cp_fault_type.sa0)
                                 && binsof(cp_out.out_bins) intersect {15};
      // SA1 stucks a node HIGH — all-zeros output (0) is structurally unreachable
      ignore_bins sa1_zero_out = binsof(cp_fault_en.on)  && binsof(cp_fault_type.sa1)
                                 && binsof(cp_out.out_bins) intersect {0};
    }

    // -- Cross 3: algo × out ------------------------------------------------
    cross_algo_output: cross cp_algo, cp_out {
      ignore_bins fdg_unreachable = binsof(cp_algo.fdg) &&
                                    binsof(cp_out.out_bins) intersect {[2:13]};
    }

    cross_algo_carry: cross cp_algo, cp_ext {
  ignore_bins fdg_no_partial = binsof(cp_algo.fdg) && binsof(cp_ext.partial);

  // WPG (Weighted Pattern Generation) uses probability-weighted stimulus —
  // alternating carry patterns ext=5 (4'b0101) and ext=10 (4'b1010) fall
  // outside the weighted distribution space and are statistically unreachable
  ignore_bins wpg_alt_carry  = binsof(cp_algo.wpg) &&
                               binsof(cp_ext.partial) intersect {5, 10};
}

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
