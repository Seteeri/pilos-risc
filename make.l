# Concat kernel files -> kern/kern-incbin.l to be included by linker
(when T

  (prinl "Gen kern.l")
  
  (call "rm" "-f" "kern.l")
  
  (let (Dir "src/kern"
        FilesKern ())
    (recur (Dir)
        (for F (dir Dir)
          (let Path (pack Dir "/" F)
              (cond
                ((=T (car (info Path)))             # Is a subdirectory?
                    (recurse Path) )                 # Yes: Recurse
                ((= (pack (tail 2 (chop Path))) ".l")
                    (push 'FilesKern Path)) ) ) ) )        # Yes: Print it      
    
    (out "kern.l"
      (for F '("src/kern/nsp.l"  # always first
               "src/lib/misc.l"
               "src/lib/lib.l"               
               "src/kern/bit.l"
               "src/dev/uart.mini.l"
               "src/dev/mbox.l"
               "src/dev/gic/cpu.l"
               "src/dev/gic/dist.l"
               "src/dev/gic/gic.l"
               "src/dev/gic/irq.l"
               #"src/dev/timer.l"
               "src/kern/term.l"
               "src/kern/kern.l")
        (in F (echo))))))


# Modify picolisp.s $Kerns symbol        
        
(bye)
