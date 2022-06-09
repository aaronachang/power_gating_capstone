
#source ${SRC_DIR}/config.tcl -echo
#source ${SRC_DIR}/phys_vars.tcl -echo

proc preroute_cells {cells mode vdd_net direction hlayer vlayer} {   
   preroute_standard_cells \
      -cell_master_filter $cells \
      -cell_master_filter_mode "select" \
      -mode $mode \
      -nets $vdd_net \
      -connect $direction \
      -v_width 0.38 \
      -h_width 0.38 \
      -h_layer $hlayer \
      -v_layer $vlayer \
      -max_fanout 20 \
      -extend_for_multiple_connections \
      -optimize_via_locations \
      -remove_floating_pieces
}

preroute_cells "HDRS*" "net" "VDD_sw"  "both" "M4" "M3"
preroute_cells "HDRS*" "net" "VDD_sw"  "both" "M4" "M5"
preroute_cells "HDRS*" "net" "VDD_sw"  "both" "M2" "M1"
preroute_cells "HDRS*" "net" "VDD_sw"  "both" "M2" "M3"
preroute_cells "HDRS*" "net" "tVDD"  "both" "M4" "M3"
preroute_cells "HDRS*" "net" "tVDD"  "both" "M4" "M5"
preroute_cells "HDRS*" "net" "tVDD"  "both" "M2" "M1"
preroute_cells "HDRS*" "net" "tVDD"  "both" "M2" "M3"

set all_power_switches [get_cells -hierarchical -filter "ref_name =~ HDRS*"]
set_attribute -quiet $all_power_switches is_fixed      true
set_attribute -quiet $all_power_switches is_placed     true
set_attribute -quiet $all_power_switches is_soft_fixed false

# Connect all power and ground pins
derive_pg_connection -all -reconnect
verify_pg_nets
