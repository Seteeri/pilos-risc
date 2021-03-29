(symbols '(timer pico))

(local)
(init pr start stop)

(de pr ()
  (prl-kern (text "cnt-frq @1"   (cnt-frq)))

  (prl-kern (text "cntv-ctl @1"  (cntv-ctl)))
  (prl-kern (text "cntv-cval @1" (cntv-cval)))
  (prl-kern (text "cntv-tval @1" (cntv-tval)))
  (prl-kern (text "cntvct @1"    (cntvct)))

  (prl-kern (text "cntp-ctl @1"  (cntp-ctl)))
  (prl-kern (text "cntp-cval @1" (cntp-cval)))
  (prl-kern (text "cntp-tval @1" (cntp-tval)))
  (prl-kern (text "cntpct @1"    (cntpct)))

  NIL)

(de init ()
  (let IrqID (cdr (assoc "IRQ-CORE-N-V-TIMER" *Irq))
    (gic~cfg  IrqID gic~EDGE-CFG) # 2
    (gic~pri  IrqID (>> -4 0))
    (gic~tgt  IrqID (hex "1")) # proc 0
    (gic~pend IrqID) # clr pend
    (gic~enab IrqID T)))

(de start (N)

  (daif2)

  # status, mask, switch
  # unmask = on
  # mask = off/ignored
  (cntv-ctl 0)
  (isb)

  (println 'timer-start N)
  (cntv-cval (+ (cntvct) (* N (cnt-frq))))
  (isb)

  (cntv-ctl 1)
  (isb)

  (let IrqID (cdr (assoc "IRQ-CORE-N-V-TIMER" *Irq))
    (gic~pend IrqID)
    (gic~enab IrqID T))

  (daif2 T)

  (pr)

  NIL)


(de stop ()

  (daif2)

  # status, mask, switch
  # unmask = on
  # mask = off/ignored
  (cntv-ctl 0)
  (isb)

  (cntv-cval 0)
  (isb)

  (let IrqID (cdr (assoc "IRQ-CORE-N-V-TIMER" *Irq))
    (gicd-pend IrqID)
    (gicd-enab IrqID))

  (daif2 T)

  (pr)

  NIL)


(de intr ()
  (prl-kern (pack *IntID " Start timer @ 1 sec"))
  (start 1))


(symbols '(pico))
