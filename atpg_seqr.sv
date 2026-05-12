class atpg_seqr extends uvm_sequencer #(atpg_item);
  `uvm_component_utils(atpg_seqr)
  
  function new(string name = "atpg_seqr", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
endclass
