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
