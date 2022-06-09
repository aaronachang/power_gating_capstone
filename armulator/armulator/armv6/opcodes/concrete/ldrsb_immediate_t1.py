from armulator.armv6.bits_ops import substring
from armulator.armv6.opcodes.abstract_opcodes.ldrsb_immediate import LdrsbImmediate


class LdrsbImmediateT1(LdrsbImmediate):
    @staticmethod
    def from_bitarray(instr, processor):
        imm32 = substring(instr, 11, 0)
        rt = substring(instr, 15, 12)
        rn = substring(instr, 19, 16)
        index = True
        add = True
        wback = False
        if rt == 13:
            print('unpredictable')
        else:
            return LdrsbImmediateT1(instr, add=add, wback=wback, index=index, imm32=imm32, t=rt, n=rn)
