(symbols '(pico))

#{

    Board Model: 0
    Board Revision: C03112
    Board Serial: 10000000 BA08938C
    Firmware Revision: 5FF86CB4
    ARM Memory Base/Size: 3B400000 0
    VC Memory Base/Size: 4C00000 3B400000
    MAC Address: DC-A6-32-9B-40-37

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
  (prl-kern (text "Co Stack Size: @1 KB" (stack 64)))
  (prl-kern (text "*Kern Load Ticks: @1" (usec))))


(de intr ()
  (case *IntID
    (27 (timer~intr))
    (125 (prl-kern "AUX"))
    (T  (prl-kern (format *IntID)))))


(de main ()

  (uart~init)

  # Switch input
  # TODO: mov to nsp - load very first
  #(setq *Putc uart~wr-ch)

  # Switch input to UART1 (mini UART)
  # On exit, set NIL to switch back to kern input
  #(setq *Getc '(uart~rd))

  ################
  # print sys info

  (prinl)

  (setq *Int intr)

  (pr-mbox)

  (prl-kern)

  ##############
  # drivers

  (gic~init)
  (timer~init)

  (prl-kern)

  ##########
  # preamble

  (pr-sys)

  (prl-kern)

  (timer~pr)

  (prl-kern)

  ###################
  # start term (repl)

  # when intr, use (loop (wfe) (read) ...)

  (term))


(main)
