beginning:
    MOVS 5, #24

    MOV 7, 14

    ADDS 5, 7, #3
    
    ADDS 0, 3, 5
    
    ADD SP, SP, #120
    
    SUBS 0, 2, #4

random:    
    SUBS 1, 3, 6
    
    SUB SP, SP, #99
    
    CMP 1, 4
    
    ANDS 7, 3
    
    EORS 2, 5
    
    ORRS 0, 0
    
    MVNS 4, 6
    
    LSLS 1, 1, 7
    
    LSRS 2, 2, 6
    
    ASRS 3, 3, 5
    
    RORS 4, 4, 6

new_label:    
    STR 2, [3, #28]
    
    LDR 7, [6, #11]
    
    BEQ new_label
    
    BNE #-100
    
    BCS #-100
    
    BCC #-100
    
    BMI #-100
    
    BPL #-100
    
    BVS #-100
    
    BVC #-100
    
    BHI #-100
    
    BLS #-100
    
    BGE #-100
    
    BLT #-100
    
    BGT #-100
    
    BLE #-100
    
    BAL #-100
    
    B #-1000
    
    BL #20
    
    BX 14
    
    NOOP

    ENCR #10, #50

    ECOG
