Pre-Release
===========

https://github.com/ARM-software/arm-trusted-firmware/blob/master/bl32/tsp/tsp_timer.c

Week 29MAR2021

* UART [DONE]
  * refactor UART ptrs to use *Uart
  * rewrite uart init in kern

* optimization needs volatile
  * create 'setv for volatile wr
  * add option for ptr*

* refactor loadKern -> parsePtr
  * do without mkstr?
    * use repl, modify getParse to simply read from ptr
  * rewrite 'load to do 'str/any from ptr
    * loadKern makes str sym from ptr
    * like 'any or 'str
  * sym for ptr to end
  * sym for load fn

-------------------

* move kern.l to end of bin
  * read from &end
    * main: mkStr &end
  * embed plio instead of string...later?
    * would need to translate lisp source code to bin data
* uart
  * test interrupts
    * mini
    * full

* usec
  * in main (firmware time)
  * pre kern (pil21 time)
  * post kern (kern time)

???
* mmu -> pil21
* fix div -> compile clangrt
  * build on pi for now, shouldnt change much

LATER

* rewrite debug fns: '! (_break) 'e '$
  * kern dbg fns will call repl
  * pil21 repl calls
    * ... : err -> top-level
      * (repl 0 ($ "? ") $Nil)
    * '!  : brkLoad -> immediate
      * requires debug flag
      * (repl 0 ($ "! ") $Nil)
    * loadAll
      * (repl Exe null (mkStr P))
    * main
      * (repl 0 ($ ": ") $Nil)

* rebase pil21
* ptr syms
  * rename byte  -> ptr8
  * add ptr16
  * check ptr64
  * ptr128?
* case fns
  * implement c fns uppc/lowc etc
* check rd/bin fns
* make fns use globals? [not so useful now...]
  * adr only change if mmu changes
  * possible to make mmu dynamic
    * https://www.raspberrypi.org/forums/viewtopic.php?t=268543
    * any ptrs need to be updated
    * as long as pages containing kernel do not change

* handle synchronous exceptions
  * aka data aborts, invalid ptr etc
  * https://developer.arm.com/documentation/100933/0100/Synchronous-and-asynchronous-exceptions

General
=======

    anything manipulating lisp data with ptrs belongs in interpreter
    except for MMIO or peripheral/external devices

* reimplement alloc
  * heapAlloc must check stack/heap bounds
  * poss create segment for coroutines

* gc
  * on free inter heap, push to list
  * what about arbitrarily sized allocs?
    * coroutines can fit within 1MB

* multiple timers
  * move to kern space
  * one cval
  * on cond, check next timer
  * this means timers need to be kept sorted -> binary tree

* limit pointer use to system registers and peripheral access (MMIO)

* reader can be implemented in lisp with i/o + 'any or 'str (parser)
  * parser can be implemented in lisp with intern

# Milestones

* 0.0 (Bootstrap)
  * serial
  * interrupts
  * mailbox
  * notes
    * extsym not work (need SD card access)
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
