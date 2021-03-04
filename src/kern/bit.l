#{

  Bits

  assume LE
  
  default unsigned
  
  todo check overflow
  
}#

  
(de bw-not (N)
  (bin
    (pack
      (make
        (for B (chop (bin N))
          (link (if (= B "1") "0" "1")))))))

(de c->s (B) (| (>> -8 (cadr B)) (>> 0 (car B))))
(de s->c (I) (list (& I 255) (& (>> 8  I) 255) ))

(de c->i (B)
  (| (>> -24 (cadddr B)) (>> -16 (caddr B)) (>> -8 (cadr B)) (>> 0 (car B))))
(de i->c (I)
  (list (& I 255) (& (>> 8  I) 255) (& (>> 16 I) 255) (& (>> 24 I) 255)))

(de c->l (B)
  (let ((C D E F G H I J) B)
    (| (>> -56 J) (>> -48 I) (>> -40 H) (>> -32 G)
       (>> -24 F) (>> -16 E) (>> -8 D)  (>> 0 C))))
(de l->c (I) 
  (list (& I 255)         (& (>> 8  I) 255) (& (>> 16 I) 255) (& (>> 24 I) 255)
        (& (>> 32 I) 255) (& (>> 40 I) 255) (& (>> 48 I) 255) (& (>> 56 I) 255)))

#{

  Ptr

  (de * ptr) # rd sz
  (de * ptr num) # wr sz
  
  (de ** ptr list  ) # wr sz, ret ptr  
  (de ** ptr num   ) # rd sz, ret lst or num if 1
  
}#

# uint8

(de uc* (P V) (byte P (num? V)))

(de uc** (P V)
  (cond
    ((pair V)
      (dec 'P) (for (I . X) V (byte (+ P I) X)) P)
    ((and (num? V) (> V 1))
      (dec 'P) (make (for X V (link (byte (+ P X))))))
    (T # V=NIL
      (byte P V))))
      
# uint16
      
(de us* (P V)
  (if V
      (uc** P (i->c V))
      (c->i (uc** P 2))))
      
(de us** (P V)
  (cond
    ((pair V)
      (for X V (uc* P (s->c X)) (inc 'P 2)))
    ((and (num? V) (> V 1))
      (make (do V (link (c->s (uc* P 2))) (inc 'P 2))))
    (T # V=NIL
      (c->s (uc* P 2)))))
      
# uint32

(de ui* (P V)
  (if V
      (uc** P (i->c V))
      (c->i (uc** P 4))))
      
(de ui** (P V)
  (cond
    ((pair V)
      (for X V (uc* P (i->c X)) (inc 'P 4)))
    ((and (num? V) (> V 1))
      (make (do V (link (c->i (uc* P 4))) (inc 'P 4))))
    (T # V=NIL
      (c->i (uc* P 4)))))

# uint64

(de ul* (P V)
  (if V
      (uc** P (l->c V))
      (c->l (uc** P 8))))
      
(de ul** (P V)
  (cond
    ((pair V)
      (for X V (uc* P (l->c X)) (inc 'P 8)))
    ((and (num? V) (> V 1))
      (make (do V (link (c->l (uc* P 8))) (inc 'P 8))))
    (T # V=NIL
      (c->l (uc* P 8)))))
