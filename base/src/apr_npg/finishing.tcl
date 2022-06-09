
# FINAL FINISHING
# ==========================================================================

# Load variable definitions
source ${SRC_DIR}/config.tcl
source ${SRC_DIR}/phys_vars.tcl

# INSERT ANTENNA DIODES
# ==========================================================================

if {$FIX_ANTENNA} {
   if { $USE_ANTENNA_DIODES && [file exists [which $ANTENNA_RULES_FILE]] && $ROUTING_DIODES != ""} {
      source $ANTENNA_RULES_FILE
      set_route_zrt_detail_options \
         -antenna true \
         -diode_libcell_names $ROUTING_DIODES \
         -insert_diodes_during_routing true
      route_zrt_detail -incremental true
   }
}

# Replace fill with decap
remove_stdcell_filler -stdcell
if {$FINISH_WITH_DECAP} {
   insert_stdcell_filler \
      -cell_with_metal $DECAP_CELLS \
      -connect_to_power VDD \
      -connect_to_ground VSS \
      -respect_keepout
   
   insert_stdcell_filler \
      -cell_with_metal $FILL_CELLS \
      -connect_to_power VDD \
      -connect_to_ground VSS \
      -respect_keepout
}

# Connect P/G
derive_pg_connection
verify_pg_nets

# INSERT METAL FILL
# ==========================================================================
if {$INSERT_METAL_FILL} {
   # Get the metal numbers
   set max_fill_layer [string index $MAX_ROUTING_LAYER 1]
   set min_fill_layer [string index $MIN_ROUTING_LAYER 1]

   # By default, fill is created in <current_design>.FILL
   insert_metal_filler \
      -from_metal $min_fill_layer \
      -to_metal $max_fill_layer \
      -routing_space $METAL_FILL_SPACING
}

# Check LVS/DRC
# ==========================================================================
verify_zrt_route
verify_lvs -ignore_min_area
