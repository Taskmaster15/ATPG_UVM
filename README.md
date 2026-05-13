# ATPG_UVM — README

This repository contains a small UVM-based ATPG (Automatic Test Pattern Generation) example for a 4-bit adder/subtractor with simple stuck-at fault injection. Below is a concise purpose summary for each .sv file and an example xrun command to run the full flow (UVM + DUT).

# ATPG execution — high-level flow (using atpg.py)

High-level flow: cleanup → run xrun (GUI, blocks until closed) → run IMC to load coverage.

1) Run Command

```sh
chmod +x atpg.py      # optional
./atpg.py
# or
python3 atpg.py
```

2) Commands the script executes (with placeholders)

```sh
rm -rf xcelium.d cov_work xrun.log xrun.history waves.shm dump.vcd

xrun -uvm -64bit -svseed <seed> -access +rwc -top <TOP> -l xrun.log -coverage all -covoverwrite -covtest test_sv<seed> <SOURCE_FILES> -gui

imc -load cov_work/scope/test_sv<seed>
```
