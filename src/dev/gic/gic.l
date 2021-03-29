(symbols '(gic pico))

(local)
(ON-CTL OFF-CTL
 gicd-enab gicd-pend gicd-act
 gicd-cfg  gicd-pri  gicd-tgt
 gic-init gicd-init gicc-init
 +Gic)

(def 'ON-CTL  (>> 0 1))
(def 'OFF-CTL (>> 0 0))

# 8.9.7 GICD_ICFGR<n>, Interrupt Configuration Registers
(def 'LVL   (hex "0")) # level-sensitive
(def 'EDGE  (hex "2")) # edge-triggered

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

# abstract out and pass name

(de gicd-enab (Irq F)
  (ptr32
    (+ (cdr (assoc (if F "DIST-ISENABLER" "DIST-ICENABLER") *Gic))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

(de gicd-pend (Irq F)
  (ptr32
    (+ (cdr (assoc (if F "DIST-ISPENDR" "DIST-ICPENDR") *Gic))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

(de gicd-act (Irq F)
  (ptr32
    (+ (cdr (assoc (if F "DIST-ISACTIVER" "DIST-ICACTIVER") *Gic))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

(de gicd-cfg (Irq X)
  (let (Shft (* (% Irq 16) 2)
        P    (+ (cdr (assoc "DIST-ICFGR" *Gic)) (* (/ Irq 16) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "03"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))

(de gicd-pri (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (cdr (assoc "DIST-IPRIORITYR" *Gic)) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (setq Reg (hex "00FFFFFF"))
    (ptr32 P Reg)))

(de gicd-tgt (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (cdr (assoc "DIST-ITARGETSR" *Gic)) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))

# init

(de gic-init ()
  (gicd-init)
  (gicc-init))


(de gicd-init ()

  (ptr32 (cdr (assoc "DIST-CTLR" *Gic)) 0)

  # TODO: store on init
  (let Max-Intr-ID 224

    # Disable/clear pend
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (gicd-enab N)
      (gicd-pend N))

    # Set lowest priority
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Pr (+ (cdr (assoc "DIST-IPRIORITYR" *Gic)) O))
        (when (=0 (% N 4))
          (ptr32 Pr (hex "FFFFFFFF")))))

    # Set tgt of SPIs -> PE 0
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Ta (+ (cdr (assoc "DIST-ITARGETSR" *Gic)) O))
        (when (=0 (% N 4))
          (ptr32 Ta (hex "01010101")))))

    # Set trigger of SPIs -> level
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 16))
            Cf (+ (cdr (assoc "DIST-ICFGR" *Gic)) O))
        (when (=0 (% N 16))
          (ptr32 Cf LVL)))))

  (ptr32 (cdr (assoc "DIST-CTLR" *Gic)) 1))


(de gicc-init ()
  (ptr32 (cdr (assoc  "CPUI-CTLR" *Gic)) 0)

  # Set the priority level as the lowest priority
  # Note: Higher priority corresponds to a lower Priority field value in the GIC_PMR.
  # In addition to this, writing 255 to the GICC_PMR always sets it to the
  # largest supported priority field value.
  (ptr32 (cdr (assoc "CPUI-PMR" *Gic)) (hex "FF")) # "F0"

  # Handle all of interrupts in a single group
  (ptr32 (cdr (assoc "CPUI-BPR" *Gic)) (hex "0"))

  # Clear all pending interrupts

  (ptr32 (cdr (assoc "CPUI-CTLR" *Gic)) 1))


###########################################################

(class +Gic)
(dm T ()
  (=: p (hex "FF840000"))

  (=: dist (new '(+Dist) (+ (: p) (hex "1000"))))
  (=: cpu  (new '(+Cpu)  (+ (: p) (hex "2000")))))

# Pass T/NIL to set/clear
(dm enab> (Irq Fn) ((if Fn 'is-enab> 'ic-enab>) (: dist) Irq Fn))
(dm pend> (Irq Fn) ((if Fn 'is-pend> 'ic-pend>) (: dist) Irq Fn))
(dm act>  (Irq Fn) ((if Fn 'is-act>  'ic-act>)  (: dist) Irq Fn))

(dm find-pend-irq> ()
  (let Irq NIL
    (for Id (max-intr-id> (: dist))
      # check pend bit
      (let (J (dec Id)
            W (is-pend> (: dist) J)
            B (>> (- (% J 32)) 1))
        #(prl-kern (pack "(find-pend-irq) " J "@" (+ (get (: dist) 'is-pend) (* (/ J 32) 4)) " " B " " W ))
        (when (n0 (& B W))
          (prl-kern (pack "(find-pend-irq) " J " " B " " W " <<<<"))
          (setq Irq J))))
    Irq))

(symbols '(pico))
