import atpg_pkg::*;
class atpg_item extends uvm_sequence_item;

  `uvm_object_utils(atpg_item)

  algo_e algo_sel;

  // Inputs
  rand logic [3:0] a,b;

  // add/sub select
  rand logic k;

  // fault controls
  rand logic fault_en;
  rand logic fault_type;

  // Outputs captured by monitor
  logic [3:0] out;
  logic [3:0] ext;

  // PRNG Constraints
  constraint prng_c {
    (algo_sel == PRNG) -> {
      a inside {[0:15]};
      b inside {[0:15]};

      k inside {0,1};

      fault_en dist {1 := 80, 0 := 20};

      fault_type inside {0,1}; 
    }

  }

  // FDG Constraints
  constraint fdg_c {

    (algo_sel == FDG) -> {

      fault_en == 1;

      // carry generation
      (a[0] & (b[0] ^ k)) == 1'b1;

      // carry propagation
      (a[1] ^ (b[1] ^ k)) == 1'b1;
      (a[2] ^ (b[2] ^ k)) == 1'b1;
      (a[3] ^ (b[3] ^ k)) == 1'b1;

    }

  }

  // WPG Constraints
  constraint wpg_c {

    (algo_sel == WPG) -> {

      a dist {
        4'b0000 :/ 20,
        4'b1111 :/ 20,
        [1:14]  :/ 60
      };

      b dist {
        4'b0000 :/ 20,
        4'b1111 :/ 20,
        [1:14]  :/ 60
      };

      k dist {0 := 50, 1 := 50};

      fault_en dist {1 := 80, 0 := 20};

      fault_type dist {0 := 50, 1 := 50};

    }

  }

  function new(string name = "atpg_item");
    super.new(name);
  endfunction

endclass
