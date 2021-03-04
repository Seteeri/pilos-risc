Design
======

* Primarily inspired by Lisp Machines and Symbolics
* Departs from mainstream OS
  * Focused on single users
    * Mainstream OS focused on production/enterprise driving development for those use cases ($$$)
  * No processes, single-address space
    * Mainstream OS based on Unix/C model due to history and C being
    "portable assembler"
  * Symbol oriented (versus file or object)
  * No compilation - only interpretation
  * Zero C code (almost)
* Designed for maximum hackability: consistency, correctiveness, cohesiveness, comprehensability
  * User and developer are not segregated - considered same entity so it becomes
  a matter of degree on the spectrum
  * Consider SBCL's 4 optimization flags: debug, speed, space, safety
    * Zepto metaphorically prioritizes hi-lo: debug, speed, safety/space
  * Follows same design objectives as PicoLisp:
    * Simple
    * Unlimited
    * Dynamic
    * Practical
  * Lies somewhere between Richard P. Gabriel's MIT and NJ approach to development - 
  [The Rise of Worse is Better](https://www.dreamsongs.com/RiseOfWorseIsBetter.html)
    * Simplicity - NJ
    * Correctness - MIT
    * Consistency - MIT
    * Completeness - MIT

It's not quite the same of course, but I like to imagine if Lisp Machines were
more widely accessible and available, and the internet was ubiquitous...imagine
the possibilites ;)

## Why PicoLisp

The entire stack above the interpreter is pure Lisp (below is asm).
All runtime data and higher level data structures are built out of cells. 

"A Radical Approach"

https://raw.githubusercontent.com/tj64/picolisp-works/master/editor.pdf

    ...For one thing (and not just from a philosophical point of view) a compiled
    Lisp program is no longer Lisp at all. It breaks the fundamental rule of
    “formal equivalence of code and data”. The resulting code does not consist
    of S-Expressions, and cannot be handled by Lisp.

    The source language (Lisp) was transformed to another language (machine
    code), with inevitable incompatibilities between different virtual machines.

    You understand that we are not really talking about “interpretation”. A Lisp
    system immediately converts all input to internal pointer structures called “S-
    Expressions”. True “interpretation” would deal with one-dimensional charac-
    ter codes, considerably slowing down the execution process. Lisp, however,
    “evaluates” the S-Expressions by quickly following these pointer structures.
    There are no searches or lookups involved, so nothing is really “interpreted”.
    But out of habit we’ll stick to that term.

    A Lisp program as an S-Expression forms a tree of executable nodes. The
    code in these nodes is typically written in optimized C or assembly, so the
    task of the interpreter is simply to pass control from one node to the other.
    Because many of those built-in lisp functions are very powerful and do a lot
    of processing, most of the time is spent in the nodes. The tree itself functions
    as a kind of glue.
    
