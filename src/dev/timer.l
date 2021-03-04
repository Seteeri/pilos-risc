(symbols '(timer pico))

(local)
(off-cntv on-cntv set-timer exha-2
 test-me)


(de test-me () (println "test-me timer"))


(de exha-2 ()
  # read iar...
  (let? Irq (find-pend-irq> *gic)
  
    (prinl (cntvct) " " (cntv-cval) " " Irq)
    
    # off
    (ic-enab-intr> (get *gic 'dist) Irq)
    
    #(eoi> Irq)
    (ic-pend-intr> (get *gic 'dist) Irq)
    
    (set-timer 1)
    
    # on
    (is-enab-intr> (get *gic 'dist) Irq)))

    
(de off-cntv ()
  (let (C (cntv-ctl)
        C (& C (bw-not C))) # 0
    (cntv-ctl C)))
    

(de on-cntv ()
  (let (C (cntv-ctl)
        C (| C (>> 0 1))) # 1
    (cntv-ctl C)))
    

(de set-timer (Sec)
  (let (Cntfrq (cntfrq)
        Ticks (* Sec Cntfrq)
        Cur-Cnt (cntvct))
    # set cmp val
    (cntv-cval (+ Cur-Cnt Ticks))))  
 

(symbols '(pico))
