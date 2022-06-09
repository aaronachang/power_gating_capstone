
template : core_mesh(m12os,num_m1m2_straps) {
   layer : M6 {
      direction : horizontal
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : 0
      trim_strap : true
   }
   layer : M5 {
      direction : vertical
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : 0
      trim_strap : true
   }
   layer : M4 {
      direction : horizontal
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : 0
      trim_strap : true
   }
   layer : M3 {
      direction : vertical
      width : 0.38
      spacing : interleaving
      pitch : 7.2
      offset_type : centerline
      offset_start: boundary
      offset : 0
      trim_strap : true
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
   advanced_rule : on {
      honor_advanced_via_rule : on
      stack_vias: adjacent
   }
}

