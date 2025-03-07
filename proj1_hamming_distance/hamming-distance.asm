section .bss
  str1: resb 1025
  str2: resb 1025

section .data
  ;prompt for first string
  str1_prmpt: db "Enter the first string: "
  str1_prmpt_len: equ $-str1_prmpt
  str2_prmpt: db "Enter the second string: "
  str2_prmpt_len: equ $-str2_prmpt
  output_msg: db "Hamming Distance: "
  output_msg_len: equ $-output_msg

section .text
  global _start

_start:
  ; Read input
  ; call prompt print
  push str1_prmpt
  push str1_prmpt_len
  call print

  ;get str1 input
  mov eax, 3
  mov ebx, 0
  mov ecx, str1
  mov edx, 1025
  int 0x80

  ; call prompt print
  push str2_prmpt
  push str2_prmpt_len
  call print
  ; get str2 input
  mov eax, 3
  mov ebx, 0
  mov ecx, str2
  mov edx, 1025
  int 0x80

  ; Used as counter (DO NOT CHANGE)
  xor edx, edx ; use edx for counter
  xor edi, edi ; zero out pointer

  char_loop:
    xor eax, eax
    mov al, byte [str1+edi]
    ;and eax, 0x000000FF  ;Mask out three bytes

    xor ebx, ebx
    mov bl, byte [str2+edi]
    ;and ebx, 0x000000FF

    ; Exit if EOL
    cmp al, 0x0A
    je report_count
    cmp bl, 0x0A
    je report_count

    xor al, bl ; compare char
    ; if different by 1, eax looks like:
    ; 000000000000001

    ; nested loop
    push edi
    xor edi, edi
    bit_cmp_loop:
      shr al, 1 ; bitshift to carry
      jnc loop_end
	add edx, 1
      loop_end:

      add edi, 1
      cmp edi, 8
      jl bit_cmp_loop
      pop edi

    ; increment count
    add edi, 1
    cmp edi, 1025
    jl char_loop

    report_count:
    push edx
    ; Print output msg
    push output_msg
    push output_msg_len
    call print
    ; Print hamming distance
    ; note that edx is still pushed
    call int_print

    ; Format newline
    push 0x0A ; newline char
    push esp
    push 1
    call print
    call exit


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

exit:
  mov eax, 1
  int 0x80
