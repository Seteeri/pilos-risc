PilOS
=====

This a PicoLisp OS inspired by [PilOS (x86-64)](https://picolisp.com/wiki/?PilOS) on AArch64 (aka arm64). It is based on pil21 (LLVM).

## Devices

The initial targets are based on what I have physically available:

* Raspberry Pi 4 4/8 GB models (64-bit mode)
  * 3rd edition 64-bit; previous editions only 32-bit
* PinePhone

## Setup

PilOS is currently cross-compiled on x86-64 so you can either build the toolchain or use prebuilt binaries from your distro or [Linaro](https://www.linaro.org/downloads/) (*aarch64-elf 	64-bit Armv8 Cortex-A, little-endian*). Compiling natively should simply call the binaries.

Once setup, ensure paths in ``arm64/make-arm64.l`` are correct (defaults to ``../../gcc-linaro-*-x86_64_aarch64-elf/bin``), and then build as normal ``(cd arm64; make)`` which will result in ``arm64.elf`` and ``kernel8.img`` (rpi boot default will look for the latter).

### Emulation (QEMU)

    qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial null -serial stdio

or:
    
    qemu-system-aarch64 -M virt -cpu cortex-a57 -nographic -kernel kernel8.elf -m 8192

### Raspberry Pi 4

1. Setup the memory card partition with the firmware provided by the foundation. The quick and dirty way is to download one of the OS [images](https://www.raspberrypi.org/software/operating-systems/), and replace ``kernel8.img``; otherwise, you can properly format the partitions using one of the guides. Unzip and write the raw img to the memory card:
  
  ``dd bs=1M if=2020-12-02-raspios-buster-armhf-lite.img of=/dev/sdX conv=fsync``
  
  **Replace "/dev/sdX" with the correct drive - ensure this is the right drive as everything will be overwritten!**
  
  * Guides
    * [s-matyukevich](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/docs/Prerequisites.md)
    * [bztsrc](https://github.com/bztsrc/raspi3-tutorial)
    * [isometimes](https://github.com/isometimes/rpi4-osdev)
  
2. Copy ``kernel8.img`` to the boot partition on the card (first partition) e.g. ``/dev/sdc1``.
  
3. Ensure ``config.txt`` has the following:
  
    ```
    arm_64bit=1
    uart_2ndstage=1
    core_freq_min=500
    ```

  * First line enables 64-bit mode causing bootloader to look for ``kernel8.img``
  * Second line enables boot debug info to UART
  * Third line maintains UART timing for 115200 baud rate
    
4. A USB to serial TTL cable is required such as from [adafruit](https://www.adafruit.com/product/954) which can then be used with ``screen`` or ``minicom``:

    dmesg:
    
    ```
    usb 1-10.4: new full-speed USB device number 29 using xhci_hcd
    usb 1-10.4: New USB device found, idVendor=10c4, idProduct=ea60, bcdDevice= 1.00
    usb 1-10.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
    usb 1-10.4: Product: CP2102 USB to UART Bridge Controller
    usb 1-10.4: Manufacturer: Silicon Labs
    usb 1-10.4: SerialNumber: 0001
    cp210x 1-10.4:1.0: cp210x converter detected
    usb 1-10.4: cp210x converter now attached to ttyUSB2
    ```
    
    run:
        
        screen /dev/ttyUSB2 115200

    or: 
        
        minicom -b 115200 -o -D /dev/ttyUSB2

## Resources    
    
### OS Dev

* Primary

  * [isometimes](https://github.com/isometimes/rpi4-osdev) (RPI4 tutorials)

  * [BrianSidebotham](https://github.com/BrianSidebotham/arm-tutorial-rpi) (RPI4 tutorials)
  
  * [NienfengYao](https://github.com/NienfengYao/armv8-bare-metal) (armv8 bare metal complete example) 
  
  * [sudharson14](https://github.com/sudharson14/xv6-OS-for-arm-v8) (xv6 edu OS)
  
  * [dwelch67](https://github.com/dwelch67/raspberrypi-three)
  
    * https://www.raspberrypi.org/forums/viewtopic.php?t=38076 (interrupts)
  
  * [rust-embedded](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials) (RPI4)  
  
  * [leiradel](https://github.com/leiradel/barebones-rpi)
    
    * [GitHub Page](https://leiradel.github.io/)
  
  * [Operating Systems: Three Easy Pieces](http://pages.cs.wisc.edu/~remzi/OSTEP/) (general OS arch)
  
* Secondary

  * [s-matyukevich](https://github.com/s-matyukevich/raspberry-pi-os) (RPI3 tutorials)

  * [bztsrc](https://github.com/bztsrc/raspi3-tutorial) (RPI3 tutorials)

  * [ashwio](https://github.com/ashwio/arm64-hypervisor-tutorial) (arm64 hypervisor)

  * [umanovskis1](https://github.com/umanovskis/baremetal-arm) (ARMv7)

  * [lowenware](https://github.com/lowenware/leos-kernel) (LeOS - rust)

  * [osdev](https://wiki.osdev.org/ARM_RaspberryPi_Tutorial_C) (RPI tutorial)

  * [jsandler18](https://jsandler18.github.io/tutorial/boot.html) (RPI2/3)
  
  * [NikosMouzakitis](https://github.com/NikosMouzakitis/Arm_generic/tree/master/06_output_input) (tidbits)

  * [embeddedartistry](https://github.com/embeddedartistry/libc) (bare metal lib for C)
  
  * https://events.static.linuxfound.org/sites/events/files/slides/KoreaLinuxForum-2014.pdf


### Lisp OS Projects/Ideas

* https://github.com/froggey/Mezzano (Common Lisp)

* https://github.com/mntmn/interim (Scheme-like, JIT)

  * http://dump.mntmn.com/interim-paper/
  * http://interim-os.com/
  * https://news.ycombinator.com/item?id=18202863

* https://luksamuk.codes/posts/lispm-001.html

* http://metamodular.com/lispos.pdf

  * https://news.ycombinator.com/item?id=19121443


### Lisp Machines

* http://fare.tunes.org/LispM.html

* https://news.ycombinator.com/item?id=835020


## miniPicoLisp (32-bit)

For 32-bit/embeded purposes, please see miniPicoLisp:

https://picolisp.com/wiki/?embedded

Fortunately, booting into a C library is a much more straight-forward process in conjunction with newlib etc.
