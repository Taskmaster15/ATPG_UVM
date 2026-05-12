class atpg_seq extends uvm_sequence #(atpg_item);

  `uvm_object_utils(atpg_seq)

  atpg_item::algo_e algo;
  int count = 50;

  function new(string name = "atpg_seq");
    super.new(name);
  endfunction

  task body();

    atpg_item tr;

    repeat(count) begin
      tr = atpg_item::type_id::create("tr");

      start_item(tr);
      tr.algo_sel = algo;
      assert(tr.randomize()) 
        else `uvm_fatal("SEQ","Randomization Failed!");
      
      `uvm_info("SEQ", $sformatf("algo=%s a=%b b=%b k=%0b fault_en=%0b fault_type=%0b",
  tr.algo_sel.name(), tr.a, tr.b, tr.k, tr.fault_en, tr.fault_type), UVM_MEDIUM)
      finish_item(tr);
      #10;
    end

  endtask

endclass