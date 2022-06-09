set results "results"
set reports "reports"

file mkdir ./$results
file mkdir ./$reports

# Project and design
# ==========================================================================
set CORNER "LOW"

# ICC runtime 
# ==========================================================================
# Silence the unholy number of warnings that are known to be harmless
suppress_message "DPI-025"
suppress_message "PSYN-485"

# Library setup
# ==========================================================================

set DESIGN_MW_LIB_NAME "design_lib"
# Logic libraries 
set TSMC_PATH "/home/lab.apps/vlsiapps/kits/tsmc/N65RF/1.0c/digital"
set TARGETCELLLIB_PATH "$TSMC_PATH/Front_End/timing_power_noise/NLDM/tcbn65gplus_140b"
set ADDITIONAL_SEARCH_PATHS [list \
				 "$TARGETCELLLIB_PATH" \
				 "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/cell_frame/tcbn65gplus/LM/*" \
				 "$synopsys_root/libraries/syn" \
				 "./" \
				]
set TARGET_LIBS [list \
		     "tcbn65gplustc0d8.db" \
		    ]
#Used by sdc 
set ADDITIONAL_TARGET_LIBS {}
	# RAM_16B_512.db}
set ADDITIONAL_SYMBOL_LIBS {}
set SYMBOL_LIB "tcbn65gplustc0d8.db"
set SYNOPSYS_SYNTHETIC_LIB "dw_foundation.sldb"

# Reference libraries 
set MW_REFERENCE_LIBS "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/frame_only/tcbn65gplus"
set MW_ADDITIONAL_REFERENCE_LIBS {}
	# ./RAM_16B_512}

# # Worst case library
# set LIB_WC_FILE   "tcbn65gplustc0d8.db"
# set LIB_WC_NAME   "tcbn65gplustc0d8"

# # Best case library
# set LIB_BC_FILE   "tcbn65gplusbc0d8.db"
# set LIB_BC_NAME   "tcbn65gplusbc0d8"

# # Operating conditions
# set LIB_WC_OPCON  "NC0D8COM"
# set LIB_BC_OPCON  "NC0D8COM"

# Technology files
set MW_TECHFILE_PATH "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/techfiles"
set MW_TLUPLUS_PATH "$MW_TECHFILE_PATH/tluplus"
set MAX_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcbest_top2.tluplus"
set MIN_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcworst_top2.tluplus"

set TECH2ITF_MAP_FILE "star.map_9M"
set MW_TECHFILE "tsmcn65_9lmT2.tf"

# POWER NETWORK CONFIG
# ==========================================================================
set MESH_FILE "mesh.tpl"
set MESH_NAME "core_mesh"
set CUSTOM_POWER_PLAN_SCRIPT "macro_power.tcl"

# FUNCTIONAL CONFIG
# ==========================================================================

set_route_zrt_common_options -global_max_layer_mode hard
if {$TOOL_NAME == "ICC"} {
    # Zroute and the common router do not respect macro blockage layers by default
    set_route_zrt_common_options \
	-read_user_metal_blockage_layer "true" \
	-wide_macro_pin_as_fat_wire "true"
}

set FILL_CELLS {FILL8 FILL4 FILL2 FILL1}

# RESULT GENERATION AND REPORTING
# ==========================================================================
set reports "reports" ; # Directory for reports
set results "results" ; # For generated design files
source ${SCRIPTS_DIR}/common_functions.tcl

