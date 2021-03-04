PIL
===

* reimplement alloc
  * heapAlloc must check stack/heap bounds
  * poss create segment for coroutines
* create syms: *put *get
  * replace (call $XXX) -> (eval (eval *XXX))
* finish repl
* create syms: *repl [???]
  * replace (call $XXX) -> (eval (eval *XXX))
  * need to integrate error handling
* optimization needs volatile
  
* err return
  * should not longjmp?
  * talk to alex why not like CL
* on kern error, jump to top-level repl
  * lisp sets glob sym and err checks it
    so it knows which fn to use

* gc
  * on free inter heap, push to list
  * what about arbitrarily sized allocs?
    * coroutines can fit within 1MB

IO

* diff reading from str/kern vs uart/input
  * min for boot is read/eval from str/ptr
  * implement print in kernel? or the wr fn...
    * create global *put or *get
    * replace print to file (gen interface should make this no prob)
  * error handling needs it
  * primitive lisp -> experiment with minimal primitives
    * data type ops incl eval
      * lists
      * symbols
      * numbers
    * i/o
      * ptr functions (load/store instructions)
    * sys
    * gc
    * debug
  
* rewrite I/O fns:
  accept acquire any beep char close connect ctl dir echo eof eol err ext fd file flush format from hear here host in info ipid key line listen load mail msg once open opid out path peek pipe poll port pp pr prEval pretty prin prinl print println printsp rc rd read release rewind scl script show skip space str sym sync tab tell till tmp tty udp view wait wr

Later:  
  
* coroutines
  * might work okay?

* external symbols (after SD card)

RPI
===

Interrupts
* rename daif -> daif2
* add exception vector [DONE]
* timers [DONE]
  * add inline asm to llvm.l
  * add pilsrc fns
* hook asm to interp [DONEish]
  * main sets signal handlers (using iSignal) to call sig fun
    * lib.c: iSignal
    * main.l:(de void sig ((i32 . N)) -> $Signal
      * sets signal
    * dec.l: (var Sig i32 0)
      * certain points call sigChk
* integrate gic driver

Later:

Mailbox
* more fn for display

SD Card

* Ethernet
* USB
* Codecs
  * Images: PNG, GIF, JPEG
* Audio
* Software Rasterizer

General
=======
* rewrite drivers to use classes instead of namespace
* move kern.l to end of bin
* embed plio instead of string

* version 0.0 (Lakenheath)
  * serial
  * interrupts
  * mailbox
* version 1.0 (Stuttgart)
  * display
  * ethernet
  * usb
  * keyboard
  * sd card (ext syms)

PLIO:
(out "file.plio" (pr *Kernel))
(eval (plio *Kern))

https://github.com/riscv/riscv-musl/issues/6
__jmp_buf is declared to hold 22 words = 176 bytes
