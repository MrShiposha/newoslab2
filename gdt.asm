gdt_base:
gdt_null:
    dq 0x0

gdt_code_16: istruc descriptor
    at lim,    dw CODE_16_SIZE-1
    at base_l, dw r_entry
    at base_m, db 0x0
    at access, db CODE_ACCESS
    at flags,  db 0x0
    at base_h, db 0x0
iend

gdt_code_32: istruc descriptor
    at lim,    dw CODE_32_SIZE-1
    at base_l, dw p_entry
    at base_m, db 0x0
    at access, db CODE_ACCESS
    at flags,  db 01000000b
    at base_h, db 0x0
iend

gdt_data: istruc descriptor
    at lim,    dw DATA_SIZE-1
    at base_l, dw 0x0
    at base_m, db 0x0
    at access, db DATA_ACCESS
    at flags,  db 01000000b
    at base_h, db 0x0
iend

gdt_stack: istruc descriptor
    at lim,    dw STACK_SIZE-1
    at base_l, dw stack_base
    at base_m, db 0x0
    at access, db DATA_ACCESS
    at flags,  db 01000000b
    at base_h, db 0x0
iend

gdt_video: istruc descriptor
    at lim,    dw VIDEO_SIZE-1
    at base_l, dw 0x8000
    at base_m, db 0x0B
    at access, db DATA_ACCESS
    at flags,  db 01000000b
    at base_h, db 0x0
iend

gdt_extmemory: istruc descriptor
    at lim,    dw EXTMEMORY_SIZE-1
    at base_l, dw 0x0
    at base_m, db 0x0
    at access, db DATA_ACCESS
    at flags,  db 11001111b
    at base_h, db 0x0
iend
gdt_end:

gdt_descriptor_base: istruc gdt_descriptor
    at lim,  dw gdt_end - gdt_base - 1
    at base, dd gdt_base
iend