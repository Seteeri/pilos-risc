#
# Copyright (C) 2018 bzt (bztsrc@github)
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
#

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)
CFLAGS = -Wall -O0 -ffreestanding -nostdinc -nostdlib -mcpu=cortex-a72+nosimd
OBJDUMP = llvm-objdump
NM = llvm-nm

all: clean kernel8.img

start.o: start.S
	clang --target=aarch64-elf $(CFLAGS) -c start.S -o start.o

vector.o: vector.s
	clang --target=aarch64-elf $(CFLAGS) -c vector.s -o vector.o	
	
picolisp.o: picolisp.s
	clang --target=arm64-elf $(CFLAGS) -c picolisp.s -o picolisp.o	
	
%.o: %.c
	clang --target=aarch64-elf $(CFLAGS) -c $< -o $@

kernel8.img: start.o vector.o $(OBJS) picolisp.o
	ld.lld -m aarch64elf -nostdlib start.o vector.o $(OBJS) picolisp.o -T link.ld -o kernel8.elf
	llvm-objcopy -O binary kernel8.elf kernel8.img

clean:
	rm kernel8.elf *.o >/dev/null 2>/dev/null || true

minicom:
	sudo minicom -b 115200 -o -D /dev/ttyUSB0
	
qemu:
	qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio

dump:
	${OBJDUMP} -D kernel8.elf > kernel8.list
	$(NM) -n kernel8.elf > kernel8.map	
