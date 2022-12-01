.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp) #stores the file descriptor
    sw s5, 20(sp) #serves as temp pointer when we need row/col pointers
    sw ra, 24(sp)

    mv s0, a0 #s0 - filename
    mv s1, a1 #s1 - pointer to matrix
    mv s2, a2 #s2 - number of rows
    mv s3, a3 #s3 - number of cols

    j open_file

error0:
    addi a1, x0, 93
    jal exit2
    
error1:
    addi a1, x0, 94
    jal exit2

error2:
    addi a1, x0, 95
    jal exit2

open_file:
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a1, s0 #filename --> a1
    li a2, 1 #write-only permissions is 1
    jal fopen
    li t0, -1
    beq a0, t0, error0
    mv s4, a0 #store file descriptor in s4
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    #write row into file
    addi sp, sp, -20
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    
    mv a1, s4 #file descriptor s4-->a1 
    #set row pointer
    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)
    mv a2, sp
    
    li a3, 2 #write 2 items (row and col #)
    li a4, 4 #size of each item in buffer
    #addi sp, sp, -4
    #sw a3, 0(sp)
    jal fwrite
    #lw a3, 0(sp) #makes sure a3 holds intended number of elements written to array
    #addi sp, sp, 4
    li t0, 2
    blt a0, t0, error1 #a1 is still set to file descriptor
    addi sp, sp, 8 #restore stack space for row&col pointers
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    addi sp, sp, 20
    
    # #write col into file
    # addi sp, sp, -24
    # sw a0, 0(sp)
    # sw a1, 4(sp)
    # sw a2, 8(sp)
    # sw a3, 12(sp)
    # sw a4, 16(sp)
    
    # mv a1, s4 #file descriptor s4-->a1
    # #set col pointer
    # addi sp, sp, -4
    # sw s3, 0(sp)
    # mv a2, sp

    # li a3, 1 #write one item (aka num_cols)
    # li a4, 4 #size of each item in buffer

    # jal fwrite

    # li t1, 1
    # blt t1, a0, error1
    # addi sp, sp, 4 #restore stack space for col pointer
    
    # lw a0, 0(sp)
    # lw a1, 4(sp)
    # lw a2, 8(sp)
    # lw a3, 12(sp)
    # lw a4, 16(sp)
    # addi sp, sp, 20
    
    j write_file
    
write_file:
    addi sp, sp, -20
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    
    mul a3, s3, s2 #t2 - total number of items is row*col
    li a4, 4 #size of each item in buffer
    mv a2, s1 #matrix in mem--> a2
    mv a1, s4 #file descriptor s4-->a1
    # addi sp, sp, -4
    # sw a3, 0(sp)
    jal fwrite
    # lw a3, 0(sp) #makes sure a3 holds intended number of elements written to array
    # addi sp, sp, 4
    mul t2, s3, s2
    # blt a0, t2, error1
    blt a0, t2, error1
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    addi sp, sp, 20
    
    #does it make a difference whether incrementing pointer is s1 or a1?
    #addi s1, s1, 4 #increment pointer for matrix in memory
    
    j close_file

close_file:   
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    mv a1, s4 #file descriptor to a1
    jal fclose
    bne a0, x0, error2 #a0=0 on success
    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp, 8

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28

    ret

