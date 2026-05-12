class atpg_test extends uvm_test;
  `uvm_component_utils(atpg_test)
  atpg_env env;
  
  function new(string name = "atpg_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = atpg_env::type_id::create("env",this);
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
  
  task run_phase(uvm_phase phase);
    atpg_vseq vseq;
    
    phase.raise_objection(this);
    
    vseq = atpg_vseq::type_id::create("vseq");
    vseq.start(env.agt.seqr);
    
    phase.drop_objection(this);
  endtask
  
  function void report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("COV", $sformatf("Overall    : %.2f%%", env.cov.cg.get_coverage()),        UVM_LOW)
  `uvm_info("COV", $sformatf("cp_ext     : %.2f%%", env.cov.cg.cp_ext.get_coverage()), UVM_LOW)
  `uvm_info("COV", $sformatf("cp_out     : %.2f%%", env.cov.cg.cp_out.get_coverage()), UVM_LOW)
  `uvm_info("COV", $sformatf("algo_output: %.2f%%", env.cov.cg.cross_algo_output.get_coverage()), UVM_LOW)
  `uvm_info("COV", $sformatf("algo_carry : %.2f%%", env.cov.cg.cross_algo_carry.get_coverage()),  UVM_LOW)
  `uvm_info("COV", $sformatf("algo_fault : %.2f%%", env.cov.cg.cross_algo_fault.get_coverage()),  UVM_LOW)
  `uvm_info("COV", $sformatf("fault_out  : %.2f%%", env.cov.cg.cross_fault_output.get_coverage()),UVM_LOW)
endfunction
  
endclass