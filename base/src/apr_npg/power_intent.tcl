
# Note: If this value is set false, 
# the compiler will disable supply sets completely and you cannot declare/update your own supply 
# sets 
set upf_create_implicit_supply_sets false

##### Power Port and Domain Setup #####
#Creating a power domain with a supply set named primary
create_power_domain TOP  
create_power_domain PGD -elements {u_mwe_pg}

#Declaring supply ports (don't declare a port for the virtual power rail, because it
# shouldn't be a top-level input to your system. It's a result of the header switch,
# which is part of your system. You do need a net for the virtual rail though, as shown
# below for VDD_sw)
#tVDD is top-level domain, VSS is ground
create_supply_port -direction in tVDD 
create_supply_port -direction in VSS

create_supply_net tVDD
create_supply_net VSS
create_supply_net VDD_sw

connect_supply_net tVDD -ports tVDD
connect_supply_net VSS -ports VSS

# Note: setting the domain supply nets like this is technically legacy code,
# but it worked better for us than the 2018 UPF. IEEE thought making the commands
# more "abstract" was a good idea 
set_domain_supply_net TOP \
  -primary_power_net tVDD \
  -primary_ground_net VSS

# You want your power net for your power-gated domain (in this case PGD) to be the
# net (not port) that you declared above
set_domain_supply_net PGD \
  -primary_power_net VDD_sw \
  -primary_ground_net VSS

#Creating header switch for domain PGD
# Note: the names of the supply and control ports don't have to match the pin names
# of the header switch cell. 
create_power_switch PGD_SWITCH \
  -domain PGD \
  -input_supply_port	{inp tVDD} \
  -output_supply_port	{outp VDD_sw} \
  -control_port		{ss_cntrl activate} \
  -on_state		{s_on inp {ss_cntrl}} \
  -off_state		{s_off {!ss_cntrl}}

#Power state table, setting voltage to 1.0 because our isolation cells
# do not operate at 1.2V
# This power state table is not needed if you use supply sets. Instead, you just declare 
# states for different objcts like a domain or supply port (or the supply set itself,
# so that the domain state is defined by a boolean function of its internal supply sets' states
add_port_state tVDD -state {TOP_VDD 1.0}
add_port_state VSS -state {GND 0.0}
add_port_state PGD_SWITCH/outp \
  -state {POWER_ON 1.0} \
  -state {POWER_OFF off}

create_pst PST -supplies 	  {tVDD    VDD_sw    VSS}
add_pst_state ON -pst PST -state  {TOP_VDD POWER_ON  GND}
add_pst_state OFF -pst PST -state {TOP_VDD POWER_OFF GND}

#In the end the problem I found with supply sets was that I couldn't find an error-free way to
# set voltages, especially for the power gate output net (ex: VDD_sw)
set_voltage 1.0 -object_list {tVDD VDD_sw}
set_voltage 0 -object_list {VSS}

#Declaring our isolation strategy, where we clamp outputs from 
# the PGD domain when 'activate' goes high
set_isolation isoPGtoTOP \
  -domain PGD \
  -isolation_power_net tVDD \
  -isolation_ground_net VSS \
  -applies_to outputs \
  -isolation_signal activate \
  -isolation_sense high


#And that's about it! Good luck to any future UPF developers:)
