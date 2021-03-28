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
  (with pico~*gic
    (let IrqID (get gic~*IntrID 'gic~CORE-N-V-TIMER)
      (gic~i-cfg>   (: gic~dist) IrqID gic~EDGE)
      (gic~i-prio>  (: gic~dist) IrqID (>> -4 0))
      (gic~i-tgts>  (: gic~dist) IrqID (hex "1")) # proc 0
      (gic~ic-pend> (: gic~dist) IrqID T)
      (gic~is-enab> (: gic~dist) IrqID T))))

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

  (with pico~*gic
    (let IrqID (get gic~*IntrID 'gic~CORE-N-V-TIMER)
      (gic~ic-pend> (: gic~dist) IrqID T)
      (gic~is-enab> (: gic~dist) IrqID T)
      #(prl-kern (format (gic~ic-pend> (: gic~dist) 27)))
      #(prl-kern (format (gic~is-enab> (: gic~dist) 27)))
      ))

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

  (with pico~*gic
    (let IrqID (get gic~*IntrID 'gic~CORE-N-V-TIMER)
      (gic~ic-pend> (: gic~dist) 27 T)
      (gic~ic-enab> (: gic~dist) 27 T)
      #(prl-kern (format (gic~ic-pend> (: gic~dist) 27)))
      #(prl-kern (format (gic~ic-enab> (: gic~dist) 27)))
      ))

  (daif2 T)

  (pr)

  NIL)


(symbols '(pico))
