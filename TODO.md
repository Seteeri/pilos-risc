Pre-Release
===========

https://github.com/ARM-software/arm-trusted-firmware/blob/master/bl32/tsp/tsp_timer.c

* load
  * rewrite 'load to load from ptr or sym
  * refactor kern to use this

* refactor repl
  * kern repl/term emulator
    * use catch/throw to bypass err->repl
    * main will simply load kern and kern should never ret
    * if ret, loop wfe (hang)
    * (loop (catch (repl]
  * i/o
    * *putc/getc
    * eval can be in kern but pr/print relies on ptr manip...
      * can implement with ptr functions but the rule is
      anything manipulating lisp data with ptrs belongs in interpreter
      except for MMIO or peripheral/external devices
    * rd/read reads from a ptr...
      * technically can be in lisp since output is lisp data
      * but make congruent with pr/print
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

* uart
  * test interrupts
    * mini
    * full

* optimization needs volatile
  * create 'setv for volatile wr
  * add option for ptr*

* move kern.l to end of bin
  * read from &end
    * main: mkStr &end
  * embed plio instead of string...later?
    * would need to translate lisp source code to bin data

* pil21 main -> reload kern on exit

* mmu -> pil21

* fix div -> compile clangrt

LATER
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
