(symbols '(pico))

(de pr-kern (X)
  # Print with cnt time
  (prinl 
    (pack "[" (cntv-ct) "] " X)))

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
    [27201597] cntv-ct: 27196357                                            
    [27338944] cnt-frq: 54000000                                            
    [27471752]                                                              
    [27540543] PilOS 21.1.25 AArch64 ARMv8-A A64                            
    [27746104] Heap Size: 1 MB                                              
    [28362097] Heap Free: 0 MB
    [28458391] Stack Size: 512 KB
    [28601545] *Kern Load Time: 21759131
    
}#

(de pr-mbox ()
  (pr-kern (pack "Board Model: "          (mbox~bmod)))
  (pr-kern (pack "Board Revision: "       (mbox~brev)))
  (pr-kern (pack "Board Serial: "         (let ((A B) (mbox~bser)) (pack A " " B))))
  (pr-kern (pack "Firmware Revision: "    (mbox~frev)))
  (pr-kern (pack "ARM Memory Base/Size: " (let ((B S) (mbox~amem)) (pack B " " S))))
  (pr-kern (pack "VC Memory Base/Size: "  (let ((B S) (mbox~vmem)) (pack B " " S))))
  (pr-kern (pack "MAC Address: "          (glue "-" (mbox~madr)))))


(de pr-arm ()
  (pr-kern (text "cntv-ctl: @1"  (cntv-ctl)))
  (pr-kern (text "cntv-cval: @1" (cntv-cval)))
  (pr-kern (text "cntv-ct: @1"   (cntv-ct)))
  (pr-kern (text "cnt-frq: @1"   (cnt-frq))))
  
  
(de pr-sys ()
  (pr-kern (text "PilOS @1 AArch64 ARMv8-A A64" (glue "." (version T))))
  (pr-kern (text "Heap Size: @1 MB" (heap)))
  (pr-kern (text "Heap Free: @1 MB" (heap T)))
  (pr-kern (text "Stack Size: @1 KB" (stack 512)))
  (pr-kern (text "*Kern Load Time: @1" (usec))))


(de main ()

  # print pagetable
  
  (prinl)
  
  #(loop (println (mbox~bser)))

  (pr-mbox)
  
  (pr-kern)   
  
  (pr-arm)
  
  (pr-kern)
  
  (pr-sys)
  
  # init drivers
  
  (term)
  
  # pil21 calls C library to exit
  # we need to break main repl loop
  (loop))
    
    
(main)
