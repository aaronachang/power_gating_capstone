
# VARIABLES RELATED TO PHYSICAL DESIGN
# =====================================================
#  - Used in floorplanning and power network synthesis

# ===== Size primitives =====
# SUPERTILE_SIZE: definition of a supertile
# M2M3_TRACK_CHANNEL_WIDTH: width of M2/M3 metal and spacing to next track
set M2M3_TRACK_CHANNEL_WIDTH 0.2
set CELL_HEIGHT 1.8
set SUPERTILE_SIZE [expr 8*$CELL_HEIGHT]

# ===== Core dimensions =====
# CORE_WIDTH_IN_SUPERTILES: the core dimension in units of supertiles
# CORE_HEIGHT_IN_SUPERTILES: the core dimension in units of supertiles

set CORE_WIDTH_IN_SUPERTILES  25;
set CORE_HEIGHT_IN_SUPERTILES 16;

set MIN_SPACE [expr $CELL_HEIGHT/2]

set CORE_WIDTH  [expr $CORE_WIDTH_IN_SUPERTILES * $SUPERTILE_SIZE]
set CORE_HEIGHT [expr $CORE_HEIGHT_IN_SUPERTILES * $SUPERTILE_SIZE]

# ===== Core power ring =====
# POWER_RING_CLEARANCE: spacing between adjacent power rings, and between the core and innermost ring edge
# POWER_RING_SPACE: space between the IO pads and outermost ring edge
# POWER_RING_WIDTH: width of a core power ring
# POWER_RING_CHANNEL_WIDTH: combined width of the rings, clearances, and spacing
# RING_HLAYER: horizontal ring metal
# RING_VLAYER: vertical ring metal
set POWER_RING_CLEARANCE 2.0
set POWER_RING_SPACE 1.2
set POWER_RING_WIDTH 3.0
set POWER_RING_CHANNEL_WIDTH [expr 2*$POWER_RING_WIDTH + 2*$POWER_RING_CLEARANCE + $POWER_RING_SPACE]
set RING_HLAYER M6
set RING_VLAYER M7

# ===== Chip Finishing =====
# METAL_FILL_SPACING: minimum spacing between metal fill and non-fill metals
set METAL_FILL_SPACING 2.0
