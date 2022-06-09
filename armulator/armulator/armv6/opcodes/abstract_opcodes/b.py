from armulator.armv6.opcodes.opcode import Opcode
from armulator.armv6.bits_ops import add


class B(Opcode):
    def __init__(self, instruction, imm32):
        super().__init__(instruction)
        self.imm32 = imm32

    def execute(self, processor):
        if processor.condition_passed():
            processor.branch_write_pc(add(processor.registers.pc_store_value(), self.imm32, 32))
