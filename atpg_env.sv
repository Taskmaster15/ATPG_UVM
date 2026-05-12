class atpg_env extends uvm_env;
  `uvm_component_utils(atpg_env)
  
  atpg_sb sb;
  atpg_agt agt;
  atpg_cov cov;
  
  function new(string name = "atpg_env", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    sb = atpg_sb::type_id::create("sb",this);
    agt = atpg_agt::type_id::create("agt",this);
    cov = atpg_cov::type_id::create("cov",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
  
endclass