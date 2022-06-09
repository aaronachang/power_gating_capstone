from armulator.armv6.bits_ops import set_substring, to_signed, substring, to_unsigned
from armulator.armv6.opcodes.opcode import Opcode


class Sasx(Opcode):
    def __init__(self, instruction, m, d, n):
        super().__init__(instruction)
        self.m = m
        self.d = d
        self.n = n

    def execute(self, processor):
        if processor.condition_passed():
            n = processor.registers.get(self.n)
            m = processor.registers.get(self.m)
            diff = to_signed(substring(n, 15, 0), 16) - to_signed(substring(m, 31, 16), 16)
            sum_ = to_signed(substring(n, 31, 16), 16) + to_signed(substring(m, 15, 0), 16)
            d = set_substring(0, 15, 0, to_unsigned(diff, 16))
            d = set_substring(d, 31, 16, to_unsigned(sum_, 16))
            processor.registers.set(self.d, d)
            ge = 0b11 if diff >= 0 else 00
            ge = set_substring(ge, 3, 2, 0b11 if sum_ >= 0 else 00)
            processor.registers.cpsr.ge = ge
