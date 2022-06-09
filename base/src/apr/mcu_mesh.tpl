
template : core_lower_mesh(num_m1m2_straps,m12os,m3os,m4os,m5os,m6os) {
   layer : M1 {
      direction : horizontal
      width : 0.33
      spacing : interleaving
      pitch : 3.6
      offset_type : centerline
      offset_start: boundary
      offset : @m12os
      trim_strap : false
      number: @num_m1m2_straps
   }
   layer : M2 {
      direction : horizontal
      width : 0.33
      spacing : interleaving
      pitch : 3.6
      offset_type : centerline
      offset_start: boundary
      offset : @m12os
      trim_strap : false
      number: @num_m1m2_straps
   }
   layer : M3 {
      direction : vertical
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : @m3os
      trim_strap : true
   }
   layer : M4 {
      direction : horizontal
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : @m4os
      trim_strap : true
   }
   layer : M5 {
      direction : vertical
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : @m5os
      trim_strap : true
   }
   layer : M6 {
      direction : horizontal
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : @m6os
      trim_strap : true
   }
   advanced_rule : on {
      honor_advanced_via_rule : on
      stack_vias: adjacent
   }
}

template: core_upper_mesh(m7_os) {
   layer : M7 {
      direction : vertical
      width : 4                 #power strap width
      spacing : interleaving    #space between adjacent straps
      pitch : 43.2              #between non-adjacent nets
      offset_type : centerline  #start the offset from the inner edge of the 1st strap
      offset_start: boundary    #start the offset calculation at the start of the core
      offset : @m7_os             #start 1/2 supertile away from core edge
      trim_strap : false        #get rid of straps that intersect with <2 wires
   }
   advanced_rule : on {
      honor_advanced_via_rule : on
      stack_vias : adjacent
   }
}

