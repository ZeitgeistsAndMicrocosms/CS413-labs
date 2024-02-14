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
@
@ Step 1 - Welcome Prompt
@*******************
prompt:
@*******************

@ Welcome the user, then bring them to the main menu.
   mov r2, #0
   ldr r0, =welcomePrompt
   bl printf

@********************
mainMenu:
@********************
   ldr r0, =menuPrompt
   bl printf
   ldr r0, =menuSelection
   bl printf

@*********   
inputClear:
@**********
   ldr r0, =strInputPattern @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

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
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 so that
                            @ it can be printed. 
    

@ Step 2 - Calling the designated functiond

@ Step 2a - Addition Implementation
@*******************
addNumbers:
@*******************
@ Asks the user for a first integer to act as an addend.
   ldr r2, =addFirstPrompt
   bl getSelection
   mv r3, r1
@ Asks the user for a second integer to act as an adder.
   ldr r2, =addSecondPrompt
   bl getSelection
   mv r4, r1

   adds r4, r3, r4
   mv r1, r4
   bl printf

@ Step 2b - Subtraction Implementation
@********************
subNumbers:
@********************
@ Asks the user for the integer to be subtracted from.
   ldr r2, =subFirstPrompt
   bl getSelection
   mv r3, r1
   b inputClear
@ Asks the user for the integer to subtract by.
   ldr r2, =subSecondPrompt
   bl getSelection
   mv r4, r1
   b inputClear

   subs r4, r3, r4
   mv r1, r4
   bl printf

@ Step 2c - Multiplication Implementation 
@********************
mulNumbers:
@********************
@ Asks the user for the integer to serve as the multiplicand.
   ldr r2, =mulFirstPrompt
   bl getSelection
   mv r3, r1
   b inputClear
@ Asks the user for the integer to serve as the multiplier.
   ldr r2, =mulSecondPrompt
   bl getSelection
   mv r4, r1
   b inputClear

   muls r4, r3, r4
   mv r1, r4
   bl printf

@ Step 2d - Division Implementation
@********************
divNumbersInit:
@********************
@ Asks the user for the integer to serve as the dividend.
   ldr r2, =divFirstPrompt
   bl getSelection
   mv r3, r1
   b inputClear
@ Asks the user for the integer to serve as the divisor.
   ldr r2, =divSecondPrompt
   bl getSelection
   mv r4, r1
   b inputClear
@ Checks to see if the integer given for the divisor was 0. If so, branch to divByZero
@ Else, checks to see if the integer given for the divisor was negative.  If so, continue.
@ Else, branch forward to divNumbers.
    mov r6, #1

@********************
divNumbers:
*********************
@ Actual divison implementation.  

@***********
readerror:
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

   b prompt

rangePrompt:
ldr r0, =outOfRange
bl printf
b inputPrompting

@*******************
divByZero:
@*******************
@ Presents user with error message before branching back to mainMenu.

@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 

.data

@ Declare the strings and data needed


.balign 4
outOfRange: .asciz "Please enter a valid number!  \n\n"

.balign 4
welcomePrompt: .asciz "Hello there! This program will act as a four-function calculator until exited by the user. (That's you!) \n\n"

.balign 4
menuPrompt: .asciz "Select a mathematical function below by entering its associated integer in the list below. \n"

.balign 4
menuSelection: .asciz "1 - Addition \n2 - Subtraction \n3 - Multiplication \n 4 - Division \n\n"

.balign 4
strOutputNum: .asciz "The value entered is: %d \n\n"

.balign 4
addFirstPrompt: .asciz "Please enter the first you want added:  \n\n"

.balign 4
addSecondPrompt: .asciz "Please enter the second value you want added:  \n\n"

.balign 4
subFirstPrompt: .asciz "Please enter the first value you want subtracted: \n\n"

.balign 4
subSecondPrompt: .asciz "Please enter the second value you want subtracted: \n\n"

.balign 4
mulFirstPrompt: .asciz "Please enter the first value you want multiplied: \n\n"

.balign 4
mulSecondPrompt: .asciz "Please enter the second value you want multiplied: \n\n"

.balign 4
divFirstPrompt: .asciz "Please enter the first value you want divided: \n\n"

.balign 4
divSecondPrompt: .asciz "Please enter the second value you want divided: \n\n"

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
