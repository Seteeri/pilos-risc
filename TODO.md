PIL
===

Interrupts
* rename ptr32 -> int
* rename ptr64 -> long
* clean up gic
* clean up uart
  * mini vs full
* move timers to kernel space

Coroutines
* might work okay?

SD Card
* external symbols (after SD card)

Later:

Mailbox
* more fn for display

SD Card

General
=======
* reimplement alloc
  * heapAlloc must check stack/heap bounds
  * poss create segment for coroutines
* optimization needs volatile
* rewrite drivers to use classes instead of namespace
* move kern.l to end of bin
* embed plio instead of string
* create syms: *put *get
  * replace (call $XXX) -> (eval (eval *XXX))
* create syms: *repl [???]
  * replace (call $XXX) -> (eval (eval *XXX))
  * need to integrate error handling
  * err jumps to repl
    * jump to *repl instead  
* on kern error, jump to repl...

* finish (cnt ...) api
* err return
  * should not longjmp?
  * talk to alex why not like CL
* gc
  * on free inter heap, push to list
  * what about arbitrarily sized allocs?
    * coroutines can fit within 1MB

* multiple timers
  * move to kern space
  * one cval
  * on cond, check next timer
  * this means timers need to be kept sorted -> binary tree

* rewrite I/O fns:
  accept acquire any beep char close connect ctl dir echo eof eol err ext fd file flush format from hear here host in info ipid key line listen load mail msg once open opid out path peek pipe poll port pp pr prEval pretty prin prinl print println printsp rc rd read release rewind scl script show skip space str sym sync tab tell till tmp tty udp view wait wr
  

# Milestones
  
* 0.0 ()
  * serial
  * interrupts
  * mailbox
* 0.1 (Lakenheath)
  * sd card (ext syms)
  * display
* 1.0 (Stuttgart)
  * Network/ethernet/TCP/IP
  * USB
  * Keyboard (need USB)
* 2.0
  * SMP (giant lock -> fine-grained)
    * Malloc
  * Codecs (or <2.0)
    * Images: PNG, GIF, JPEG
* 3.0
  * Audio Driver
* 4.0
  * Software Rasterizer
* 5.0
  * Web Browser
* 6.0
  * Graphics Drivers
  * Wifi/Modem Drivers
  * Linux/C emulator/virtulization
    * Compile C to Lisp?

PLIO:
(out "file.plio" (pr *Kernel))
(eval (plio *Kern))

https://github.com/riscv/riscv-musl/issues/6
__jmp_buf is declared to hold 22 words = 176 bytes

https://news.ycombinator.com/item?id=1878608

The maximum number of interrupts is 1020 (0b11111). Max ID = [1019 0]
