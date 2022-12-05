ori x3, x0, hex
ori x4, x0, #2
sw x3, x4, 0
addi x4, x4, -1
sw x3, x4, 0
bne x4, x0, -4
sw x3, x4, 0
jal 0, 0