nasm -f bin main.asm -o main.bin
qemu-system-i386 -m 128M -drive file=main.bin,format=raw