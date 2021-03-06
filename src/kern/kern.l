(symbols '(pico))
    
#{

    [24908182] Board Model: 0                                               
    [25121743] Board Revision: C03112                                       
    [25410831] Board Serial: 10000000 BA08938C                              
    [25712292] Firmware Revision: 5FF86CB4                                  
    [26004380] ARM Memory Base/Size: 3B400000 0                             
    [26337306] VC Memory Base/Size: 4C00000 3B400000                        
    [26695736] MAC Address: DC-A6-32-9B-40-37                               
    [26916918]                                                              
    [26977889] cntv-ctl: 0                                                  
    [27086774] cntv-cval: 0                                                 
    [27201597] cntvct: 27196357                                            
    [27338944] cnt-frq: 54000000                                            
    [27471752]                                                              
    [27540543] PilOS 21.1.25 AArch64 ARMv8-A A64                            
    [27746104] Heap Size: 1 MB                                              
    [28362097] Heap Free: 0 MB
    [28458391] Stack Size: 512 KB
    [28601545] *Kern Load Time: 21759131
    
}#

(de pr-mbox ()
  (prl-kern (pack "Board Model: "          (mbox~bmod)))
  (prl-kern (pack "Board Revision: "       (mbox~brev)))
  (prl-kern (pack "Board Serial: "         (let ((A B) (mbox~bser)) (pack A " " B))))
  (prl-kern (pack "Firmware Revision: "    (mbox~frev)))
  (prl-kern (pack "ARM Memory Base/Size: " (let ((B S) (mbox~amem)) (pack B " " S))))
  (prl-kern (pack "VC Memory Base/Size: "  (let ((B S) (mbox~vmem)) (pack B " " S))))
  (prl-kern (pack "MAC Address: "          (glue "-" (mbox~madr)))))
  
  
(de pr-sys ()
  (prl-kern (text "PilOS @1 AArch64 ARMv8-A A64" (glue "." (version T))))
  (prl-kern (text "Heap Size: @1 MB" (heap)))
  (prl-kern (text "Heap Free: @1 MB" (heap T)))
  (prl-kern (text "Stack Size: @1 KB" (stack 256)))
  (prl-kern (text "*Kern Load Time: @1" (usec))))


(de alarm-2 ()

  #{
  
    When the GIC recognizes an interrupt request, it marks its state as pending. Regenerating a pending interrupt does
    not affect the state of the interrupt.
    
    The GIC interrupt handling sequence is:
    
    1. The GIC determines the interrupts that are enabled.
    2. For each pending interrupt, the GIC determines the targeted processor or processors.
    3. For each CPU interface, the Distributor forwards the highest priority pending interrupt that targets that
    interface.
    4. Each CPU interface determines whether to signal an interrupt request to its processor, and if required, does so.
    
    5. The processor acknowledges the interrupt, and the GIC returns the interrupt ID and updates the interrupt
    state.
    6. After processing the interrupt, the processor signals End of Interrupt (EOI) to the GIC.  
    
  }#

  (prl-kern)
  (prl-kern (pack "(alarm2)"))

  # rd Interrupt Ack Register (IAR)
  
  (let? Irq (gic~find-pend-irq> *gic)
  
    (prl-kern (pack "(alarm2) " Irq))
    
    # mask all intrs (disable)
    (daif2)
    
    # disable intr in gic
    (gic~ic-enab> (get *gic 'gic~dist) Irq T)
    
    # rd End of Interrupt Register (EOIR) in CPU
    
    # clr pending intr
    (gic~ic-pend> (get *gic 'gic~dist) Irq T)
    
    # rearm timer
    
    # enable intr in gic
    (gic~is-enab> (get *gic 'gic~dist) Irq T)
    
    # unmask all intr (enable)
    (daif2 T)
    
    T))  

  
(de main ()
  
  ################
  # print sys info
  
  (prinl)

  (pr-mbox)
  
  (prl-kern)
  
  (timer~pr)
  
  (prl-kern)
  
  (pr-sys)
  
  ##############
  # init drivers
  
  (prl-kern)
  
  (def '*gic
    (new '(gic~+Gic) (hex "FF840000")))
  
  (timer~init)
  
  ############
  # start term
  
  (term)
  
  # pil21 calls C library to exit
  # we need to break main repl loop
  (loop))
    
    
(main)
