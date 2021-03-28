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
