(symbols '(timer pico))

(local)
(init pr start)

(de pr ()
  (prl-kern (text "cnt-frq: @1"   (cnt-frq)))
  
  (prl-kern (text "cntv-ctl: @1"  (cntv-ctl)))
  (prl-kern (text "cntv-cval: @1" (cntv-cval)))
  (prl-kern (text "cntv-tval: @1" (cntv-tval)))  
  (prl-kern (text "cntvct: @1"    (cntvct)))
  
  (prl-kern (text "cntp-ctl: @1"  (cntp-ctl)))
  (prl-kern (text "cntp-cval: @1" (cntp-cval)))
  (prl-kern (text "cntp-tval: @1" (cntp-tval)))
  (prl-kern (text "cntpct: @1"    (cntpct)))
  
  NIL)

  
(de init ()
  (with pico~*gic
    (gic~i-cfg>   (: gic~dist) irq~TIMER-VIRT-EL1 gic~EDGE)
    (gic~i-prio>  (: gic~dist) irq~TIMER-VIRT-EL1 (>> -4 0))
    (gic~i-tgts>  (: gic~dist) irq~TIMER-VIRT-EL1 (hex "1")) # proc 0
    (gic~ic-pend> (: gic~dist) irq~TIMER-VIRT-EL1 T)
    (gic~is-enab> (: gic~dist) irq~TIMER-VIRT-EL1 T)))    


(de start (T1 T2)

  (daif2)
  
  (let (C (cntv-ctl)
        C (& C (bw-not C))) # 0
    (cntv-ctl C))
    
  (let (Cntfrq (cnt-frq)
        Ticks (* T1 Cntfrq)
        Cur-Cnt (cntvct))
    (cntv-cval (+ Cur-Cnt Ticks)))
    
  (let (C (cntv-ctl)
        C (| C (>> 0 1))) # 1
    (cntv-ctl C))

  (daif2 T)
  
  (alarm T (pico~alarm-2))
  
  (pr)
  
  NIL)
    

(symbols '(pico))
