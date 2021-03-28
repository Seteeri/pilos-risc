#{

  This file is loaded first
  
  Create all namespaces matching filenames
  
  In each file
    * change namespace
    * define (local)
    * ...
  
  Switch back to pico
  
  
  Reading libA~foo is equivalent to:
    switching the current namespace search order to libA only (with symbols)
    reading the symbol foo
    switching back to the original search order
  %~foo temporarily switches the search order to the CDR of the current namespace list. 

}#



# misc, lib, bits are global (pico nsp);
# considered part of "stdlib"
(def '*nsp 
  '(timer
    irq
    gic
    uart
    mbox))
  
(for X *nsp

  # create nsp/sym in pico (global)
  (symbols X 'pico)

  # ret top level
  (symbols '(pico)))

(de prl-kern (X)
  # Print with cnt time
  (prinl 
    (pack (cntvct) " " X)))

(de pr-kern (X)
  # Print with cnt time
  (prin 
    (pack (cntvct) " " X)))   
# 08oct20 Software Lab. Alexander Burger

# *Allow

(de *Day . (Mon Tue Wed Thu Fri Sat Sun .))
(de *Mon . (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec .))

### Locale ###
(de *Ctry)
(de *Lang)
(de *Sep0 . ".")
(de *Sep3 . ",")
(de *CtryCode)
(de *NatTrunkPrf)
(de *DateFmt @Y "-" @M "-" @D)
(de *DayFmt "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")
(de *MonFmt "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")

(de locale (Ctry Lang . @)  # "DE" "de" ["app/loc/" ..]
   (load (if (setq *Ctry Ctry) (pack "@loc/" @ ".l") "@loc/NIL.l"))
   (ifn (setq *Lang Lang)
      (for S (idx '*Uni)
         (set S S) )
      (let L
         (sort
            (make
               ("loc" (pack "@loc/" Lang))
               (while (args)
                  ("loc" (pack (next) Lang)) ) ) )
         (balance '*Uni L T)
         (for S L
            (set (car (idx '*Uni S)) (val S)) ) ) ) )

(de "loc" (F)
   (when (info F)
      (in F
         (use X
            (while (setq X (read))
               (if (=T X)
                  ("loc" (read))
                  (set (link @) (name (read))) ) ) ) ) ) )

### String ###
(de wrap (Max Lst)
   (setq Lst (split Lst " " "\n"))
   (pack
      (make
         (while Lst
            (if (> Max (length (car Lst)))
               (chain
                  (make
                     (link (++ Lst))
                     (loop
                        (NIL Lst)
                        (T (>= (+ (length (car Lst)) (sum length (made))) Max)
                           (link "\n") )
                        (link " " (++ Lst)) ) ) )
               (link (++ Lst))
               (and Lst (link "\n")) ) ) ) ) )

### Number ###
(de money (N Cur)
   (if Cur
      (pack (format N 2 *Sep0 *Sep3) " " Cur)
      (format N 2 *Sep0 *Sep3) ) )

(de round (N D)
   (if (> *Scl (default D 3))
      (format (*/ N (** 10 (- *Scl D))) D *Sep0 *Sep3)
      (format N *Scl *Sep0 *Sep3) ) )

# Binary notation
(de bin (X I)
   (cond
      ((num? X)
         (let (S (and (lt0 X) '-)  L (& 1 X)  A (cons 0 I))
            (until (=0 (setq X (>> 1 X)))
               (at A (push 'L " "))
               (push 'L (& 1 X)) )
            (pack S L) ) )
      ((setq X
            (filter
               '((C) (not (sp? C)))
               (chop X) ) )
         (let (S (and (= '- (car X)) (++ X))  N 0  C)
            (loop
               (NIL (setq C (format (++ X))))
               (NIL (or (=0 C) (=1 C)))
               (setq N (| C (>> -1 N)))
               (NIL X (if S (- N) N)) ) ) ) ) )

# Octal notation
(de oct (X I)
   (cond
      ((num? X)
         (let (S (and (lt0 X) '-)  L (& 7 X)  A (cons 0 I))
            (until (=0 (setq X (>> 3 X)))
               (at A (push 'L " "))
               (push 'L (& 7 X)) )
            (pack S L) ) )
      ((setq X
            (filter
               '((C) (not (sp? C)))
               (chop X) ) )
         (let (S (and (= '- (car X)) (++ X))  N 0  C)
            (loop
               (NIL (setq C (format (++ X))))
               (NIL (>= 7 C 0))
               (setq N (| C (>> -3 N)))
               (NIL X (if S (- N) N)) ) ) ) ) )

# Hexadecimal notation
(de hex (X I)
   (cond
      ((num? X)
         (let (S (and (lt0 X) '-)  L (hex1 X)  A (cons 0 I))
            (until (=0 (setq X (>> 4 X)))
               (at A (push 'L " "))
               (push 'L (hex1 X)) )
            (pack S L) ) )
      ((setq X
            (filter
               '((C) (not (sp? C)))
               (chop X) ) )
         (let (S (and (= '- (car X)) (++ X))  N 0  C)
            (loop
               (setq C (- (char (++ X)) `(char "0")))
               (and (> C 9) (dec 'C 7))
               (and (> C 22) (dec 'C 32))
               (NIL (>= 15 C 0))
               (setq N (| C (>> -4 N)))
               (NIL X (if S (- N) N)) ) ) ) ) )

(de hex1 (N)
   (let C (& 15 N)
      (and (> C 9) (inc 'C 7))
      (char (+ C `(char "0"))) ) )

# Hexadecimal/Alpha notation
(de hax (X)
   (if (num? X)
      (pack
         (mapcar
            '((C)
               (when (> (setq C (- (char C) `(char "0"))) 9)
                  (dec 'C 7) )
               (char (+ `(char "@") C)) )
            (chop (hex X)) ) )
      (hex
         (mapcar
            '((C)
               (when (> (setq C (- (char C) `(char "@"))) 9)
                  (inc 'C 7) )
               (char (+ `(char "0") C)) )
            (chop X) ) ) ) )

### Tree ###
(de balance ("Var" "Lst" "Flg")
   (unless "Flg" (set "Var"))
   (let "Len" (length "Lst")
      (recur ("Lst" "Len")
         (unless (=0 "Len")
            (let ("N" (>> 1 (inc "Len"))  "L" (nth "Lst" "N"))
               (idx "Var" (car "L") T)
               (recurse "Lst" (dec "N"))
               (recurse (cdr "L") (- "Len" "N")) ) ) ) ) )

(de depth (Idx)  #> (max . average)
   (let (C 0  D 0  N 0)
      (cons
         (recur (Idx N)
            (ifn Idx
               0
               (inc 'C)
               (inc 'D (inc 'N))
               (inc
                  (max
                     (recurse (cadr Idx) N)
                     (recurse (cddr Idx) N) ) ) ) )
         (or (=0 (setq @@ C)) (*/ D C)) ) ) )

### Allow ###
(de allowed Lst
   (setq *Allow (cons NIL (car Lst)))
   (balance *Allow (sort (cdr Lst))) )

(de allow (X Flg)
   (nond
      (*Allow)
      (Flg (idx *Allow X T))
      ((member X (cdr *Allow)) (queue '*Allow X)) )
   X )

### Telephone ###
(de telStr (S)
   (cond
      ((not S))
      ((and *CtryCode (pre? (pack *CtryCode " ") S))
         (pack *NatTrunkPrf (cdr (member " " (chop S)))) )
      (T (pack "+" S)) ) )

(de expTel (S)
   (setq S
      (make
         (for (L (chop S) L)
            (ifn (sub? (car L) " -")
               (link (++ L))
               (let F NIL
                  (loop
                     (and (= '- (++ L)) (on F))
                     (NIL L)
                     (NIL (sub? (car L) " -")
                        (link (if F '- " ")) ) ) ) ) ) ) )
   (cond
      ((= "+" (car S)) (pack (cdr S)))
      ((head '("0" "0") S) (pack (cddr S)))
      (*CtryCode
         (let L *NatTrunkPrf
            (loop
               (NIL L (pack *CtryCode " " S))
               (NIL (= (++ L) (++ S))) ) ) ) ) )

### Date ###
# ISO date
(de $dat (S C)
   (if C
      (and
         (= 3
            (length (setq S (split (chop S) C))) )
         (date
            (format (car S))               # Year
            (or (format (cadr S)) 0)       # Month
            (or (format (caddr S)) 0) ) )  # Day
      (and
         (format S)
         (date
            (/ @ 10000)       # Year
            (% (/ @ 100) 100) # Month
            (% @ 100) ) ) ) )

# Localized
(de datStr (D F)
   (when (setq D (date D))
      (let
         (@Y (if F (pad 2 (% (car D) 100)) (pad 4 (car D)))
            @M (pad 2 (cadr D))
            @D (pad 2 (caddr D)) )
         (pack (fill *DateFmt)) ) ) )

(de strDat (S)
   (use (@Y @M @D)
      (and
         (match *DateFmt (chop S))
         (date
            (format @Y)
            (or (format @M) 0)
            (or (format @D) 0) ) ) ) )

(de expDat (S)
   (cond
      ((= "." S) (date))
      ((or (pre? "+" S) (pre? "-" S)) (+ (date) (format S)))
      (T
         (use (@Y @M @D X)
            (unless (match *DateFmt (setq S (chop S)))
               (if
                  (or
                     (cdr (setq S (split S ".")))
                     (>= 2 (length (car S))) )
                  (setq
                     @D (car S)
                     @M (cadr S)
                     @Y (caddr S) )
                  (setq
                     @D (head 2 (car S))
                     @M (head 2 (nth (car S) 3))
                     @Y (nth (car S) 5) ) ) )
            (and
               (setq @D (format @D))
               (date
                  (nond
                     (@Y (car (date (date))))
                     ((setq X (format @Y)))
                     ((>= X 100)
                        (+ X
                           (* 100 (/ (car (date (date))) 100)) ) )
                     (NIL X) )
                  (nond
                     (@M (cadr (date (date))))
                     ((setq X (format @M)) 0)
                     ((n0 X) (cadr (date (date))))
                     (NIL X) )
                  @D ) ) ) ) ) )

# Day of the week
(de day (Dat Lst)
   (when Dat
      (get
         (or Lst *DayFmt)
         (inc (% (inc Dat) 7)) ) ) )

# Week of the year
(de week (Dat)
   (let W
      (-
         (_week Dat)
         (_week (date (car (date Dat)) 1 4))
         -1 )
      (if (=0 W) 53 W) ) )

(de _week (Dat)
   (/ (- Dat (% (inc Dat) 7)) 7) )

# Last day of month
(de ultimo (Y M)
   (dec
      (if (= 12 M)
         (date (inc Y) 1 1)
         (date Y (inc M) 1) ) ) )

### Time ###
(de $tim (S)
   (setq S (split (chop S) ":"))
   (unless (or (cdr S) (>= 2 (length (car S))))
      (setq S
         (list
            (head 2 (car S))
            (head 2 (nth (car S) 3))
            (nth (car S) 5) ) ) )
   (when (format (car S))
      (time @
         (or (format (cadr S)) 0)
         (or (format (caddr S)) 0) ) ) )

(de stamp (Dat Tim)
   (and (=T Dat) (setq Dat (date T)))
   (default Dat (date)  Tim (time T))
   (pack (dat$ Dat "-") " " (tim$ Tim T)) )

### I/O ###
(de chdir ("Dir" . "Prg")
   (let? "Old" (cd "Dir")
      (finally (cd "Old")
         (run "Prg") ) ) )

(de dirname (F)
   (let L (flip (chop F))
      (while (= "/" (car L))
         (++ L) )
      (pack (flip (member "/" L))) ) )

(de basename (F)
   (let L (flip (chop F))
      (while (= "/" (car L))
         (++ L) )
      (pack (stem (flip L) "/")) ) )

(de ssl ("Host" "Path" . "Prg")
   (in (list "@bin/ssl" "Host" 443 "Path")
      (and
         (tail '`(chop "200 OK") (line))
         (from "\r\n\r\n")
         (run "Prg") ) ) )

(de download (Host Src Dst)
   (let (F (tmp 'download)  Size)
      (in (list "@bin/ssl" Host 443 Src)
         (and
            (tail '`(chop "200 OK") (line))
            (from "Content-Length:")
            (setq Size (read))
            (from "\r\n\r\n")
            (out F (echo))
            (= Size (car (info F)))
            (=0 (%@ "rename" 'I F Dst)) ) ) ) )

# Print or eval
(de prEval ("Prg" "Ofs")
   (default "Ofs" 1)
   (for "X" "Prg"
      (if (atom "X")
         (prinl (eval "X" "Ofs"))
         (eval "X" "Ofs") ) ) )

# Echo here-documents
(de here (S)
   (line)
   (echo S) )

# Multiline Base64
(de prBase64 (N)
   (while
      (do N
         (NIL (ext:Base64 (rd 1) (rd 1) (rd 1)))
         T )
      (prinl) ) )

# Send mail
(de mail (Host Port From To Sub Att . Prg)
   (let? S
      (if (pair Port)
         (pipe (exec "@bin/ssl" Host (fin Port)))
         (connect Host Port) )
      (let B (pack "==" (date) "-" (time T) "-" (usec) "==")
         (prog1
            (and
               (pre? "220 " (in S (line T)))
               (out S (prinl "HELO " (cdr (member "@" (chop (fin From)))) "^M"))
               (pre? "250 " (in S (line T)))
               (or
                  (atom Port)
                  (and
                     (out S
                        (prin "AUTH PLAIN ")
                        (pipe
                           (prog
                              (prin (car Port))
                              (wr 0)
                              (prin (car Port))
                              (wr 0)
                              (prin (cadr Port)) )
                           (prBase64 T) )
                        (prinl "^M") )
                     (pre? "235 " (in S (line T))) ) )
               (out S (prinl "MAIL FROM:<" (fin From) ">^M"))
               (pre? "250 " (in S (line T)))
               (if (atom To)
                  (_rcpt To)
                  (find bool (mapcar _rcpt To)) )
               (out S (prinl "DATA^M"))
               (pre? "354 " (in S (line T)))
               (out S
                  (prinl "From: " (fin From) "^M")
                  (prinl "To: " (or (fin To) (glue "," To)) "^M")
                  (prin "Subject: ")
                  (ifn (find > (chop Sub) '("~" .))
                     (prinl Sub "^M")
                     (prin "=?utf-8?B?")
                     (pipe (prin Sub) (prBase64 T))
                     (prinl "?=^M") )
                  (when (pair From)
                     (prinl "Reply-To: " (car From) "^M") )
                  (prinl "User-Agent: PicoLisp^M")
                  (prinl "MIME-Version: 1.0^M")
                  (when Att
                     (prinl "Content-Type: multipart/mixed; boundary=\"" B "\"^M")
                     (prinl "^M")
                     (prinl "--" B "^M")
                     (unless (cadr Att)
                        (prinl "Content-Type: multipart/alternative; boundary=\"==" B "==\"^M")
                        (prinl "^M")
                        (prinl "--==" B "==^M") ) )
                  (prinl "Content-Type: text/plain; charset=utf-8^M")
                  (prinl "Content-Transfer-Encoding: 8bit^M")
                  (prinl "^M")
                  (prEval Prg 2)
                  (prinl "^M")
                  (when Att
                     (loop
                        (if (cadr Att)
                           (prinl "--" B "^M")
                           (prinl "--==" B "==^M") )
                        (prin "Content-Type: " (or (caddr Att) "application/octet-stream"))
                        (and (cadr Att) (prin "; name=\"" @ "\""))
                        (prinl "^M")
                        (prinl
                           "Content-Transfer-Encoding: "
                           (if (cadr Att) "base64" "8bit")
                           "^M" )
                        (prinl "^M")
                        (in (car Att)
                           (ifn (cadr Att)
                              (echo)
                              (prBase64 18)
                              (prinl) ) )
                        (prinl "^M")
                        (unless (cadr Att)
                           (prinl "--==" B "==--^M")
                           (prinl "^M") )
                        (NIL (setq Att (cdddr Att))) )
                     (prinl "--" B "--^M") )
                  (prinl ".^M")
                  (prinl "QUIT^M") )
               T )
            (close S) ) ) ) )

(de _rcpt (To)
   (out S (prinl "RCPT TO:<" To ">^M"))
   (pre? "250 " (in S (line T))) )

### Debug ###
#`*Dbg

# Replace from pilos/init/lib/misc.l

# Hex Dump
(de hd (Src Cnt)
   (if (and (str? Src) (abspath Src) (fetch NIL @))
      (in Src
         (let Pos 0
            (while
               (and
                  (nand Cnt (lt0 (dec 'Cnt)))
                  (make (do 16 (and (rd 1) (link @)))) )
               (_hd @) ) ) )
      (let Pos (or (num? Src) (hex Src))
         (do (or Cnt 1)
            (_hd
               (make
                  (for I 16
                     (link (ptr (+ Pos I -1))) ) ) ) ) ) ) )

(de _hd (L)
   (prin (pad 8 (hex Pos)) "  ")
   (inc 'Pos 16)
   (for N L
      (prin (pad 2 (hex N)) " ") )
   (space (inc (* 3 (- 16 (length L)))))
   (for N L
      (prin (if (>= 126 N 32) (char N) ".")) )
   (prinl) )
# 27dec20 Software Lab. Alexander Burger

(de task (Key . Prg)
   (nond
      (Prg (del (assoc Key *Run) '*Run))
      ((num? Key) (quit "Bad Key" Key))
      ((assoc Key *Run)
         (push '*Run
            (conc
               (make
                  (when (lt0 (link Key))
                     (link (+ (eval (++ Prg) 1))) ) )
               (ifn (sym? (car Prg))
                  Prg
                  (cons
                     (cons 'job
                        (cons
                           (lit
                              (make
                                 (while (atom (car Prg))
                                    (link
                                       (cons (++ Prg) (eval (++ Prg) 1)) ) ) ) )
                           Prg ) ) ) ) ) ) )
      (NIL (quit "Key conflict" Key)) ) )

(de timeout (N)
   (if2 N (assoc -1 *Run)
      (set (cdr @) (+ N))
      (push '*Run (list -1 (+ N) '(bye)))
      (del @ '*Run) ) )

(de tasks Task
   (task -2 (abs (run Task))  "Prg" Task
      (let (L (assoc @ *Run)  P (run "Prg"))
         (if2 (lt0 (car L)) (lt0 P)
            (set (cdr L) (abs P))            # (-2 111 ..) -> (-2 999 ..)
            (ifn P
               (task -2)
               (set L P)                     # (-2 999 ..) -> (7 ..)
               (con L (cddr L)) )
            (prog                            # (7 ..) -> (-2 999 ...)
               (set L -2)
               (con L (cons (abs P) (cdr L))) )
            (ifn P
               (task (car L))
               (set L P) ) ) ) ) )           # (3 ..) -> (7 ..)

(de abort ("N" . "Prg")
   (catch 'abort
      (alarm "N" (throw 'abort))
      (finally (alarm 0) (run "Prg")) ) )

(de macro "Prg"
   (run (fill "Prg")) )

(de later ("@Var" . "@Prg")
   (macro
      (task (pipe (pr (prog . "@Prg")))
         (setq "@Var" (in @ (rd)))
         (task (close @)) ) )
   "@Var" )

(de recur recurse
   (run (cdr recurse)) )

(de curry "Z"
   (let ("X" (++ "Z")  "Y" (++ "Z")  "P" (filter pat? "X"))
      (if2 "P" (diff "X" "P")
         (list "Y" (cons 'job (lit (env @)) (fill "Z" "P")))
         (cons "Y" (fill "Z" "P"))
         (list "Y" (cons 'job (lit (env @)) "Z"))
         (cons "Y" "Z") ) ) )

### Definitions ###
(de expr ("F")
   (set "F"
      (list '@ (list 'pass (box (getd "F")))) ) )

(de subr ("F")
   (set "F" (getd (cadadr (getd "F")))) )

(de undef ("X" "C")
   (when (pair "X")
      (setq  "C" (cdr "X")  "X" (car "X")) )
   (ifn "C"
      (prog1 (val "X") (set "X"))
      (prog1
         (cdr (asoq "X" (val "C")))
         (set "C"
            (delq (asoq "X" (val "C")) (val "C")) ) ) ) )

(de redef "Lst"
   (let ("Old" (car "Lst")  "New" (name "Old"))
      (set
         "New" (getd "Old")
         "Old" "New"
         "Old" (fill (cdr "Lst") "Old") )
      "New" ) )

(de sysdefs ("Sym" "Alt")
   (in (or "Alt" "@lib/sysdefs")
      (if (from (pack "\n[" "Sym" "]\n"))
         (while (and (skip) (<> "[" @))
            (def (read) (read)) )
         (quit "No sysdefs" "Sym") ) ) )

(de daemon ("X" . Prg)
   (prog1
      (nond
         ((pair "X")
            (or (pair (getd "X")) (expr "X")) )
         ((pair (cdr "X"))
            (method (car "X") (cdr "X")) )
         (NIL
            (method (car "X") (get (or (cddr "X") *Class) (cadr "X"))) ) )
      (con @ (append Prg (cdr @))) ) )

(de patch ("Lst" "Pat" . "Prg")
   (bind (fish pat? "Pat")
      (recur ("Lst")
         (loop
            (cond
               ((match "Pat" (car "Lst"))
                  (set "Lst" (run "Prg")) )
               ((pair (car "Lst"))
                  (recurse @) ) )
            (NIL (cdr "Lst"))
            (T (atom (cdr "Lst"))
               (when (match "Pat" (cdr "Lst"))
                  (con "Lst" (run "Prg")) ) )
            (setq "Lst" (cdr "Lst")) ) ) ) )

(de cache ("Var" "X" . "Prg")
   (let "K" (cons (char (hash "X")) "X")
      (nond
         ("Prg" (caar (idx "Var" "K")))
         ((setq "Var" (caar (idx "Var" "K" T)))
            (set (car "K") (run "Prg" 1)) )
         ((n== "Var" (val "Var"))
            (set "Var" (run "Prg" 1)) )
         (NIL (val "Var")) ) ) )

### I/O ###
(de tab (Lst . @)
   (for N Lst
      (let V (next)
         (and (gt0 N) (space (- N (length V))))
         (prin V)
         (and (lt0 N) (args) (space (- 0 N (length V)))) ) )
   (prinl) )

(de beep ()
   (prin "^G") )

(de msg (X . @)
   (out 2
      (print X)
      (pass prinl) )
   X )

(de script (File . @)
   (load File) )

(de once "Prg"
   (unless (idx '*Once (file) T)
      (run "Prg" 1) ) )

(de rc (File Key . @)
   (ctl File
      (in File
         (let Lst (read)
            (ifn (args)
               (cdr (assoc Key Lst))
               (let Val (next)
                  (loop
                     (if (assoc Key Lst)
                        (con @ Val)
                        (push 'Lst (cons Key Val)) )
                     (NIL (args))
                     (setq Key (next)  Val (next)) )
                  (protect
                     (out File (println Lst)) )
                  Val ) ) ) ) ) )

(de acquire (File)
   (ctl File
      (in File
         (let P (rd)
            (or
               (= P *Pid)
               (unless (and P (kill P 0))
                  (out File (pr *Pid)) ) ) ) ) ) )

(de release (File)
   (ctl File (out File)) )

# Temporary Files
(de tmp @
   (unless *Tmp
      (push '*Bye '(call "rm" "-r" *Tmp))
      (push '*Fork '(off *Tmp) '(del '(call "rm" "-r" *Tmp) '*Bye))
      (call "mkdir" "-p"
         (setq *Tmp (pack (path "~/.pil/tmp/") *Pid "/")) ) )
   (pass pack *Tmp) )

### String ###
(de pad (N Val)
   (pack (need N (chop Val) "0")) )

(de align (X . @)
   (pack
      (if (pair X)
         (mapcar
            '((X) (need X (chop (next)) " "))
            X )
         (need X (chop (next)) " ") ) ) )

(de center (X . @)
   (pack
      (if (pair X)
         (let R 0
            (mapcar
               '((X)
                  (let (S (chop (next))  N (>> 1 (+ X (length S))))
                     (prog1
                        (need (+ N R) S " ")
                        (setq R (- X N)) ) ) )
               X ) )
         (let S (chop (next))
            (need (>> 1 (+ X (length S))) S " ") ) ) ) )

### List ###
(de uniq (Lst)
   (let R NIL
      (filter
         '((X)
            (not (idx 'R (cons (hash X) X) T)) )
         Lst ) ) )

### Symbol ###
(de qsym "Sym"
   (cons (val "Sym") (getl "Sym")) )

(de loc (S X)
   (if (and (str? X) (= S X))
      X
      (and
         (pair X)
         (or
            (loc S (car X))
            (loc S (cdr X)) ) ) ) )

(de -symbols ()
   (symbols (cons (intern (opt)) (symbols))) )

(de private ()
   (symbols '(priv) (read)) )

(de local ()
   (symbols (list (car (symbols)))
      (read) ) )

(de export (Sym)
   (symbols (list (or Sym (cadr (symbols))))
      (read) ) )

(de import Lst
   (for Sym Lst
      (unless (== Sym (intern Sym T))
         (quit "Import conflict" Sym) ) )
   Lst )

### Date/Time ###
(de *mon . (jan feb mar apr may jun jul aug sep oct nov dec .))

(de dat$ (Dat C)
   (when (date Dat)
      (pack (car @) C (pad 2 (cadr @)) C (pad 2 (caddr @))) ) )

(de tim$ (Tim F)
   (when (setq Tim (time Tim))
      (pack (pad 2 (car Tim)) ":" (pad 2 (cadr Tim))
         (and F ":")
         (and F (pad 2 (caddr Tim))) ) ) )

(de datSym (Dat)
   (when (date Dat)
      (pack
         (pad 2 (caddr @))
         (get *mon (cadr @))
         (pad 2 (% (car @) 100)) ) ) )

### OOP ###
(de class Lst
   (let L (val (setq *Class (car Lst)))
      (def *Class
         (recur (L)
            (if (atom (car L))
               (cdr Lst)
               (cons (car L) (recurse (cdr L))) ) ) ) ) )

(de object ("Sym" "Val" . @)
   (putl "Sym")
   (def "Sym" "Val")
   (while (args)
      (put "Sym" (next) (next)) )
   "Sym" )

(de extend X
   (setq *Class (car X)) )

# Class variables
(de var X
   (if (pair (car X))
      (put (cdar X) (caar X) (cdr X))
      (put *Class (car X) (cdr X)) ) )

(de var: X
   (apply meta X This) )

### Math ###
(de scl ("N" . "Prg")
   (if "Prg"
      (let *Scl "N" (run "Prg"))
      (setq *Scl "N") ) )

# (Knuth Vol.2, p.442)
(de ** (X N)  # N th power of X
   (if (ge0 N)
      (let Y 1
         (loop
            (when (bit? 1 N)
               (setq Y (* Y X)) )
            (T (=0 (setq N (>> 1 N)))
               Y )
            (setq X (* X X)) ) )
      0 ) )

# Accumulate
(de accu ("Var" Key Val)
   (when Val
      (if (assoc Key (val "Var"))
         (con @ (+ Val (cdr @)))
         (push "Var" (cons Key Val)) ) ) )

### REPL ###
(de complete (S)
   (when S
      (setq "*Cmpl"
         (if (=T S)
            (list "   ")
            (conc
               (if (sub? "~" S)
                  (let
                     (L (split (chop S) "~")
                        N (pack (car L))
                        P (pack (cadr L)) )
                     (extract
                        '((X)
                           (and (pre? P X) (pack N "~" X)) )
                        (all (intern N)) ) )
                  (filter '((X) (pre? S X)) (all)) )
               (let P (rot (split (chop S) "/"))
                  (setq
                     S (pack (car P))
                     P (and (cdr P) (pack (glue "/" @) "/")) )
                  (extract
                     '((X)
                        (when (pre? S X)
                           (let F (pack P X)
                              (if (=T (car (info F)))
                                 (pack F "/")
                                 F ) ) ) )
                     (dir P T) ) ) ) ) ) )
   (pop '"*Cmpl") )

### Pretty Printing ###
(de pretty (X N)
   (setq N (abs (space (or N 0))))
   (while (and (pair X) (== 'quote (car X)))
      (prin "'")
      (++ X) )
   (cond
      ((atom X) (print X))
      ((memq (car X) '(de dm redef))
         (_pretty
            (spPrt (++ X))
            (spPrt (++ X))
            (prtty1 X N Z) ) )
      ((memq (car X) '(let let?))
         (_pretty
            (cond
               ((atom (car X))
                  (spPrt (++ X))
                  (prtty? (++ X) N) )
               ((>= 12 (size (car X)))
                  (prin " (")
                  (let Z (++ X)
                     (prtty2 Z NIL Z) )
                  (prin ")") )
               (T
                  (nlPrt N)
                  (prin "(")
                  (let Z (++ X)
                     (prtty2 Z (+ N 3) Z) )
                  (prin " )") ) )
            (prtty1 X N Z) ) )
      ((== 'for (car X))
         (_pretty
            (cond
               ((or (atom (car X)) (atom (cdar X)))
                  (spPrt (++ X))
                  (prtty? (++ X) N) )
               ((>= 12 (size (car X)))
                  (spPrt (++ X)) )
               (T
                  (nlPrt N)
                  (prtty0 (++ X) (+ 3 N)) ) )
            (prtty1 X N Z) ) )
      ((== 'if2 (car X))
         (_pretty
            (when (>= 12 (size (head 2 X)))
               (spPrt (++ X))
               (spPrt (++ X)) )
            (prtty1 X N Z) ) )
      ((memq (car X) '(while until do state finally co))
         (prtty3 X N) )
      ((>= 12 (size X))
         (ifn (memq (car X) '(set setq default))
            (print X)
            (prin "(")
            (let Z X
               (printsp (++ X))
               (prtty2 X NIL Z) )
            (prin ")") ) )
      ((memq (car X) '(=: use later recur tab new))
         (_pretty
            (space)
            (print (++ X))
            (prtty1 X N Z) ) )
      ((memq (car X) '(setq default))
         (_pretty
            (if (cdddr X)
               (prog
                  (nlPrt N)
                  (prtty2 X N Z) )
               (spPrt (++ X))
               (nlPrt1 (++ X) N) ) ) )
      ((memq (car X) '(T NIL ! if ifn when unless case casq with catch throw push bind job in out err ctl))
         (prtty3 X N) )
      (T (prtty0 X N)) ) )

(de _pretty "Prg"
   (prin "(")
   (let Z X
      (print (++ X))
      (run "Prg") )
   (prin " )") )

(de prtty0 (X N)
   (prin "(")
   (let Z X
      (pretty (++ X) (- -3 N))
      (prtty1 X N Z) )
   (prin " )") )

(de prtty1 (X N Z)
   (loop
      (NIL X)
      (T (== Z X) (prin " ."))
      (T (atom X) (prin " . ") (print X))
      (nlPrt1 (++ X) N) ) )

(de prtty2 (X N Z)
   (loop
      (print (++ X))
      (NIL X)
      (T (== Z X) (prin " ."))
      (T (atom X) (prin " . ") (print X))
      (if N
         (prtty? (++ X) N)
         (space)
         (print (++ X)) )
      (NIL X)
      (T (== Z X) (prin " ."))
      (T (atom X) (prin " . ") (print X))
      (if N
         (nlPrt N)
         (space 2) ) ) )

(de prtty3 (X N)
   (prin "(")
   (let Z X
      (print (++ X))
      (when (or (atom (car X)) (>= 12 (size (car X))))
         (spPrt (++ X)) )
      (when X
         (prtty1 X N Z)
         (space) ) )
   (prin ")") )

(de prtty? (X N)
   (ifn (or (atom X) (>= 12 (size X)))
      (nlPrt1 X N)
      (spPrt X) ) )

(de spPrt (X)
   (space)
   (print X) )

(de nlPrt (N)
   (prinl)
   (space (+ 3 N)) )

(de nlPrt1 (X N)
   (prinl)
   (pretty X (+ 3 N)) )

(de pp ("X" C)
   (let *Dbg NIL
      (pretty
         (if (or C (pair "X"))
            (cons 'dm "X"
               (if (pair "X")
                  (method (car "X") (cdr "X"))
                  (method "X" C) ) )
            (cons 'de "X" (val "X")) ) )
      (prinl)
      "X" ) )

(de show ("X" . @)
   (let *Dbg NIL
      (setq "X" (pass get "X"))
      (when (sym? "X")
         (print "X" (val "X"))
         (prinl)
         (maps
            '((X)
               (space 3)
               (if (atom X)
                  (println X)
                  (println (cdr X) (car X)) ) )
            "X" ) )
      "X" ) )

(de view (X Y)
   (let *Dbg NIL
      (if (=T Y)
         (let N 0
            (recur (N X)
               (when X
                  (recurse (+ 3 N) (cddr X))
                  (space N)
                  (println (car X))
                  (recurse (+ 3 N) (cadr X)) ) ) )
         (let Z X
            (loop
               (T (atom X) (println X))
               (if (atom (car X))
                  (println '+-- (++ X))
                  (print '+---)
                  (view
                     (++ X)
                     (append Y (cons (if X "|   " "    "))) ) )
               (NIL X)
               (mapc prin Y)
               (T (== Z X) (println '*))
               (println '|)
               (mapc prin Y) ) ) ) ) )

### Check ###
# Assertions
(de assert Prg
   (when *Dbg
      (let A (if (cdr Prg) (cons 'and Prg) (car Prg))
         (cons
            (list 'unless A
               (list 'quit "'assert' failed" (lit A)) ) ) ) ) )

# Unit tests
(de test ("Pat" . "Prg")
   (bind (fish pat? "Pat")
      (unless (match "Pat" (run "Prg"))
         (msg "Prg")
         (quit "'test' failed" "Pat") ) ) )

### Debug ###
#`*Dbg

#(and (info "~/.pil/rc") (load @@))

#(load "@lib/lint.l" "@lib/debug.l" "@lib/vip.l")

#(noLint 'pretty 'Z)
#(noLint '_pretty 'Z)
#{

  Bits

  assume LE
  
  default unsigned
  
  todo check overflow
  
}#

# https://stackoverflow.com/questions/8011700/how-do-i-extract-specific-n-bits-of-a-32-bit-unsigned-integer-in-c
(de ubfx (R B A)
  # a < b
  (>> A (& R (>> (- A) (- (>> (- (+ (- B A) 1)) 1) 1)))))

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


(def 'LF (char "^J"))
(def 'CR (char "^M"))

# tx fifo accept >= 1 byte
(de poll-tx-emp () (until (bit? (get LSR-BIT 'TX-GE1) (byte LSR))))

# rx fifo has >= 1 sym
(de poll-rx-ge1 () (until (bit? (get LSR-BIT 'RX-GE1) (byte LSR))))

(de rd ()  (poll-rx-ge1) (byte IO))

(de wr (B) (poll-tx-emp) (byte IO B))
(de wr-ch () (wr *Ch))

(de pr (S) (for C (chop S) (wr (char C))))

(de prl (S) (pr S) (wr LF))

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
      (prin (hex (byte (+ pico~*MBox (* 16 (dec Y)) (dec X)))) " "))
      (prinl)))

(de zero-buf () (for X (* 4 32) (ptr32 (+ pico~*MBox X) 0)))

(de madr ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 8))         # msg sz
  (ui* (+ pico~*MBox (* 4 1)) 0)               # msg req/res code
  (ui* (+ pico~*MBox (* 4 2)) MAC-ADDRESS)  # tag id
  (ui* (+ pico~*MBox (* 4 3)) 8)               # val buf sz
  (ui* (+ pico~*MBox (* 4 4)) 8)               # buf req/res code (see md)
  (ui* (+ pico~*MBox (* 4 5)) 0)               # zero buf
  (ui* (+ pico~*MBox (* 4 6)) 0)               # zero buf
  (ui* (+ pico~*MBox (* 4 7)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  # BE
  (list
    (hex (byte (+ pico~*MBox (* 4 5) 0)))
    (hex (byte (+ pico~*MBox (* 4 5) 1)))
    (hex (byte (+ pico~*MBox (* 4 5) 2)))
    (hex (byte (+ pico~*MBox (* 4 5) 3)))
    (hex (byte (+ pico~*MBox (* 4 5) 4)))
    (hex (byte (+ pico~*MBox (* 4 5) 5)))))


(de amem ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 8)) # This msg len
  (ui* (+ pico~*MBox (* 4 1)) 0) # REQ/RES
  (ui* (+ pico~*MBox (* 4 2)) ARM-MEMORY)
  (ui* (+ pico~*MBox (* 4 3)) 8) # req sz
  (ui* (+ pico~*MBox (* 4 4)) 8) # res sz
  (ui* (+ pico~*MBox (* 4 5)) 0)
  (ui* (+ pico~*MBox (* 4 6)) 0)
  (ui* (+ pico~*MBox (* 4 7)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ pico~*MBox (* 4 6))))
    (hex (ptr32 (+ pico~*MBox (* 4 5))))))


(de vmem ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 8)) # This msg len
  (ui* (+ pico~*MBox (* 4 1)) 0) # REQ/RES
  (ui* (+ pico~*MBox (* 4 2)) VC-MEMORY)
  (ui* (+ pico~*MBox (* 4 3)) 8) # req sz
  (ui* (+ pico~*MBox (* 4 4)) 8) # res sz
  (ui* (+ pico~*MBox (* 4 5)) 0)
  (ui* (+ pico~*MBox (* 4 6)) 0)
  (ui* (+ pico~*MBox (* 4 7)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ pico~*MBox (* 4 6))))
    (hex (ptr32 (+ pico~*MBox (* 4 5))))))

(de brev ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 7))            # msg len
  (ui* (+ pico~*MBox (* 4 1)) 0)                  # REQ
  (ui* (+ pico~*MBox (* 4 2)) BOARD-REVISION)  # tag ID
  (ui* (+ pico~*MBox (* 4 3)) 4)                  # val buf sz (for response)
  (ui* (+ pico~*MBox (* 4 4)) 4)                  # request/response code
  (ui* (+ pico~*MBox (* 4 5)) 0)
  (ui* (+ pico~*MBox (* 4 6)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ pico~*MBox (* 4 5))))))


(de bmod ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 7))            # msg len
  (ui* (+ pico~*MBox (* 4 1)) 0)                  # REQ
  (ui* (+ pico~*MBox (* 4 2)) BOARD-MODEL)  # tag ID
  (ui* (+ pico~*MBox (* 4 3)) 4)                  # val buf sz (for response)
  (ui* (+ pico~*MBox (* 4 4)) 4)                  # request/response code
  (ui* (+ pico~*MBox (* 4 5)) 0)
  (ui* (+ pico~*MBox (* 4 6)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ pico~*MBox (* 4 5))))))


(de frev ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 7))            # msg len
  (ui* (+ pico~*MBox (* 4 1)) 0)                  # REQ
  (ui* (+ pico~*MBox (* 4 2)) FIRMWARE-REVISION)  # tag ID
  (ui* (+ pico~*MBox (* 4 3)) 4)                  # val buf sz (for response)
  (ui* (+ pico~*MBox (* 4 4)) 4)                  # request/response code
  (ui* (+ pico~*MBox (* 4 5)) 0)
  (ui* (+ pico~*MBox (* 4 6)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ pico~*MBox (* 4 5))))))


(de bser ()

  (wait-wr)

  (zero-buf)

  (ui* (+ pico~*MBox (* 4 0)) (* 4 8)) # This msg len
  (ui* (+ pico~*MBox (* 4 1)) 0) # REQ/RES
  (ui* (+ pico~*MBox (* 4 2)) BOARD-SERIAL)
  (ui* (+ pico~*MBox (* 4 3)) 8) # req sz
  (ui* (+ pico~*MBox (* 4 4)) 8) # res sz
  (ui* (+ pico~*MBox (* 4 5)) 0)
  (ui* (+ pico~*MBox (* 4 6)) 0)
  (ui* (+ pico~*MBox (* 4 7)) TAG-END)

  (let R (| pico~*MBox CH-PRO-AV)
    (ptr32 WRITE1 R)
    (wait-rd R))

  (list
    (hex (ptr32 (+ pico~*MBox (* 4 6))))
    (hex (ptr32 (+ pico~*MBox (* 4 5))))))

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
      (= RESP (ui* (+ pico~*MBox (* 4 1))))))

(symbols '(pico))
(symbols '(gic pico))

(local)
(+Cpu
 init-cpu
 ia>
 eoi>)


(class +Cpu)
(dm T (P)

  (=: ctl    P)
  (=: pm     (+ P (hex "0004")))
  (=: bp     (+ P (hex "0008")))
  (=: ia     (+ P (hex "000C")))

  (=: eoi    (+ P (hex "0010")))
  (=: rp     (+ P (hex "0014")))
  (=: hppi   (+ P (hex "0018")))
  (=: abp    (+ P (hex "001C")))

  (=: aia    (+ P (hex "0020")))
  (=: aeoi   (+ P (hex "0024")))
  (=: ahppi  (+ P (hex "0028")))
  (=: ap0    (+ P (hex "00D0")))

  (=: ns-ap0 (+ P (hex "00E0")))
  (=: iid    (+ P (hex "00FC")))
  (=: di     (+ P (hex "1000")))

  (init> This))


(dm init> ()

  (ptr32 (: ctl) OFF-CTL)

  # Set the priority level as the lowest priority
  # Note: Higher priority corresponds to a lower Priority field value in the GIC_PMR.
  # In addition to this, writing 255 to the GICC_PMR always sets it to the
  # largest supported priority field value.
  (ptr32 (: pm) (hex "FF")) # "F0"

  # Handle all of interrupts in a single group
  (ptr32 (: bp) (hex "0"))

  # Clear all of the active interrupts
  (when NIL
    (let Pen-IRQ c # =255
      (while (not (= Pen-IRQ (hex "3FF")))
        (ptr32 (: eoi)
          (ptr32 (: ia)))
        (setq Pen-IRQ (& (ptr32 (: ia)) (hex "3FF"))))))

  (ptr32 (: ctl) ON-CTL))


(dm ia> (X)
  (if X
      (ptr32 (: ia) X)
      (ptr32 (: ia))))

(dm eoi> (X)
  (if X
      (ptr32 (: eoi) X)
      (ptr32 (: eoi))))


(dm di> (X)
  (if X
      (ptr32 (: di) X)
      (ptr32 (: di))))


(symbols '(pico))
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

    # Set lowest priority
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Pr (+ (: i-prio) O))
        (when (=0 (% N 4))
          (ptr32 Pr (hex "FFFFFFFF")))))

    # Set tgt of SPIs -> PE 0
    (for (N 0 (< N Max-Intr-ID) (inc N))
      (let (O (* 4 (/ N 4))
            Ta (+ (: i-tgts) O))
        (when (=0 (% N 4))
          (ptr32 Ta (hex "01010101")))))

    # Set trigger of SPIs -> level
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
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "03"))))
        Reg  (| Reg (>> (- Shft) X)))
    (ptr32 P Reg)))

# FIX
(dm i-prio> (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (: i-prio) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "FF"))))
        Reg  (| Reg (>> (- Shft) X)))
    (setq Reg (hex "00FFFFFF"))
    (ptr32 P Reg)))


(dm i-tgts> (Irq X)
  (let (Shft (* (% Irq 4) 8)
        P    (+ (: i-tgts) (* (/ Irq 4) 4))
        Reg  (& (ui* P) (bw-not (>> (- Shft) (hex "FF"))))
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
(symbols '(gic pico))

(local)
(ON-CTL OFF-CTL
 +Gic)

(def 'ON-CTL  (>> 0 1))
(def 'OFF-CTL (>> 0 0))

# abstract out and pass name
(de gicd-enab (Irq F)
  (ptr32
    (+ (get *Gic (if F "DIST-ISENABLER" "DIST-ICENABLER"))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

(de gicd-pend (Irq F)
  (ptr32
    (+ (get *Gic (if F "DIST-ISPENDR" "DIST-ICPENDR"))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

(de gicd-act (Irq F)
  (ptr32
    (+ (get *Gic (if F "DIST-ISACTIVER" "DIST-ICACTIVER"))
       (* (/ Irq 32) 4))
    (>> (- (% Irq 32)) 1)))

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
(symbols '(gic pico))

(local) 
(*IntrID

  CORE-N-HP-TIMER 
  CORE-N-V-TIMER  
  LEGACY-FIQn     
  CORE-N-PS-TIMER 
  CORE-N-PNS-TIMER
  LEGACY-IRQn     

  MAILBOX-0 
  MAILBOX-1 
  MAILBOX-2 
  MAILBOX-3 
  MAILBOX-4 
  MAILBOX-5 
  MAILBOX-6 
  MAILBOX-7 
  MAILBOX-8 
  MAILBOX-9 
  MAILBOX-10
  MAILBOX-11
  MAILBOX-12
  MAILBOX-13
  MAILBOX-14
  MAILBOX-15

  CORE-0-PMU 
  CORE-1-PMU 
  CORE-2-PMU 
  CORE-3-PMU 
  AXIERR     
  LOCAL-TIMER

  TIMER                 
  MAILBOX               
  DOORBELL-0            
  DOORBELL-1              
  VPU0-HALTED           
  VPU1-HALTED           
  ARM-ADDRESS-ERROR     
  ARM-AXI-ERROR           
  SOFTWARE-INTERRUPT-0  
  SOFTWARE-INTERRUPT-1  
  SOFTWARE-INTERRUPT-2  
  SOFTWARE-INTERRUPT-3    
  SOFTWARE-INTERRUPT-4  
  SOFTWARE-INTERRUPT-5  
  SOFTWARE-INTERRUPT-6  
  SOFTWARE-INTERRUPT-7

  TIMER-0          
  TIMER-1          
  TIMER-2          
  TIMER-3          
  H264-0           
  H264-1           
  H264-2           
  JPEG             
  ISP              
  USB              
  V3D              
  TRANSPOSER       
  MULTICORE-SYNC-0 
  MULTICORE-SYNC-1 
  MULTICORE-SYNC-2 
  MULTICORE-SYNC-3 
  DMA-0            
  DMA-1            
  DMA-2            
  DMA-3            
  DMA-4            
  DMA-5            
  DMA-6            
  DMA-7&8          
  DMA-9&10         
  DMA-11           
  DMA-12           
  DMA-13           
  DMA-14           
  AUX              
  ARM              
  DMA-15           
  HDMI-CEC         
  HVS              
  RPIVID           
  SDC              
  DSI-0            
  PIXEL-VALVE-2    
  CAMERA-0         
  CAMERA-1         
  HDMI-0           
  HDMI-1           
  PIXEL-VALVE-3    
  SPI/BSC-SLAVE    
  DSI-1            
  PIXEL-VALVE-0    
  PIXEL-VALVE-1&4  
  CPR              
  SMI              
  GPIO-0           
  GPIO-1           
  GPIO-2           
  GPIO-3           
  I2C-ALL          
  SPI-ALL          
  PCM/I2S          
  SDHOST           
  PL011-UART-ALL   
  ETH-PCIe-L2-ALL  
  VEC              
  CPG              
  RNG              
  EMMC&2           
  ETH-PCIe-SECURE  

  AVS         
  PCIE-0-INTA 
  PCIE-0-INTB 
  PCIE-0-INTC 
  PCIE-0-INTD 
  PCIE-0-MSI  
  GENET-0-A   
  GENET-0-B   
  USB0-XHCI-0)

# Source:
#
# Link: https://datasheets.raspberrypi.org/bcm2711/bcm2711-peripherals.pdf
#
# Sections:
# 6.3. GIC-400 interrupt controller, Figure 7. GIC IRQ routing
# 6.4. Legacy interrupt controller, Figure 9. Legacy IRQ status registers

(de *IntrID

  # Software Generated Interrupt (SGI) [0-15]
  # none
  
  # Per Processor Interrupts (PPI) [16-31]
  
  (CORE-N-HP-TIMER  . 26)  # hypervisor timer
  (CORE-N-V-TIMER   . 27)  # virtual timer
  (LEGACY-FIQn      . 28)
  (CORE-N-PS-TIMER  . 29)  # secure physical
  (CORE-N-PNS-TIMER . 30)  # non-secure physical
  (LEGACY-IRQn      . 31)

  # Shared Processor Interrupts [32-1020]
  
  ################################
  # Chapter 13. ARM Mailboxes [32-47]
  (MAILBOX-0  . 32)
  (MAILBOX-1  . 33)  
  (MAILBOX-2  . 34)  
  (MAILBOX-3  . 35)
  (MAILBOX-4  . 36)
  (MAILBOX-5  . 37)  
  (MAILBOX-6  . 38)  
  (MAILBOX-7  . 39)
  (MAILBOX-8  . 40)
  (MAILBOX-9  . 41)  
  (MAILBOX-10 . 42)  
  (MAILBOX-11 . 43)
  (MAILBOX-12 . 44)
  (MAILBOX-13 . 45)  
  (MAILBOX-14 . 46)  
  (MAILBOX-15 . 47)  
  ################################
  
  (CORE-0-PMU  . 48)
  (CORE-1-PMU  . 48)
  (CORE-2-PMU  . 48)
  (CORE-3-PMU  . 48)  
  (AXIERR      . 52)
  (LOCAL-TIMER . 53)
  
  ################################
  # ARMC Peripheral Interrupts [64-79]
  # 6.2.3. ARMC interrupts, Table 101. ARMC peripheral IRQs
  (TIMER                . 64)  
  (MAILBOX              . 65)  
  (DOORBELL-0           . 66)  
  (DOORBELL-1           . 67)    
  (VPU0-HALTED          . 68)  
  (VPU1-HALTED          . 69)  
  (ARM-ADDRESS-ERROR    . 70)  
  (ARM-AXI-ERROR        . 71)    
  (SOFTWARE-INTERRUPT-0 . 72)  
  (SOFTWARE-INTERRUPT-1 . 73)  
  (SOFTWARE-INTERRUPT-2 . 74)  
  (SOFTWARE-INTERRUPT-3 . 75)    
  (SOFTWARE-INTERRUPT-4 . 76)  
  (SOFTWARE-INTERRUPT-5 . 77)  
  (SOFTWARE-INTERRUPT-6 . 78)  
  (SOFTWARE-INTERRUPT-7 . 79)
  
  ################################
  # VC Peripheral Interrupts [96-159]
  # 6.2.4. VideoCore interrupts, Table 102. VC peripheral IRQs
  (TIMER-0          . 96)
  (TIMER-1          . 97)
  (TIMER-2          . 98)
  (TIMER-3          . 99)
  (H264-0           . 100)
  (H264-1           . 101)
  (H264-2           . 102)
  (JPEG             . 103)
  (ISP              . 104)
  (USB              . 105)
  (V3D              . 106)
  (TRANSPOSER       . 107)
  (MULTICORE-SYNC-0 . 108)
  (MULTICORE-SYNC-1 . 109)
  (MULTICORE-SYNC-2 . 110)
  (MULTICORE-SYNC-3 . 111)
  (DMA-0            . 112)
  (DMA-1            . 113)
  (DMA-2            . 114)
  (DMA-3            . 115)
  (DMA-4            . 116)
  (DMA-5            . 117)
  (DMA-6            . 118)
  (DMA-7&8          . 119)
  (DMA-9&10         . 120)
  (DMA-11           . 121)
  (DMA-12           . 122)
  (DMA-13           . 123)
  (DMA-14           . 124)
  (AUX              . 125) # UART1 + SPI1/2, Figure 6. Peripheral IRQ OR-ing
  (ARM              . 126)
  (DMA-15           . 127)
  (HDMI-CEC         . 128)
  (HVS              . 129)
  (RPIVID           . 130)
  (SDC              . 131)
  (DSI-0            . 132)
  (PIXEL-VALVE-2    . 133)
  (CAMERA-0         . 134)
  (CAMERA-1         . 135)
  (HDMI-0           . 136)
  (HDMI-1           . 137)
  (PIXEL-VALVE-3    . 138)
  (SPI/BSC-SLAVE    . 139)
  (DSI-1            . 140)
  (PIXEL-VALVE-0    . 141)
  (PIXEL-VALVE-1&4  . 142)
  (CPR              . 143)
  (SMI              . 144)
  (GPIO-0           . 145)
  (GPIO-1           . 146)
  (GPIO-2           . 147)
  (GPIO-3           . 148)
  (I2C-ALL          . 149) # [0-6], Figure 6. Peripheral IRQ OR-ing
  (SPI-ALL          . 150) # [0-7], Figure 6. Peripheral IRQ OR-ing
  (PCM/I2S          . 151)
  (SDHOST           . 152)
  (PL011-UART-ALL   . 153) # UART5/4/3/2/0, Figure 6. Peripheral IRQ OR-ing
  (ETH-PCIe-L2-ALL  . 154)
  (VEC              . 155)
  (CPG              . 156)
  (RNG              . 157)
  (EMMC&2           . 158)
  (ETH-PCIe-SECURE  . 159)
  
  ################################  
  # ARMC Peripheral Interrupts [160-216]
  # Unlisted IDs reserved
  (AVS         . `(+ 160 9)) # ...216
  (PCIE-0-INTA . `(+ 160 15))
  (PCIE-0-INTB . `(+ 160 16))
  (PCIE-0-INTC . `(+ 160 17))
  (PCIE-0-INTD . `(+ 160 18))
  (PCIE-0-MSI  . `(+ 160 20))
  (GENET-0-A   . `(+ 160 29))  
  (GENET-0-B   . `(+ 160 30))    
  (USB0-XHCI-0 . `(+ 160 48)))

(symbols '(pico))
(symbols '(timer pico))

(local)
(init pr start stop)

(de pr ()
  (prl-kern (text "cnt-frq @1"   (cnt-frq)))

  (prl-kern (text "cntv-ctl @1"  (cntv-ctl)))
  (prl-kern (text "cntv-cval @1" (cntv-cval)))
  (prl-kern (text "cntv-tval @1" (cntv-tval)))
  (prl-kern (text "cntvct @1"    (cntvct)))

  (prl-kern (text "cntp-ctl @1"  (cntp-ctl)))
  (prl-kern (text "cntp-cval @1" (cntp-cval)))
  (prl-kern (text "cntp-tval @1" (cntp-tval)))
  (prl-kern (text "cntpct @1"    (cntpct)))

  NIL)


(de init ()
  (with pico~*gic
    (let IrqID (get gic~*IntrID 'gic~CORE-N-V-TIMER)
      (gic~i-cfg>   (: gic~dist) IrqID gic~EDGE)
      (gic~i-prio>  (: gic~dist) IrqID (>> -4 0))
      (gic~i-tgts>  (: gic~dist) IrqID (hex "1")) # proc 0
      (gic~ic-pend> (: gic~dist) IrqID T)
      (gic~is-enab> (: gic~dist) IrqID T))))

(de start (N)

  (daif2)

  # status, mask, switch
  # unmask = on
  # mask = off/ignored
  (cntv-ctl 0)
  (isb)

  (println 'timer-start N)
  (cntv-cval (+ (cntvct) (* N (cnt-frq))))
  (isb)

  (cntv-ctl 1)
  (isb)

  (with pico~*gic
    (let IrqID (get gic~*IntrID 'gic~CORE-N-V-TIMER)
      (gic~ic-pend> (: gic~dist) IrqID T)
      (gic~is-enab> (: gic~dist) IrqID T)
      #(prl-kern (format (gic~ic-pend> (: gic~dist) 27)))
      #(prl-kern (format (gic~is-enab> (: gic~dist) 27)))
      ))

  (daif2 T)

  (pr)

  NIL)


(de stop ()

  (daif2)

  # status, mask, switch
  # unmask = on
  # mask = off/ignored
  (cntv-ctl 0)
  (isb)

  (cntv-cval 0)
  (isb)

  (with pico~*gic
    (let IrqID (get gic~*IntrID 'gic~CORE-N-V-TIMER)
      (gic~ic-pend> (: gic~dist) 27 T)
      (gic~ic-enab> (: gic~dist) 27 T)
      #(prl-kern (format (gic~ic-pend> (: gic~dist) 27)))
      #(prl-kern (format (gic~ic-enab> (: gic~dist) 27)))
      ))

  (daif2 T)

  (pr)

  NIL)


(symbols '(pico))
(symbols '(pico))

(de term ()

  # Terminal Emulator
  #
  # * set @, @@

  # Ctrl Chars
  #
  # DEL = 127 = "^?"
  # BS  = 8   = "^H"
  # ESC = 27  = "^["

  (pr-kern ": ")

  (loop
    (let E
          (catch '("")
            (repl)
            T)
      (unless (=T E)
        (do-err-repl E)))))


(de do-err-repl (E)
  (pr-kern "Catch! ")
  (println E ^)
  # reset buf, print prompt
  (off *buf-term)
  (pr-kern ": "))


(de repl ()

  (let? C (char (uart~rd))

    (case C

      ("^M" # enter key = CR
        (case-cr))

      ("^H" # bs
        (case-bs))


      ("^?" # del
        (when *buf-term
          (prin "^H ^H")
          (pop '*buf-term)))

      ("^[" # esc
        (case-esc))

      (T
        (prin C)
        (push '*buf-term C)))))


(de case-del ())


(de case-bs ()
  (when *buf-term
    (prin "^H ^H")
    (pop '*buf-term)))


(de case-cr ()
  (if *buf-term
      (prog
        (for E (str (pack (flip *buf-term)))
          (prinl)
          (let F (eval E)
            (pr-kern "-> ")  # make fn...
            (println F)))
        (off *buf-term))
      (prinl))
  (pr-kern ": "))


(de case-esc ()

  # https://en.wikipedia.org/wiki/ANSI_escape_code#Terminal_input_sequences
  # https://www.reddit.com/r/AskProgramming/comments/frln70/im_programming_an_arduino_to_run_a_vt100vt102/
  # see xterm

  (when (= (uart~rd) (char "[")) # CSI

    (case (char (uart~rd))

      ("D" # cur left
        (when *buf-term (prin "^H")))

      ("B" # cur down
        # history next
        T)

      ("A" # cur up
        # history prev
        T)

      ("C" # cur right
        # track len, then get from front
        T)

      # vt seq, followed by (char "~") -> 126
      ("3" # del = ESC [ 3 ~
        (uart~rd))

      ("1" # home
        (uart~rd))

      ("6" # pg dn
        (uart~rd))

      ("5" # pg up
        (uart~rd))

      ("F" # end
        (uart~rd))

      (T
        (prinl "CSI? " @ " " (uart~rd))))))
(symbols '(pico))

#{

    [24908182] Board Model: 0
    [25121743] Board Revision: C03112
    [25410831] Board Serial: 10000000 BA08938C
    [25712292] Firmware Revision: 5FF86CB4
    [26004380] ARM Memory Base/Size: 3B400000 0
    [26337306] VC Memory Base/Size: 4C00000 3B400000
    [26695736] MAC Address: DC-A6-32-9B-40-37
    [26916918]
    [26977889] cntv-ctl: 0
    [27086774] cntv-cval: 0
    [27201597] cntvct: 27196357
    [27338944] cnt-frq: 54000000
    [27471752]
    [27540543] PilOS 21.1.25 AArch64 ARMv8-A A64
    [27746104] Heap Size: 1 MB
    [28362097] Heap Free: 0 MB
    [28458391] Stack Size: 512 KB
    [28601545] *Kern Load Time: 21759131

}#

(de pr-mbox ()
  (prl-kern (pack "Board Model: "          (mbox~bmod)))
  (prl-kern (pack "Board Revision: "       (mbox~brev)))
  (prl-kern (pack "Board Serial: "         (let ((A B) (mbox~bser)) (pack A " " B))))
  (prl-kern (pack "Firmware Revision: "    (mbox~frev)))
  (prl-kern (pack "ARM Memory Base/Size: " (let ((B S) (mbox~amem)) (pack B " " S))))
  (prl-kern (pack "VC Memory Base/Size: "  (let ((B S) (mbox~vmem)) (pack B " " S))))
  (prl-kern (pack "MAC Address: "          (glue "-" (mbox~madr)))))


(de pr-sys ()
  (prl-kern (text "PilOS @1 AArch64 ARMv8-A A64" (glue "." (version T))))
  (prl-kern (text "Heap Size: @1 MB" (heap)))
  (prl-kern (text "Heap Free: @1 MB" (heap T)))
  (prl-kern (text "Co Stack Size: @1 KB" (stack 64)))
  (prl-kern (text "*Kern Load Time: @1" (usec))))


(de intr ()
  # pass num?
  (case *IntID
    (27
      (prl-kern (pack *IntID " Start timer..."))
      (timer~start 3))
    (T
      (prl-kern (format *IntID)))))

(de main ()

  # Switch input
  # TODO: mov to nsp - load very first
  #(setq *Putc '(uart~wr-ch))
  (setq *Putc uart~wr-ch)

  # Switch input to UART1 (mini UART)
  # On exit, set NIL to switch back to kern input
  (setq *Getc '(uart~rd))

  ################
  # print sys info

  (prinl)

  (setq *Int intr)

  (pr-mbox)

  (prl-kern)

  ##############
  # drivers

  (def '*gic
    (new '(gic~+Gic))) # (hex "FF840000")

  (timer~init)

  (prl-kern)

  ##########
  # preamble

  (pr-sys)

  (prl-kern)

  (timer~pr)

  (prl-kern)

  ###################
  # start term (repl)

  (term))


(main)
