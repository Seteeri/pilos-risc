(symbols '(gic pico))

(local)
(+Cpu
 init-cpu)

 
(class +Cpu)
(dm T (P)
  (=: p P)
  
  (=: ctl    (+ P (hex "0000")))
  (=: pm     (+ P (hex "0004")))
  (=: bp     (+ P (hex "0008")))
  (=: ia     (+ P (hex "000C")))

  (=: eoi    (+ P (hex "0010")))
  (=: rp     (+ P (hex "0014")))  
  (=: hppi   (+ P (hex "0018")))
  (=: abp    (+ P (hex "001C")))  

  (=: aia    (+ P (hex "0020")))
  (=: aeoi   (+ P (hex "0024")))  
  (=: ahppi  (+ P (hex "0028")))
  (=: ap0    (+ P (hex "00D0")))  

  (=: ns-ap0 (+ P (hex "00E0")))    
  (=: iid    (+ P (hex "00FC")))
  (=: di     (+ P (hex "1000")))
  
  (init> This))


(dm init> ()
 
  (ui* (: ctl) CTL-OFF)
  
  # Set the priority level as the lowest priority
  # Note: Higher priority corresponds to a lower Priority field value in the GIC_PMR.
  # In addition to this, writing 255 to the GICC_PMR always sets it to the 
  # largest supported priority field value.
  (ui* (: pm) (hex "FF")) # "F0"

  # Handle all of interrupts in a single group
  (ui* (: bp) (hex "0"))
  
  # Clear all of the active interrupts
  (when NIL
    (let Pen-IRQ c # =255
      (while (not (= Pen-IRQ (hex "3FF")))
        (ui* (: eoi)
               (ui* (: ia)))
        (setq Pen-IRQ (& (ui* (: ia)) (hex "3FF"))))))
  
  (ui* (: ctl) CTL-ON))

  
(symbols '(pico))
