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

#(1566154470) (find-pend-irq) 128 128 71
#(1566764933) (find-pend-irq) 32768 32768 111
#(1567660449) (find-pend-irq) 16384 16384 174

(dm find-pend-irq> ()
  (let Irq NIL
    (for Id (max-intr-id> (: dist))
      # check pend bit
      (let (J (dec Id)
            W (is-pend> (: dist) J)
            B (>> (- (% J 32)) 1))
        #(prl-kern (pack "(find-pend-irq) " J "@" (+ (get (: dist) 'is-pend) (* (/ J 32) 4)) " " B " " W ))
        (when (n0 (& B W))
          (prl-kern (pack "(find-pend-irq) " J " " B " " W " <<<<"))
          (setq Irq J))))
    Irq))

(class +Vicb)
(class +Hyp)
(class +Vci)    
    
(symbols '(pico))
