.data
.text

switch:
addi $t0, $zero, 0xFFFF
sll $t0, $t0, 16
addi $t0, $t0, 0xC000 #t0 IO输入输出基地址
lw $t3, 0($t0) #t3 IO输入
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
andi $t4, $t3, 0xFF #t4操作数
addi $t5, $t4, -1
and $t5, $t5, $t4 #$t5为零即正确
slti $t5, $t5, 1
sll $t4, $t4, 8
or $t4, $t4, $t5
sw $t4, 0($t0)
j switch

case1:
andi $t4, $t3, 0xFF #t4操作数
andi $t5, $t4, 1
sll $t4, $t4, 8
or $t4, $t4, $t5
sw $t4, 0($t0)
j switch

case2:
or $s1, $t4, $t5
sw $s1, 0($t0)
j switch

case3:
nor $s1, $t4, $t5
sw $s1, 0($t0)
j switch

case4:
xor $s1, $t4, $t5
sw $s1, 0($t0)
j switch

case5:
addi $s1, $zero, 0x80
and $s2, $t4, $s1
and $s3, $t5, $s1 #s2, s3符号位
slt $s0, $s3, $s2 #先比较正负,s0是1时，符合条件
bne $s2, $s3, Exit5
and $s4, $s2, $s3
beq $zero, $s4, compare5
beq $t4, $t5, compare5
slt $s0, $t5, $t4
j Exit5
compare5:
slt $s0, $t4, $t5
Exit5:
sw $s0, 0($t0)
j switch

case6:
sltu $s1, $t4, $t5
sw $s1, 0($t0)
j switch

case7:
andi $t4, $t3, 0xFF # t4 operand1
srl $t3, $t3, 8
andi $t5, $t3, 0xFF #t5 operand2
sll $s7, $t4, 8
or $s7, $s0, $t5
sw $s7, 0($t7)







