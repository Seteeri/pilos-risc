(symbols '(gic pico))

#{

  DIST-I-ID: 33559611 1000000000000101000011101
   PRODUCTID:  (2)
   VARIANT:  (0)
   REVISION:  (1)
   IMPLEMENTER:  (1083)
  DIST-TYPE-R: 64615 1111110001100111
   LSPI: 31 (31)
   SECURITY-EXTN: 2 (1)
   CPU-NUMBER: T (3)
   IT-LINES-NUMBER: 224 (7)

  ARM® Generic Interrupt Controller Architecture version 2.0

}#

(local)
(ON-CTL OFF-CTL LVL-CFG EDGE-CFG
 dist-id-bits dist-type-bits
 lst-bits pr-bits dist-type dist-iid pr-reg pr-type pr-iid
 max-iid fld-32-1 fld-8 fld-2
 enab pend act cfg pri tgt
 init dist-init cpui-init)

(def 'ON-CTL  1)
(def 'OFF-CTL 0)

# 8.9.7 GICD_ICFGR<n>, Interrupt Configuration Registers
(def 'LVL-CFG   (bin "00")) # level-sensitive
(def 'EDGE-CFG  (bin "10")) # edge-triggered

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

(de lst-bits (P L N)
  # Make assoc list of name : masked
  (let O (make
          (let R (ptr32 P)
            (for Nm-Msk L
              (let (Nm  (car Nm-Msk)
                    Msk (cdr Nm-Msk))
                # extract bits
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

(de max-iid ()
  (* (+ (dist-type 'IT-LINES-NUMBER) 1) 32))

#### fields/registers

# calc ptr off and reg shift

(de fld-32-1 (Irq Reg)
  # 32 bits cfg/interrupt/register = 32 interrupts/register
  (ptr32
    (+ (cdr (assoc Reg *Gic))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

# toggle irq state by writing bits in set or clear register
(de enab (Irq F) (fld-32-1 Irq (if F "DIST-ISENABLER" "DIST-ICENABLER")))
(de pend (Irq F) (fld-32-1 Irq (if F "DIST-ISPENDR"   "DIST-ICPENDR")))
(de act  (Irq F) (fld-32-1 Irq (if F "DIST-ISACTIVER" "DIST-ICACTIVER")))

# (bin (need 32 "1")) = 4294967295 = "FFFFFFFF"

(de fld-8 (Irq Reg X)
  # 8 bits cfg/interrupt/register = 4 interrupts/register
  (let (Off (* (/ Irq 4) 4)
        Ptr (+ (cdr (assoc Reg *Gic)) Off)
        B (chop (bin (ptr32 Ptr)))
        Shft (* (% Irq 4) 8)
        Lo (tail Shft B)
        Md (pad 8 (bin X))
        Hi (head (- 32 8 Shft) B))
    (ptr32 Ptr
      (bin (pack (conc Hi Md Lo))))))


(de fld-2 (Irq Reg X)
  # 2 bits cfg/interrupt/register = 16 interrupts/register
  (let (Off (* (/ Irq 16) 4)
        Ptr (+ (cdr (assoc Reg *Gic)) Off)
        B (chop (bin (ptr32 Ptr)))
        Shft (* (% Irq 16) 2)
        Lo (tail Shft B)
        Md (pad 2 (bin X))
        Hi (head (- 32 2 Shft) B))
    (ptr32 Ptr
      (bin (pack (conc Hi Md Lo))))))


(de pri (Irq X)
  # low value = hi priority
  #
  # GIC supports min 16 and max 256 priority lvls
  #
  # To find lvls supported, wr 0xFF to a field and read it back
  # See Table 4-15, Page 104
  # -> pi supports 256 levels
  (fld-8 Irq "DIST-IPRIORITYR" X))

(de tgt (Irq X)
  # See Table 4-16, Page 107
  #
  # See Table 4-17, Page 107
  # bit N enables forwarding interrupts to interface N
  # 0bxxxxxxx1 = CPU interface 0
  # 0b1xxxxxxx = CPU interface 7
  (fld-8 Irq "DIST-ITARGETSR" X))

(de cfg (Irq X)
  (fld-8 Irq "DIST-ICFGR" X))

#### init

(de init ()
  (pr-type)
  (pr-iid)
  (dist-init)
  (cpui-init))


(de dist-init ()

  (ptr32 (cdr (assoc "DIST-CTLR" *Gic)) OFF-CTL)

  (for (Irq 0 (< Irq (max-iid)) (inc Irq))

    # Disable/clear pend
    (enab Irq)
    (pend Irq)
    # can chunk these...create fn to do rx
    (pri Irq 0)
    (tgt Irq (hex "1")) # PE0
    (cfg Irq EDGE-CFG))

  (ptr32 (cdr (assoc "DIST-CTLR" *Gic)) ON-CTL))


(de cpui-init ()

  (ptr32 (cdr (assoc  "CPUI-CTLR" *Gic)) OFF-CTL)

  # print CPU-IIDR

  # Only interrupts with priority higher than this val will be signaled to PE
  # FF is the max val which is lowest priority so prio lvl > FF to be signaled
  # basically says pass all interrupts
  #
  # Higher priority corresponds to a lower Priority field value
  #
  # Writing 255 always sets it to the largest supported priority field value
  (ptr32 (cdr (assoc "CPUI-PMR" *Gic)) (hex "FF")) # "F0"

  # Handle all interrupts in a single group
  (ptr32 (cdr (assoc "CPUI-BPR" *Gic)) 0)

  # Clear all pending interrupts?

  (ptr32 (cdr (assoc "CPUI-CTLR" *Gic)) ON-CTL))


(symbols '(pico))
