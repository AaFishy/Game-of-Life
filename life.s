# board2.s ... Game of Life on a 15x15 grid

	.data

N:	.word 15  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225
    # COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by <<YOU>>, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

## Global Data
        .data
msg1:   .asciiz "# Iterations: "
msg2:   .asciiz "=== After iteration "
msg3:   .asciiz " ==="
hash:   .asciiz "#"
dot:    .asciiz "."
eol:    .asciiz "\n"

## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow


########################################################################
# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $sp
# Uses:		$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2, $t3, $a0, $a1, $v0
# Clobbers:	$t0, $t1, $t2, $t3, $a0, $a1

# Locals:	
#       - 'int maxiters' in $s0
#	- 'int n' in $s1
#	- 'int i' in $s2
#	- 'int j' in $s3
# 	- 'int nn' in $s4

# Structure:
#	main
#	-> [prologue]
#	-> main_seed
#               -> for1
#               -> for2
#               -> for3
#               -> end_for3
#               -> end_for2
#               -> end_for1
#       -> main_post
#	-> [epilogue]

# Code:
        # Setting up stack frame
        sw      $fp, -4($sp)    # Push $fp onto stack
        la      $fp, -4($sp)    # Set up $fp for this function
        sw      $ra, -4($fp)    # Save return address
        sw      $s0, -8($fp)    # Save $s0 as int maxiters
        sw      $s1, -12($fp)   # Save $s1 as int n (first for loop)
        sw      $s2, -16($fp)   # Save $s2 as int i (second for loop)
        sw      $s3, -20($fp)   # Save $s3 as int j (third for loop)
        sw      $s4, -24($fp)   # Save $s4 as int nn (saves return from neighbour)
        sw      $s5, -28($fp)   # Save $s5 as N
        sw      $s6, -32($fp)   # Save $s6 as newBoard[i][j]
        addi    $sp, $sp, -32
        
        # Loading in board
        
        lw      $s5, N
    
        # Main program code
        
	la      $a0, msg1
	li      $v0, 4
	syscall         # printf("# Iterations: ");
	
	li      $v0, 5
	syscall         # scanf("%d", into $v0);
	
	move    $s0, $v0        # Stores scan into maxiters
	
	li      $s1, 1  # Sets n = 1
	
for1:   # Uses n as iterator; n <= maxiters
        bgt     $s1, $s0, end_for1      # Ends for1 if n > maxiters
        li      $s2, 0  # Sets i = 0
        
for2:   # Uses i as iterator; i < N (N from board1.s)
        bge     $s2, $s5, end_for2      # Ends for2 if i >= N
        li      $s3, 0  # Sets j = 0
        
for3:   # Uses j as iterator: j < N
        bge     $s3, $s5, end_for3      # Ends for3 if j >= N

# Sets i and j to be arguments passed to neighbours function
        move    $a0, $s2        # $a0 is i
        move    $a1, $s3        # $a1 is j
        
        jal     neighbours  # Jump to the neighbours function and links back
        nop     #[BRANCH DELAY]
        
        move    $s4, $v0        # nn = $v0 which has return value from neighbours
        
        la      $t3, board
        la      $t4, newBoard

        mul     $t0, $s2, $s5   # $t0 = i * N
        add     $t1, $t0, $s3   # $t1 = i * N + j
        add     $t2, $t1, $t3   # $t2 = offset on board
        lb      $t0, ($t2)      # $t0 = value of board[i][j]
        
        lb      $s6, ($t2)      # $s6 = value of newBoard[i][j]
        
        move    $a0, $t0        # $a0 = board[i][j]
        move    $a1, $s4        # $a1 = nn
        
        jal     decideCell
        nop     #[BRANCH DELAY]
        
        move    $s6, $v0
        add     $t3, $t1, $t4   # $t3 = offset on newBoard
        sb      $s6, ($t3)      # newboard[i][j] = return value from decideCell
        
        addi    $s3, $s3, 1     # Iterating for3
        j       for3
        
        
end_for3:
        addi    $s2, $s2, 1     # Iterating for2
        j       for2

end_for2:
        
        # printf ("=== After iteration %d ===\n", n);
        
        la      $a0, msg2
        li      $v0, 4
        syscall         # Printf("=== After iteration ")
        
        move    $a0, $s1
        li      $v0, 1
        syscall         # Printf("%d", n)
        
        la      $a0, msg3
        li      $v0, 4
        syscall         # Print f("===")
        
        la      $a0, eol
        li      $v0, 4
        syscall
        
        
        jal     copyBackAndShow
        
        addi    $s1,$s1, 1  # Iterating for3
        
        j       for1

end_for1:

main__post:
        
# Cleaning up stack frame
        lw      $s6, -32($fp)
        lw      $s5, -28($fp)
        lw      $s4, -24($fp)
        lw      $s3, -20($fp)
        lw      $s2, -16($fp)
        lw      $s1, -12($fp)
        lw      $s0, -8($fp)
        lw      $ra, -4($fp)
        la      $sp, 4($fp)
        lw      $fp, ($fp)
	jr	$ra

########################################################################
# .TEXT <decideCell>

decideCell:

# Frame:	$fp, $ra, $s0, $sp
# Uses:		$s0, $a0, $a1, $v0
# Clobbers:	$a0, $a1

# Locals:	
#       - 'char ret' in $s0

# Structure:
#	decideCell
#	-> [prologue]
#	-> dc_seed
#               -> dc_if_1
#                       -> dc_if_2
#                       -> dc_else_if_2
#                       -> dc_else_2
#               -> dc_else_if_1
#               -> dc_else_1
#               -> dc_end_if
#       -> dc_post
#	-> [epilogue]

# Setting up stack frame
        sw      $fp, -4($sp)    # Push $fp onto stack
        la      $fp, -4($sp)    # Set up $fp for this function
        sw      $ra, -4($fp)    # Save return address
        sw      $s0, -8($fp)    # Save $s0 as char ret
        add     $sp, $sp, -8
        
dc_if_1:
        bne     $a0, 1, dc_else_if_1    # if (old == 1)
        
dc_if_2:
        bge     $a1, 2, dc_else_if_2_1    # if (nn < 2)
        li      $s0, 0                  # ret = 0
        j       dc_end_if
        
dc_else_if_2_1:
        # if (nn == 2 || nn == 3)
        bne     $a1, 2, dc_else_if_2_2
        li      $s0, 1                  # ret = 1
        j       dc_end_if
        
dc_else_if_2_2:
        bne     $a1, 3, dc_else_2
        li      $s0, 1                  # ret = 1
        j       dc_end_if
        
dc_else_2:
        li      $s0, 0                  # ret = 0
        j       dc_end_if
        
dc_else_if_1:
        bne     $a1, 3, dc_else_1       # if (nn == 3)
        li      $s0, 1                  # ret = 1
        j       dc_end_if
        
dc_else_1:
        li      $s0, 0                  # ret = 0

dc_end_if:
        move    $v0, $s0                # return ret
        
# Cleaning up stack frame
        lw      $s0, -8($fp)
        lw      $ra, -4($fp)
        la      $sp, 4($fp)
        lw      $fp, ($fp)
	jr	$ra

########################################################################
# .TEXT <neighbours>

neighbours:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $sp
# Uses:		$s0, $s1, $s2, $s3, $s4, $t0, $t1, $t2, $t3, $t4, $t5, $a0, $a1, $v0
# Clobbers:	$t0, $t1, $t2, $t3, $t4, $t5, $a0, $a1

# Locals:	
#       - 'int nn' in $s0
#	- 'int x' in $s1
#	- 'int y' in $s2

# Structure:
#	neighbours
#	-> [prologue]
#	-> nb_seed
#               -> nb_for1
#               -> nb_for2
#                       -> nb_if_third_1
#                       -> nb_if_third_2
#                       -> nb_last_if
#               -> nb_f2_iterate
#               -> nb_end_for2
#               -> nb_end_for1
#       -> nb_post
#	-> [epilogue]

# Setting up stack frame
        sw      $fp, -4($sp)    # Push $fp onto stack
        la      $fp, -4($sp)    # Set up $fp for this function
        sw      $ra, -4($fp)    # Save return address
        sw      $s0, -8($fp)    # Save $s0 as int nn
        sw      $s1, -12($fp)   # Save $s1 as int x
        sw      $s2, -16($fp)   # Save $s2 as int y
        sw      $s3, -20($fp)   # Save $s3 as N
        sw      $s4, -24($fp)   # Save $s4 as board
        addi    $sp, $sp, -24
        
        li      $s0, 0          # int nn = 0
        li      $s1, -1         # int x = -1
        
        lw      $s3, N          # Save $s3 as N
                
nb_for1:
        bgt     $s1, 1, nb_end_for1     # ends for1 if x > 1
        li      $s2, -1         # int y = -1
        
nb_for2:
        bgt     $s2, 1, nb_end_for2     # ends for2 if y > 1
        add     $t0, $a0, $s1           # $t0 = i + x
        add     $t1, $a1, $s2           # $t1 = j + y
        sub     $t2, $s3, 1             # $t2 = N - 1
        
        blt     $t0, 0, nb_f2_iterate            # i + x < 0) continue
        bgt     $t0, $t2, nb_f2_iterate          # i + x > N - 1) continue
        
        blt     $t1, 0, nb_f2_iterate            # j + y < 0) continue
        bgt     $t1, $t2, nb_f2_iterate          # j + y > N - 1) continue
        
# if (x==0 && y==0) continue
nb_if_third_1:
        beq     $s1, 0, nb_if_third_2
        j       nb_last_if
        
nb_if_third_2:
        beq     $s2, 0, nb_f2_iterate
        
nb_last_if:
        # Finding board[i+x][j+y]
        la      $s4, board

        mul     $t3, $t0, $s3   # $t3 = (i+x) * N
        add     $t4, $t3, $t1   # $t4 = (i+x) * N + (j+y)
        add     $s4, $t4, $s4   # $s4 = offset on board
        
        lb      $t5, ($s4)      # $t6 = value of board[i+x][j+y]
        
        # if(board[i+x][j+y] ==1) nn++;
        bne     $t5, 1, nb_f2_iterate
        addi    $s0, $s0, 1
        
nb_f2_iterate:
        addi    $s2, $s2, 1     # y++
        j       nb_for2

nb_end_for2:
        addi    $s1, $s1, 1     # x++
        j       nb_for1        
        
nb_end_for1:
        move    $v0, $s0        # return nn

#Cleaning Stack Frame
        lw      $s4, -24($fp)
        lw      $s3, -20($fp)
        lw      $s2, -16($fp)
        lw      $s1, -12($fp)
        lw      $s0, -8($fp)
        lw      $ra, -4($fp)
        la      $sp, 4($fp)
        lw      $fp, ($fp)
	jr	$ra

########################################################################
# .TEXT <main>

copyBackAndShow:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $sp
# Uses:		$s0, $s1, $s2, $s3, $s4, $t0, $t1, $t2, $t3, $a0, $v0
# Clobbers:	$t0, $t1, $t2, $t3, $a0

# Locals:	
#	- 'int i' in $s0
#	- 'int j' in $s1

# Structure:
#	copyBackAndShow
#	-> [prologue]
#	-> cbs_seed
#               -> cbs_for1
#               -> cbs_for2
#                       -> cbs_if
#                       -> cbs_else
#                       -> cbs_end_if
#               -> cbs_end_for2
#               -> cbs_end_for1
#       -> cbs_post
#	-> [epilogue]

# Setting up stack frame
        sw      $fp, -4($sp)    # Push $fp onto stack
        la      $fp, -4($sp)    # Set up $fp for this function
        sw      $ra, -4($fp)    # Save return address
        sw      $s0, -8($fp)    # Save $s0 as int i
        sw      $s1, -12($fp)   # Save $s1 as int j
        sw      $s2, -16($fp)   # Save $s2 as N
        sw      $s3, -20($fp)   # Save $s3 as board
        sw      $s4, -24($fp)   # Save $s4 as newBoard
        
        addi    $sp, $sp, -24
                
        lw      $s2, N          # Save $s2 as N
        
        li      $s0, 0          # int i = 0
        
cbs_for1:
        bge     $s0, $s2, cbs_end_for1  # Ends for1 if i >= N
        li      $s1, 0          # int j = 0
        
cbs_for2:
        bge     $s1, $s2, cbs_end_for2  # Ends for2 if j >= N
        
        la      $s3, board
        la      $s4, newBoard
        
        # board location
        mul     $t0, $s0, $s2   # $t0 = i * N
        add     $t1, $t0, $s1   # $t1 = i * N + j
        add     $s3, $t1, $s3   # $s3 = offset on board
        
        # newBoard location
        add     $s4, $t1, $s4   # $s4 = offset on newBoard
        lb      $t3, ($s4)      # $t3 = value of newBoard[i][j]
        
        # board[i][j] = newBoard[i][j]
        sb      $t3, ($s3)
        
        lb      $t0, ($s3)      # $t0 = value of board[i][j]
        
cbs_if:
        bne     $t0, 0, cbs_else        # jumps to else if board[i][j] != 0
        lb      $a0, dot
        li      $v0, 11
        syscall         # putchar('.')
        
        j       cbs_end_if
        
cbs_else:
        lb      $a0, hash
        li      $v0, 11
        syscall
        
cbs_end_if:
        add     $s1, $s1, 1     # j++
        j       cbs_for2
        
cbs_end_for2:
        add     $s0, $s0, 1     # i++
        
        la      $a0, eol
        li      $v0, 4
        syscall         # putchar('\n')
        
        j       cbs_for1
        
cbs_end_for1:
        
cbs_post:
#Cleaning Stack Frame
        lw      $s4, -24($fp)
        lw      $s3, -20($fp)
        lw      $s2, -16($fp)
        lw      $s1, -12($fp)
        lw      $s0, -8($fp)
        lw      $ra, -4($fp)
        la      $sp, 4($fp)
        lw      $fp, ($fp)
	jr	$ra