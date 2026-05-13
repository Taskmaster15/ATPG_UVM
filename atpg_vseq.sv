import atpg_pkg::*;
class atpg_vseq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(atpg_vseq)

  int counts[algo_e] = '{
    PRNG : 150,
    FDG  : 150,
    WPG  : 150
  };

  task body();
    atpg_seq seq;
    algo_e order[$] = '{PRNG, FDG, WPG};
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
