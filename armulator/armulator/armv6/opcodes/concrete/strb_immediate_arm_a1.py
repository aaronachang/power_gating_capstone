from armulator.armv6.bits_ops import bit_at, substring
from armulator.armv6.opcodes.abstract_opcodes.strb_immediate_arm import StrbImmediateArm


class StrbImmediateArmA1(StrbImmediateArm):
    @staticmethod
    def from_bitarray(instr, processor):
        index = bit_at(instr, 24)
        add = bit_at(instr, 23)
        w = bit_at(instr, 21)
        imm32 = substring(instr, 11, 0)
        rt = substring(instr, 15, 12)
        rn = substring(instr, 19, 16)
        wback = (not index) or w
        if rt == 15 or (wback and (rn == 15 or rn == rt)):
            print('unpredictable')
        else:
            return StrbImmediateArmA1(instr, add=add, wback=wback, index=index, t=rt, n=rn, imm32=imm32)
