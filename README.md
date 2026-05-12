# ATPG_UVM — README

This repository contains a small UVM-based ATPG (Automatic Test Pattern Generation) example for a 4-bit adder/subtractor with simple stuck-at fault injection. Below is a concise purpose summary for each .sv file and an example xrun command to run the full flow (UVM + DUT).

## Quick xrun commands

- Basic (wildcard — compiles all .sv files in the folder, elaborates and runs):
```
xrun -uvm -64bit -access +rwc -top tb_top -l xrun.log -R *.sv
```

## File-by-file purpose

- testbench.sv
  - Top-level testbench that creates the simulation clock and instantiates the DUT interface and module.
  - Creates the virtual interface in the UVM config DB so UVM components can access the DUT signals.
  - Launches the UVM test `atpg_test`.
  - Exposes `algo_obs` for quick observation of the chosen algorithm (via the interface).

- design.sv
  - Contains the DUT: a 4-bit chained adder/subtractor (`bas`) built from `FA` (full-adder) instances.
  - Declares the `bas_if` interface which holds inputs, outputs, and fault control signals.
  - Implements simple fault injection: `fault_en` and `fault_type` can force a carry bit to 0/1.
  - Implements b modification: `b_mod = b ^ {4{ k }}` to convert add/sub semantics.

- atpg_item.sv
  - Defines the transaction item (`atpg_item`) used by sequences, driver, monitor and scoreboard.
  - Declares the algorithm enum (`PRNG`, `FDG`, `WPG`) and input/output fields along with fault controls.
  - Contains constrained-randomization constraints for the three algorithm modes (PRNG, FDG, WPG).
  - Provides distributions and functional constraints (e.g., carry-generation/propagation for FDG).

- atpg_seq.sv
  - Implements a sequence that generates `count` transactions of type `atpg_item`.
  - For each item: sets `algo_sel`, randomizes the other fields, logs the chosen transaction, and drives a short time delay.
  - Uses `start_item` / `finish_item` to integrate with the driver via the sequencer.

- atpg_vseq.sv
  - Virtual sequence that composes the test from multiple algorithm-specific sequences.
  - Uses an enum-indexed associative array (`counts`) to control how many transactions of each algorithm to run.
  - Randomizes/shuffles the order of algorithm blocks and starts each sub-sequence on the test sequencer.
  - Provides a single place to tune per-algorithm run lengths.

- atpg_seqr.sv
  - Simple sequencer class parameterized by `atpg_item`.
  - Acts as the sequence-to-driver rendezvous point in the active agent.

- atpg_drv.sv
  - Active driver that gets `atpg_item` transactions from the sequencer and drives signals onto the `bas_if` virtual interface.
  - Performs signal assignments synchronized to the DUT clock.
  - Logs each driven transaction for traceability.

- atpg_mon.sv
  - Monitor that samples DUT interface signals and constructs `atpg_item` observations.
  - Sends observations out via an analysis port to scoreboard and coverage collector.
  - Converts the interface `algo_sel` bits to the `atpg_item` enum for consistent bookkeeping.

- atpg_sb.sv
  - Scoreboard that implements a golden reference model for the bas DUT.
  - Compares expected outputs and carry chain (`exp_out`, `exp_ext`) to DUT outputs and reports:
    - FAULT DETECTED (when fault-en is set and outputs differ)
    - DUT ERROR (unexpected mismatch when no fault injection)
    - MATCH / FAULT MASKED messages otherwise.
  - Logs carry-generation status for visibility.

- atpg_env.sv
  - UVM environment that instantiates the agent, scoreboard and coverage subscriber.
  - Connects the monitor analysis port to both the scoreboard and coverage components.
  - Central place for environment-level configuration.

- atpg_agt.sv
  - UVM agent class that creates the sequencer, driver and monitor (agent is active by default).
  - Retrieves and sets the virtual interface in the UVM config DB so `mon` and `drv` can obtain it.
  - Connects the driver port to the sequencer during the connect phase.

- atpg_cov.sv
  - Coverage subscriber implementing a covergroup to collect functional coverage.
  - Coverpoints include inputs (a, b), operation (k), outputs, fault flags, and algorithm selection.
  - Cross coverage tracks algorithm vs. output and algorithm vs. carry and algorithm vs. fault conditions.
  - Samples transactions from the monitor via the analysis connection.

- atpg_test.sv
  - Defines the UVM test that builds the `atpg_env`.
  - In `run_phase` it creates and starts the top-level virtual sequence (`atpg_vseq`) on the agent's sequencer.
  - In `report_phase` prints coverage statistics (uses the environment's coverage object).
  - Calls `uvm_top.print_topology()` during end_of_elaboration for debug.

---

## Tips / Troubleshooting

- Ensure your simulator has a UVM installation (most modern xrun/Xcelium installs include UVM). If your UVM headers are external, add `+incdir+<uvm_include_path>` or set the simulator-specific UVM option.
- If the simulator complains about missing `uvm_pkg` or `uvm_macros.svh`, confirm that the simulator’s UVM include path is available or sourced.
- To collect coverage, add the simulator's coverage flags (e.g., Xcelium: `-coverage` / `-covdir <dir>`), then use the simulator GUI or reports to inspect coverage results.
- Use `-timescale 1ns/1ps` (or change to match your requirements) to keep time units consistent.
- If you want waveforms, add the simulator waveform options (e.g., `-access +rwc` and Xcelium `-snapshot` or `dsa` flags) to dump an .fsdb/vcd depending on your toolflow.
