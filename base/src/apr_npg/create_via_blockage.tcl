proc create_via_blockage {low high} {
    #Need this to force zroute to honour routing blockages.
    set_route_zrt_common_options -global_max_layer_mode hard
    set_route_zrt_common_options -read_user_metal_blockage_layer true 
    set blockageLayerPrefix "via"
    set blockageLayerSuffix "Blockage"
    for {set i $low} {$i < $high} {incr i} {
	set blockage $blockageLayerPrefix$i$blockageLayerSuffix
	echo "	create_routing_blockage -layers [get_layers -include_system  $blockage ]  -bbox [list [get_attribute [get_die_area]  bbox]]"
	create_routing_blockage -layers [get_layers -include_system  $blockage ]  -bbox [list [get_attribute [get_die_area]  bbox]] 
    }

}
