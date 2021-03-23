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


(de intr ()
  # pass num?
  (case *IntID
    (27
      (prl-kern (pack *IntID " Restart timer..."))
      (timer~start))))


(de main ()

  ################
  # print sys info

  (prinl)

  (setq *MBox (hex "4000000"))
  (setq *Int intr)

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

  ###################
  # start term (repl)

  (term))


(main)
