class atpg_mon extends uvm_monitor;
  `uvm_component_utils(atpg_mon)
  uvm_analysis_port #(atpg_item) ap;
  virtual bas_if bif;
  
  function new(string name = "atpg_mon", uvm_component parent = null);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual bas_if)::get(this,"","bif",bif))
      `uvm_fatal("MON","Interface not connected");
  endfunction
  
  task run_phase(uvm_phase phase);
    atpg_item seq;
    forever begin
      
      @(posedge bif.clk);
      @(posedge bif.clk);
      
      seq = atpg_item::type_id::create("seq");
      seq.a = bif.a;
      seq.b = bif.b;
      seq.k = bif.k;
      seq.out = bif.out;
      seq.ext = bif.ext;
      seq.fault_en   = bif.fault_en;
      seq.fault_type = bif.fault_type;
      seq.algo_sel   = bif.algo_sel;
      
      `uvm_info("MON", $sformatf("@%0t a=%b b=%b k=%0b fault_en=%0b fault_type=%0b out=%b ext=%b", $time, seq.a, seq.b, seq.k, seq.fault_en, seq.fault_type, seq.out, seq.ext), UVM_LOW)
      
      ap.write(seq);
    end
  endtask
endclass
