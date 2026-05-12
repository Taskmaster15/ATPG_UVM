class atpg_vseq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(atpg_vseq)

  // Enum drives count lookup — single structure, no parallel arrays
  int counts[atpg_item::algo_e] = '{
    atpg_item::PRNG : 150,
    atpg_item::FDG  : 150,
    atpg_item::WPG  : 150
  };

  task body();
  atpg_seq seq;
  atpg_item::algo_e order[$] = '{atpg_item::PRNG, atpg_item::FDG, atpg_item::WPG};
  order.shuffle();
  foreach(order[i]) begin
    seq       = atpg_seq::type_id::create($sformatf("seq_%s", order[i].name()));
    seq.algo  = order[i];
    seq.count = counts[order[i]];
    seq.start(m_sequencer);
  end
endtask

  function new(string name = "atpg_vseq");
    super.new(name);
  endfunction
endclass