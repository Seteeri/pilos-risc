(symbols '(gic pico))

(local)
(ON-CTL OFF-CTL
 +Gic +Vicb +Hyp +Vci)
 
(def 'ON-CTL  (>> 0 1))
(def 'OFF-CTL (>> 0 0))

(class +Gic)
(dm T (P)
  (=: p P)
  
  (=: dist (new '(+Dist) (+ P (hex "1000"))))
  (=: cpu  (new '(+Cpu)  (+ P (hex "2000")))))
  
# Pass T/NIL to set/clear
(dm enab> (Irq Fn X) ((if Fn 'is-enab> 'ic-enab>) (: dist) Irq X))
(dm pend> (Irq Fn X) ((if Fn 'is-pend> 'ic-pend>) (: dist) Irq X))
(dm act>  (Irq Fn X) ((if Fn 'is-act>  'ic-act>)  (: dist) Irq X))

# [366511298] (find-pend-irq) 111
# [367337545] (find-pend-irq) 174

(dm find-pend-irq> ()
  (let Irq NIL
    (for Id (max-intr-id> (: dist))
      # check pend bit
      (let (J (dec Id)
            W (is-pend> (: dist) J)
            B (>> (- (% J 32)) 1))
        (when (n0 (& B W))
          (prl-kern (pack "(find-pend-irq) " B " " W " " J))
          (setq Irq J))))
    Irq))

(class +Vicb)
(class +Hyp)
(class +Vci)    
    
(symbols '(pico))
