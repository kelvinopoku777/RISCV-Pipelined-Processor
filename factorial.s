start:
    addi sp, zero, 1024
    addi a0, zero, 6
    jal ra, fact
    sw a0, 0(zero)
    beq zero, zero, halt_label

fact:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    addi t0, zero, 1
    bne a0, t0, recurse
    addi a0, zero, 1
    addi sp, sp, 8
    jalr zero, 0(ra)

recurse:
    addi a0, a0, -1
    jal ra, fact
    lw t1, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    mul a0, a0, t1
    jalr zero, 0(ra)

halt_label:
    halt
