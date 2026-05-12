#!/usr/bin/env python3
# Minimal runner: build and run an xrun command, then run IMC to load the coverage.
# Edit SOURCE_FILES or TOP if your filenames/top-module differ.

import os
import random
import subprocess
import sys

# --- User-editable settings ---
SOURCE_FILES = ["testbench.sv"]   # change to ["tb.sv"] if you prefer the Perl names
TOP = "tb_top"                    # change to "tb" if you prefer the Perl names

# --- Derived / runtime values ---
seed = random.randint(0, 49)
cov_test_name = f"test_sv{seed}"
cov_scope = f"cov_work/scope/{cov_test_name}"

# --- Cleanup (same as the Perl script) ---
os.system("rm -rf xcelium.d cov_work xrun.log xrun.history waves.shm dump.vcd")

# --- Build xrun command (printed for convenience) ---
xrun_cmd = [
    "xrun",
    "-uvm",
    "-svseed", str(seed),
] + SOURCE_FILES + [
    "-top", TOP,
    "-access", "+rwc",
    "-coverage", "all",
    "-covoverwrite",
    "-covtest", cov_test_name,
   # "-input", f"@probe -create -shm {TOP} -all -depth all -dynamic",
    "-gui"
]

print("Running xrun:")
print(" ".join(xrun_cmd))

# Run xrun (this will block until simulator/GUI closes)
rc = subprocess.run(xrun_cmd).returncode
if rc != 0:
    print(f"xrun failed (rc={rc}) - exiting.")
    sys.exit(rc)

# --- Run IMC to load the coverage scope (as in your Perl example) ---
imc_cmd = ["imc", "-load", cov_scope]
print("Running IMC:")
print(" ".join(imc_cmd))

rc2 = subprocess.run(imc_cmd).returncode
if rc2 != 0:
    print(f"IMC failed (rc={rc2})")
    sys.exit(rc2)

print("Done.")
