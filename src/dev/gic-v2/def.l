(symbols '(gic pico))

(local)
(CTL-ON CTL-OFF)
 
# MOVE to GIC?
(def 'CTL-ON (>> 0 1))
(def 'CTL-OFF (>> 0 0))


(symbols '(pico))
