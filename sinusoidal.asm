;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
;Author information
;  Author name: Arun Sangar
;  Author email: arun.sangar@csu.fullerton.edu or asangar94@gmail.com
;  Author location: CSUF
;Course information
;  Course number: CPSC240
;  Assignment number: 5
;  Due date: 2015-Apr-07
;Project information
;  Project title: Sinusoidal Calculator
;  Purpose: Find the sine value of a given radian using the taylor series for sin(x)
;  Status: No known errors
;  Project files: sinusoidal.asm, nextterm.cpp, sindriver.cpp, utilities.inc
;Module information
;  This module's call name: sinusoidal
;  Language: X86-64
;  Syntax: Intel
;  Date last modified: 2015-Apr-06
;  Purpose: This module is the main assembly program that will call subprograms to calculate sin(x) with a given accuracy.
;  File name: sinusoidal.asm
;  Status: Possibly something wrong with computation, (lots of zeroes for last terms) I know it's suppose to be a very small number, so I'm unsure of the validity
;          Last three test cases gave weird outputs
;  Future enhancements: None planned
;Translator information
;  Linux: nasm -f elf64 -l sinusoidal.lis -o sinusoidal.o sinusoidal.asm
;References and credits
;  Holliday, fp-io.asm, inputintegers.asm
;Format information
;  Page width: 172 columns
;  Begin comments: 61
;  Optimal print specification: Landscape, 7 points or smaller, monospace, 8Â½x11 paper
;
;Preconditions:
;	1.Pointer to reserved storage for the nanoseconds is stored in rdi
;
;Postconditions:
;	1.Reserved storage for nanosecods will be manipulated to the correct value
;       2.Last term of the taylor series will be stored in xmm0 (return value)
;
;===== Begin code area =====================================================================================================================================================

%include "debug.inc"                                        ;Link debugger
%include "utilities.inc"                                    ;Link backup/restore/timer

extern printf                                               ;External C function for writing to standard output device
extern scanf                                                ;External C function for reading from the standard input device

extern nextterm                                             ;External C++ function for computing the next term of the sin(x) taylor series (recurrence relation)

global sinusoidal                                           ;This makes sinusoidal callable by functions outside of this file.

segment .data                                               ;Place initialized data here

;===== Declare some messages ===============================================================================================================================================

welcomemessage db "This program will compute sin(x) with incredible accuracy!.", 10, 0   

ticsmessage db "The CPU time is now %ld tics.", 10, 0

radianmessage db "Please enter a radian value for x and sin(x) with be computed accordingly: ", 0
termmessage   db "Enter the number of terms to be computed in the taylor series computation: ", 0

donemessage    db "The value for sin(x) has been computed.", 10
               db "The clock before the computation was %ld tics.", 10
               db "The clock after the computation was %ld tics.", 10, 0

computationmsg db "The computation required %ld tics, which equals %ld nanoseconds = %1.10lf seconds.", 10, 0
sinmsg         db "Sin(x) = %1.18lf", 10, 0
lasttermmsg    db "The last term of the taylor series was %1.18lf", 10, 0

goodbye db "The main assembly program will now return the last term of the taylor series to the driver. Goodbye!", 10, 0

;===== Declare formats =====================================================================================================================================================

stringformat db "%s", 0                                     ;general string format              

integerformat db "%ld", 0                                   ;general 8-byte integer format

eight_byte_format db "%lf", 0                               ;general 8-byte float format

;===== Declare unintialized data ===========================================================================================================================================

segment .bss                                                ;Place un-initialized data here.

align 16                                                    ;Insure a 16-byte boundary for printf.

;===== Begin executable instructions here ==================================================================================================================================

segment .text                                               ;Place executable instructions in this segment.

sinusoidal:                                                 ;Entry point.  Execution begins here.

;===========================================================================================================================================================================
;===== Begin Backup Section ================================================================================================================================================
;===========================================================================================================================================================================

backupgprs                                                  ;Macro - Backup all GPR registers

backupstatecomp 7                                           ;Macro - Backup AVX/SSE/FPU registers

;===========================================================================================================================================================================
;===== End Backup Section ==================================================================================================================================================
;===========================================================================================================================================================================

;===========================================================================================================================================================================
;===== Begin the application ===============================================================================================================================================
;===========================================================================================================================================================================

;===== Display welcome message =============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, welcomemessage                              ;"This program will compute sin(x) with incredible accuracy!."
call       printf                                           ;Call a library function to make the output

;===== Get CPU tics and save it into a single register =====================================================================================================================

getcpuclock                                                 ;Macro - get current CPU clock tics
mov       rsi, rdx                                          ;Move the tics into rsi for printf to display the current amount of tics

;===== Display the current tics read of the CPU ============================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, ticsmessage                                 ;"The CPU time is now %ld tics."
call       printf                                           ;Call a library function to make the output

;===== Display radian message ==============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, radianmessage                               ;"Please enter a radian value for x and sin(x) with be computed accordingly: "
call       printf                                           ;Call a library function to make the output

;===== Get the radian value from user input ================================================================================================================================

push qword 0                                                ;Reserve 8 bytes of storage for the incoming number
mov qword  rax, 0                                           ;SSE is not involved in this scanf operation
mov        rdi, eight_byte_format                           ;"%lf"
mov        rsi, rsp                                         ;Give scanf a point to the reserved storage
call       scanf                                            ;Call a library function to do the input work
movsd      xmm15, [rsp]                                     ;Copy radian number (xmm15) this will be used to save value of sin(x) (total of taylor series)
movsd      xmm14, [rsp]                                     ;Copy radian number (xmm14) this will hold the last term of the series (the radian itself is the first term)
movsd      xmm13, [rsp]                                     ;Copy radian number (xmm13) this will be used to hold the radian value (to compute the next term)
pop        rax                                              ;Make free the storage that was used by scanf

;===== Display number of terms message =====================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, termmessage                                 ;"Enter the number of terms to be computed in the taylor series computation: "
call       printf                                           ;Call a library function to make the output

;===== Get desired number of terms from user input =========================================================================================================================

push qword 0                                                ;Reserve 8 bytes of storage for the incoming number
mov qword  rax, 0                                           ;SSE is not involved in this scanf operation
mov        rdi, integerformat                               ;"%ld"
mov        rsi, rsp                                         ;Give scanf a point to the reserved storage
call       scanf                                            ;Call a library function to do the input work
mov        r15, [rsp]                                       ;Copy the inputted "number of terms" number to a safe gpr register (r15)
pop        rax                                              ;Make free the storage that was used by scanf

;===== Get CPU tics and save it into a single register =====================================================================================================================

getcpuclock                                                 ;Macro - get current CPU clock tics
mov       r13, rdx                                          ;Move the tics into r13 to be printed by printf after the computation

;===== Start the taylor series =============================================================================================================================================

mov qword  rbx, 0                                           ;Zero out the loop counter
movsd      xmm1, xmm14                                      ;Move the last term into xmm1 as the second parameter for the first nextterm call
starttaylorloop:                                            ;Loop entry point
 
cmp        rbx, r15                                         ;Comparision, if the loop counter exceeds or is equal to the desired number of terms
jge        endtaylorloop                                    ;Jump to termination point

;===== Perform computation of the next term ================================================================================================================================

movsd      xmm0, xmm13                                      ;Move the stored radian value to xmm0 as the first parameter of nextterm (double)
mov        rdi, rbx                                         ;Move the loop counter (iteration number of the series) into rdi as the third parameter (integer)
call       nextterm                                         ;Call external C++ function to compute the next term of the taylor series
addsd      xmm15, xmm0                                      ;Add the term to the total of the taylor series
movsd      xmm1, xmm0                                       ;Move the last term into xmm1 to be used in the next iteration of nextterm

;===== Increment loop counter and jump to top ==============================================================================================================================

inc        rbx                                              ;Incremement loop counter
jmp        starttaylorloop                                  ;Jump to the start of the loop to terminate/compute next term
endtaylorloop:                                              ;Loop termination point
movsd      xmm14, xmm1                                      ;Move the last term of the series computation to a safe SSE register

;===== Get CPU tics and save it into a single register =====================================================================================================================

getcpuclock                                                 ;Macro - get current CPU clock tics
mov       r14, rdx                                          ;Move the tics into r14 to be printed by printf 

;===== Display completed computation message ===============================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, donemessage                                 ;"The value for sin(x) has been computed."
mov        rsi, r13                                         ;"The clock before the computation was %ld tics."
mov        rdx, r14                                         ;"The clock after the computation was %ld tics."
call       printf                                           ;Call a library function to make the output

;===== Get number of clock tics taken for computation ======================================================================================================================

mov        rsi, r14                                         ;Store the number of clock tics after the computation in rsi (computation tics = first parameter for printf)
sub        rsi, r13                                         ;Subtract the number of clock tics before the computation from the number of clock tics after the computation

;===== Setup for division ==================================================================================================================================================

mov        rax, rsi                                         ;Move the number of clocks tics for the computation into rax to be divided by the GHz of the CPU
imul       rax, 10                                          ;Multiply the clock tics by 10 so we can use integer division with the GHz also multiplied by 10
mov        r12, 34                                          ;Move 34 into r12 to divide the number of clock tics by (34 = 3.4GHz)

;===== Compute nanoseconds =================================================================================================================================================

cqo                                                         ;Extend rax to rdx:rax
div        r12                                              ;Divide number of clock tics by CPU speed
mov        rdx, rax                                         ;Move the quotient (nanoseconds) into rdx (second parameter for printf)
mov        r12, [rsp+72]                                    ;Get the pointer value to store the number of nanoseconds (passed back to caller)
mov        [r12], rdx                                       ;Store the number of nanoseconds into the reserved storage

;===== Compute seconds =====================================================================================================================================================

push       rdx                                              ;Push the nanoseconds onto the stack to be used to find the number of seconds for the computation
vcvtsi2sd  xmm0, [rsp]                                      ;Convert the integer value to a floating-point value from memory to SSE (This instruction is very useful!)
mov        r12, 0x41cdcd6500000000                          ;Store 1 billion in floating-point format into r12 (used to divide nanoseconds to get seconds)
mov        [rsp], r12                                       ;Move the float onto the stack
movsd      xmm2, [rsp]                                      ;Move the float into SSE to divide the nanoseconds 
divsd      xmm0, xmm2                                       ;Divide the nanoseconds by 1 billion (third parameter for printf)
pop rax                                                     ;Clear the stack

;===== Display computation timing ==========================================================================================================================================

mov qword  rax, 1                                           ;One floating point from SSE will be printed
mov        rdi, computationmsg                              ;"The computation required %ld tics, which equals %ld nanoseconds = %1.10lf seconds."  
call       printf                                           ;Call a library function to make the output

;===== Display sin(x) value ================================================================================================================================================

movsd      xmm0, xmm15                                      ;Move the total value of the taylor series (value of sin(x)) to xmm0 for printf
mov qword  rax, 1                                           ;One floating point from SSE will be printed
mov        rdi, sinmsg                                      ;"Sin(x) = %1.18lf"
call       printf                                           ;Call a library function to make the output

;===== Display last term of series =========================================================================================================================================

movsd      xmm0, xmm14                                      ;Move the last term of the taylor series to xmm0 for printf
mov qword  rax, 1                                           ;One floating point from SSE will be printed
mov        rdi, lasttermmsg                                 ;"The last term of the taylor series was %1.18lf"
call       printf                                           ;Call a library function to make the output

;===== Conclusion message ==================================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, goodbye                                     ;"The main assembly program will now return the last term of the taylor series to the driver. Goodbye!"
call       printf                                           ;Call a library function to do the hard work.

;===== Save return value to bypass the backup ==============================================================================================================================

push qword 0                                                ;Push a qword onto the stack to save the last term during the AVX/SSE backup
movsd      [rsp], xmm14                                     ;Move the last term to the reserved storage

;===========================================================================================================================================================================
;===== End the Application =================================================================================================================================================
;===========================================================================================================================================================================

;===========================================================================================================================================================================
;===== Begin Restore Section ===============================================================================================================================================
;===========================================================================================================================================================================

restorestatecomp 7                                          ;Macro - Restore AVX/SSE/FPU registers

movsd      xmm0, [rsp]                                      ;Move the last term into xmm0 to be pass back to the caller as the return value
pop        rax                                              ;Clear the stack

restoregprs                                                 ;Macro - Restore all GPR registers

;===========================================================================================================================================================================
;===== End Restore Section =================================================================================================================================================
;===========================================================================================================================================================================

ret                                                         ;Pop a qword from the stack into rip, and continue executing..
;========== End of program arrayprocess.asm ===============================================================================================================================
;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
