(symbols '(pico))

(def *Errs
  '(
    # big.l
    "Div/0"

    # db.l
    "Bad DB file"
    "DB read: <ERRNO>"
    "DB write: <ERRNO>"
    "Bad Journal"
    "DB fsync error: <ERRNO>"
    "DB Oversize"
    "Bad ID"

    # flow.l
    "Bad message"
    "Bad super"
    "Bad extra"
    "Tag not found"
    "Reentrant coroutine"
    "Can't stop main routine"
    "No coroutines"
    "Coroutine not found"
    "Tag expected"
    "No Break"

    # io.l
    #"Open error: <ERRNO>"
    #"Close error: <ERRNO>"
    #"Pipe error: <ERRNO>"
    "Size overflow"
    "EOF Overrun"
    "Bad input <>"
    "Bad FD"
    #"Select error: <ERRNO>"
    "Bad dotted pair"
    "Super parentheses mismatch"

    # main.l
    "Stack overflow"
    "Bad argument"
    "Small number expected"
    "Number expected"
    "Symbol expected"
    "External symbol expected"
    "Name expected"
    "Atom expected"
    "Cons pair expected"
    "List expected"
    "Variable expected"
    "Item not found"
    "Protected"
    #"File lock: <ERRNO>"
    #"Can't fork"
    "Bad symbol namespace"
    "Undefined"

    # subr.l
    "Not making"))
