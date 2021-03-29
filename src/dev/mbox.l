(symbols '(mbox pico))

# https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
# https://www.raspberrypi.org/forums/viewtopic.php?t=250591
# https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-5/#mailboxes
# need 16-byte aligned chunk of memory
# https://github.com/raspberrypi/documentation/blob/JamesH65-mailbox_docs/configuration/mailboxes/propertiesARM-VC.md

#{
  struct MailBoxRegisters {
    const uint32_t Read0;	  // 0x00         Read data from VC to ARM
    uint32_t Unused[3];       // 0x04-0x0F
    uint32_t Peek0;	       // 0x10
    uint32_t Sender0;      // 0x14
      uint32_t Status0;	// 0x18         Status of VC to ARM
    uint32_t Config0;	// 0x1C
    uint32_t Write1;	// 0x20         Write data from ARM to VC
    uint32_t Unused2[3];	// 0x24-0x2F
    uint32_t Peek1;	   // 0x30
    uint32_t Sender1;  // 0x34
    uint32_t Status1;	  // 0x38         Status of ARM to VC
    uint32_t Config1;	  // 0x3C
  };
}#

(local)
(MMIO MAILBOX
 zero-buf pr-buf set-mbox serial wait-wr wait-rd
 madr amem vmem bmod brev frev bser
 CH-POW
 CH-FRA
 CH-VIR
 CH-VCH
 CH-LED
 CH-BUT
 CH-TOU
 CH-PRO-AV
 CH-PRO-VA

 READ0
 UNUSED0
 PEEK0
 SENDER0
 STATUS0
 CONFIG0
 WRITE1
 UNUSED2
 PEEK1
 SENDER1
 STATUS1
 CONFIG1

 EMPTY
 FULL
 LEV
 RESP

 FIRMWARE-REVISION
 BOARD-MODEL
 BOARD-REVISION
 MAC-ADDRESS
 BOARD-SERIAL
 ARM-MEMORY
 VC-MEMORY
 TAG-END

 )

(def 'MMIO     (hex "FE000000"))
(def 'MAILBOX  (+ MMIO (hex "0000B880")))

# Mailbox Registers (uint32s)
(def 'READ0    (+ MAILBOX (hex "00")))
(def 'UNUSED0  (+ MAILBOX (hex "04"))) # [3] 0F
(def 'PEEK0    (+ MAILBOX (hex "10")))
(def 'SENDER0  (+ MAILBOX (hex "14")))
(def 'STATUS0  (+ MAILBOX (hex "18")))
(def 'CONFIG0  (+ MAILBOX (hex "1C")))
(def 'WRITE1   (+ MAILBOX (hex "20")))
(def 'UNUSED2  (+ MAILBOX (hex "24"))) # [3] 2F
(def 'PEEK1    (+ MAILBOX (hex "30")))
(def 'SENDER1  (+ MAILBOX (hex "34")))
(def 'STATUS1  (+ MAILBOX (hex "38")))
(def 'CONFIG1  (+ MAILBOX (hex "3C")))

(def 'EMPTY (hex "40000000")) # Mailbox Status Register: Mailbox Empty
(def 'FULL  (hex "80000000")) # Mailbox Status Register: Mailbox Full
(def 'LEV   (hex "400000FF"))
(def 'RESP  (hex "80000000"))

# Chans
(def 'CH-POW 0)    # Power management
(def 'CH-FRA 1)    # Framebuffer
(def 'CH-VIR 2)    # Virtual UART
(def 'CH-VCH 3)    # VCHIQ
(def 'CH-LED 4)    # LEDs
(def 'CH-BUT 5)    # Buttons
(def 'CH-TOU 6)    # Touch screen
                   # Skip 7

# Request from ARM for response by VC
(def 'CH-PRO-AV 8) # Property tags (ARM -> VC)

# Request from VC for response by ARM (none currently defined)
(def 'CH-PRO-VA 9) # Property tags (VC -> ARM)

# Tags
(def 'FIRMWARE-REVISION (hex "00000001"))
(def 'BOARD-MODEL       (hex "00010001"))
(def 'BOARD-REVISION    (hex "00010002"))
(def 'MAC-ADDRESS       (hex "00010003"))
(def 'BOARD-SERIAL      (hex "00010004"))
(def 'ARM-MEMORY        (hex "00010005"))
(def 'VC-MEMORY         (hex "00010006"))
(def 'TAG-END           (hex "0"))

(de pr-buf ()
  (prinl)
  (for Y 9
    (for X 16
      (prin (hex (byte (+ *MBox (* 16 (dec Y)) (dec X)))) " "))
      (prinl)))

(de zero-buf () (for X (* 4 32) (ptr32 (+ *MBox X) 0)))

(de madr ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 8))         # msg sz
  (ui* (+ *MBox (* 4 1)) 0)               # msg req/res code
  (ui* (+ *MBox (* 4 2)) MAC-ADDRESS)  # tag id
  (ui* (+ *MBox (* 4 3)) 8)               # val buf sz
  (ui* (+ *MBox (* 4 4)) 8)               # buf req/res code (see md)
  (ui* (+ *MBox (* 4 5)) 0)               # zero buf
  (ui* (+ *MBox (* 4 6)) 0)               # zero buf
  (ui* (+ *MBox (* 4 7)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  # BE
  (list
    (hex (byte (+ *MBox (* 4 5) 0)))
    (hex (byte (+ *MBox (* 4 5) 1)))
    (hex (byte (+ *MBox (* 4 5) 2)))
    (hex (byte (+ *MBox (* 4 5) 3)))
    (hex (byte (+ *MBox (* 4 5) 4)))
    (hex (byte (+ *MBox (* 4 5) 5)))))


(de amem ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 8)) # This msg len
  (ui* (+ *MBox (* 4 1)) 0) # REQ/RES
  (ui* (+ *MBox (* 4 2)) ARM-MEMORY)
  (ui* (+ *MBox (* 4 3)) 8) # req sz
  (ui* (+ *MBox (* 4 4)) 8) # res sz
  (ui* (+ *MBox (* 4 5)) 0)
  (ui* (+ *MBox (* 4 6)) 0)
  (ui* (+ *MBox (* 4 7)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ *MBox (* 4 6))))
    (hex (ptr32 (+ *MBox (* 4 5))))))


(de vmem ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 8)) # This msg len
  (ui* (+ *MBox (* 4 1)) 0) # REQ/RES
  (ui* (+ *MBox (* 4 2)) VC-MEMORY)
  (ui* (+ *MBox (* 4 3)) 8) # req sz
  (ui* (+ *MBox (* 4 4)) 8) # res sz
  (ui* (+ *MBox (* 4 5)) 0)
  (ui* (+ *MBox (* 4 6)) 0)
  (ui* (+ *MBox (* 4 7)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ *MBox (* 4 6))))
    (hex (ptr32 (+ *MBox (* 4 5))))))

(de brev ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 7))            # msg len
  (ui* (+ *MBox (* 4 1)) 0)                  # REQ
  (ui* (+ *MBox (* 4 2)) BOARD-REVISION)  # tag ID
  (ui* (+ *MBox (* 4 3)) 4)                  # val buf sz (for response)
  (ui* (+ *MBox (* 4 4)) 4)                  # request/response code
  (ui* (+ *MBox (* 4 5)) 0)
  (ui* (+ *MBox (* 4 6)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ *MBox (* 4 5))))))


(de bmod ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 7))            # msg len
  (ui* (+ *MBox (* 4 1)) 0)                  # REQ
  (ui* (+ *MBox (* 4 2)) BOARD-MODEL)  # tag ID
  (ui* (+ *MBox (* 4 3)) 4)                  # val buf sz (for response)
  (ui* (+ *MBox (* 4 4)) 4)                  # request/response code
  (ui* (+ *MBox (* 4 5)) 0)
  (ui* (+ *MBox (* 4 6)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ *MBox (* 4 5))))))


(de frev ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 7))            # msg len
  (ui* (+ *MBox (* 4 1)) 0)                  # REQ
  (ui* (+ *MBox (* 4 2)) FIRMWARE-REVISION)  # tag ID
  (ui* (+ *MBox (* 4 3)) 4)                  # val buf sz (for response)
  (ui* (+ *MBox (* 4 4)) 4)                  # request/response code
  (ui* (+ *MBox (* 4 5)) 0)
  (ui* (+ *MBox (* 4 6)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ *MBox (* 4 5))))))


(de bser ()

  (wait-wr)

  (zero-buf)

  (ui* (+ *MBox (* 4 0)) (* 4 8)) # This msg len
  (ui* (+ *MBox (* 4 1)) 0) # REQ/RES
  (ui* (+ *MBox (* 4 2)) BOARD-SERIAL)
  (ui* (+ *MBox (* 4 3)) 8) # req sz
  (ui* (+ *MBox (* 4 4)) 8) # res sz
  (ui* (+ *MBox (* 4 5)) 0)
  (ui* (+ *MBox (* 4 6)) 0)
  (ui* (+ *MBox (* 4 7)) TAG-END)

  (let R (| *MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ *MBox (* 4 6))))
    (hex (ptr32 (+ *MBox (* 4 5))))))

(de wait-wr-1 () (while (bit? FULL  (>> -4 (ptr32 STATUS0))) (prinl (ptr32 STATUS0))))

(de wait-rd-1 () (while (bit? EMPTY (>> -4 (ptr32 STATUS0))) (prinl (ptr32 STATUS0))))

(de wait-wr-2 ()
  (loop
    (setq X (ptr32 STATUS0))
    (prin "W " X " " (hex X) " | ")
    (for X 8 (prin (byte (+ STATUS0 (dec X))) " "))
    (prin " | ")
    (prinl) (prinl)
    (NIL (bit? FULL (>> -4 X)))))

(de wait-rd-2 ()
  (loop
    (setq X (ptr32 STATUS0))
    (prin "R " X " " (hex X) " | ")
    (for X 8 (prin (byte (+ STATUS0 (dec X))) " "))
    (prinl) (prinl)
    (NIL (bit? EMPTY (>> -4 X)))))

(de wait-wr ()
  (while (bit? FULL (ptr32 STATUS0))))

(de wait-rd (R)
  (loop
    (while (bit? EMPTY (ptr32 STATUS0)))
    (T (= R (ptr32 READ0)))
      (= RESP (ui* (+ *MBox (* 4 1))))))

(symbols '(pico))
