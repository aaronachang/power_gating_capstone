NOOP
MOVS 0, #195        //00100[Rd][im8] 195 //init:
MOVS 1, #255        //00100[Rd][im8] 255
MOVS 2, #0          //00100[Rd][im8] 0
ENCR #10, #50       //Mid- GCD encryption step.
NOOP                //Some delays to let the encryption start.
NOOP
STR 0, [0, #5]      //01100<im5><Rm><Rd> //CPU Stalls because ENCR is running.
STR 1, [1, #5]      //01100<im5><Rm><Rd>
GCD:
CMP 0, 1            //0100001010[Rm][Rn] //GCD:
BMI  Swap           //1101[cond][swap addr]
SUBS  0, 0, 1       //0001101[Rm][Rn][Rd]
CMP 1, 2            //0100001010[Rm][Rn]
BEQ  Done           //1101[cond][im8]
BAL  GCD            //1101[cond][im8]
Swap:
MOV 3, 1            //010001100[Rm][Rd]  //Swap:
MOV 1, 0            //010001100[Rm][Rd]
MOV 0, 3            //010001100[Rm][Rd]
BAL  GCD            //1101[cond][im8]
Done:
MOV 4, 0            //010001100[Rm][Rd] //Done:
NOOP
NOOP
NOOP
NOOP
NOOP
STR 4 [7, #7]       //01100<im5><Rm><Rd> (Store result of GCD in memory.)
idle:
NOOP
B idle
