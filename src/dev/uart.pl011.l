(symbols '(uart pico))

(local)
(MMIO
 DR
 FR
 LF
 CR
 pr-fr
 wait-tx
 wait-rx
 rd
 wr
 pr
 prl)
  
(def 'MMIO (hex "FE000000"))
(def 'DR   (+ MMIO (hex "00201000")))
(def 'FR   (+ MMIO (hex "00201018"))
(def 'LF   (char "^J"))
(def 'CR   (char "^M"))

(de wait-tx () (while (bit? 32 (byte FR))))
(de wait-rx () (while (bit? 16 (byte FR))))

# poss need ptr32/64
(de rd ()  (wait-rx) (byte DR))
(de wr (B) (wait-tx) (byte DR B))

(de pr (S)
  (for C (chop S)
    #(when (= C LF) (wr (char CR)))
    (wr (char C))))
    
(de prl (S)
  (pr S)
  # (wr CR) 
  (wr LF))

        
(symbols '(pico))
