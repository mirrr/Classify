.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:

    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp) #counter for a1, number of elements left in array, from 0 to n
    sw s1, 4(sp) 
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)
    
    addi s0, x0, -1
    add s1, x0, a3 #s1 stores stride of v0
    add s2, x0, a4 #s2 stores tride of v1
    
    addi s3, x0, 0 #s3 stores sum (aka return value)
    
    addi t0, x0, 1
    blt a2, t0, error0
    blt a3, t0, error
    blt a4, t0, error
    j loop_start
    
error0:
    addi a1, x0, 75
    jal exit2
   
error:
    addi a1, x0, 76
    jal exit2

loop_start:
    addi s0, s0, 1 #counter++
    blt s0, a2, loop_continue #if no more elements in array
    j loop_end

loop_continue:
    mul t0, s1, s0 #t0 - indexing for v0 array
    mul t1, s2, s0 #t0 - indexing for v1 array
    slli t0, t0, 2
    slli t1, t1, 2
    add t2, a0, x0 #store address of v0 array
    add t3, a1, x0 #store address of v1 array
    add t2, t2, t0 #offset to index into the value we want to check - v0 array
    add t3, t3, t1 #offset to index into the value we want to check - v1 array
    
    lw t4, 0(t2) #values at v0 array and v1 array respectively
    lw t5, 0(t3)
    
    mul t6, t4, t5
    add s3, s3, t6

    #addi sp, sp, -12
    #sw t0, 0(sp)
    #sw t1, 4(sp)
    #sw t2, 8(sp)
    #sw t3, 12(sp)
    
    j loop_start
    
loop_end:
    # Epilogue
    mv a0, s3
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    
    ret