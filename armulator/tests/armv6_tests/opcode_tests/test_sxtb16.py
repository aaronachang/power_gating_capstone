from armulator.armv6.opcodes.concrete.sxtb16_a1 import Sxtb16A1
from armulator.armv6.opcodes.concrete.sxtb16_t1 import Sxtb16T1


def test_sxtb16_t1(thumb_v6_without_fetch):
    arm = thumb_v6_without_fetch
    arm.opcode = 0b11111010001011111111001010010000
    arm.opcode_len = 32
    opcode = arm.decode_instruction(arm.opcode)
    opcode = opcode.from_bitarray(arm.opcode, arm)
    assert type(opcode) == Sxtb16T1
    assert opcode.instruction == arm.opcode
    assert opcode.m == 0
    assert opcode.d == 2
    assert opcode.rotation == 8
    arm.registers.set(opcode.m, 0xfefffeff)
    arm.emulate_cycle()
    assert arm.registers.get(opcode.d) == 0xfffefffe


def test_sxtb16_a1(arm_v6_without_fetch):
    arm = arm_v6_without_fetch
    arm.opcode = 0b11100110100011110010010001110000
    arm.opcode_len = 32
    opcode = arm.decode_instruction(arm.opcode)
    opcode = opcode.from_bitarray(arm.opcode, arm)
    assert isinstance(opcode, Sxtb16A1)
    assert opcode.instruction == arm.opcode
    assert opcode.m == 0
    assert opcode.d == 2
    assert opcode.rotation == 8
    arm.registers.set(opcode.m, 0xfefffeff)
    arm.emulate_cycle()
    assert arm.registers.get(opcode.d) == 0xfffefffe
