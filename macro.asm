%macro setcursor 2
    ; ah <- row
    ; al <- col
    ; CHANGING AX, EDI
    mov ah, %1
    mov al, %2
    push ax
    push bx
    xor bx, bx
    mov bl, al
    mov al, 80
    mul ah
    add ax, bx
    shl ax, 1
    xor edi, edi
    mov di, ax
    pop bx
    pop ax
%endmacro

%macro print 2
    push eax
    push esi
    mov esi, %1
    mov ah, %2
%%.pp_loop:
    lodsb
    or al, al
    jz %%.pp_ret
    stosw
    jmp %%.pp_loop
%%.pp_ret:
    pop esi
    pop eax
%endmacro

%macro itoa 2
    ; 1 <- int
    ; 2 <- string buffer address 
    push eax
    push esi
    push ebp
    push ecx
    mov eax, %1
    mov esi, %2
    
    xor ebp, ebp
%%.push_char:
    xor edx, edx
    mov ecx, 10
    div ecx ; eax = q, edx = r
    add edx, '0'
    push dx
    inc ebp
    test eax, eax
    jnz %%.push_char ; end of recursion -- do not display leadeing zeros
    mov ecx, ebp
%%.itoa_ret:
    pop ax
    mov [esi], ax
    inc esi
    loop %%.itoa_ret
    mov byte [esi], 0
    
    pop ecx
    pop ebp
    pop esi
    pop eax
%endmacro

%macro hex_b 2
    push ax
    push esi

    mov al, %1
    mov esi, %2

    mov ah, '0'
    mov [esi], ah
    inc esi
    mov ah, 'x'
    mov [esi], ah
    inc esi
    xor ah, ah


    shl ax, 4
    shr al, 4

    cmp ah, 9
    jna %%.to_ascii_h
    add ah, 7 ; 7 symbols between digits and 'A' in ASCII table
%%.to_ascii_h:
    add ah, '0'
    mov [esi], ah
    inc esi

    cmp al, 9
    jna %%.to_ascii_l
    add al, 7
%%.to_ascii_l:
    add al, '0'
    mov [esi], al
    inc esi

    mov byte [esi], 0

    pop ax
    pop esi
%endmacro