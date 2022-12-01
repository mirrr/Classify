.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp) #counter for a1, number of elements left in array
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)
	
    addi s0, x0, -1
    addi t0, x0, 1
    bge a1, t0, loop_start
	addi a1, x0, 78
    jal exit2
    
loop_start:
	addi s0, s0, 1 #counter++
    blt s0, a1, loop_continue
	j loop_end

loop_continue:
    slli t2, s0, 2
    add t0, a0, x0 #store address of our array
    add t2, t2, t0 #offset to index into the value we want to check
	lw t1, 0(t2)
    bge t1, x0, loop_start
    sw x0, 0(t2)
    j loop_start
    
loop_end:
    # Epilogue
	lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    
	ret
