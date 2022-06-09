# PLACEMENT OPTIMIZATION
# ================================
# Optimize
set place_opt_args "-effort low -congestion"

echo "place_opt $place_opt_args"
eval "place_opt $place_opt_args"

insert_stdcell_filler \
   -cell_with_metal {FILL8 FILL4 FILL2 FILL1} \
   -respect_keepout

# Connect all power and ground pins
derive_pg_connection -all -reconnect -create_ports all
verify_pg_nets
