BOOTLOADER_ADDRESS   equ 0x7c00
BOOTLOADER_SIZE      equ 512
SIGNATURE_ADDRESS    equ BOOTLOADER_ADDRESS + BOOTLOADER_SIZE - 2
SECOND_STAGE_ADDRESS equ SIGNATURE_ADDRESS + 2

%include "gdt_decl.asm"

bits 16
org BOOTLOADER_ADDRESS

r_entry:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov bp, STACK_SIZE
    mov sp, bp

    call bios_check_extensions
    jc r_no_bios_ext

    call bios_load_sectors
    jc r_err_load_sectors

    call r_clear_screen
    mov si, pm_msg_entering_msg
    call r_print

    cli ; запрет маскируемых прерываний
    ; запрет немаскируемых прерываний
    in	al, 0x70
    or	al, 0x80
    out	0x70, al

    lgdt [gdt_descriptor_base]

    ; сохраним маски прерываний контроллеров
    in al, 0x21 ; TODO обрати внимание на порты в методе!
    mov [master_int_mask], al
    in al, 0xa1
    mov [slave_int_mask], al

    ; TODO ИЗУЧИТЬ
    mov al, 0x11
    out 0x20, al
    mov al, 0x20
    out 0x21, al
    
    mov al, 4
    out 0x21, al
    mov al, 1
    out 0x21, al 
    ; /TODO

    ; Запретим все прерывания в ведущем контроллере, кроме IRQ0 (таймер) и IRQ1(клавиатура)
    mov al, 0xFC
    out 0x21, al

    ; запретим все прерывания в ведомом контроллере
    mov al, 0xFF
    out 0xA1, al

    lidt [idt_descriptor_base]

    ; A20
    in al, 0x92
    or al, 2
    out 0x92, al

    mov eax, cr0
    or al, 0x1
    mov cr0, eax
    jmp dword CODE_32_SEGMENT:0 ; :0 потому что это косвенный jmp

r_setcursor:
    ; dh <- row
    ; dl <- col
    push ax
    push bx
    xor bh, bh
    xor al, al
    mov ah, 0x02
    int 0x10
    pop bx
    pop ax
    ret


r_print:
    pusha
    mov ah, 0x0e ; Display Character
.rp_loop:
    lodsb
    or al, al
    jz .rp_ret
    int 0x10 ; BIOS Interrupt vector
    jmp .rp_loop
.rp_ret:
    popa
    ret

r_clear_screen:
    xor ah, ah
    mov al, 0x03 ; 03h: 80x25 text resolution, 640x200 pixels, 16 colors, 4 pages. http://www.columbia.edu/~em36/wpdos/videomodes.txt
    int 0x10
    ret

r_no_bios_ext:
    call r_clear_screen
    mov si, no_bios_ext_msg
    call r_print
    jmp halt

r_err_load_sectors:
    call r_clear_screen
    mov si, err_load_sectors_msg
    call r_print
    jmp halt

p_exit_end:
    mov eax, cr0
    and al, 0xFE
    mov cr0, eax
    jmp word 0x00:r_reentry
    
r_reentry:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov bp, STACK_SIZE
    mov sp, bp

    ; перепрограммируем ведущий контроллер обратно на вектор 8 - смещение, по которому вызываются стандартные обработчики прерываний в реалмоде
    mov	al, 0x11	; инициализация
    out	0x20, al
    mov	al, 8	; отправка смещения
    out	0x21, al
    mov	al, 4	; волшебные команды, "код - работай!"
    out	0x21, al
    mov	al, 1
    out	0x21, al

    ; восстанавливаем маски контроллеров прерываний
    mov	al, master_int_mask
    out 0x21, al
    mov	al, slave_int_mask
    out	0xA1, al

    lidt [r_idtr]

    ; разрешаем немаскируемые прерывания
    in	al, 0x70
    and	al, 0x7F
    out	0x70, al
	sti ; затем маскируемые

    mov dh, 4
    xor dl, dl
    call r_setcursor

    mov si, pm_exit_msg
    call r_print


; Waiting for key...
    hlt ; for ENTER up
    hlt ; for down any key

shutdown:
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax

halt:
    cli
    hlt

%include "bios.asm"

r_end:

no_bios_ext_msg:
    db "No BIOS extensions present.", 0

err_load_sectors_msg:
    db "Can't load sectors.", 0

r_idtr:
    dw 0x33f, 0, 0

master_int_mask:
    db 0

slave_int_mask:
    db 0

FIRST_SECTION_LENGTH equ $$-$

section .bss ; unititialized data
stack_base:
    resb SIGNATURE_ADDRESS - (BOOTLOADER_ADDRESS + FIRST_SECTION_LENGTH)
stack_end:

section signature start=SIGNATURE_ADDRESS
dw 0xaa55

section second_stage start=SECOND_STAGE_ADDRESS
%include "protected.asm"
%include "idt.asm"
%include "gdt.asm"
%include "data.asm"
