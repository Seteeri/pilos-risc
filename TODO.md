PIL
===

Interrupts
* rename daif -> daif2
* clean up gic
* clean up uart
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
  
* 0.0 (Lakenheath)
  * serial
  * interrupts
  * mailbox
* 0.1 (Mildenhall)
  * sd card (ext syms)
  * display
* 1.0 (Stuttgart)
  * network/ethernet/TCP/IP
  * USB
  * Keyboard (need USB)
* 2.0
  * Codecs (or <2.0)
    * Images: PNG, GIF, JPEG
  * Audio
  * Software Rasterizer
* 3.0
  * Graphics drivers

PLIO:
(out "file.plio" (pr *Kernel))
(eval (plio *Kern))

https://github.com/riscv/riscv-musl/issues/6
__jmp_buf is declared to hold 22 words = 176 bytes
