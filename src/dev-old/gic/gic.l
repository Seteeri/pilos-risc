(symbols '(gic pico))

(local)
(ON-CTL OFF-CTL
 +Gic)

(def 'ON-CTL  (>> 0 1))
(def 'OFF-CTL (>> 0 0))

(class +Gic)
(dm T ()
  (=: p (hex "FF840000"))

  (=: dist (new '(+Dist) (+ (: p) (hex "1000"))))
  (=: cpu  (new '(+Cpu)  (+ (: p) (hex "2000")))))

# Pass T/NIL to set/clear
(dm enab> (Irq Fn) ((if Fn 'is-enab> 'ic-enab>) (: dist) Irq Fn))
(dm pend> (Irq Fn) ((if Fn 'is-pend> 'ic-pend>) (: dist) Irq Fn))
(dm act>  (Irq Fn) ((if Fn 'is-act>  'ic-act>)  (: dist) Irq Fn))

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

(symbols '(pico))
