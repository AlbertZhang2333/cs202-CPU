.data
.text
switch:

addi $t0, $zero, 0xFFFF
addi $t1, $zero, 16
sll $t0, $t0, $t1
addi $t0, $t0, 0xC000//t0 IO基地址
lw $t3, 0($t0) //t3 IO输入
addi $t1, $zero, 7
and $t1, $t1, $t3//t1用例编号
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

andi $t4, $t3, 0xFF //t4 operand
addi $t5, $t4, -1
and $t5, $t5, $t4 //$t5 v&(v - 1)
slti $t5, $t5, 1
sll $t4, $t4, 8
or $t4, $t4, $t5
sw $t4, 0($t0)

case1??
andi $t4, $t3, 0xFF //t4??????
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
and $s3, $t5, $s1 //s2, s3????λ
sltu $s0, $s3, $s2//????????
bne $s2, $s3, Exit5
and $s4, $s2, $s3
beq $zero, $s4, compare5
add $s4, $zero, $t4
add $t4, $zero, $t5
add $t5, $zero, $s4
addi $s1, $zero, 0xFF
xor $t4, $t4, $s1
xor $t5, $t5, $s1
compare5:
sltu $s0, $t4, $t5
Exit5:
sw $s0, 0($t0)
j switch

case6:
sltu $s1, $t4, $t5
sw $s1, 0($t0)
j switch

case7:
andi $t4, $t3, 0xFF //t4 operand1
sll $t3, $t3, 8
andi $t5, $t3, 0xFF //t5 operand2
sll $s0, $t4, 8
or $s0, $s0, $t5
sw $s0, 0($t0)







