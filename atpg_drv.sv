class atpg_drv extends uvm_driver #(atpg_item);
  `uvm_component_utils(atpg_drv)
 
  virtual bas_if bif;
  
  function new(string name = "atpg_drv",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual bas_if)::get(this,"","bif",bif))
       `uvm_fatal("DRV", "Interface not connected");
    
  endfunction
   
  task run_phase(uvm_phase phase);
    atpg_item seq;
    forever begin
      seq_item_port.get_next_item(seq);
      
      @(posedge bif.clk);
      bif.a <= seq.a;
      bif.b <= seq.b;
      bif.k <= seq.k;
      bif.fault_en <= seq.fault_en;
      bif.fault_type <= seq.fault_type;
      bif.algo_sel   <= seq.algo_sel; 
      
      `uvm_info("DRV", $sformatf("@%0t algo=%s a=%b b=%b k=%0b fault_en=%0b fault_type=%0b", $time, seq.algo_sel.name(), seq.a, seq.b, seq.k, seq.fault_en, seq.fault_type),UVM_LOW)
      
      seq_item_port.item_done(); 
    end
  endtask
endclass
