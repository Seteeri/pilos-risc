(symbols '(gic pico))

(local)
(+Gic +Vicb +Hyp +Vci)
  
#{

  Cls -> ptrs
  - Intr use dist/cpu methods
    - +Dist is singleton: *dist
  - Dist/Cpu methods for ctl registers

  Cls holds offsets
  Meths use offsets

}#

(class +Vicb)
(class +Hyp)
(class +Vci)

(class +Gic)
(dm T (P)
  (=: p    P)
  
  (=: dist (new '(+Dist) (+ P (hex "1000"))))
  (=: cpu  (new '(+Cpu)  (+ P (hex "2000")))))

# Pass T/NIL to set/clear
(dm enab> (Irq Fn X) ((if Fn 'is-enab> 'ic-enab>) (: dist) Irq X))
(dm pend> (Irq Fn X) ((if Fn 'is-pend> 'ic-pend>) (: dist) Irq X))
(dm act>  (Irq Fn X) ((if Fn 'is-act>  'ic-act>)  (: dist) Irq X))

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

(symbols '(pico))
