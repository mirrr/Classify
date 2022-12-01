.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    addi t0, x0, 1
	blt a1, t0, error0
    blt a2, t0, error0
    blt a4, t0, error1
    blt a5, t0, error1
    bne a2, a4, error2

    # Prologue
	addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp) 
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)
    
    mv s0, a0 #s0 - pointer to start of m0
    mv s1, a1 #s1 - number of rows in m0
    mv s2, a2 #s2 - number of columns in m0 (stride)
    mv s3, a3 #s3 - pointer to start of m1
    mv s4, a4 #s4 - number of rows in m1
    mv s5, a5 #s3 - number of columns in m1 (stride)
    mv s6, a6 #s6 - d, the resulting product matrix
    
    mv s7, x0 #row counter
    mv s8, x0 #col counter
    
    j outer_loop_start

error0:
    addi a1, x0, 72
    jal exit2
    
error1:
    addi a1, x0, 73
    jal exit2
    
error2:
    addi a1, x0, 74
    jal exit2

outer_loop_start: #iterate through rows in m0
    bge s7, s1, outer_loop_end
    mul t0, s7, s2 #t0 stores row index position
    slli t0, t0, 2 #t0 converted to bytes
    add t1, a0, t0 #t1 - offset address for m0
    j inner_loop_start
	
inner_loop_start: #iterate through columns in m1
    bge s8, s5, inner_loop_end
    slli t2, s8, 2 #t2 - column index position in bytes
    add t2, a3, t2 #t2 - offset address for m1

    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp) 
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw t1, 28(sp)
    sw t2, 32(sp)

    mv a0, t1
    mv a1, t2
    mv a2, s2
    li a3, 1
    mv a4, s5

    jal dot

    mv t3, a0 #t3 stores dot product value returned by dot func

    lw a0, 0(sp)
    lw a1, 4(sp) 
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    lw t1, 28(sp)
    lw t2, 32(sp)
    addi sp, sp, 36

    sw t3, 0(s6)
    addi s6, s6, 4

    addi, s8, s8, 1 #increment column counter
    j inner_loop_start

inner_loop_end:
    mv s8, x0 #reset columns to zero

    addi s7, s7, 1
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp) 
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40
    
    ret