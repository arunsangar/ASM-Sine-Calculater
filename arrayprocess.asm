;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
;Author information
;  Author name: Arun Sangar
;  Author email: arun.sangar@csu.fullerton.edu or asangar94@gmail.com
;  Author location: CSUF
;Course information
;  Course number: CPSC240
;  Assignment number: 4
;  Due date: 2015-Mar-12
;Project information
;  Project title: Array Processor
;  Purpose: Given two arrays, append and display the new array to the console
;  Status: No known errors
;  Project files: arrayprocess.asm, arraydriver.cpp, inputarray.asm, sumarray.asm, displayarray.cpp, geolength.cpp, appendarray.cpp
;Module information
;  This module's call name: arrayprocess
;  Language: X86-64
;  Syntax: Intel
;  Date last modified: 2015-Mar-11
;  Purpose: This module is the main assembly program that will call subprograms to calculate/process information.
;  File name: loancalc.asm
;  Status: No known errors
;  Future enhancements: None planned
;Translator information
;  Linux: nasm -f elf64 -l arrayprocess.lis -o arrayprocess.o arrayprocess.asm
;References and credits
;  Holliday, fp-io.asm, inputintegers.asm
;Format information
;  Page width: 172 columns
;  Begin comments: 61
;  Optimal print specification: Landscape, 7 points or smaller, monospace, 8Â½x11 paper
;
;Preconditions
;  1.Pointer to start of array C stored in rdi (minimum 100 quad words)
;  2.Pointer to the size of array C stored in rsi (should be 100+)
;
;Postconditions
;  1.Array C will be filled with elements (maximum of 100 quad words)
;  2.Size of array C will correspond to the size of the inputed arrays A and B (will be 0-100)
;
;===== Begin code area =====================================================================================================================================================

%include "debug.inc"                                        ;Link debugger

extern printf                                               ;External C function for writing to standard output device
extern scanf                                                ;External C function for reading from the standard input device
extern getchar                                              ;External C function for reading a character from the standard input device

extern inputarray                                           ;External ASM function for inputting an array
extern displayarray                                         ;External C++ function for outputting an array
extern appendarray                                          ;External ASM function for combining arrays
extern sumarray                                             ;External ASM function for summing the elemnets of an array
extern geolength                                            ;External C++ function for computing the geometric length of an array

global arrayprocess                                         ;This makes arrayprocess callable by functions outside of this file.

segment .data                                               ;Place initialized data here

;===== Declare some messages ===============================================================================================================================================

welcomemessage db "Welcome to array processing.", 10, 0   

arrayamessage  db "Please enter quadword floats for array A.", 10, 0
arrayadone     db "Thank you, this is array A:", 10, 0
arraybmessage  db "Please enter quadword floats for array B,", 10, 0
arraybdone     db "Thank you, this is array B:", 10, 0

appendmessage  db "Next, A and B were appended to create array C, which is displayed here:", 10, 0

arraysum       db "The sum of each of the 3 arrays has been computed here:", 10
	       db " Sum A =  %3.10lf", 10
               db " Sum B =  %3.10lf", 10
               db " Sum C =  %3.10lf", 10, 0

geometriclen   db "The geometric length of each of the 3 arrays has been computed here:", 10
               db " Geometric length A = %3.10lf", 10
               db " Geometric length B = %3.10lf", 10
               db " Geometric length C = %3.10lf", 10, 0

goodbye db "The main assembly program will now return the appeneded array C to the driver. Goodbye!", 10, 0

;===== Declare formats =====================================================================================================================================================

stringformat db "%s", 0                                     ;general string format              

integerformat db "%ld", 0                                   ;general 8-byte integer format

eight_byte_format db "%lf", 0                               ;general 8-byte float format

;===== Declare unintialized data ===========================================================================================================================================

segment .bss                                                ;Place un-initialized data here.

align 64                                                    ;Insure that the inext data declaration starts on a 64-byte boundar.
backuparea resb 832                                         ;Create an array for backup storage having 832 bytes.

arraya resq 50                                              ;Reserve 50 quad words for array A
arrayb resq 50                                              ;Reserve 50 quad words for array B

;===== Begin executable instructions here ==================================================================================================================================

segment .text                                               ;Place executable instructions in this segment.

arrayprocess:                                               ;Entry point.  Execution begins here.

;===========================================================================================================================================================================
;===== Begin Backup Section ================================================================================================================================================
;===========================================================================================================================================================================

push       rbp                                              ;Save a copy of the stack base pointer
mov        rbp, rsp                                         ;This will preserve the linked list of base pointers.
push       rbx                                              ;Back up rbx
push       rcx                                              ;Back up rcx
push       rdx                                              ;Back up rdx
push       rsi                                              ;Back up rsi
push       rdi                                              ;Back up rdi
push       r8                                               ;Back up r8
push       r9                                               ;Back up r9
push       r10                                              ;Back up r10
push       r11                                              ;Back up r11
push       r12                                              ;Back up r12
push       r13                                              ;Back up r13
push       r14                                              ;Back up r14
push       r15                                              ;Back up r15
pushf                                                       ;Back up rflags

mov        rax, 6                                           ;Move 6 into rax for xsave to only backup AVX and SSE registers
mov        rdx, 0                                           ;Move 0 into rdi for xsave
xsave      [backuparea]                                     ;Call xsave for backup

;===========================================================================================================================================================================
;===== End Backup Section ==================================================================================================================================================
;===========================================================================================================================================================================

;===========================================================================================================================================================================
;===== Begin the application ===============================================================================================================================================
;===========================================================================================================================================================================

;===== Display welcome message =============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, welcomemessage                              ;"Welcome to array processing."
call       printf                                           ;Call a library function to make the output

;===== Display array A message =============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, arrayamessage                               ;"Please enter quad word floats for array A: "
call       printf                                           ;Call a library function to make the output

;===== Call C++ function to move data into array A =========================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be used
mov        rdi, arraya                                      ;Move the start pointer for array A to rdi as the 1st parameter for inputarray
mov        rsi, 50                                          ;Move the size of the reserved storage to rsi as the 2nd parameter for inputarray  
call       inputarray                                       ;Call ASM function to input array elements into the reserved storage
push       rsi                                              ;Move the size of array A to a safe register
push       rsi                                              ;Push a qword for the 16-byte boundary

;===== Display array A is done message =====================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, arrayadone                                  ;"Thank you, this is array A: "
call       printf                                           ;Call a library function to make the output

;===== Display array A =====================================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, arraya                                      ;Move the start pointer for array A to rdi as the 1st parameter for displayarray
mov        rsi, [rsp]                                       ;Move the size of array A to rsi as the 2nd parameter for display array  
call       displayarray                                     ;Call C++ function to display the array

;===== Compute sum of array A ==============================================================================================================================================

mov        rdi, arraya                                      ;Move the start pointer for array A to rdi as the 1st parameter for sumarray
mov        rsi, [rsp]                                       ;Move the size of array A to rsi as the 2nd paramter for sumarray
call       sumarray                                         ;Call ASM function to compute the sum of array A
movsd      xmm15, xmm0                                      ;Move the computed sum of array A to a safe AVX register (low half xmm15) (returned by sumarray)

;===== Compute geometric length of array A =================================================================================================================================

call       geolength                                        ;Call C++ function to compute the geometric length of array A
movlhps    xmm15, xmm0                                      ;Move the computed geometric length to a safe AVX register (high half xmm15) (returned by geolength)

;===== Display array B message =============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, arraybmessage                               ;"Please enter quad word floats for Array B."
call       printf                                           ;Call a library function to make the output

;===== Clear input array ===================================================================================================================================================

mov qword  rax, 0                                           ;Something was stored on the input array
call       getchar                                          ;Without this getchar my program would not run properly

;===== Call C++ function to move data into array B =========================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be used
mov        rdi, arrayb                                      ;Move the start pointer for array B to rdi as the 1st parameter for inputarray
mov        rsi, 50                                          ;Move the size of the reserved storage to rsi as the 2nd parameter for inputarray             
call       inputarray                                       ;Call ASM function to input array elements into the reserved storage
push       rsi                                              ;Move the size of array B into a safe register
push       rsi                                              ;Push a qword for the 16-byte boundary

;===== Display array B is done message =====================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, arraybdone                                  ;"Thank you, this is array B: "
call       printf                                           ;Call a library function to make the output

;===== Display array B =====================================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, arrayb                                      ;Move the start pointer for array B to rdi as the 1st parameter for displayarray
mov        rsi, [rsp]                                       ;Move the size of the array to rsi as the 2nd parameter for displayarray  
call       displayarray                                     ;Call C++ function to display the array

;===== Compute sum of array B ==============================================================================================================================================

mov        rdi, arrayb                                      ;Move the start pointer for array B into rdi as the 1st parameter for sumarray
mov        rsi, [rsp]                                       ;Move the size of array B into rsi as the 2nd parameter for sumarray
call       sumarray                                         ;Call ASM function compute the sum of array B
movsd      xmm14, xmm0                                      ;Move the computed sum of array B into a safe AVX register (low half xmm14) (returned by sumarray)

;===== Compute geometric length of array B =================================================================================================================================

call       geolength                                        ;Call C++ function to compute the geometric length of array B
movlhps    xmm14, xmm0                                      ;Move the computed geometric length into a safe AVX register (half half xmm14) (returned by geolength)

;===== Append arrays A and B ===============================================================================================================================================

mov        rdi, [rsp+104]                                   ;Move start pointer of array C to rdi as 1st parameter for appendarray
mov        rsi, [rsp+112]                                   ;Move the size of array C to rsi as the 2nd parameter for appendarray (pointer- the value will be changed)
mov        rdx, arraya                                      ;Move start pointer of array A to rdx as 3rd parameter for appendarray
mov        rcx, [rsp+16]                                    ;Move size of array A to rcx as 4th parameter for appendarray
mov        r8, arrayb                                       ;Move start pointer of array B to r8 as 5th parameter for appendarray
mov        r9,  [rsp]                                       ;Move size of array B to r9 as the 6th parameter for appendarray
call       appendarray                                      ;Call ASM function to combine array A and array B for appendarray

;===== Display welcome message =============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, appendmessage                               ;"Next, A and B were appended to create array C, which is displayed here:"
call       printf                                           ;Call a library function to make the output

;===== Display array C =====================================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, [rsp+104]                                   ;Move the start pointer for array C to rdi as the 1st parameter for displayarray
mov        r8, [rsp+112]                                    ;Move the pointer for the size of array C to a register so we can access the value held by the pointer
mov        rsi, [r8]                                        ;Move the size of array C to rsi as the 2nd parameter for displayarray  
call       displayarray                                     ;Call C++ function to display the array

;===== Compute sum of array C ==============================================================================================================================================

mov        rdi, [rsp+104]                                   ;Move the start pointer for array C to rdi as the 1st parameter for sumarray
mov        r8, [rsp+112]                                    ;Move the pointer for the size of array C to a register so we can access the value held by the pointer
mov        rsi, [r8]                                        ;Move the size of array C into rsi as the 2nd parameter for sumarray
call       sumarray                                         ;Call ASM function to compute the sum of array C
movsd      xmm13, xmm0                                      ;Move the computed sum into a safe AVX register (low half xmm13) (returned by sumarray)

;===== Compute geometric length of array C =================================================================================================================================

call       geolength                                        ;Call C++ function to compute the geometric length of array C
movlhps    xmm13, xmm0                                      ;Move the computed geomtric length into a safe AVX register (high half xmm13) (returned by geolength)

;===== Prepare for use of printf to display sums ===========================================================================================================================

movsd      xmm0, xmm15                                      ;Move the sum of array A into xmm0 for printf
movsd      xmm1, xmm14                                      ;Move the sum of array B into xmm1 for printf
movsd      xmm2, xmm13                                      ;Move the sum of array C into xmm2 for printf

;===== Display the sums of all 3 arrays ====================================================================================================================================

mov qword  rax, 3                                           ;3 floating point numbers will be outputed by printf
mov        rdi, arraysum                                    ;"The sum of each of the 3 arrays has been computed here:"
call       printf                                           ;Call a library function to make the output

;===== Prepare for use of printf to display geometric lengths ==============================================================================================================

movhlps    xmm0, xmm15                                      ;Move the geometric length of array A into xmm0 for printf
movhlps    xmm1, xmm14                                      ;Move the geometric length of array B into xmm1 for printf
movhlps    xmm2, xmm13                                      ;Move the geometric length of array C into xmm2 for printf

;===== Display the geometric lengths of all 3 arrays =======================================================================================================================

mov qword  rax, 3                                           ;3 floating point numbers will be outputed by printf
mov        rdi, geometriclen                                ;"The geometric length of each of the 3 arrays has been computed here:"
call       printf                                           ;Call a library function to make the output

;===== Clear the stack =====================================================================================================================================================

pop rax                                                     ;Clear the stack of the stored sizes of arrays A and B 
pop rax                                                     ;As well as the extra pushes to keep the 16-byte boundary
pop rax
pop rax

;===== Conclusion message ==================================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, goodbye                                     ;""The main assembly program will now return the appeneded array C to the driver. Goodbye!"
call       printf                                           ;Call a library function to do the hard work.

;Now the stack is in the same state as when the application area was entered.  It is safe to leave this application area.

;===========================================================================================================================================================================
;===== End the Application =================================================================================================================================================
;===========================================================================================================================================================================

;===========================================================================================================================================================================
;===== Begin Restore Section ===============================================================================================================================================
;===========================================================================================================================================================================

mov        rax, 6                                           ;Move 6 into rax for xrstor to only restore AVX and SSE registers
mov        rdx,0                                            ;Move 0 into rdi for xrstor
xrstor     [backuparea]                                     ;Call xrstor for restore 

popf                                                        ;Restore rflags
pop        r15                                              ;Restore r15
pop        r14                                              ;Restore r14
pop        r13                                              ;Restore r13
pop        r12                                              ;Restore r12
pop        r11                                              ;Restore r11
pop        r10                                              ;Restore r10
pop        r9                                               ;Restore r9
pop        r8                                               ;Restore r8
pop        rdi                                              ;Restore rdi
pop        rax                                              ;Do not restore rsi
pop        rdx                                              ;Restore rdx
pop        rcx                                              ;Restore rcx
pop        rbx                                              ;Restore rbx
pop        rbp                                              ;Restore rbp

;===========================================================================================================================================================================
;===== End Restore Section =================================================================================================================================================
;===========================================================================================================================================================================

ret                                                         ;Pop a qword from the stack into rip, and continue executing..
;========== End of program arrayprocess.asm ===============================================================================================================================
;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
