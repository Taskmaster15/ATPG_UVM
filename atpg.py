#!/usr/bin/env python3
# Minimal UVM runner: run xrun (GUI) with a small random seed and then run IMC to load the coverage.
# Edit SOURCE_FILES or TOP if your filenames/top-module differ.

import os, random, subprocess, sys

# --- user-editable ---
SOURCE_FILES = ["testbench.sv"]   # testbench.sv includes the other .sv files
TOP = "tb_top"

# --- runtime values ---
seed = random.randint(0, 100)
cov_test = f"test_sv{seed}"
cov_scope = f"cov_work/scope/{cov_test}"

# cleanup previous artifacts
os.system("rm -rf xcelium.d cov_work xrun.log xrun.history waves.shm dump.vcd")

# build and run xrun (blocks until you close SimVision)
xrun_cmd = [
    "xrun",
    "-uvm",
    "-64bit",
    "-svseed", str(seed),
    "-access", "+rwc",
    "-top", TOP,
    "-l", "xrun.log",
    "-coverage", "all",
    "-covoverwrite",
    "-covtest", cov_test,
] + SOURCE_FILES + [
    "-gui",
]

print("Invoking xrun:")
print(" ".join(xrun_cmd))
rc = subprocess.run(xrun_cmd).returncode
if rc != 0:
    print(f"xrun failed (rc={rc})")
    sys.exit(rc)

# run IMC to load the produced coverage scope (blocks until IMC finishes)
imc_cmd = ["imc", "-load", cov_scope]
print("Invoking IMC:")
print(" ".join(imc_cmd))
rc2 = subprocess.run(imc_cmd).returncode
if rc2 != 0:
    print(f"IMC failed (rc={rc2})")
    sys.exit(rc2)

print("Done.")
