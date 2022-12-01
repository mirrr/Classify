.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp) #counter for a1, number of elements left in array
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)
    
    lw s2, 0(a0)
    addi s3, x0, 0
	
    addi s0, x0, -1
    addi t0, x0, 1
    bge a1, t0, loop_start
	addi a1, x0, 77
    jal exit2

loop_start:
	addi s0, s0, 1 #counter++
    blt s0, a1, loop_continue #if no more elements in array
	j loop_end

loop_continue:
    slli t2, s0, 2
    add t0, a0, x0 #store address of our array
    add t2, t2, t0 #offset to index into the value we want to check
	lw t1, 0(t2)
    addi t3, s2, 1
    blt t1, t3, loop_start #if val < s2 + 1 --> val <= s2
    addi s2, t1, 0 #s2 contains max value
    addi s3, s0, 0 #s3 contains max index
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
