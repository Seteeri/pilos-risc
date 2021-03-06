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
(def 'LVL (hex "0")) # level-sensitive
(def 'EDGE  (hex "2")) # edge-triggered 

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
  (=: p P)
  
  # Enables the forwarding of pending interrupts from the Distributor to the CPU interfaces.
  (=: ctl          (+ (: p) (hex "000")))
  
  # Provides information about the configuration of the GIC. It indicates:
  # whether the GIC implements the Security Extensions
  # the maximum number of interrupt IDs that the GIC supports
  # the number of CPU interfaces implemented
  # if the GIC implements the Security Extensions, the maximum number of
  #   implemented Lockable Shared Peripheral Interrupts (LSPIs).
  (=: type-r       (+ (: p) (hex "004")))
  
  # Provides information about the implementer and revision of the Distributor.
  (=: i-id         (+ (: p) (hex "008")))
  
  # The GICD_IGROUPR registers provide a status bit for each interrupt supported by the GIC.
  # Each bit controls whether the corresponding interrupt is in Group 0 or Group 1. 
  #
  # On start-up or reset, each interrupt with ID32 or higher resets as Group 0 and therefore all SPIs are Group 0 unless
  # the system reprograms the appropriate GICD_IGROUPR bit. See GICD_IGROUPR0 reset value for information
  # about the reset configuration of interrupts with IDs 0-31.  
  (=: i-group      (+ (: p) (hex "080")))
  
  # The GICD_ISENABLERs provide a Set-enable bit for each interrupt supported by the GIC.
  # Writing 1 to a Set-enable bit enables forwarding of the corresponding interrupt from the
  # Distributor to the CPU interfaces. Reading a bit identifies whether the interrupt is enabled.
  (=: is-enab      (+ (: p) (hex "100")))
  
  # The GICD_ICENABLERs provide a Clear-enable bit for each interrupt supported by the
  # GIC. Writing 1 to a Clear-enable bit disables forwarding of the corresponding interrupt from
  # the Distributor to the CPU interfaces. Reading a bit identifies whether the interrupt is
  # enabled.  
  (=: ic-enab      (+ (: p) (hex "180")))  
  
  # The GICD_ISPENDRs provide a Set-pending bit for each interrupt supported by the GIC.
  # Writing 1 to a Set-pending bit sets the status of the corresponding peripheral interrupt to
  # pending. Reading a bit identifies whether the interrupt is pending.  
  (=: is-pend      (+ (: p) (hex "200")))
  
  # The GICD_ICPENDRs provide a Clear-pending bit for each interrupt supported by the GIC.
  # Writing 1 to a Clear-pending bit clears the pending state of the corresponding peripheral
  # interrupt. Reading a bit identifies whether the interrupt is pending.  
  (=: ic-pend      (+ (: p) (hex "280")))
  
  # The GICD_ISACTIVERs provide a Set-active bit for each interrupt that the GIC supports.
  # Writing to a Set-active bit Activates the corresponding interrupt. These registers are used
  # when preserving and restoring GIC state.  
  (=: is-act       (+ (: p) (hex "300")))
  
  # The GICD_ICACTIVERs provide a Clear-active bit for each interrupt that the GIC
  # supports. Writing to a Clear-active bit Deactivates the corresponding interrupt. These
  # registers are used when preserving and restoring GIC state.  
  (=: ic-act       (+ (: p) (hex "380")))
  
  # The GICD_IPRIORITYRs provide an 8-bit priority field for each interrupt supported by the
  # GIC. This field stores the priority of the corresponding interrupt.  
  (=: i-prio       (+ (: p) (hex "400")))
  
  # The GICD_ITARGETSRs provide an 8-bit CPU targets field for each interrupt supported
  # by the GIC. This field stores the list of target processors for the interrupt. That is, it holds
  # the list of CPU interfaces to which the Distributor forwards the interrupt if it is asserted and
  # has sufficient priority.  
  (=: i-tgts       (+ (: p) (hex "800")))
    
  # The GICD_ICFGRs provide a 2-bit Int_config field for each interrupt supported by the GIC.
  # This field identifies whether the corresponding interrupt is edge-triggered or level-sensitive,
  # see Interrupt types on page 1-18.    
  (=: i-cfg        (+ (: p) (hex "C00")))
    
  (=: ppi-s        (+ (: p) (hex "D00")))    
  (=: spi-s        (+ (: p) (hex "D04")))
  (=: sgi          (+ (: p) (hex "F00")))
  (=: c-pend-sgi   (+ (: p) (hex "F10")))
  (=: s-pend-sgi   (+ (: p) (hex "F20")))  
  
  (=: pid-4        (+ (: p) (hex "FD0")))
  (=: pid-5        (+ (: p) (hex "FD4")))
  (=: pid-6        (+ (: p) (hex "FD8")))
  (=: pid-7        (+ (: p) (hex "FDC")))    

  (=: pid-0        (+ (: p) (hex "FE0")))
  (=: pid-1        (+ (: p) (hex "FE4")))
  (=: pid-2        (+ (: p) (hex "FE8")))
  (=: pid-3        (+ (: p) (hex "FEC")))

  (=: cid-0        (+ (: p) (hex "FF0")))    
  (=: cid-1        (+ (: p) (hex "FF4")))
  (=: cid-2        (+ (: p) (hex "FF8")))
  (=: cid-3        (+ (: p) (hex "FEC")))
  
  (init> This))

(dm on> ()  (ui* (: ctl) CTL-ON))
(dm off> () (ui* (: ctl) CTL-OFF))

(dm type-r> (N) (mak-nm-lst (: type-r) DIST-TYPE-R-MSK N))
(dm get-it-lines-number> () (type-r> This 'IT-LINES-NUMBER))

(dm max-intr-id> () (* (+ (get-it-lines-number> This) 1) 32))

(dm pr-type-r> () 
  (prl-kern
    (pack
      "[gic] DIST-TYPE-R: "
      (ui* (: type-r)) "="
      (bin (ui* (: type-r)))))
  (pr-reg (type-r> This) DIST-TYPE-R-PR))

(dm i-id>   (N) (mak-nm-lst (: i-id) DIST-I-ID-MSK N))
(dm pr-i-id> () 
  (prl-kern
    (pack
      "[gic] DIST-I-ID: "
      (ui* (: i-id)) "="
      (bin (ui* (: i-id)))))
  (pr-reg (i-id> This) NIL)) # No pr fns

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
          (ui* En (hex "FFFFFFFF"))
          (ui* Pe (hex "FFFFFFFF")))))

    # Set intr priorities to lowest prior
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Pr (+ (: i-prio) O))
        (when (=0 (% N 4))
          (ui* Pr (hex "FFFFFFFF")))))

    # Set tgt of spi's, proc 0
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Ta (+ (: i-tgts) O))
        (when (=0 (% N 4))
          (ui* Ta (hex "01010101")))))

    # Set trigger of spi's, level triggered
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 16))
            Cf (+ (: i-cfg) O))
        (when (=0 (% N 16))
          (ui* Cf LVL)))))

  # On distributor
  (on> This))

# Get
  
(dm is-enab> (Irq) (ui* (+ (: is-enab) (* (/ Irq 32) 4))))
(dm is-pend> (Irq) (ui* (+ (: is-pend) (* (/ Irq 32) 4))))
(dm is-act>  (Irq) (ui* (+ (: is-act)  (* (/ Irq 32) 4))))


(dm ic-enab> (Irq Wd) (ui* (+ (: ic-enab) (* (/ Irq 32) 4)) Wd))
(dm ic-pend> (Irq Wd) (ui* (+ (: ic-pend) (* (/ Irq 32) 4)) Wd))
(dm ic-act>  (Irq Wd) (ui* (+ (: ic-act)  (* (/ Irq 32) 4)) Wd))

# Set

# ((volatile uint32_t *)(uintptr_t)(0x08000000 + 0x100 + ( (irq / 32) * 4 ) ))
(dm is-enab-intr> (Irq) (ul* (+ (: is-enab) (* (/ Irq 32) 4)) (>> (- (% Irq 32)) 1)))
(dm is-pend-intr> (Irq) (ui* (+ (: is-pend) (* (/ Irq 32) 4)) (>> (- (% Irq 32)) 1)))
(dm is-act-intr>  (Irq) (ui* (+ (: is-act)  (* (/ Irq 32) 4)) (>> (- (% Irq 32)) 1)))
                      
(dm ic-enab-intr> (Irq) (ui* (+ (: ic-enab) (* (/ Irq 32) 4)) (>> (- (% Irq 32)) 1)))
(dm ic-pend-intr> (Irq) (ui* (+ (: ic-pend) (* (/ Irq 32) 4)) (>> (- (% Irq 32)) 1)))
(dm ic-act-intr>  (Irq) (ui* (+ (: ic-act)  (* (/ Irq 32) 4)) (>> (- (% Irq 32)) 1)))


(dm i-cfg> (Irq Cfg)
  (let (Shft (* (% Irq 16) 2)
        P    (+ (: i-cfg) (* (/ Irq 16) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "03"))))
        Reg  (| Reg (>> (- Shft) Cfg)))
    (ui* P Reg)))

(dm i-prio> (Irq Prio)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (: i-prio) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) Prio)))
    (setq Reg (hex "00FFFFFF"))
    (ui* P Reg)))

(dm i-tgts> (Irq Proc)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (: i-tgts) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) Proc)))
    (ui* P Reg)))


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
        (prl-kern (pack "[gic]  " Nm ": " Out "=" Va))))
    Msk
    Fns))


(symbols '(pico))
