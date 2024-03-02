@ Filename: sanders2.s
@ Name: Kaleb Sanders
@ Email: kcs0020@uah.edu
@ Class: CS413-01 SP24
@ 
@ History:
@  Date           Purpose of Change
@  ----           -----------------
@  27-Feb-2024    Origin of Program
@  2-Mar-2024     2nd Draft Published
@
@ Use these commands to assemble, link, run, and debug this program:
@   as -o sanders3.o sanders3.s
@   gcc -o sanders3 sanders3.o
@   ./sanders3 ;echo $?
@   gdb --args ./sanders3

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ***********************************************************************

.equ READERROR

.global main

main:
@ Main code:

ldr r11, #48 @ Initial Water Condition
ldr r10, #0 @ Initial large cup count condition
ldr r9, #0 @ Initial medium cup count condition
ldr r8, #0 @ Initial small cup count condition

@ Step 1 - Welcome Prompt
@********
userWelcome:
@********
@ Print user prompt
ldr r0, =welcomePrompt
bl printf

@ Step 2 - K-cup Size Prompt
@********
userSizeSelection:
@********
@ Print user prompt and check for user input character to then branch (S, M, L, B, W, T)
ldr r0, =userSelection
bl printf
bl getSelection
cmp r1, #'S'
beq smallCheck
cmp r1, #'s'
beq smallCheck
cmp r1, #'M'
beq mediumCheck
cmp r1, #'m'
beq mediumCheck
cmp r1, #'L'
beq largeCheck
cmp r1, #'l'
beq largeCheck
cmp r1, #'B'
b brew1
cmp r1, #'b'
b brew1
cmp r1, #'W'
b water
cmp r1, #'w'
b water
cmp r1, #'T'
b terminate
cmp r1, #'t'
b terminate

@ Step 3 - User Water Status Delivery
@********
userStatusMessage:
@********
@ Print user Prompt and then check for B, W, or T
ldr r0, =readyToBrew
bl printf
bl scanf
cmp r1, #'B'
b brew1
cmp r1, #'b'
b brew1
cmp r1, #'W'
b water
cmp r1, #'w'
b water
cmp r1, #'T'
b terminate
cmp r1, #'t'
b inputError

@ ----------------
@ Utility Functions

@******
inputError:
@******
ldr r0, =inputErrorMsg
bl printf

@ Small Check
@******
smallCheck:
@******
@Checks to see if water level in tank is too low
ldr r4, #6
cmp r4, r11
blt ...
bge userStatusMessage

@ Medium Check
@******
mediumCheck:
@******
@Checks to see if water level in tank is too low
ldr r4, #8
cmp r4, r11
blt waterSupplyError
bge userStatusMessage

@ Large Check
@******
largeCheck:
@******
@Checks to see if water level in tank is too low
ldr r4, #10
cmp r4, r11
blt waterSupplyError
bge userStatusMessage

@ Water Supply Error
@******
waterSupplyError:
@******
@ Lets the user know there is an error with the water supply
ldr r0, =errorNotEnough
b userSizeSelection

@******
brewSmall:
@******
@ Subtracts amount of cup size of water 
@ from total water size and adds cup size count
sub r11, r11, #6
add r8, r8, #1
b welcomePrompt

@******
brewMedium:
@******
@ Subtracts amount of cup size of water 
@ from total water size and adds cup size count
sub r11, r11, #8
add r9, r9, #1
b welcomePrompt

@******
brewLarge:
@******
@ Subtracts amount of cup size of water 
@ from total water size and adds cup size count
sub r11, r11, #10
add r10, r10, #1
b welcomePrompt

@ ----------------
@ Persistent Functions

@ Brew Func (B)
@******
brew1:
@******
@ Branch based on brew type
cmp r4, #6
beq brewSmall
cmp r4, #8
beq brewMedium
cmp r4, #19
beq brewLarge

@ Secret Func (W)
@******
water:
@******
@ Presents the water remaining in the tank and how many cups have been made so far
ldr r0, =waterRaminaing
bl printf
ldr r0, =cupsSoFar
bl printf

@ Exit Func (T)
@******
terminate:
@******
@ equivalent to myexit
   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call 

@ ----------------
@ IO Functions

@*******************
getSelection: @ REDO TO READ CHARACTERS
@*******************
@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be intInput.
   push {lr}
   ldr r0, =chrInputPattern @ Setup to read in one number.                              //I think this may need to be updated. I do not remember whether or not ASM can read in chars as ints.
   ldr r1, =chrInput        @ load r1 with the address of where the                     //This is fine though, we may just need to relabel it as charInput
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readError            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 so that     //Is this necessary? I think that this line may interfere with the returning value of r1.
   
   pop {lr}
   mov pc, lr

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


@ ----------------
@ Data 

.data

.balign 4
welcomePrompt: .asciz "Welcome to the Coffee Maker\n\nInsert K-cup and press B to begin making coffee.\n\nPress T to turn off machine.\n"

.balign 4
userSelection: .asciz "Please select your K-Cup size:\n\n1. Small (6 oz)\n2. Medium (8 oz)\n3. Large (10 oz)\n\nInsert s for small, m for medium, or l for large\n\n"

.balign 4
readyToBrew: .asciz "Ready to Brew\n\nPlease place the K-cup in the tray and press B to brew"

.balign 4
errorNotEnough: .asciz "Error: Please choose a smaller size\n"

.balign 4
waterRefill: .asciz "Please refill the water conatainer\n"

.balign 4
waterRaminaing: .asciz "You have %d oz remaining in the water container\n"

.balign 4
cupsSoFar: .asciz: "You have made %d small cups, %d medium cups, and %d large cups of coffee\n"

.balign 4
inputErrorMsg: .asciz: "The letter you inputted was not a valid option. Please try again.\n\n"

@ Format pattern for scanf call.
.balign 4
chrInputPattern: .asciz "%c"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ Used to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input. 

.balign 4
chrInput: .word 0   @ Location used to store the user input. 
@ Let the assembler know these are the C library functions. 

@ ----------------
@ IO Syscalls

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
