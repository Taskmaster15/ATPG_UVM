#!/usr/bin/env perl
use strict;
use warnings;

# Minimal UVM runner in Perl:
# - cleans previous artifacts
# - picks a small random seed
# - runs xrun (UVM + coverage)
# - then runs IMC to load the coverage scope
#
# Edit @SOURCE_FILES or $TOP if your filenames/top-module differ.
# Run:   perl run_sim.pl

my @SOURCE_FILES = ("testbench.sv");   # testbench.sv includes the other .sv files
my $TOP = "tb_top";

# runtime values
my $seed = int(rand(100));
my $cov_test = "test_sv$seed";
my $cov_scope = "cov_work/scope/$cov_test";

# cleanup previous artifacts
system("rm -rf xcelium.d cov_work xrun.log xrun.history waves.shm dump.vcd");

# build xrun command
my @xrun_cmd = (
    "xrun",
    "-uvm",
    "-64bit",
    "-svseed", $seed,
    "-access", "+rwc",
    "-top", $TOP,
    "-l", "xrun.log",
    "-coverage", "all",
    "-covoverwrite",
    "-covtest", $cov_test,
    @SOURCE_FILES,
    "-gui",
);

print "Invoking xrun:\n", join(" ", @xrun_cmd), "\n";
system(@xrun_cmd);
my $rc = $? >> 8;
if ($rc != 0) {
    die "xrun failed (rc=$rc)\n";
}

# run IMC to load the produced coverage scope
my @imc_cmd = ("imc", "-load", $cov_scope);
print "Invoking IMC:\n", join(" ", @imc_cmd), "\n";
system(@imc_cmd);
my $rc2 = $? >> 8;
if ($rc2 != 0) {
    die "IMC failed (rc=$rc2)\n";
}

print "Done.\n";
