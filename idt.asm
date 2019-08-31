struc i_descriptor
    offs_l   resw 1 ; Адрес обработчика (0..15)
    sel      resw 1 ; Селектора сегмента кода
    _reserved resb 1
    attr     resb 1 ; Атрибуты
    offs_h   resw 1 ; Адрес обработчика (16..23)
endstruc

struc idt_descriptor
    lim  resw 1
    base resd 1
endstruc

idt_base:
i_dummys:
%rep 32
    istruc i_descriptor
        at offs_l,  dw (dummy_isr - p_entry)
        at sel,     dw CODE_32_SEGMENT
        at _reserved, db 0x0
        at attr,    db 0x8E
        at offs_h,  dw 0x0
    iend
%endrep

    istruc i_descriptor
        at offs_l,  dw (timer_int - p_entry)
        at sel,     dw CODE_32_SEGMENT
        at _reserved, db 0x0
        at attr,    db 0x8E
        at offs_h,  dw 0x0
    iend

    istruc i_descriptor
        at offs_l,  dw (keyboard_int - p_entry)
        at sel,     dw CODE_32_SEGMENT
        at _reserved, db 0x0
        at attr,    db 0x8E
        at offs_h,  dw 0x0
    iend

idt_end:

; INTERRUPT HANDLERS
dummy_isr:
    push edi
    push ax
    setcursor 12, 30
    print pm_dummy_int, 0x4f
    pop ax
    pop edi
    iret

timer_int:
    push edi
    push ax
    itoa [timer], buffer
    setcursor 24, 0
    print pm_timer_int, 0x0f
    print buffer, 0x0f
    pop ax
    pop edi

    inc dword [timer]

    ; EOI
    mov	al, 0x20
    out	0x20, al
    iret

keyboard_int:
ENTER_SCANCODE equ 0x1C
BACKSPACE_SCANCODE equ 0x0E

    push eax
    push edi
    push edx

    xor edx, edx
    mov dx, word [cursor]

    xor eax, eax
    mov ah, 0x0e
    in al, 0x60
    cmp al, 0x80 ; Is key up?
    ja .ki_ret

    cmp al, ENTER_SCANCODE
    jne .ki_check_backspace
    mov [exit_flag], ax
.ki_check_backspace:
    cmp al, BACKSPACE_SCANCODE
    jne .ki_write
    dec dx
    dec dx
    mov al, ' '
    mov word [es:edx], ax
    mov al, BACKSPACE_SCANCODE
    jmp .ki_ret
.ki_write:
    push bx
    xor bx, bx
    mov bl, al
    mov al, [ascii_table+bx]
    mov word [es:edx], ax
    inc dx
    inc dx
    mov al, bl
    pop bx
.ki_ret:
    mov word [cursor], dx
    hex_b al, buffer

    setcursor 23, 0
    print pm_last_scancode, 0x0f
    print buffer, 0x0f

    pop edx
    pop edi
    pop eax

    ; continue keaboard int handling
    in	al, 0x61
    or	al, 0x80
    out	0x61, al

    ; EOI
    mov	al, 0x20
    out	0x20, al

    iret

idt_descriptor_base: istruc idt_descriptor
    at lim,  dw idt_end - idt_base - 1
    at base, dd idt_base
iend

r_idtr: istruc idt_descriptor
    at lim,  dw 0x33f
    at base, dd 0
iend