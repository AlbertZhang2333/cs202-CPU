.data
.text
switch:
addi $t0, $zero, 0xFFFF
sll $t0, $t0, 16
addi $t0, $t0, 0xC000 #t0 IO输入输出基地址
lw $t3, 0($t0) //t3 IO输入
addi $t1, $zero, 7
and $t1, $t1, $t3 #t1用例编号
srl $t3, $t3, 3

addi $t2, $zero, 0
beq $t2, $t1, case0
addi $t2, $t2, 1
beq $t2, $t1, case1
addi $t2, $t2, 1
beq $t2, $t1, case2
addi $t2, $t2, 1
beq $t2, $t1, case3
addi $t2, $t2, 1
beq $t2, $t1, case4
addi $t2, $t2, 1
beq $t2, $t1, case5
addi $t2, $t2, 1
beq $t2, $t1, case6
addi $t2, $t2, 1
beq $t2, $t1, case7
j switch

case0:
#闪烁
addi $s0, $zero,0
sw $s0, 1($t0)
andi $t4, $t3, 0xFF #t4 operand
addi $t5, $zero, 1
add $s1, $zero, $t4
srl $s1, $s1, 7
beq $s1, $zero, Loop0

addi $t7,$zero,1
addi $t6,$zero,32767
sll $t6,$t6,9
stall0:
addi $t7,$t7,1
bne $t7,$t6,stall0
addi $s0, $zero, 0xFFFF
sw $s0, 1($t0)
addi $t7,$zero,1
addi $t6,$zero,32767
sll $t6,$t6,9
stall01:
addi $t7,$t7,1
bne $t7,$t6,stall01

Loop0:
add $s0, $s0, $t5
addi $t5, $t5, 1
slt $s1, $t4, $t5
beq $s1, $zero, Loop0
sw $s0, 1($t0)
j switch


case1:
addi $s0, $zero, 0
addi $s1, $zero, 0
andi $t4, $t3, 0xFF
add $a0, $zero, $t4
jal func1
add $s0, $s0, $s1
sw $s0, 1($t0)
j switch

func1:
add $sp, $sp, -8
sw $ra, 4($sp)
sw $a0, 0($sp)
addi $s0, $s0, 2
slti $t5, $a0, 2
beq $t5, $zero, L1
addiu $v0, $zero, 1
addi $sp, $sp, 8
jr $ra
L1:
addi $a0, $a0, -1
jal func1
lw $a0, 0($sp)
lw $ra, 4($sp)
addi $s1, $s1, 2
addi $sp, $sp, 8
addu $v0, $v0, $a0
jr $ra



case2:
andi $t4, $t3, 0xFF
add $a0, $zero, $t4
jal func2
sw $v0, 1($t0)
j switch

func2:
add $sp, $sp, -8
sw $ra, 4($sp)
sw $a0, 0($sp)
sw $a0, 1($t0)

addi $t7,$zero,1
addi $t6,$zero,32767
sll $t6,$t6,9
stall2:
 addi $t7,$t7,1
 bne $t7,$t6,stall2

slti $t5, $a0, 2
beq $t5, $zero, L1
addiu $v0, $zero, 1
addi $sp, $sp, 8
jr $ra
L2:
addi $a0, $a0, -1
jal func2
lw $a0, 0($sp)
lw $ra, 4($sp)
addi $sp, $sp, 8
addu $v0, $v0, $a0
jr $ra


case3:
andi $t4, $t3, 0xFF
add $a0, $zero, $t4
jal func3
sw $v0, 1($t0)
j switch

func3:
add $sp, $sp, -8
sw $ra, 4($sp)
sw $a0, 0($sp)
slti $t5, $a0, 2
beq $t5, $zero, L1
addiu $v0, $zero, 1
addi $sp, $sp, 8
jr $ra
L3:
addi $a0, $a0, -1
jal func3
lw $a0, 0($sp)
lw $ra, 4($sp)
sw $a0, 1($t0)

addi $t7,$zero,1
addi $t6,$zero,32767
sll $t6,$t6,9
stall3:
 addi $t7,$t7,1
 bne $t7,$t6,stall3

addi $sp, $sp, 8
addu $v0, $v0, $a0
jr $ra


case4:
andi $t4, $t3, 0xFF
srl $t3, $t3, 8
andi $t5, $t3, 0xFF
addu $s0, $t4, $t5
srl $s1, $s0, 7
andi $s1, $s1, 1
srl $t4, $t4, 7
srl $t5, $t5, 7
and $s2, $t4, $t5
xori $s3, $s1, 1
and $s2, $s2, $s3
xori $t4, $t4, 1
xori $t5, $t5, 1
and $s1, $s1, $t4
and $s1, $s1, $t5
or $s1, $s1, $s2
sll $s0, $s0, 8
or $s0, $s0, $s1
sw $s0, 1($t0)
j switch


case5:
#t4(低位） - t5(高位)
andi $t4, $t3, 0xFF
srl $t3, $t3, 8
andi $t5, $t3, 0xFF
xori $t5, $t5, 0xFF
addi $t5, $t5, 1 #t5变相反数
addu $s0, $t4, $t5
srl $s1, $s0, 7
andi $s1, $s1, 1
srl $t4, $t4, 7
srl $t5, $t5, 7
and $s2, $t4, $t5
xori $s3, $s1, 1
and $s2, $s2, $s3
xori $t4, $t4, 1
xori $t5, $t5, 1
and $s1, $s1, $t4
and $s1, $s1, $t5
or $s1, $s1, $s2
sll $s0, $s0, 8
or $s0, $s0, $s1
sw $s0, 1($t0)
j switch


case6:
addi $t6, $zero, 0
addi $t7, $zero, 8
andi $t4, $t3, 0xFF
srl $t3, $t3, 8
andi $t5, $t3, 0xFF
andi $s4, $t4, 0x80
srl $s4, $s4, 7
andi $s5, $t5, 0x80
srl $s5, $s5, 7 # s4, s5符号位
xor $s6, $s4, $s5 # s6为1运算结果为负
beq $zero, $s4, reversec6s5
xori $t4, $t4, 0xFF
addi $t4, $t4, 1
reversec6s5:
beq $zero, $s5, Loop6
xori $t5, $t5, 0xFF
addi$t5, $t5, 0xFF
Loop6:
andi $s5, $t4, 0x40
beq $zero, $s5, next6
add $s0, $t5, $s0
next6:
sll $s0, $s0, 1
sll $t4, $t4, 1
addi $t6, $t6, 1
bne $t6, $t7, Loop6
beq $s6, $zero, Exit
xori $s0, $s0, 0xFFFF
addi $s0, $s0, 1
Exit:
sw $s0, 1($t0)
j switch


case7:
addi $t6, $zero, 0
addi $t7, $zero, 9
andi $t4, $t3, 0xFF
srl $t3, $t3, 8
andi $t5, $t3, 0xFF //t4 remainder, t5 divisor
andi $s4, $t4, 0x80
srl $s4, $s4, 7
andi $s5, $t5, 0x80
srl $s5, $s5, 7 # s4, s5符号位
xor $s6, $s4, $s5 # s6为1运算结果为负
beq $zero, $s4, reversec7s5
xori $t4, $t4, 0xFF
addi $t4, $t4, 1
reversec7s5:
beq $zero, $s5, pre
xori $t5, $t5, 0xFF
addi$t5, $t5, 0xFF
pre:
sll $t5, $t5, 8
addi $s0, $zero, 0 #Q
Loop7:
xori $s1, $t5, 0xFF
addi $s1, $s1, 1 //s1 = -divisor
add $t4, $t4, $s1
andi $s2, $t4, 0x80
slt $s3, $zero, $s2
beq $s3, $zero, positive
add $t4, $t4, $t5
sll $s0, $s0, 1 
j next7
positive:
sll $s0, $s0, 1
ori $s0, $s0, 1
next7:
srl $t5, $t5, 1
addi $t6, $t6, 1
bne $t6, $t7, Loop7
beq $s6, $zero, Exit
xori $s0, $s0, 0xFFFF
addi $s0, $s0, 1
Exit:
#交替显示
sw $s0, 1($t0)
j switch
