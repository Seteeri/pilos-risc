(symbols '(gic pico))

(local)
(+Dist
 init-dist
 ctl> id>
 prl-dist-iid prl-dist-type
 get-it-lines-number
 dist-cfg      dist-i-prio dist-i-tgts
 dist-clr-pend dist-on-intr dist-off-intr)


# 8.9.7 GICD_ICFGR<n>, Interrupt Configuration Registers
(def 'LVL   (hex "0")) # level-sensitive
(def 'EDGE  (hex "2")) # edge-triggered

# create assoc list, store in Dist

(def 'DIST-I-ID-MSK
  (list
    (cons 'PRODUCTID   '(31 24))
    (cons 'VARIANT     '(19 16))
    (cons 'REVISION    '(15 12))
    (cons 'IMPLEMENTER '(11 0))))


(def 'DIST-TYPE-R-MSK
  (list
    (cons 'LSPI            '(15 11))
    (cons 'SECURITY-EXTN   '(10 10))
    (cons 'CPU-NUMBER      '(7   5))
    (cons 'IT-LINES-NUMBER '(4   0))))


(def 'DIST-TYPE-R-PR
  '(((X) (if (=0 X) "NO SECURITY EXTENSIONS" X))
    ((X) (+ X 1))
    ((X) (n0 X))
    ((X) (* X 32))))


(class +Dist)
(dm T (P)

  (=: ctl          P)
  (=: type-r       (+ P (hex "004")))
  (=: i-id         (+ P (hex "008")))
  (=: i-group      (+ P (hex "080")))

  (=: is-enab      (+ P (hex "100")))
  (=: ic-enab      (+ P (hex "180")))

  (=: is-pend      (+ P (hex "200")))
  (=: ic-pend      (+ P (hex "280")))

  (=: is-act       (+ P (hex "300")))
  (=: ic-act       (+ P (hex "380")))

  (=: i-prio       (+ P (hex "400")))
  (=: i-tgts       (+ P (hex "800")))
  (=: i-cfg        (+ P (hex "C00")))

  (=: ppi-s        (+ P (hex "D00")))
  (=: spi-s        (+ P (hex "D04")))
  (=: sgi          (+ P (hex "F00")))
  (=: c-pend-sgi   (+ P (hex "F10")))
  (=: s-pend-sgi   (+ P (hex "F20")))

  (=: pid-4        (+ P (hex "FD0")))
  (=: pid-5        (+ P (hex "FD4")))
  (=: pid-6        (+ P (hex "FD8")))
  (=: pid-7        (+ P (hex "FDC")))

  (=: pid-0        (+ P (hex "FE0")))
  (=: pid-1        (+ P (hex "FE4")))
  (=: pid-2        (+ P (hex "FE8")))
  (=: pid-3        (+ P (hex "FEC")))

  (=: cid-0        (+ P (hex "FF0")))
  (=: cid-1        (+ P (hex "FF4")))
  (=: cid-2        (+ P (hex "FF8")))
  (=: cid-3        (+ P (hex "FEC")))

  (init> This))


(dm init> ()

  # TODO: On init, create id, type-r cls since fixed
  # Pr info
  (pr-i-id> This)
  (pr-type-r> This)

  # Off distributor
  # Cfg before intrs passed to CPU
  (off> This)

  # TODO: store on init
  (let (Intr-Lns (get-it-lines-number> This)
        Max-Intr-ID (* (+ Intr-Lns 1) 32))

    # Disable/clear IRQs
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 32))
            En (+ (: ic-enab) O)
            Pe (+ (: ic-pend) O))
        (when (=0 (% N 32))
          (ptr32 En (hex "FFFFFFFF"))
          (ptr32 Pe (hex "FFFFFFFF")))))

    # Set intr priorities to lowest prior
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Pr (+ (: i-prio) O))
        (when (=0 (% N 4))
          (ptr32 Pr (hex "FFFFFFFF")))))

    # Set tgt of spi's, proc 0
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Ta (+ (: i-tgts) O))
        (when (=0 (% N 4))
          (ptr32 Ta (hex "01010101")))))

    # Set trigger of spi's, level triggered
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 16))
            Cf (+ (: i-cfg) O))
        (when (=0 (% N 16))
          (ptr32 Cf LVL)))))

  # On distributor
  (on> This))


(dm on> ()  (ptr32 (: ctl) ON-CTL))
(dm off> () (ptr32 (: ctl) OFF-CTL))

(dm type-r> (N) (mak-nm-lst (: type-r) DIST-TYPE-R-MSK N))
(dm get-it-lines-number> () (type-r> This 'IT-LINES-NUMBER))

(dm max-intr-id> () (* (+ (get-it-lines-number> This) 1) 32))

(dm pr-type-r> ()
  (prl-kern
    (pack
      "gic DIST-TYPE-R: "
      (ptr32 (: type-r)) " "
      (bin (ptr32 (: type-r)))))
  (pr-reg (type-r> This) DIST-TYPE-R-PR))

(dm i-id>   (N) (mak-nm-lst (: i-id) DIST-I-ID-MSK N))
(dm pr-i-id> ()
  (prl-kern
    (pack
      "gic DIST-I-ID: "
      (ptr32 (: i-id)) " "
      (bin (ptr32 (: i-id)))))
  (pr-reg (i-id> This) NIL)) # No pr fns

#####################

# Rd

(dm is-enab> (Irq X)
  (if X
      (ptr32 (+ (: is-enab) (* (/ Irq 32) 4))
        (>> (- (% Irq 32)) 1))
      (ptr32 (+ (: is-enab) (* (/ Irq 32) 4)))))

(dm is-pend> (Irq X)
  (if X
      (ptr32 (+ (: is-pend) (* (/ Irq 32) 4))
        (>> (- (% Irq 32)) 1))
      (ptr32 (+ (: is-pend) (* (/ Irq 32) 4)))))

(dm is-act>  (Irq X)
  (if X
      (ptr32 (+ (: is-act) (* (/ Irq 32) 4))
        (>> (- (% Irq 32)) 1))
      (ptr32 (+ (: is-act) (* (/ Irq 32) 4)))))


(dm ic-enab> (Irq X)
  (if X
      (ptr32 (+ (: ic-enab) (* (/ Irq 32) 4))
        (>> (- (% Irq 32)) 1))
      (ptr32 (+ (: ic-enab) (* (/ Irq 32) 4)))))

(dm ic-pend> (Irq X)
  (if X
      (ptr32 (+ (: ic-pend) (* (/ Irq 32) 4))
        (>> (- (% Irq 32)) 1))
      (ptr32 (+ (: ic-pend) (* (/ Irq 32) 4)))))

(dm ic-act>  (Irq X)
  (if X
      (ptr32 (+ (: ic-act) (* (/ Irq 32) 4))
        (>> (- (% Irq 32)) 1))
      (ptr32 (+ (: ic-act) (* (/ Irq 32) 4)))))


(dm i-cfg> (Irq X)
  (let (Shft (* (% Irq 16) 2)
        P    (+ (: i-cfg) (* (/ Irq 16) 4))
        Reg  (& (ui* P) (bnot (>> (- Shft) (hex "03"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))

# FIX
(dm i-prio> (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (: i-prio) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bnot (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (setq Reg (hex "00FFFFFF"))
    (ptr32 P Reg)))


(dm i-tgts> (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (: i-tgts) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bnot (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))


#############################

# Both empty = rd
# One or more = wr
(dm ctl> (Grp0 Grp1)
  (if (nor Grp0 Grp1)))

######################

(de mak-nm-lst (P L N)
  # Make assoc list of name : masked
  (let O (make
          (let R (ui* P)
            (for Nm-Msk L
              (let (Nm  (car Nm-Msk)
                    Msk (cdr Nm-Msk))
                (link (cons Nm (ubfx R (car Msk) (cadr Msk))))))))
    # Return single prop if N
    (if N
        (get O N)
        O)))

(de pr-reg (Msk Fns)
  (mapc
    '((A Pr)
      (let (Nm  (car A)
            Va  (cdr A)
            Out (when Pr (Pr Va)))
        (prl-kern (pack "gic  " Nm ": " Out " (" Va ")"))))
    Msk
    Fns))


(symbols '(pico))
