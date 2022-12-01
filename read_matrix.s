.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -24
    sw s0, 0(sp) #filename
    sw s1, 4(sp) #row pointer
    sw s2, 8(sp) #col pointer
    sw s3, 12(sp) #holds file descriptor
    sw s4, 16(sp)
    sw ra, 20(sp)

    #save filename, row, and col pointer to s registers
    mv s0, a0
    mv s1, a1
    mv s2, a2

    j open_file

error0:
    addi a1, x0, 88
    jal exit2
    
error1:
    addi a1, x0, 90
    jal exit2

error2:
    addi a1, x0, 91
    jal exit2

error3:
    addi a1, x0, 92
    jal exit2

open_file:
    #open file
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a1, a0 #filepath-->a1
    li a2, 0 #read only permissions is 0
    jal fopen 
    li t0, -1
    beq a0, t0, error1
    mv s3, a0 #store file descriptor in s3
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    #read the values of row
    addi sp, sp, -12
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)
    
    mv a2, a1 #row pointer
    addi a3, x0, 4 #number of bytes to be read
    mv a1, s3 #file descriptor
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fread
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a3, a0, error2 # number of bytes we wanted to read!= if number of bytes read

    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    addi sp, sp, 12

    #read the values of col
    addi sp, sp, -12
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)
    
    #a2 is already pointing to the col pointer
    addi a3, x0, 4 #number of bytes to be read
    mv a1, s3 #file descriptor
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fread
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a3, a0, error2 #if number of bytes read != number of bytes we wanted to read

    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    addi sp, sp, 12
    #malloc space
    lw s1, 0(a1) #load row number into s1
    lw s2, 0(a2) #load col number into s2
    mul t1, s1, s2 #t1 stores size of matrix (row*col)

    #malloc space for matrix pointer
    # addi sp, sp, -4
    # sw a0, 0(sp)  do we need to store a0??
    slli t1, t1, 2
    mv a0, t1 #move size into a0 argument for malloc

    jal malloc #a0 is now a pointer to our matrix
    mv s4, a0 #s4 is now a pointer to our matrix
    beq s4, x0, error0
    mv s0, s4 #s0 will be our pointer down the matrix array

    j load_matrix

load_matrix:
    addi sp, sp, -16
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)
    sw a0, 12(sp)
    
    mv a2, s0 #row pointer
    addi a3, x0, 4 #number of bytes to be read
    mv a1, s3 #file descriptor
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fread
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a3, a0, close_file # number of bytes we wanted to read!= if number of bytes read

    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    lw a0, 12(sp)
    addi sp, sp, 16

    addi s0, s0, 4 #increment matrix pointer
    j load_matrix


close_file:
    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    lw a0, 12(sp)
    addi sp, sp, 16

    #close file
    mv a1, s3 #move file descriptor to a1 for fclose
    jal fclose
    bne a0, x0, error3

    mv a0, s4 #move our matrix pointer to a0

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    ret
