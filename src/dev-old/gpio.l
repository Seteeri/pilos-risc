(symbols '(uart pico))
(local)
(BASE              
 FSEL0             
 FSEL1             
 FSEL2             
 FSEL3             
 FSEL4             
 FSEL5             
 SET0              
 SET1              
 CLR0              
 CLR1              
 LEV0              
 LEV1              
 EDS0              
 EDS1              
 REN0              
 REN1              
 FEN0              
 FEN1              
 HEN0              
 HEN1              
 LEN0              
 LEN1              
 AREN0             
 AREN1             
 AFEN0             
 AFEN1             
 PUP-PDN-CNTRL-REG0
 PUP-PDN-CNTRL-REG1
 PUP-PDN-CNTRL-REG2
 PUP-PDN-CNTRL-REG3
 MAX-PIN
 PUD-CLK0
 PUD-CLK1
 FN-IN    
 FN-OUT   
 FN-ALT0  
 FN-ALT1  
 FN-ALT2  
 FN-ALT3  
 FN-ALT4  
 FN-ALT5  
 PU-NONE
 PU-DN  
 PU-UP) 

# datasheet incorrect @ 0x7E21 5000
(def 'BASE               (hex "FE200000"))
(def 'FSEL0              (hex "FE200000"))
(def 'FSEL1              (hex "FE200004"))
(def 'FSEL2              (hex "FE200008"))
(def 'FSEL3              (hex "FE20000C"))
(def 'FSEL4              (hex "FE200010"))
(def 'FSEL5              (hex "FE200014"))
(def 'SET0               (hex "FE20001C"))
(def 'SET1               (hex "FE200020"))
(def 'CLR0               (hex "FE200028"))
(def 'CLR1               (hex "FE20002C"))
(def 'LEV0               (hex "FE200034"))
(def 'LEV1               (hex "FE200038"))
(def 'EDS0               (hex "FE200040"))
(def 'EDS1               (hex "FE200044"))
(def 'REN0               (hex "FE20004C"))
(def 'REN1               (hex "FE200050"))
(def 'FEN0               (hex "FE200058"))
(def 'FEN1               (hex "FE20005C"))
(def 'HEN0               (hex "FE200064"))
(def 'HEN1               (hex "FE200068"))
(def 'LEN0               (hex "FE200070"))
(def 'LEN1               (hex "FE200074"))
(def 'AREN0              (hex "FE20007C"))
(def 'AREN1              (hex "FE200080"))
(def 'AFEN0              (hex "FE200088"))
(def 'AFEN1              (hex "FE20008C"))
(def 'PUP-PDN-CNTRL-REG0 (hex "FE2000E4"))
(def 'PUP-PDN-CNTRL-REG1 (hex "FE2000E8"))
(def 'PUP-PDN-CNTRL-REG2 (hex "FE2000EC"))
(def 'PUP-PDN-CNTRL-REG3 (hex "FE2000F0"))

(def 'MAX-PIN 53)

# why not defined in manual
(def 'PUD-CLK0 (hex "FE200098"))
(def 'PUD-CLK1 (hex "FE20009C"))

(def 'FN-IN       0)
(def 'FN-OUT      1)
(def 'FN-ALT0     4)
(def 'FN-ALT1     5)
(def 'FN-ALT2     6)
(def 'FN-ALT3     7)
(def 'FN-ALT4     3)
(def 'FN-ALT5     2)

# datasheet incorrect @ GPIO_PUP_PDN_CNTRL_REG0 Register
(def 'PU-NONE 0)
(def 'PU-DN   1)
(def 'PU-UP   2)
    

(de call (Pin Val Bs Fld-Sz Fld-Max)
  (let Fld-Msk (- (>> (- Fld-Sz) 1) 1)
  
    (when (and (<= Pin Fld-Max)
               (<= Val Fld-Msk))
               
      (let (N-Flds (/ 32 Fld-Sz)
            Reg    (+ Bs (* (/ Pin N-Flds) 4))
            Shft   (* (% Pin N-Flds) Fld-Sz))

        (ui* Reg
              (| (& (ui* Reg)
                    (bw-not (>> (- Shft Fld-Msk))))
                 (>> (- Shft Val))))
        
        T))))

(de set  (Pin Val) (call Pin Val SET0 1 MAX-PIN))
(de clr  (Pin Val) (call Pin Val CLR0 1 MAX-PIN))
(de pull (Pin Val) (call Pin Val PUP-PDN-CNTRL-REG0 2 MAX-PIN))
(de fn   (Pin Val) (call Pin Val SEL0 3 MAX-PIN))

(de use-alt3 (Pin) (pull Pin 'PU-NONE) (fn Pin 'FN-ALT3))

(de use-alt5 (Pin) (pull Pin 'PU-NONE) (fn Pin 'FN-ALT5))

(de init-out-pin-pu-none (Pin) (pull Pin 'PU-NONE) (fn Pin 'FN-OUT))

(de set-pin-out (Pin Bool) ((if Bool set clr) Pin 1)) 

(symbols '(pico))
