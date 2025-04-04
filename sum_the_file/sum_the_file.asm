section .data
  input_msg : db "Filename: ", 0  ; path to read
  input_msg_len: equ $-input_msg
  output_msg : db "The sum is: ", 0 ; output msg
  output_msg_len : equ $-output_msg

section .bss
  dynamic_path: resb 1024
  buffer : resb 1024

section .text
  global _start

_start:
  push input_msg
  push input_msg_len
  call print

  mov eax, 3
  mov ebx, 0
  mov ecx, dynamic_path
  mov edx, 1024
  int 0x80

  xor edi, edi
null_terminate:
  mov al, byte [dynamic_path + edi]
  cmp al, 10
  je terminate
  add edi, 1
  jmp null_terminate
terminate:
  mov [dynamic_path+edi], byte 0

  ; puts file descriptor in eax
  mov eax, 5
  mov ebx, dynamic_path
  xor ecx, ecx
  int 0x80

  mov ebx, eax
  mov eax, 3
  mov ecx, buffer
  mov edx, 1024
  int 0x80

  ; print output message
  push output_msg
  push output_msg_len
  call print
  ; calculate sum and print
  push buffer
  call fill_ints
  push eax
  call int_print
  ; print \n
  push 10
  push esp
  push 1
  call print
  sub esp, 4

  mov eax, 1
  int 0x80

fill_ints:
  ; Variable documentation
  ; ebp:
  ;   +8, buffer pointer
  ; esp:
  ;   +0 max num ints
  ;   +4 line counter
  ;   +8 buffer counter
  ;   +12 sum
  push ebp
  mov ebp, esp
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx

  sub esp, 16

  mov [esp + 12], dword 0
  mov eax, dword [ebp + 8]
  mov [esp + 8], dword eax
  mov [esp + 4], dword 0
  mov [esp + 0], dword 0

  push dword [esp + 8]
  call read_ints
  ; set max ints
  mov [esp + 0], eax
  ; set cursor to first int line
  add ebx, 1
  mov ecx, [esp + 8]
  add ebx, ecx
  mov [esp + 8], ebx

sum_loop:
  push dword [esp + 8]
  call read_ints
  ; update sum
  mov ecx, [esp + 12]
  add eax, ecx
  mov [esp + 12], eax
 ; update buffer counter
  mov ecx, [esp + 8]
  add ebx, ecx
  add ebx, 1
  mov [esp + 8], ebx
  ; update line counter
  mov ecx, [esp + 4]
  add ecx, 1
  mov [esp + 4], ecx

  ; jump logic
  mov ebx, [esp + 4]
  mov eax, [esp + 0]
  cmp ebx, eax
  jl sum_loop

  return_sum:
  mov eax, [esp + 12]
  add esp, 16
  pop ebp
  ret 4

read_ints:
  push ebp
  mov ebp, esp
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx

  mov eax, [ebp+8]  ; Pointer to the line to read
  xor edi, edi
  push dword 0  ; counter variable
read_loop:
  mov bl, byte [eax + edi]
  cmp bl, 10  ; compare with newline
  je return_result
  push eax
  xor eax, eax
  mov al, byte [esp+4]
  mov ecx, 10
  mul ecx
  sub bl, 48
  add eax, ebx
  mov [esp+4], eax
  pop eax

  add edi, 1
  jmp read_loop

return_result:
  pop eax
  mov ebx, edi
  pop ebp
  ret 4

print:
  ; create call frame
  push ebp ; Remember that this is 32bit(4 bytes)
  mov ebp, esp
  ; Function body
  mov eax, 4
  mov ebx, 1
  mov ecx, [ebp+12]
  mov edx, [ebp+8]
  int 0x80
  ; dump stack frame
  pop ebp
  ret 8

int_print:
  push ebp
  mov ebp, esp

  mov eax, [ebp+8] ; get int
  cmp eax, 0
  jne checked_zero
    test:
    mov eax, 0x30303030 ; 0000
    push eax
    push esp
    push 4
    call print
    pop eax
    pop ebp
    ret 4
  checked_zero:

  xor edi, edi
  xor ecx, ecx
  loop_divide:
    ; Divide
    xor edx, edx
    mov ebx, 10
    div ebx
    add edx, 48
    shrd ecx, edx, 8
    add edi, 1
    cmp edi, 4
    jl loop_divide
    ; Output
    ; flip register
    mov ebx, ecx
    xor ecx, ecx
    or ch, bl
    or cl, bh
    ror ecx, 16
    ror ebx, 16
    or ch, bl
    or cl, bh
    ; Finally print
    push ecx
    push esp
    push 4
    call print
    pop eax
  pop ebp
  ret 4

