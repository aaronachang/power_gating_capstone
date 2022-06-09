#!/usr/bin/tclsh
####################################################################################
############## Primetime script for power estimation ###############################
####################################################################################

set_app_var sh_continue_on_error false
################### SETUP NECESSARY FILES HERE ####################################
########### Initially set the path(s) to search for netlist and (or) library file(s)
set search_path "../apr/results \
                 /home/lab.apps/vlsiapps/kits/tsmc/N65LP/digital/Front_End/timing_power_noise/NLDM/tcbn65lpcghvt_200a \
                 /home/lab.apps/vlsiapps/kits/tsmc/N65LP/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a \
                 /home/lab.apps/vlsiapps/kits/tsmc/N65LP/digital/Back_End/milkyway/tcbn65lp_200a/cell_frame/tcbn65lp/LM/* \
                 /home/lab.apps/vlsiapps/kits/tsmc/N65LP/digital/Back_End/milkyway/tcbn65lpcghvt_200a/cell_frame/tcbn65lpcghvt/LM/* "

########## Set all the library files for all standard cells and macros present /
# in the netlist separated by white space ##########################################
set library_file "cpu_top.apr.v tcbn65lptc.db tcbn65lpcghvttc.db tcbn65lpbc.db tcbn65lptc1d0.db tcbn65lptc1d01d0.db tcbn65lptc1d01d2.db"
set netlist ../apr/results/cpu_top.apr.v

########### Set a constraint file to estimate initial input transition #############
set constraint ../apr/results/cpu_top.apr.sdc

########### Set a spef file to include RC extraction parameters ####################
# no spef output from ICC
# set PARASITIC_FILES ../src/annotate/mac.spef.gz

########### Set design name to the top module of the gate level netlist ###########
set design_name cpu_top

############ Set switching activity file for internal node transition - can be a /
# vcd or saif file ############################################################### 
set activity_file "../sim/post-apr/vcdplus.vpd"
#../sim/vcd.dump.gz

############ Strip path includes only those modules in the switching activity file /
# which has information about switching and eliminates the rest of the file #######
set strip_path cpu_top_testbench/dut

#set_app_var sh_continue_on_error false
############# Set the power analysis mode - Averaged, vectorless or timebased #####
set power_enable_analysis TRUE
set power_analysis_mode averaged

set_app_var search_path $search_path
set_app_var link_path $library_file
read_verilog $netlist
current_design $design_name
link -verbose

#################### Include constraint and parasitic files for power estimation /
#### only if they are present ##################################################
if {[info exists constraint]} {
 read_sdc $constraint
}

if {[info exists PARASITIC_FILES]} {
 foreach para_file $PARASITIC_FILES {
  read_parasitics $para_file
 }
}  


check_timing
update_timing
report_timing

if {[info exists activity_file] && [string match "*vcd*" $activity_file]} {
 puts "its a vcd file"
 read_vcd -strip_path $strip_path $activity_file
 # read_vcd $activity_file
 set switching_type "vcd"
} elseif {[info exists activity_file] && [string match "*saif" $activity_file]} {
 puts "its a saif file"
 set switching_type "saif"
 read_saif -strip_path $strip_path $activity_file
} else {
 puts "No activity file found to run Primetime"
 set switching_type "vectorfree"
}

check_power
update_power
report_power -hierarchy > $design_name.$switching_type.$power_analysis_mode.power.rpt
quit 
