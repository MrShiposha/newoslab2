
all:
	nasm -f bin main.asm -o main.bin

# qemu-system-i386 -drive 'file=main.bin,format=raw'