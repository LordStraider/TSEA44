        .align 4
        .global ___udivsi3
        .global ___umodsi3
	
___udivsi3:
	l.addi          r1,r1,-4
        l.sw            0(r1),r9
        l.addi          r11,r0,0
        l.addi          r8,r4,0
        l.addi          r5,r3,0
        l.sfne          r8,r11
        l.bnf           4f
        l.addi          r7,r0,0
        l.sfgtu         r8,r5
        l.bf            5f
        l.sfeq          r8,r5
        l.bf            6f
        l.sfltu         r11,r8
        l.bnf           2f
        l.addi          r13,r0,32
        l.movhi         r9,hi(0x80000000)
        l.addi          r6,r0,-1
1:
        l.and           r3,r5,r9
        l.slli          r4,r7,1
        l.addi          r15,r5,0
        l.srli          r3,r3,31
        l.add           r13,r13,r6
        l.or            r7,r4,r3
        l.sfltu         r7,r8
        l.bf            1b
        l.slli          r5,r5,1
2:
        l.srli          r7,r7,1
        l.addi          r13,r13,1
        l.addi          r9,r0,0
        l.sfltu         r9,r13
        l.bnf           4f
        l.addi          r5,r15,0
        l.movhi         r15,hi(0x80000000)
        l.addi          r17,r0,0
3:
        l.and           r3,r5,r15
        l.slli          r4,r7,1
        l.srli          r3,r3,31
        l.or            r7,r4,r3
        l.sub           r6,r7,r8
        l.and           r3,r6,r15
        l.srli          r3,r3,31
        l.addi          r4,r0,0
        l.sfne          r3,r4
        l.bf            1f
        l.slli          r3,r11,1
        l.addi          r4,r0,1
1:
        l.slli          r5,r5,1
        l.sfne          r4,r17
        l.bnf           2f
        l.or            r11,r3,r4
        l.addi          r7,r6,0
2:
        l.addi          r9,r9,1
        l.sfltu         r9,r13
        l.bf            3b
        l.nop           0
	l.j		4f
	l.nop           0
6:	
	l.j		4f
	l.addi		r11,r0,1
5:
	l.addi		r7,r5,0
4:
        l.lwz           r9,0(r1)
        l.jr            r9
        l.addi          r1,r1,4

        .align 4
        .global ___divsi3
___divsi3:
	l.addi          r1,r1,-8
        l.sw            0(r1),r9
        l.sw            4(r1),r10
        l.addi          r5,r3,0
        l.addi          r10,r0,0
        l.sflts         r5,r10
        l.bnf           1f
        l.addi          r3,r0,0
        l.addi          r10,r0,1
        l.sub           r5,r0,r5
1:
        l.sflts         r4,r3
        l.bnf           1f
        l.nop           0
        l.addi          r10,r10,1
        l.sub           r4,r0,r4
1:
        l.jal           ___udivsi3
        l.addi          r3,r5,0
        l.addi          r3,r0,1
        l.sfeq          r10,r3
        l.bnf           1f
        l.nop           0
        l.sub           r11,r0,r11
1:
        l.lwz           r9,0(r1)
        l.lwz           r10,4(r1)
        l.jr            r9
        l.addi          r1,r1,8

	.align 4
        .global ___umodsi3
___umodsi3:
	l.addi          r1,r1,-4
	l.sw            0(r1),r9
	l.jal           ___udivsi3
	l.nop           0
	l.addi		r11,r7,0
	l.lwz           r9,0(r1)
	l.jr            r9
	l.addi          r1,r1,4
	
	.align 4
        .global ___modsi3
___modsi3:
        l.addi          r1,r1,-8
        l.sw            0(r1),r9
        l.sw            4(r1),r10
        l.sflts         r3,r0
        l.bnf           1f
        l.nop           0
        l.addi          r10,r0,1
        l.sub           r3,r0,r3
1:
        l.sflts         r4,r0
        l.bnf           1f
        l.nop           0
        l.sub           r4,r0,r4
1:
        l.jal           ___udivsi3
        l.nop           0
        l.addi          r3,r0,1
        l.sfeq          r10,r3
        l.bnf           1f
        l.addi		r11,r7,0
        l.sub           r11,r0,r11
1:
        l.lwz           r9,0(r1)
        l.lwz           r10,4(r1)
        l.jr            r9
        l.addi          r1,r1,8	
