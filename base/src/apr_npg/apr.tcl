
set design_name "cpu_top"  ;  # Name of the design

# CONFIGURATION
# ==========================================================================
set TOOL_NAME "ICC"
# directory where tcl src is located 
set SCRIPTS_DIR "../src/apr_npg"


# Configure design, libraries
# ==========================================================================
source ${SCRIPTS_DIR}/setup_65lp.tcl -echo
source ${SCRIPTS_DIR}/library.tcl -echo

# READ DESIGN
# ==========================================================================
# Read in the verilog, uniquify and save the CEL view.
import_designs $design_name.syn.v -format verilog -top $design_name
link

# TIMING CONSTRAINTS
# ==========================================================================
read_sdc ./$design_name.syn.sdc
check_timing

get_cells -hierarchy
set_dont_touch regfile1/mem

#Set UPF
#=============================================================================#
# source -echo -verbose ${SCRIPTS_DIR}/power_intent.tcl

# FLOORPLAN CREATION
# =========================================================================
# Create core shape and pin placement
source ${SCRIPTS_DIR}/floorplan.tcl -echo

# PHYSICAL POWER NETWORK
# ==========================================================================
save_mw_cel -as ${design_name}_prepns
source ${SCRIPTS_DIR}/power.tcl -echo
# source ${SCRIPTS_DIR}/multi_power.tcl -echo

# PLACEMENT OPTIMIZATION
# ==========================================================================
save_mw_cel -as ${design_name}_preplaceopt
source ${SCRIPTS_DIR}/placeopt.tcl -echo

# CTS & CLOCK ROUTING
# ==========================================================================
save_mw_cel -as ${design_name}_preclock
source ${SCRIPTS_DIR}/clocks.tcl


# SIGNAL ROUTING
# ==========================================================================
save_mw_cel -as ${design_name}_preroute
source ${SCRIPTS_DIR}/route.tcl -echo
verify_lvs -ignore_floating_port

# GENERATE RESULT FILES
# ==========================================================================
save_mw_cel -as ${design_name}_finished
source ${SCRIPTS_DIR}/generate.tcl -echo

# REPORT DRCS AS POPUP WINDOW
# ==========================================================================
source ${SCRIPTS_DIR}/report_drcs.tcl -echo
report_drc -highlight -color green

start_gui
