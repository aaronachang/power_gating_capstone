
# ==========================================================================
# TIMING CONSTRAINTS
# ==========================================================================

# Read timing and apply constraints from synthesis
read_sdc ./$design_name.syn.sdc
check_timing

# Set setup/hold derating factors
# - 0% derate
set_timing_derate -early 1.0
set_timing_derate -late  1.0

# Check for false or multicycle path settings, any disabled arcs and case_analysis settings
#report_timing_requirements
#report_disable_timing
#report_case_analysis

# Check clock health and assumptions
#report_clock -skew
#report_clock

# Ensure that no net drives multiple ports, buffer logic constants instead of duplicating
set_fix_multiple_port_nets -all -buffer_constants

