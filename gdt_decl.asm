CODE_16_SEGMENT equ gdt_code_16 - gdt_base
CODE_16_SIZE    equ r_entry - r_end

CODE_32_SEGMENT equ gdt_code_32 - gdt_base
CODE_32_SIZE    equ p_end - p_entry

DATA_SEGMENT equ gdt_data - gdt_base
DATA_SIZE    equ data_end - data_base

STACK_SEGMENT equ gdt_stack - gdt_base
STACK_SIZE    equ 256

VIDEO_SEGMENT equ gdt_video - gdt_base
VIDEO_SIZE    equ 0x8000 ; 32kb

EXTMEMORY_SEGMENT equ gdt_extmemory - gdt_base
EXTMEMORY_SIZE    equ 0xFFFF

DATA_ACCESS equ 10010010b
CODE_ACCESS equ 10011010b

struc descriptor
    lim resw 1    ; Граница (0..15)
    base_l resw 1 ; База (0..15)
    base_m resb 1 ; База (15..23)
    access resb 1 ; Байт атрибутов №1 (Access byte)
    flags  resb 1 ; Байт атрибутов №2 (граница в битах 16..19)
    base_h resb 1 ; База (24..31)
endstruc

struc gdt_descriptor
    lim  resw 1
    base resd 1
endstruc