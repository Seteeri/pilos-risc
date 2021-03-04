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
  '(uart
    mbox))
  
(for X *nsp

  # create nsp/sym in pico (global)
  (symbols X 'pico)

  # ret top level
  (symbols '(pico)))
