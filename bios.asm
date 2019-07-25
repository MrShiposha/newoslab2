SECTORS_TO_READ equ 4 ; if no such sectors -- will be error
TARGET_SEGMENT  equ SECOND_STAGE_ADDRESS
TARGET_OFFSET   equ 0x0000
START_BLOCK     equ 1 ; 0 == first block

HDD_INDEX equ 0x80

struc DiskAddressPacket
    size     resb 1 ; size of DAP, always 16 bytes (0x10)
    reserved resb 1 ; always 0
    sectors  resw 1 ; num sectors to read
    address  resw 2 ; segment:offset target address
    start    resq 1 ; absolute number of the start of the sectors to be read 
                    ; (1st sector of drive has number 0) using logical block addressing.
endstruc

bios_check_extensions:
    ; if extensions exists then CF == 0
    ; else CF == 1
    ; hint: use jc/jnc
    push ax
    push bx
    push si
    mov ah, 0x41   ; BIOS function
    mov bx, 0x55aa ; func param (magic number)
    mov dl, HDD_INDEX
    int 0x13
    pop si
    pop bx
    pop ax
    ret

bios_load_sectors:
    pusha
    mov dl, HDD_INDEX
    xor al, al
    mov ah, 0x42 ; Extended Read Sectors From Drive
    mov si, .bls_dap
    int 0x13
    popa
    ret

.bls_dap: istruc DiskAddressPacket
    at size,     db 0x10
    at reserved, db 0x0
    at sectors,  dw SECTORS_TO_READ 
    at address
        dw TARGET_SEGMENT
        dw TARGET_OFFSET
    at start, dq START_BLOCK
iend