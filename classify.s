.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    #note: store row and col pointer in stack, not malloc
    #You should save the addresses to # rows and columns that you give to read_matrix in a save register. Then you can do e.g. lw t0, 0(s2) to load the value at address s2 into t0.

    #Prologue
    addi sp, sp, -44
    sw s0, 0(sp) 
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp) #m0_file matrix
    sw s4, 16(sp) #m1_file matrix
    sw s5, 20(sp) #input_file matrix
    sw s6, 24(sp) #output_file 
    sw s7, 28(sp) #pointer to rows and cols
    sw s8, 32(sp) #stores network calculation progress matrix
    sw s9, 36(sp) #holds argmax result
    sw ra, 40(sp)
    
    mv s1, a1 #array of args
    mv s2, a2 #store classification fxn
    
    li t0, 5 
    bne a0, t0, error1 #check to see if exactly 4 elements in argv
    
    j load_matrices

error0:
    addi a1, x0, 88
    jal exit2
    
error1:
    addi a1, x0, 89
    jal exit2


    # =====================================
    # LOAD MATRICES
    # =====================================
load_matrices:
    addi sp, sp, -24 #make stack space for row and col pointer s7
    li t0, -1
    sw t0, 0(sp) #m0 rows
    sw t0, 4(sp) #m0 cols
    sw t0, 8(sp) #m1 rows
    sw t0, 12(sp) #m1 cols
    sw t0, 16(sp) #input rows
    sw t0, 20(sp) #input cols
    mv s7, sp

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    lw a0, 4(s1) #m0_path found at index 1
    mv a1, s7 
    addi a2, s7, 4
    jal read_matrix
    mv s3, a0 #store pointer of m0 matrix in memory to s3
    lw t0, 0(s7)
    lw t1, 4(s7)

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    addi sp, sp, -20
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)

    # Load pretrained m1
    lw a0, 8(s1) #m1_path found at index 2
    addi a1, s7, 8
    addi a2, s7, 12
    jal read_matrix
    mv s4, a0 #store pointer of m1 matrix in memory to s4

    lw t2, 8(s7)
    lw t3, 12(s7)

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    addi sp, sp, 20

    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    # Load input matrix
    lw a0, 12(s1) #input_path found at index 3
    addi a1, s7, 16
    addi a2, s7, 20
    jal read_matrix
    mv s5, a0 #store pointer of input matrix in memory to s5

    lw t4, 16(s7)
    lw t5, 20(s7)
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    addi sp, sp, 28

    j run_layers


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
run_layers:    
    #malloc space for s8 matrix pointer
    # lw t0, 0(s7)
    # lw t1, 20(s7)
    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    sw t4, 28(sp)
    sw t5, 32(sp)

    mul t6, t0, t5
    slli t6, t6, 2
    mv a0, t6
    jal malloc
    mv s8, a0
    beq s8, x0, error0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    lw t4, 28(sp)
    lw t5, 32(sp)
    addi sp, sp, 36

    #1. matmul of m0 and input
    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    sw t4, 28(sp)
    sw t5, 32(sp)

    mv a0, s3 #m0-->a0
    # lw a1, 0(s7) #row and col vals of m0
    # lw a2, 4(s7)
    mv a1, t0
    mv a2, t1
    mv a3, s5 #input -->a3
    # lw a4, 16(s7) #row and col vals of input
    # lw a5, 20(s7)
    mv a4, t4
    mv a5, t5

    mv a6, s8
    jal matmul  #store matmul results in s8
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    lw t4, 28(sp)
    lw t5, 32(sp)
    addi sp, sp, 36

    #2. relu of above results
    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    sw t4, 28(sp)
    sw t5, 32(sp)
    
    mv a0, s8 #results-->a0
    # lw t0, 0(s7) #row of hidden_layer (aka m0_row)
    # lw t1, 20(s7) #col of hidden_layer (aka input_col)
    mul a1, t0, t5 #row*col of hidden_layer
    jal relu

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    lw t4, 28(sp)
    lw t5, 32(sp)
    addi sp, sp, 36

    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    sw t4, 28(sp)
    sw t5, 32(sp)

    #malloc space for s0 matrix pointer
    # lw t0, 8(s7)
    # lw t1, 20(s7)
    mul t6, t2, t5
    slli t6, t6, 2
    mv a0, t6
    jal malloc
    mv s0, a0
    beq s0, x0, error0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    lw t4, 28(sp)
    lw t5, 32(sp)
    addi sp, sp, 36

    #3. matmul of m1 and above results
    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    sw t4, 28(sp)
    sw t5, 32(sp)
        
    mv a0, s4 #m1-->a0
    # lw a1, 8(s7) #row of m1
    # lw a2, 12(s7) #col of m1
    mv a1, t2
    mv a2, t3
    mv a3, s8 #results-->a3
    # lw a4, 0(s7) #row of hidden_layer (aka m0_row)
    # lw a5, 20(s7) #col of hidden_layer (aka input_col)
    mv a4, t0
    mv a5, t5
    mv a6, s0 #scores into s0
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    lw t4, 28(sp)
    lw t5, 32(sp)
    addi sp, sp, 36
    
    j write_output

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
write_output:
    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp) 
    sw t4, 28(sp)
    sw t5, 32(sp)
    
    lw a0, 16(s1) #output_path found at index 4
    mv a1, s0 #scores matrix-->a1
    # lw a2, 8(s7) #row of source (aka m1_row)
    # lw a3, 20(s7) #col of source (aka input_col)
    mv a2, t2
    mv a3, t5
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp) 
    lw t4, 28(sp)
    lw t5, 32(sp)
    addi sp, sp, 36
    j classification

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
classification:
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s0 #scores-->a0
    lw t0, 8(s7) #row
    lw t1, 20(s7) #col
    mul a1, t0, t1
    jal argmax
    mv s9, a0 #store argmax index
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    bne s2, x0, end
    j printclassify


printclassify:
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    # Print classification
    mv a1, s9
    jal print_int
    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    j end
    
end:
    mv a0, s9 #classification to a0 return
    #free mallocs from read_matrix
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s3
    jal free

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s4
    jal free

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s5
    jal free

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s0
    jal free

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s8
    jal free

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # addi sp, sp, -12
    # sw a0, 0(sp)
    # sw a1, 4(sp)
    # sw a2, 8(sp)

    # jal print_num_alloc_blocks

    # lw a0, 0(sp)
    # lw a1, 4(sp)
    # lw a2, 8(sp)
    # addi sp, sp, 12

    addi sp, sp, 24 # restore stack space for row and col pointers
    # addi sp, sp, 8 #restore stack space for s8 and s7

    lw s0, 0(sp) #stores network calculation progress matrix
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp) #m0_file matrix
    lw s4, 16(sp) #m1_file matrix
    lw s5, 20(sp) #input_file matrix
    lw s6, 24(sp) #output_file
    lw s7, 28(sp) #pointer to rows
    lw s8, 32(sp) #pointer to cols
    lw s9, 36(sp) #holds argmax result
    lw ra, 40(sp)
    addi sp, sp, 44

    ret