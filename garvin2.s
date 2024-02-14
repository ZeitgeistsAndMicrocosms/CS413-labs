@ Filename: garvin2.s
@ Author:   Will Garvin | wag0014@uah.edu | CS413-01 Spring 2024
@ Purpose:  Create a four-function calculator within ARM Assembly that utilizes
@ the stack to call functions and parameters as well as proper implementations 
@ of functions in the form of subroutine calls.
@ History: 
@    Date       Purpose of change
@    ----       ----------------- 
@   16-Feb-2024  Original Version Published.
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o garvin2.o garvin2.s
@    gcc -o garvin2 garvin2.o
@    .garvin2 ;echo $?
@    gdb --args ./garvin2 

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ***********************************************************************

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

@ Step 1  -  Welcome Prompt
@*******************
initPrompt:
@*******************
@ Welcome the user, then bring them to the main menu.
   mov r2, #0
   ldr r0, =welcomePrompt
   bl printf

@ Step 2  -  User Input for Integers
@*******************
intInputPrompt:
@*******************
   ldr r0, =firstInputPrompt
   bl printf
   b getSelection
   cmp r1, #0
   blt intRangePrompt
   mov r4, r1
   ldr r0, =secondInputPrompt
   bl printf
   b getSelection
   cmp r1, #0
   blt intRangePrompt
   mov r5, r1
   push{r4, r5}

@ Step 3a -  Menu Prompt
@********************
mainMenu:
@********************
   ldr r0, =menuPrompt
   bl printf
   ldr r0, =menuSelection
   bl printf

@ Step 3b - User Menu Selection
@********************
menuSelect:
@********************
@ Instructions under this label get the user's choice for the menu as an integer, 
@ then promptly branch to the respective subroutine based on that input. If the 
@ user did not provide a valid input, let them know and branch to mainMenu.
   b getSelection
   mov r4, r1
   cmp r4, #1
   blt menuRangePrompt
   bleq addNumbers
   cmp r1, #2
   bleq subNumbers
   cmp r1, #3
   bleq mulNumbers
   cmp r4, #4
   bleq divNumbers
   bgt menuRangePrompt



@--- Function Subroutines with Checks ---

@ Addition Implementation
@*******************
addNumbers:
@*******************
   pop{r6, r7}
   add r8, r6, r7
   bvs handleOverflow
   mov r1, r8
   bl printf
   mov pc, ir

@ Subtraction Implementation
@********************
subNumbers:
@********************
   pop{r6, r7}
   sub r8, r6, r7
   mov r1, r8
   bl printf
   mov pc, ir

@ Multiplication Implementation 
@********************
mulNumbers:
@********************
   pop{r6, r7}
   mul r8, r6, r7
   bvs handleOverflow
   mov r1, r8
   bl printf
   mov pc, ir

@ Division Implementation
@*********************
divNumbers:
@*********************


@--- Instruction Calls ---

@*******************
getSelection:
@*******************

@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be intInput. 
   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readError            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 so that

@***********
readError:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 
   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b initPrompt

@**********   
inputClear:
@**********
   ldr r0, =strInputPattern @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

@***********
intRangePrompt:
@***********
   ldr r0, =outOfRange
   bl printf
   b inputPrompting

@***********
menuRangePrompt:
@***********
   ldr r0, =outOfRange
   bl printf
   b inputPrompting

@***********
handleOverflow:
@***********
@ 
   ldr, =overflow
   bl printf
   b intInputPrompt


@*********
divByZero:
@*********
@ Presents user with error message before branching back to mainMenu.

@******
myExit:
@******
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 


.data

@ Declare the strings and data needed
.balign 4
welcomePrompt: .asciz "Hello there! This program will act as a four-function calculator until exited by the user. (That's you!) \n\n"

.balign 4
firstInputPrompt: .asciz "Please enter the first integer to be used in a calculation: \n\n"

.balign 4
secondInputPrompt: .asciz "Now, please enter a second integer: \n\n"

.balign 4
menuPrompt: .asciz "Next, select a mathematical function below by entering its associated integer from the list below. \n"

.balign 4
menuSelection: .asciz "1 - Addition \n2 - Subtraction \n3 - Multiplication \n 4 - Division \n\n"

.balign 4
strOutputNum: .asciz "The value entered is: %d \n\n"

.balign 4
outOfRange: .asciz "Please enter a valid number!  \n\n"

.balign 4
overflow: .asciz "Solution exceeds maximum supported value! (overflow)"

.balign 4 
addAnswer: .asciz "The answer to %d + %d is %d. \n\n"

.balign 4
subAnswer: .asciz "The answer to %d - %d is %d. \n\n"

.balign 4
mulAnswer: .asciz "The answer to %d * %d is %d. \n\n"

.balign 4
divAnswer: .asciz "The answer to %d / %d is %d with a remainder of %d. \n\n"

@ Format pattern for scanf call.
.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input. 

.balign 4
chrInput: .word 0   @ Location used to store the user input. 
@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else.
@
@ Additional notes about scanf and the input patterns:
@    1. If the pattern is %s or %c it is not possible for the user input to generate
@       and error code. Anything that can be typed by the user on the keyboard
@       will be accepted by these two input patterns. 
@    2. If the pattern is %d and the user input 12.123 scanf will accept the 12 as
@       valid input and leave the .123 in the input buffer. 
@    3. If the pattern is "%c" any white space characters are left in the input
@       buffer. In most cases user entered carrage return remains in the input buffer
@       and if you do another scanf with "%c" the carrage return will be returned. 
@       To ignore these "white" characters use " $c" as the input pattern. This will
@       ignore any of these non-printing characters the user may have entered.
@

@ End of code and end of file. Leave a blank line after this.
