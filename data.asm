data_base:

pm_msg:
    db "Message from protected mode.", 0

pm_msg_to_exit:
    db "Press enter for switch to real mode", 0

pm_exit_msg:
    db "Protected mode exited. Returned to real mode.", 0

pm_memory_detected_size:
    db "Memory size: ", 0

pm_bytes:
    db " bytes", 0

pm_dummy_int:
    db "UNEXPECTED INTERRUPT", 0

pm_timer_int:
    db "Timer: ", 0

pm_last_scancode:
    db "Last scancode: ", 0

timer:
    dd 0

exit_flag:
    db 0

cursor:
    dw 80*10*2

ascii_table:	
    db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0
	db 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', 0, 0
    db 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'", '`', 0, '\'
    db 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 0, '*', 0, ' '

buffer:
    times 256 db 0

data_end: