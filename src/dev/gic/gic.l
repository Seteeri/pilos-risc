(symbols '(gic pico))

(local)
(+Gic
 +Vicb +Hyp +Vci)
  
#{

  Cls -> ptrs
  - Intr use dist/cpu methods
    - +Dist is singleton: *dist
  - Dist/Cpu methods for ctl registers

  Cls holds offsets
  Meths use offsets

}#
 
(class +Gic)
(dm T (P)
  (=: p    P)
  (=: dist (new '(+Dist) (+ P (hex "1000"))))
  (=: cpu  (new '(+Cpu)  (+ P (hex "2000")))))

# Mov to Irq class  
# Irq = -1 : set all?
(dm enab> (Irq Val) ((if Val 'is-enab> 'ic-enab>) This Irq))
(dm pend> (Irq Val) ((if Val 'is-pend> 'ic-pend>) This Irq))
(dm act>  (Irq Val) ((if Val 'is-act>  'ic-act>)  This Irq))  
(dm on>   (Irq) (enab> This Irq T))
(dm off>  (Irq) (enab> This Irq))

(dm find-pend-irq> ()
  (let Irq NIL
    (for Id (max-intr-id> (: dist))
      # check pend bit
      (let (J (dec Id)
            W (is-pend> (: dist) J)
            B (>> (- (% J 32)) 1))
        (when (n0 (& B W))
          (setq Irq J))))
    Irq))

(de init (P)

  (def '*gic (new '(+Gic) P))
  
  (let Dist (get *gic 'dist)

    (i-cfg>        Dist TIMER-IRQ EDGE)
    (i-prio>       Dist TIMER-IRQ (>> -4 0))
    (i-tgts>       Dist TIMER-IRQ (hex "1")) # proc 0
    (ic-pend-intr> Dist TIMER-IRQ)
    (is-enab-intr> Dist TIMER-IRQ)))


(class +Vicb)
(dm T (P)
  (=: p P)
  (=: c0 (+ (: p) (hex "5000")))
  (=: c1 (+ (: p) (hex "5200")))
  (=: c2 (+ (: p) (hex "5400")))
  (=: c3 (+ (: p) (hex "5600")))
  (=: c4 (+ (: p) (hex "5800")))
  (=: c5 (+ (: p) (hex "5A00")))  
  (=: c6 (+ (: p) (hex "5C00")))    
  (=: c7 (+ (: p) (hex "5E00"))))

(class +Hyp)
  
(class +Vci)
  
(symbols '(pico))
