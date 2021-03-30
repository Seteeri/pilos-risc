(symbols '(gic pico))

(local)
(on-ctl off-ctl lvl-cfg edge-cfg
 dist-id-bits dist-type-bits
 lst-bits pr-bits dist-type dist-iid pr-reg pr-type pr-iid
 max-iid state enab pend act cfg pri tgt
 init dist-init cpui-init)

(def 'ON-CTL  (>> 0 1))
(def 'OFF-CTL (>> 0 0))

# 8.9.7 GICD_ICFGR<n>, Interrupt Configuration Registers
(def 'LVL-CFG   (hex "0")) # level-sensitive
(def 'EDGE-CFG  (hex "2")) # edge-triggered

(def 'DIST-IID-BITS
  (list
    (cons 'PRODUCTID   '(31 24))
    (cons 'VARIANT     '(19 16))
    (cons 'REVISION    '(15 12))
    (cons 'IMPLEMENTER '(11 0))))

(def 'DIST-TYPE-BITS
  (list
    (cons 'LSPI            '(15 11))
    (cons 'SECURITY-EXTN   '(10 10))
    (cons 'CPU-NUMBER      '(7  5))
    (cons 'IT-LINES-NUMBER '(4  0))))

#{

    35918462 gic DIST-I-ID: 33559611 1000000000000101000011101
    36207761 gic  PRODUCTID:  (2)
    36321579 gic  VARIANT:  (0)
    36454293 gic  REVISION:  (1)
    36592739 gic  IMPLEMENTER:  (1083)
    36811161 gic DIST-TYPE-R: 64615 1111110001100111
    37045496 gic  LSPI: 31 (31)
    37152538 gic  SECURITY-EXTN: 2 (1)
    37316604 gic  CPU-NUMBER: T (3)
    37470417 gic  IT-LINES-NUMBER: 224 (7)

}#

(de lst-bits (P L N)
  # Make assoc list of name : masked
  (let O (make
          (let R (ptr32 P)
            (for Nm-Msk L
              (let (Nm  (car Nm-Msk)
                    Msk (cdr Nm-Msk))
                (link (cons Nm (ubfx R (car Msk) (cadr Msk))))))))
    # Return single prop if N
    (if N
        (get O N)
        O)))

(de pr-bits (Msk Fns)
  (mapc
    '((A Pr)
      (let (Nm  (car A)
            Va  (cdr A))
        (prl-kern (pack "gic  " Nm "=" Va))))
    Msk
    Fns))

(de dist-type (Nm)
  (lst-bits
    (cdr (assoc "DIST-TYPER" *Gic))
    DIST-TYPE-BITS
    Nm))

(de dist-iid (Nm)
  (lst-bits
    (cdr (assoc "DIST-IIDR" *Gic))
    DIST-IID-BITS
    Nm))

(de pr-reg (Nm Lst)
  (let P (cdr (assoc Nm *Gic))
    (prl-kern
      (pack
        (pack "gic " Nm "=")
        (ptr32 P) "="
        (bin (ptr32 P)))))
  (pr-bits Lst This))

(de pr-type () (pr-reg "DIST-TYPER" (dist-type)))
(de pr-iid  () (pr-reg "DIST-IIDR" (dist-iid)))


#### state

(de max-iid ()
  (* (+ (dist-type 'IT-LINES-NUMBER) 1) 32))

(de state (Irq Reg)
  (ptr32
    (+ (cdr (assoc Reg *Gic))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

(de enab (Irq F) (state Irq (if F "DIST-ISENABLER" "DIST-ICENABLER")))
(de pend (Irq F) (state Irq (if F "DIST-ISPENDR" "DIST-ICPENDR")))
(de act  (Irq F) (state Irq (if F "DIST-ISACTIVER" "DIST-ICACTIVER")))

(de cfg (Irq X)
  (let (Shft (* (% Irq 16) 2)
        P    (+ (cdr (assoc "DIST-ICFGR" *Gic)) (* (/ Irq 16) 4))
        Reg  (& (ui* P) (bnot (>> (- Shft) (hex "03"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))

(de pri (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (cdr (assoc "DIST-IPRIORITYR" *Gic)) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bnot (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (setq Reg (hex "00FFFFFF"))
    (ptr32 P Reg)))

(de tgt (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (cdr (assoc "DIST-ITARGETSR" *Gic)) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bnot (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))

#### init

(de init ()
  (pr-type)
  (pr-iid)
  (dist-init)
  (cpui-init))


(de dist-init ()

  (ptr32 (cdr (assoc "DIST-CTLR" *Gic)) OFF-CTL)

  # TODO: store on init
  (let Max-IID (max-iid)

    # Disable/clear pend
    (for (N 0 (< N Max-IID) (inc N))
      (enab N)
      (pend N))

    # Set lowest priority
    (for (N 0 (< N Max-IID) (inc N))
      (let (O (* 4 (/ N 4))
            Pr (+ (cdr (assoc "DIST-IPRIORITYR" *Gic)) O))
        (when (=0 (% N 4))
          (ptr32 Pr (hex "FFFFFFFF")))))

    # Set tgt of SPIs -> PE 0
    (for (N 0 (< N Max-IID) (inc N))
      (let (O (* 4 (/ N 4))
            Ta (+ (cdr (assoc "DIST-ITARGETSR" *Gic)) O))
        (when (=0 (% N 4))
          (ptr32 Ta (hex "01010101")))))

    # Set trigger of SPIs -> level
    (for (N 0 (< N Max-IID) (inc N))
      (let (O (* 4 (/ N 16))
            Cf (+ (cdr (assoc "DIST-ICFGR" *Gic)) O))
        (when (=0 (% N 16))
          (ptr32 Cf LVL-CFG)))))

  (ptr32 (cdr (assoc "DIST-CTLR" *Gic)) ON-CTL))


(de cpui-init ()
  (ptr32 (cdr (assoc  "CPUI-CTLR" *Gic)) OFF-CTL)

  # Set the priority level as the lowest priority
  # Note: Higher priority corresponds to a lower Priority field value in the GIC_PMR.
  # In addition to this, writing 255 to the GICC_PMR always sets it to the
  # largest supported priority field value.
  (ptr32 (cdr (assoc "CPUI-PMR" *Gic)) (hex "FF")) # "F0"

  # Handle all of interrupts in a single group
  (ptr32 (cdr (assoc "CPUI-BPR" *Gic)) (hex "0"))

  # Clear all pending interrupts

  (ptr32 (cdr (assoc "CPUI-CTLR" *Gic)) ON-CTL))


(symbols '(pico))
