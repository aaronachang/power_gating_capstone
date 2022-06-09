# 2022 UW VLSI Capstone Project: Power Gating on ARM CPU
Team "Brothers in ARMs": Aaron Chang, Peter Zhong

## File Structure
capstone \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;armulator -- ARM Python Testbench \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;base -- Base directory for ARM CPU \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;src -- Source files \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;assembler -- Assembly Test Generation \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rtl -- RTL Verilog for Pipelined CPU \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rtl_np -- RTL Verilog for Non-pipelined CPU (Unsupported, for archive) \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;syn -- Synthesis source files with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;syn_npg -- Synthesis source files without power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;apr -- APR source files with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;apr_npg -- APR source files without power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sim -- VCS simulation directories \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pre-syn -- Pre-Synthesis simulation run directory \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;post-syn -- Post-Synthesis simulation run directory with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;post-syn_npg -- Post-Synthesis simulation run directory without power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;post-apr -- Post-APR simulation run directory with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;post-apr_npg -- Post-APR simulation run directory without power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;syn -- Synthesis run directory with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;syn_npg -- Synthesis run directory without power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;apr -- APR run directory with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;apr_npg -- APR run directory without power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptpx -- PrimeTime PX directory with power-gating \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptpx_npg -- PrimeTime PX directory without power-gating

## How to run Synthesis
1. Go to syn run directory
2. Run "make"

## How to run APR
0. Prerequisite: Must have run Synthesis first
1. Go to APR run directory
2. Run "make"

## How to run VCS (simulations)
0. Prerequisite: Must have run Synthesis/APR first for those simulations
1. Go to simulation directory
2. Run "make"

## How to run PTPX
0. Prerequisite: Must have run Synthesis, APR, and post-APR simulation first
1. Go to PTPX run directory
2. Run "make"

## How to run the ARM testbench
0. Prerequisite: Must have run Synthesis/APR first to generate netlist for those tests
1. Go to the armulator directory
2. For help, run "python3 arm_testbench.py --help"
3. Example of running the Fibonacci test on post-APR: "python3 arm_testbench.py -s apr -t fibonacci"

File Structure:
capstone
    armulator -- ARM Python Testbench
    base -- Base directory for ARM CPU
        src -- Source files
            assembler -- Assembly Test Generation
            rtl -- RTL Verilog for Pipelined CPU
            rtl_np -- RTL Verilog for Non-pipelined CPU (Unsupported, for archive)
            syn -- Synthesis source files with power-gating
            syn_npg -- Synthesis source files without power-gating
            apr -- APR source files with power-gating
            apr_npg -- APR source files without power-gating
        sim -- VCS simulation directories
            pre-syn -- Pre-Synthesis simulation run directory
            post-syn -- Post-Synthesis simulation run directory with power-gating
            post-syn_npg -- Post-Synthesis simulation run directory without power-gating
            post-apr -- Post-APR simulation run directory with power-gating
            post-apr_npg -- Post-APR simulation run directory without power-gating
        syn -- Synthesis run directory with power-gating
        syn_npg -- Synthesis run directory without power-gating
        apr -- APR run directory with power-gating
        apr_npg -- APR run directory without power-gating
        ptpx -- PrimeTime PX directory with power-gating
        ptpx_npg -- PrimeTime PX directory without power-gating

