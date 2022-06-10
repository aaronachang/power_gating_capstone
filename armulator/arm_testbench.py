from armulator.armv6.arm_v6 import ArmV6
from armulator.armv6.memory_controller_hub import MemoryController
from armulator.armv6.memory_types import RAM

import argparse
import os
import re
import subprocess

instructions_filepath = "../base/src/assembler"
presyn_filepath = "../base/sim/pre-syn"
postsyn_filepath = "../base/sim/post-syn"
postapr_filepath = "../base/sim/post-apr"
DATA_MEM_BASE = 0x100
DATA_MEM_SIZE = 0x0FF
FUNCTION_BASE = 0x0
sim_setup = "make softlink_"
sim_cmd = "make vcs"
sim_clean = "make clean"
sim_output = "cpu_output.txt"
testbench_reglist = []

def arm_simulation(instructions_config, verilog_folder):
    if verilog_folder == "syn":
        simulation_filepath = postsyn_filepath
    elif verilog_folder == "apr":
        simulation_filepath = postapr_filepath
    else:
        simulation_filepath = presyn_filepath
    os.chdir(simulation_filepath)
    subprocess.run(sim_clean, check=True, shell=True)
    subprocess.run(sim_setup + verilog_folder, check=True, shell=True)
    subprocess.run(sim_cmd + " TEST=" + instructions_config, check=True, shell=True)

    cpu_file = open(sim_output, "r")
    subprocess.run(sim_clean, check=True, shell=True)
    
    sim_reglist = [i for i in cpu_file.readlines()]
    passed = True
    for i in range(0, 14): #skip register 15 since simulation will be 'x'
        print("Register {}: Expected: {} Simulation: {}".format(i, testbench_reglist[i], sim_reglist[i]))
        if testbench_reglist[i] != int(sim_reglist[i]):
            print("\nError: Register {} in simulation {} does not match testbench {}".format(i, sim_reglist[i], testbench_reglist[i]))
            passed = False
    if passed:
        print("\nSimulation output matches testbench output!\n")
    cpu_file.close()


def arm_testbench(instructions_file):
    arm = ArmV6()
    arm.take_reset()
    arm.registers.sctlr.m = 0
    datamem = RAM(DATA_MEM_SIZE)
    mc_data = MemoryController(datamem, DATA_MEM_BASE, DATA_MEM_BASE + DATA_MEM_SIZE)
    arm.mem.memories.append(mc_data)

    f = open(os.path.join(instructions_filepath, instructions_file))
    CODE = bytes()
    for line in f:
        number_list = re.findall('[0-9]+', line.split("//")[0])
        if number_list:
            binary_string = "".join(number_list)
            little_endian_string = binary_string[8:] + binary_string[:8]
            byte_convert = int(little_endian_string, 2).to_bytes(2, byteorder="big")
            CODE += byte_convert

    function_memory = RAM(len(CODE))
    function_memory.write(0, len(CODE), CODE)
    mc = MemoryController(function_memory, FUNCTION_BASE, FUNCTION_BASE + len(CODE))
    arm.mem.memories.append(mc)

    arm.registers.branch_to(FUNCTION_BASE)
    while arm.registers.get(7) != 7: # When R7 = 7, program is done
        arm.emulate_cycle()

    for i in range(0, 15):
        if i == 14:
            if arm.registers.get(i) % 2 == 0:
                testbench_reglist.append((arm.registers.get(i)))
            else:
                testbench_reglist.append((arm.registers.get(i)+1)/2)
        else:
            testbench_reglist.append(arm.registers.get(i))
    f.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ARM CPU Testbench",
                                    formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-t", help="specify test to run")
    parser.add_argument("-s", 
    help='''specify which sapr folder to use for verilog
valid values: verilog, syn, apr''')
    args = parser.parse_args()
    config = vars(args)
    if (config["t"]):
        instructions_file = config["t"].lower() + ".v"
    else:
        instructions_file = "test_instr.v"
    
    arm_testbench(instructions_file)
    arm_simulation(config["t"].upper() if config["t"] else "", config["s"])

