%include "asm_io.inc"

SECTION .data

err1: db "incorrect number of command line arguments,", 0x0a,"must have one argument after sufsort",10,0
err2: db "incorrect command line argument, must contain only 0's, 1's and 2's", 0x0a,"and must be between 1 and 30 (inclusive) characters ",10,0
disp: db "sorted suffixes:",10,0

SECTION .bss

N: resd 1
X: resb 30
i: resd 1
j: resd 1
n: resd 1
m: resd 1
k: resd 1
o: resd 1
y: resd 30
i_sufcmp: resd 1
j_sufcmp: resd 1
temp: resd 1

SECTION .text
   global  asm_main

asm_main:
   enter 0,0             ; setup routine
   pusha                 ; save all registers
   mov [N], dword 0
   
   mov eax, dword [ebp+8]   ; argc
   cmp eax, dword 2         ; argc should be 2
   jne ERR1
   ; so we have the right number of arguments
   mov eax, dword [ebp+12]  ; address of argv[]
   mov ebx, dword [eax+4]   ; argv[1]
   mov eax, ebx
   jmp COUNT_LOOP

   ; loop to check 0,1,2 and length between 1 and 30 inclusive
   COUNT_LOOP: 
               cmp byte [eax], byte '0'
               je BYTE_OK

               cmp byte [eax], byte '1'
               je BYTE_OK
   
               cmp byte [eax], byte '2'
               je BYTE_OK
                
               cmp byte [eax], byte 0
               je END_LOOP
               jmp ERR2

   BYTE_OK: 
               inc eax
               add [N], dword 1
               cmp [N], dword 30
               jg ERR2
               jmp COUNT_LOOP

   END_LOOP: 
               mov ecx, X
               mov eax, dword [ebp+12]  ; address of argv[]
               mov ebx, dword [eax+4]   ; argv[1]
               mov eax, dword [N]
               mov [i], dword 0
               COPY_LOOP: 
                        cmp [i], eax
                        jge PRINT_X
                        mov al, byte [ebx]
                        mov byte [ecx], al
                        add ecx, dword 1
                        add ebx, dword 1
                        add [i], dword 1
                        jmp COPY_LOOP

   PRINT_X:
               mov eax, X
               call print_string
               call print_nl
               jmp APPEND_I

   APPEND_I:
               mov [i], dword 0
               mov edx, dword [N]
               mov ecx, y
               APPEND_LOOP:
                         cmp [i], edx
                         jge BUBBLE_SORT
                         mov eax, [i]
                         mov [ecx], eax
                         add ecx, dword 4
                         add [i], dword 1
                         jmp APPEND_LOOP


   BUBBLE_SORT:
                mov eax, 0
                mov ebx, 0
                mov ecx, 0
                mov edx, 0
                mov edx, [N]
                mov [i], edx
                add [i], dword 1
             
                FOR_I:
                         sub [i], dword 1
                         cmp [i], dword 0

                         jle DISPLAY_SORTED

                         mov [j], dword 1
                         sub [j], dword 1
                         
                         FOR_J:
                                add [j], dword 1
                                mov edx, [i]
                            
                                cmp [j], edx

                                jge FOR_I
                                
                                mov edx, [j]

                                mov eax, dword 4
                                mul edx
                                mov edx, eax
                                sub edx, 4

                                mov ebx, [y+edx]
                                mov [i_sufcmp], ebx

                                mov edx, [j]

                                mov eax, dword 4
                                mul edx
                                mov edx, eax

                                mov ebx, [y+edx]
                                mov [j_sufcmp], ebx

                                call sufcmp

                                mov [k], eax

                                cmp [k], dword 0

                                jle FOR_J

                                mov eax, [i_sufcmp]
                                mov [temp], eax

                                mov edx, [j]
                                mov eax, dword 4
                                mul edx
                                mov edx, eax
                                sub edx, 4

                                mov eax, [j_sufcmp]
                                mov [y+edx], eax

                                mov edx, [j]
                                mov eax, dword 4
                                mul edx
                                mov edx, eax

                                mov eax, [temp]
                                mov [y+edx], eax

                                jmp FOR_J

                 
   DISPLAY_SORTED:
                mov [i], dword -1
                mov eax, disp
                call print_string             

                DISP_I:
                         add [i], dword 1
                         mov eax, [N]
                         cmp [i], eax
                         jge asm_main_end

                         mov edx, [i]

                         mov eax, dword 4
                         mul edx
                         mov edx, eax

                         mov edx, [y+edx]

                         jmp DISP_Y
                         DISP_Y:
                                 cmp edx, [N]
                                 jge PRINT_SUF
                                 
                                 mov eax, [X+edx]
                                 
                                 call print_char

                                 add edx, 1
                                 jmp DISP_Y
                                 
                                 PRINT_SUF:
                                            call print_nl
                                            jmp DISP_I
                         

   jmp asm_main_end

sufcmp:
   enter 0,0
   pusha
 
   mov edx, [N]
   mov [n], edx
   mov edx, [i_sufcmp]
   sub [n], edx

   mov edx, [N]
   mov [m], edx
   mov edx, [j_sufcmp]
   sub [m], edx

   mov edx, [m]
   cmp [n], edx
   jle MIN_N  ; if n < m

   jmp MIN_M  ; if m < n
   
   MIN_N:
         mov edx, [n]
         mov [k], edx
         mov [o], dword -1
         jmp FOR_LOOP
   
   MIN_M: 
         mov edx, [m]
         mov [k], edx
         mov [o], dword -1
         jmp FOR_LOOP

   FOR_LOOP:
         add [o], dword 1
         mov edx, [k]
         cmp [o], edx
         jge FOR_LOOP_END
         mov edx, [o]
         add edx, [i_sufcmp]
         mov eax, X
         mov al, byte [eax + edx]
         mov [temp], al
         mov edx, [o]
         add edx, [j_sufcmp]
         mov eax, X
         mov al, byte [eax + edx]

         cmp [temp], al
         jl RET_MINUS_ONE
         cmp [temp], al
         jg RET_PLUS_ONE
         jmp FOR_LOOP
         
         RET_MINUS_ONE:
                    popa
                    mov eax, dword -1
                    leave
                    ret

         RET_PLUS_ONE:
                    popa
                    mov eax, dword 1
                    leave
                    ret 

   FOR_LOOP_END:
         jmp IF_N_M

   IF_N_M:
         mov eax, [m]
         cmp [n], eax
         jl RET_MINUS_ONE
         jmp RET_PLUS_ONE

 ERR1:
   mov eax, err1
   call print_string
   jmp asm_main_end

 ERR2:
   mov eax, err2
   call print_string
   jmp asm_main_end

 asm_main_end:
   popa                  ; restore all registers
   leave                     
   ret
