from armulator.armv6.bits_ops import sign_extend, substring, bit_at, bit_not, chain
from armulator.armv6.opcodes.abstract_opcodes.bl_blx_immediate import BlBlxImmediate


class BlBlxImmediateT1(BlBlxImmediate):
    @staticmethod
    def from_bitarray(instr, processor):
        imm6 = sign_extend(substring(instr, 5, 0), 6, 32)
        #imm11 = substring(instr, 10, 0)
        #j2 = bit_at(instr, 11)
        #j1 = bit_at(instr, 13)
        #imm10 = substring(instr, 25, 16)
        #s = bit_at(instr, 26)
        #i1 = bit_not(j1 ^ s, 1)
        #i2 = bit_not(j2 ^ s, 1)
        #imm32 = sign_extend(chain(s, chain(i1, chain(i2, chain(imm10, imm11 << 1, 12), 22), 23), 24), 25, 32)
        target_instr_set = processor.registers.current_instr_set()
        if processor.in_it_block() and not processor.last_in_it_block():
            print('unpredictable')
        else:
            return BlBlxImmediateT1(instr, target_instr_set=target_instr_set, imm32=imm6)
            #return BlBlxImmediateT1(instr, target_instr_set=target_instr_set, imm32=imm32)
