class atpg_agt extends uvm_agent;
  `uvm_component_utils(atpg_agt)
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  virtual bas_if bif;
  
  atpg_seqr seqr;
  atpg_drv drv;
  atpg_mon mon;
  
  function new(string name = "atpg_agt", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = atpg_mon::type_id::create("mon",this);

    if(!uvm_config_db #(virtual bas_if)::get(this,"","bif",bif))
      `uvm_fatal("AGT","Virtual interface not set");

    uvm_config_db #(virtual bas_if)::set(this,"mon","bif",bif);

    if(is_active == UVM_ACTIVE) begin
      seqr = atpg_seqr::type_id::create("seqr",this);
      drv  = atpg_drv::type_id::create("drv",this);

      uvm_config_db #(virtual bas_if)::set(this,"drv","bif",bif);
    end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
