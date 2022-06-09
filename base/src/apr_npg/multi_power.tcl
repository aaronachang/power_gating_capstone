# Clean slate in case we are rerunning
remove_power_plan_regions -all

## SET VARIABLES ##
set CELL_HEIGHT 1.8
set MESH_FILE "mcu_mesh.tpl"
set RING_FILE "rings.tpl"
set LOWER_MESH_NAME "core_lower_mesh"
set UPPER_MESH_NAME "core_upper_mesh"
set core_ppr_name "core_ppr_top"
set lower_blockage_spec "{{power_plan_regions: {PGD_EXPAND}} {layers: {M1 M2 M3 M4 M5 M6}}}"

set CORE_BBOX [join [get_core_bbox]]
set CORE_LLX  [lindex $CORE_BBOX 0]
set CORE_LLY  [lindex $CORE_BBOX 1]
set CORE_URX  [lindex $CORE_BBOX 2]
set CORE_URY  [lindex $CORE_BBOX 3]

set coords [list \
   [expr $CORE_LLX] [expr $CORE_LLY + (6 * $CELL_HEIGHT)] [expr $CORE_URX] [expr $CORE_URY] \
]



# Voltage area guardbands
set guard_x $CELL_HEIGHT
set guard_y $CELL_HEIGHT

# Add power domain regions
# Coordinates go lower left corner, then upper right
create_voltage_area -power_domain "PGD" -coordinate $coords -cycle_color \
	-guard_band_x $CELL_HEIGHT -guard_band_y $CELL_HEIGHT

create_power_plan_regions "core_ppr_top" -core
create_power_plan_regions "PGD" -voltage_area "PGD"
create_power_plan_regions "PGD_EXPAND" -voltage_area "PGD" 
#-expand 0.9

## RING Setup
#Plan your power. The outer ring extends out to hit the pin and inner stripe shrinks to cover the core.
# Set the strategies for the rings
set hlay    M6      ; # horizontal ring layer
set vlay    M7      ; # vertical ring layer
set rw      3 ; # ring width
set vss_os  1.2 ; # offset relative to core edge
set vdd_os [expr $vss_os+ $rw + 2]; #offset of the vdd relative to the core edge.
set vddl_os [expr $vdd_os + $rw + 2]; 

set vss_ring_strategy_name "vss_ring"
set vdd_ring_strategy_name "vdd_ring"
#set vddl_ring_strategy_name "vddl_ring"

set_power_ring_strategy $vss_ring_strategy_name \
   -power_plan_regions $core_ppr_name \
   -nets {VSS} \
   -template ${SCRIPTS_DIR}/rings.tpl:core_ring_vss($hlay,$vlay,$rw,$vss_os)
set_power_ring_strategy $vdd_ring_strategy_name \
   -power_plan_regions $core_ppr_name \
   -nets {tVDD} \
   -template ${SCRIPTS_DIR}/rings.tpl:core_ring_vdd($hlay,$vlay,$rw,$vdd_os)
#set_power_ring_strategy $vddl_ring_strategy_name \
   -power_plan_regions $core_ppr_name \
   -nets {VDDL} \
   -template ${SCRIPTS_DIR}/rings.tpl:core_ring_vss($hlay,$vlay,$rw,$vddl_os)

# Create the core rings
compile_power_plan -ring -strategy $vss_ring_strategy_name
compile_power_plan -ring -strategy $vdd_ring_strategy_name
#compile_power_plan -ring -strategy $vddl_ring_strategy_name


# == VSS ==
# set up the number of m1 m2 strips for VSS
set num_m1m2 [expr 1000]
set_power_plan_strategy "lower_vss" \
   -power_plan_regions "core_ppr_top" \
   -nets {VSS} \
   -extension { {nets:"VSS"} {stop: outermost_ring} } \
   -template ${SCRIPTS_DIR}/${MESH_FILE}:${LOWER_MESH_NAME}($num_m1m2,1.8,0,0,0,0)

#set vss_m7os [expr 2*$CELL_HEIGHT]
#set_power_plan_strategy "upper_vss" \
   -power_plan_regions "core_ppr_top" \
   -nets {VSS} \
   -template ${SCRIPTS_DIR}/${MESH_FILE}:${UPPER_MESH_NAME}($vss_m7os)

#compile_power_plan -strategy "upper_vss"
compile_power_plan -strategy "lower_vss"

# == VDD ==
set m12os [expr 0*$CELL_HEIGHT]
set m35os [expr 2*$CELL_HEIGHT]
set m46os [expr 2*$CELL_HEIGHT]


set_power_plan_strategy "logic_lower_vdd" \
   -power_plan_regions "core_ppr_top" \
   -nets {tVDD} \
   -blockage $lower_blockage_spec \
   -extension { {nets:"tVDD"} {direction: "B"} {stop: outermost_ring} } \
   -template ${SCRIPTS_DIR}/${MESH_FILE}:${LOWER_MESH_NAME}($num_m1m2,$m12os,$m35os,$m46os,$m35os,$m46os)

#set m0_m7os [expr 6*$CELL_HEIGHT]
#set_power_plan_strategy "logic_upper_vdd" \
   -power_plan_regions "core_ppr_top" \
   -nets {VDD} \
   -template ${SCRIPTS_DIR}/${MESH_FILE}:${UPPER_MESH_NAME}($m0_m7os)

# == CTL VDD ==
#set m12os [expr 0*$CELL_HEIGHT]
#set m35os [expr 2*$CELL_HEIGHT]
#set m46os [expr 2*$CELL_HEIGHT]


#set_power_plan_strategy "PGD_lower_vdd" \
   -power_plan_regions "PGD" \
   -nets {VDDL} \
   -extension { {nets:"VDDL"} {direction: "LRT"} {stop: outermost_ring} } \
   -template ${SCRIPTS_DIR}/${MESH_FILE}:${LOWER_MESH_NAME}($num_m1m2,$m12os,$m35os,$m46os,$m35os,$m46os)

#set ctl_m7os [expr 8*$CELL_HEIGHT]
#set_power_plan_strategy "PGD_upper_vdd" \
   -power_plan_regions "core_ppr_top" \
   -nets {VDDL} \
   -template ${SCRIPTS_DIR}/${MESH_FILE}:${UPPER_MESH_NAME}($ctl_m7os)


## create power strap for the level shifters
#create_power_strap -direction horizontal -start_at 55.8 -nets {VDDL} -layer M6 -width 0.380
#create_power_strap -direction horizontal -start_at 55.8 -nets {VDDL} -layer M1 -width 0.380


# Compile all VDD meshes
compile_power_plan -strategy "logic_lower_vdd"
#compile_power_plan -strategy "logic_upper_vdd"
#compile_power_plan -strategy "PGD_lower_vdd"
#compile_power_plan -strategy "PGD_upper_vdd"

# Via hack
# =============================

# Create M1/M2 vias
# - For some reason M1/M2 vias aren't automatically created during the core mesh creation. So we
#   have to turn the "trim_straps" option off in the mesh template file for M1 and M2, otherwise
#   no M1 straps get created (M2/M3 vias are created so M2 isn't trimmed, though). We also then
#   have to create these vias ourselves
create_preroute_vias \
   -nets {tVDD VSS} \
   -from_object_strap \
   -to_object_strap \
   -from_layer M2 \
   -to_layer   M1 \
   -advanced_via_rule
