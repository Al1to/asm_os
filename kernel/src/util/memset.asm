section .text
; in:  ebx = count, ecx = dest, dl = val
; out: void
global memset
memset:
    push eax
    
    xor eax, eax
    .loop_start:
        cmp eax, ebx
        jnb .loop_end

        mov byte [ecx], dl

        inc eax
    .loop_end:

    pop eax
    ret
