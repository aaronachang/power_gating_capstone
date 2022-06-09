# Clean slate in case we are rerunning
remove_power_plan_regions -all

# Add power domain regions
# Coordinates go lower left corner, then upper right
#create_voltage_area -coordinate { 54.100 53.865 70.655 90.000 } -power_domain CTRL -cycle_color
#create_voltage_area -coordinate { 73.000 54.000 90.000 90.000 } -power_domain COUNTER -cycle_color


# Create a power plan region for the core
set core_ppr_name "ppr_core"
create_power_plan_regions $core_ppr_name \
   -core

# Generate the power ring
# =============================
#Plan your power. The outer ring extends out to hit the pin and inner stripe shrinks to cover the core.
# Set the strategies for the rings
set hlay    M6      ; # horizontal ring layer
set vlay    M7      ; # vertical ring layer
set rw      3 ; # ring width
set vss_os  1.2 ; # offset relative to core edge
set vdd_os [expr $vss_os+ $rw + 2]; #offset of the vdd relative to the core edge.
#set vdd_cnt_os [expr $vdd_os + $rw + 2]; 

set vss_ring_strategy_name "vss_ring"
set vdd_ring_strategy_name "vdd_ring"
#set vdd_cnt_ring_strategy_name "vdd_cnt_ring"

set_power_ring_strategy $vss_ring_strategy_name \
   -power_plan_regions $core_ppr_name \
   -nets {VSS} \
   -template ${SCRIPTS_DIR}/rings.tpl:core_ring_vss($hlay,$vlay,$rw,$vss_os)
set_power_ring_strategy $vdd_ring_strategy_name \
   -power_plan_regions $core_ppr_name \
   -nets {tVDD} \
   -template ${SCRIPTS_DIR}/rings.tpl:core_ring_vdd($hlay,$vlay,$rw,$vdd_os)
#set_power_ring_strategy $vdd_cnt_ring_strategy_name \
#   -power_plan_regions $core_ppr_name \
#   -nets {VDD_CNT} \
#   -template ${SCRIPTS_DIR}/rings.tpl:core_ring_vss(M8,M9,$rw,$vdd_cnt_os)

# Constrain the core meshes
# =============================

#### FIRST BLOCK POWER METALS FROM ROUTING OVER YOUR RAM ######
# Grab the area for each RAM in your design. Create power plan region around them.
#set RAM_cells [get_cells -regexp -hierarchical -filter "ref_name =~ RAM_16B_512"]

# Create some lists defining macros with M4, and their regions. 
#set m4_macros [concat $RAM_cells]
#set m4_macro_regions {}

# Loop: Every RAM cell, create power plan region and expand.
#set i 1
#foreach_in_collection cell $m4_macros {
#    set name1 macro_region_m4_$i
#    create_power_plan_regions $name1 \
#  -group_of_macros $cell \
#  -expand [list $CELL_HEIGHT $CELL_HEIGHT] 
#    lappend m4_macro_regions macro_region_m4_$i
#    incr i 1
#}

# Set power mesh blockage for RAM cells. 
#lappend core_mesh_blockages [list \
#          [list "power_plan_regions:" $m4_macro_regions] \
#          [list "layers:" {M1 M2 M3 M4}] \
#         ]


# Specify the mesh (only reaches to up to the core boundary)
set num_m1m2 [expr int($CORE_HEIGHT_IN_CELL_HEIGHTS/2)]
set mesh_strategy_name "mesh"
set_power_plan_strategy $mesh_strategy_name \
    -power_plan_regions $core_ppr_name \
    -nets {tVDD VSS} \
    -extension { {nets:"tVDD VSS"} {stop: outermost_ring} } \
    -template ${SCRIPTS_DIR}/${MESH_FILE}:${MESH_NAME}(0,$num_m1m2)
#    -blockage $core_mesh_blockages

# Create the core rings
compile_power_plan -ring -strategy $vss_ring_strategy_name
compile_power_plan -ring -strategy $vdd_ring_strategy_name
#compile_power_plan -ring -strategy $vdd_cnt_ring_strategy_name 

# Compile the power mesh
compile_power_plan -strategy $mesh_strategy_name


create_preroute_vias \
   -nets {tVDD VSS} \
   -from_object_strap \
   -to_object_strap \
   -from_layer M2 \
   -to_layer   M1 \
   -advanced_via_rule


