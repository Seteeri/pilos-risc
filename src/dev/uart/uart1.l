(symbols '(uart pico))

(local)
(MMIO
 IRQ
 ENABLES
 IO
 IER
 IIR
 LCR
 MCR
 LSR
 MSR
 SCRATCH
 CNTL
 STAT
 BAUD

 LSR-BIT
 TX-IDL
 TX-GE1
 RX-OVE
 RX-GE1

 STAT-BIT
 TX-FIL
 RX-FIL
 TX-DON
 TX-EMP
 CT-STA
 RT-STA
 TX-FUL
 RX-OVE
 TX-IDL
 RX-IDL
 TX-AVA
 RX-AVA

 LF
 CR

 init

 pr-fr
 poll-tx-emp
 poll-rx-one
 rd
 wr
 wr-ch
 pr
 prl

 echo
 pr-stat
 pr-lsr
 pr-bit)

# https://datasheets.raspberrypi.org/bcm2711/bcm2711-peripherals.pdf
(def 'MMIO       (hex "FE000000"))
(def 'IRQ        (+ MMIO (hex "00215000"))) # Intr status
(def 'ENABLES    (+ MMIO (hex "00215004")))
(def 'IO         (+ MMIO (hex "00215040"))) # I/O Data (FIFO)
(def 'IER        (+ MMIO (hex "00215044"))) # Intr Enable
(def 'IIR        (+ MMIO (hex "00215048"))) # Intr ID
(def 'LCR        (+ MMIO (hex "0021504C"))) # Line Ctrl
(def 'MCR        (+ MMIO (hex "00215050"))) # Modem Ctrl
(def 'LSR        (+ MMIO (hex "00215054"))) # Line Status
(def 'MSR        (+ MMIO (hex "00215058"))) # Modem Status
(def 'SCRATCH    (+ MMIO (hex "0021505C"))) # Scratch
(def 'CNTL       (+ MMIO (hex "00215060"))) # Extra Ctrl
(def 'STAT       (+ MMIO (hex "00215064"))) # Extra Status info for miniUART
(def 'BAUD       (+ MMIO (hex "00215068"))) # Baudrate
# ...0xfc

(def 'GPFSEL1    (+ MMIO (hex "00200004")))

(def 'LF (char "^J"))
(def 'CR (char "^M"))

# Mov -> uart.l

(de LSR-BIT
  (TX-IDL . `(>> -6 1))  # set if transmit FIFO empty and transmitter idle
                         # i.e. finished shifting out last bit
  (TX-GE1 . `(>> -5 1))  # set if transmit FIFO can accept at least one byte
  (RX-OVE . `(>> -1 1))  # i.e one or more chars arrived whilst receive FIFO full
  (RX-GE1 . `(>>  0 1))) # set if receive FIFO holds at least 1 symbol

(de STAT-BIT
  (TX-FIL . `(>> -24 1))  # tx fifo fill level: how many symbols in fifo, 0-8
  (RX-FIL . `(>> -16 1))  # rx fifo fill level: how many symbols in fifo, 0-8
  (TX-DON . `(>> -9  1))  # tx done
  (TX-EMP . `(>> -8  1))  # tx fifo empty
  (CT-STA . `(>> -7  1))  # cts line
  (RT-STA . `(>> -6  1))  # rts line
  (TX-FUL . `(>> -5  1))  # tx fifo full (inverse)
  (RX-OVE . `(>> -4  1))  # rx overrun
  (TX-IDL . `(>> -3  1))  # tx idle
  (RX-IDL . `(>> -2  1))  # rx idle
  (TX-AVA . `(>> -1  1))  # tx fifo sp avail >= 1 sym
  (RX-AVA . `(>>  0  1))) # rx fifo sp avail >= 1 sym

# tx fifo accept >= 1 byte
(de poll-tx-emp () (until (bit? (get LSR-BIT 'TX-GE1) (byte LSR))))
# rx fifo has >= 1 sym
(de poll-rx-ge1 () (until (bit? (get LSR-BIT 'RX-GE1) (byte LSR))))

(de rd ()  (poll-rx-ge1) (byte IO))
(de wr (B) (poll-tx-emp) (byte IO B))
(de wr-ch () (wr *Ch))
(de pr (S) (for C (chop S) (wr (char C))))
(de prl (S) (pr S) (wr LF))

(de init ()
  (let (P (cdr (assoc "AUX-ENABLES" *Uart))
        R (ptr32 P))
    (ptr32 P (| R 1)))
  (ptr32 (cdr (assoc "AUX-MU-IER-REG"  *Aux)) 0)
  (ptr32 (cdr (assoc "AUX-MU-IIR-REG"  *Aux)) (hex "c6")) # disable interrupts
  (ptr32 (cdr (assoc "AUX-MU-CNTL-REG" *Aux)) 0)
  (ptr32 (cdr (assoc "AUX-MU-LCR-REG"  *Aux)) 3) # 8 bits
  (ptr32 (cdr (assoc "AUX-MU-MCR-REG"  *Aux)) 0)

  (ptr32 (cdr (assoc "AUX-MU-BAUD-REG" *Aux)) 541) # 115200 baud

  # map UART1 : GPIO

  (ptr32 GPFSEL1
    (let R (ptr32 GPFSEL1)
      # gpio14, gpio15
      # alt5
      (setq R (& R (bnot (| (>> -12 7) (>> -15 7)))))
      (setq R (| R (>> -12 2) (>> -15 2)))))

  (ptr32 (cdr (assoc "AUX-MU-CNTL-REG" *Aux)) 3)) # enable Tx, Rx

# Debug

(de echo () (loop (uart~wr (uart~rd))))

(de pr-stat ()
  # TODO: show num for first two masks
  (pr-bit STAT STAT-BIT))

(de pr-lsr () (pr-bit LSR LSR-BIT))

(de pr-bit (R M)
  (let L (let V (byte R)
            (make
              (for X M
                (let (Nm (car X) B (cdr X))
                  (link (cons Nm (if (bit? B V) 1 0)))))))
    (println R L)))

(symbols '(pico))
