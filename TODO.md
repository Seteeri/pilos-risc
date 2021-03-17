Pre-Release
===========

https://github.com/ARM-software/arm-trusted-firmware/blob/master/bl32/tsp/tsp_timer.c

KERN
* const -> sym
  * *basep
  * *gicd, *gicc
  * *aux, *uart
    * *get/set
* intr
  * define gic constants
  * symbols: *gic
    * contains ptrs for distr and cpu
    * based on mmu; user can change it
      * can change mmu with ptrs and sys reg
* uart
  * test interrupts
    * mini
    * full
    
* mmu -> pil21 
* move kern.l to end of bin
  * read from &end
    * main: mkStr &end
  * embed plio instead of string...later?
    * would need to translate lisp source code to bin data  

PIL21
* ptr syms
  * rename byte  -> ptr8
  * add ptr16
  * check ptr64
  * ptr128?
  * clean up c defs
* remove unused fns
* optimization needs volatile
  * create 'setv for volatile wr
  * add option for ptr*
* fix jmps
* move uart_init to picolisp
  * or to kern if implement *put/*get
    * replace (call $XXX) -> (eval (eval *XXX))
    * uart vs mini uart
  * technically could write all of start.S in pilsrc


General
=======
* reimplement alloc
  * heapAlloc must check stack/heap bounds
  * poss create segment for coroutines
* rewrite drivers to use classes instead of namespace

* create syms: *repl [???]
  * is it possible to move repl to kern space?
  * replace (call $XXX) -> (eval (eval *XXX))
  * err jmps to repl
    * jump to *repl instead
* on kern error, jump to repl...

* finish (cnt ...) api
  * in kern
* err return
  * talk to alex why not about CL system
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
  
* limit pointer use to system registers and peripheral access (MMIO)

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

    
# Misc

PLIO:
(out "file.plio" (pr *Kernel))
(eval (plio *Kern))

https://github.com/riscv/riscv-musl/issues/6
__jmp_buf is declared to hold 22 words = 176 bytes

https://news.ycombinator.com/item?id=1878608

The maximum number of interrupts is 1020 (0b11111). Max ID = [1019 0]
