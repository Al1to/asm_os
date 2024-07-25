section .data
    vga_buf_ptr equ 0xC00B8000
    vga_height equ 25
    vga_width  equ 80

    vga_row dw 0
    vga_col dw 0
    vga_pos dw 0

    vga_color db 0

section .text
; in:  void
; out: void
global init_vga
init_vga:
    push ebx
    push ecx

    mov bl, 15  ; white
    mov cl, 0   ; black
    call vga_entry_color
    mov [vga_color], al

    mov bx, ' '
    mov cx, [vga_color]
    call vga_entry

    xor ebx, ebx
    xor ecx, ecx

    .loop1_start:
        cmp ebx, vga_height
        jnb .loop1_end

        .loop2_start:
            cmp ecx, vga_width
            jnb .loop2_end

            mov edx, ebx
            imul edx, vga_width
            add edx, ecx
            mov word [vga_buf_ptr + edx * 2], ax

            inc ecx
            jmp .loop2_start

        .loop2_end:
            inc ebx
            xor ecx, ecx
            jmp .loop1_start
        
    .loop1_end:

    pop ecx
    pop ebx
    ret

; in:  -
; out: void
global vga_print
vga_print:
    ret

; in:  bx = char
; out: void
global vga_putc
vga_putc:
    push edx
    push cx
    push ax

    mov cx, [vga_color]
    call vga_entry

    mov edx, [vga_row]
    imul edx, vga_width
    add edx, [vga_col]
    mov word [vga_buf_ptr + edx * 2], ax

    mov edx, [vga_col]
    inc edx
    mov [vga_col], edx

    call vga_upd_cursor

    pop ax
    pop cx
    pop edx
    ret

; in:  void
; out: void
vga_upd_cursor:
    push ax

    mov ax, [vga_row]
    imul ax, word vga_width
    add ax, [vga_col]
    mov word [vga_pos], ax

    mov al, 0x0F 
    out byte 0x3D4, al
    mov al, byte [vga_pos]
    out byte 0x3D5, al

    mov al, 0x0E
    out byte 0x3D4, al
    mov al, byte [vga_pos + 1]
    out byte 0x3D5, al

    pop ax
    ret

; in:  bl = fg color, cl = bg color
; out: al = (fg | bg << 4)
vga_entry_color:
    mov al, bl
    shl cl, 4
    or al, cl
    ret

; in:  bx = char, cx = color
; out: ax = (char | color << 8)
vga_entry:
    mov ax, bx
    shl cx, 8
    or ax, cx
    ret