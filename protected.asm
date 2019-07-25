bits 32
p_entry:
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov ax, VIDEO_SEGMENT
    mov es, ax
    mov ax, STACK_SEGMENT
    mov ss, ax
    mov ax, EXTMEMORY_SEGMENT
    mov fs, ax
    mov ebp, STACK_SIZE
    mov esp, ebp    
    sti

    setcursor 2, 0
    print pm_msg, 0x0f

    call memory_size_info
    itoa eax, buffer
    setcursor 20, 0
    print pm_memory_detected_size, 0x2e
    print buffer, 0x2e
    print pm_bytes, 0x2e

    setcursor 3, 0
    print pm_msg_to_exit, 0x0f

.waiting_exit:
    mov ah, [exit_flag]
    test ah, ah
    jz .waiting_exit

p_exit_begin:
    cli
    jmp dword CODE_16_SEGMENT:(p_exit_end - r_entry)

MB_1 equ 0x100000
GB_4 equ 0xFFFFFFFF
TEST_BYTE equ 0x55

memory_size_info:
    ; eax <- memory size
    push dx
    push ebx
    push ecx

    mov ebx, MB_1 ; Skip 1 MB
    mov dl, TEST_BYTE

    mov ecx, (GB_4 - MB_1)
.msi_loop:
    mov dh, [fs:ebx]
    mov [fs:ebx], dl
    wbinvd ; flush cache
    cmp [fs:ebx], dl
    jne .msi_ret
    mov [fs:ebx], dh
    inc ebx
    loop .msi_loop
.msi_ret:
    mov eax, ebx
    pop dx
    pop ecx
    pop ebx
    ret

p_end:
