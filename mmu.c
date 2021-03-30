// https://raw.githubusercontent.com/rust-embedded/rust-raspberrypi-OS-tutorials/master/doc/11_page_tables_64KiB.png

// http://classweb.ece.umd.edu/enee447.S2019/baremetal_boot_code_for_ARMv8_A_processors.pdf

// https://community.arm.com/developer/ip-products/processors/f/cortex-a-forum/5401/armv8-mmu-problem

// https://github.com/codingbelief/arm-architecture-reference-manual-for-armv8-a/blob/master/en/chapter_d4/d42_6_the_vmsav8-64_translation_table_format.md

// (for I 65030 (let P (>> -16 (dec I)) (prinl "[" (dec I) "] MMIO=" MMIO " P=" P ", " (hex P) " " (>= MMIO P))))

#include "gpio.h"
//#include "uart.h"
#include "mmu.h"

// descripts
#define PT_TABLE    0b11       // ==PT_PAGE
#define PT_PAGE     0b11
#define PT_BLOCK    0b01

// access
#define PT_KERNEL   (0<<6)    // >=EL1
#define PT_USER     (1<<6)    // >=EL0
#define PT_RW       (0<<7)
#define PT_RO       (1<<7)
#define PT_AF       (1<<10)   // accessed flag
#define PT_NX       (1UL<<54) // no exec

// share
#define PT_OSH      (2<<8)
#define PT_ISH      (3<<8)

// MAIR register
#define PT_MEM      (0<<2)    // normal
#define PT_DEV      (1<<2)    // device
#define PT_NC       (2<<2)    // non-cache

#define TTBR_CNP    1

// linker defined
extern volatile unsigned char _end;
unsigned long r;
volatile unsigned long *paging=(unsigned long*)&_end;


void mmu_map_stage1(void)
{

  // L2
  // 29 bits since start of level 2 index in VA
  // 8192 entries but need only ~10 since PA is 8GB
  for(r=0;r<8192;r++)
    paging[r]=(unsigned long)((r<<29))|PT_BLOCK|PT_AF|PT_KERNEL|((r==7)||(r==8) ? PT_OSH|PT_DEV : PT_ISH|PT_MEM);

  // Setup memory attributes array
  mmu_mair();

  // Setup tcr register
  mmu_tcr(0b11LL, // TG1:  64KB granule size
          22LL,   // T1SZ: 64-22 is 42 bits = 4 TB VA
          0b01LL, // TG0:  64KB granule size
          22LL);  // T0SZ: 64-22 is 42 bits = 4 TB VA

  // Set register to pt to first page table
  mmu_ttrbr0((unsigned long)&_end + TTBR_CNP);

  // Enable MMU
  mmu_sctrlr();

}


void mmu_map_stage2(void) {

  // VA = 42-bits so T0SZ = 22

  // L2
  // [41:29]
  // 8192 * 512MB per entry = 4TB per table
  // RAM never exceeds 4TB so one table needed
  // Entry -> 512 block or L3 table descriptor
  // N L2 entries = 8GB / 512MB = 16 entries
  for(r=0;r<16;r++)
    paging[r]=(unsigned long)((unsigned char*)&_end+((1+r)*65536))|PT_TABLE|PT_AF|PT_KERNEL|PT_ISH|PT_MEM;

  // L3
  // [28:16]
  // 8192 entries * 64KB per entry = 512MB per table
  // Each entry -> 64KB page descriptor (no block/table)
  // N L3 tables = 4096MB / 512MB = 8 tables
  for(r=0;r<(8192*16);r++)
    paging[8192+r]=(unsigned long)(r<<16)|PT_PAGE|PT_AF|PT_KERNEL|(r>=65024 ? PT_OSH|PT_DEV : PT_ISH|PT_MEM);

  // Setup memory attributes array
  mmu_mair();

  // Setup tcr register
  mmu_tcr(0b11LL, // TG1:  64KB granule size
          22LL,   // T1SZ: 64-22 is 42 bits = 4 TB VA
          0b01LL, // TG0:  64KB granule size
          22LL);  // T0SZ: ...

  // Set register to pt to L2
  mmu_ttrbr0((unsigned long)&_end + TTBR_CNP);

  // Enable MMU
  mmu_sctrlr();
}


void mmu_map_stage3(void)
{

  // 64KB granule = tables aligned to 65536 bytes
  // VA = 48-bits = T0SZ = 16
  // 64-bits per entry
  //
  // Level  VA     Entires  OA     Descriptor
  // L1     256TB  64       4TB    table page .....
  // L2     4TB    8192     512MB  ..... page block
  // L3     512MB  8192     64KB   ..... page .....

  // Total sz for all tables:
  //
  // (+ (* 1    64)
  //    (* 64   8192)
  //    (* 8192 8192)) = 67633216 B = 66048 KB = 64 MB

  // L1:
  // 1 table
  // 1 of 64 entries
  for(r=0;r<1;r++)
    paging[r]=(unsigned long)((unsigned char*)&_end+((1+r)*65536))|PT_TABLE|PT_AF|PT_KERNEL|PT_ISH|PT_MEM;

  // L2:
  // 8192MB/4TB = ~1 table
  // 8192MB/512MB = 16 entries
  for(r=0;r<16;r++)
    paging[8192+r]=(unsigned long)((unsigned char*)&_end+((2+r)*65536))|PT_TABLE|PT_AF|PT_KERNEL|PT_ISH|PT_MEM;

  // L3:
  // 8192MB/512MB = 16 tables
  // 8192MB/64KB = 131072 entries (16 tables @ 81972 entries each)
  for(r=0;r<(8192*16);r++)
    paging[(2*8192)+r]=(unsigned long)(r<<16)|PT_PAGE|PT_AF|PT_KERNEL|(r>=65024 ? PT_OSH|PT_DEV : PT_ISH|PT_MEM);

  // Setup memory attributes array
  mmu_mair();

  // Setup tcr register
  mmu_tcr(0b11LL, // TG1:  64KB granule size
          16LL,   // T1SZ: 64-16 is 48 bits = 256 TB VA
          0b01LL, // TG0:  64KB granule size
          16LL);  // T0SZ: ...

  // Set register to pt to first page table
  mmu_ttrbr0((unsigned long)&_end + TTBR_CNP);

  // Enable MMU
  mmu_sctrlr();

}


void mmu_mair(void) {
  r= (0xFF << 0) |    // 0: normal, IWBWA, OWBWA, NTR
     (0x04 << 8) |    // 1: device, nGnRE, OSH
     (0x44 << 16);    // 2: non-cache
  asm volatile ("msr mair_el1, %0" : : "r" (r));
}


void mmu_tcr(long long int TG1,
             long long int T1SZ,
             long long int TG0,
             long long int T0SZ)
{
  // TG1 and TG0 encodings differ:
  //
  // largegrain = TCR_EL1.TG0 == '01';
  // midgrain =   TCR_EL1.TG0 == '10';
  //
  // largegrain = TCR_EL1.TG1 == '11';
  // midgrain =   TCR_EL1.TG1 == '01';

  r= (0b00LL  << 37)| // TBI=0, no tag
     (0b101LL << 32)| // IPS Intermediate Physical Address Size; 48-bit, 256TB
     (TG1     << 30)| // TG1= 64KB granule size
     (0b11LL  << 28)| // SH1=3 Inner Shareable
     (0b01LL  << 26)| // ORGN1=1 Normal memory, Outer Write-Back Write-Allocate Cacheable
     (0b01LL  << 24)| // IRGN1=1 Normal memory, Inner Write-Back Write-Allocate Cacheable
     (0b0LL   << 23)| // EPD1=0 Perform translation table walk using TTBR1 or fault
     // [22] A1= Selects whether TTBR0 or TTBR1 defines the ASID
     (T1SZ    << 16)| // T1SZ
     // [15] Reserved, RES0
     (TG0     << 14)| // TG0= 64KB granule size
     (0b11LL  << 12)| // SH0=3 Inner Shareable
     (0b01LL  << 10)| // ORGN0=1 Normal memory, Outer Write-Back Write-Allocate Cacheable
     (0b01LL  << 8) | // IRGN0=1 Normal memory, Inner Write-Back Write-Allocate Cacheable
     (0b0LL   << 7) | // EPD0=0 Perform translation table walk using TTBR1 of fault
     // [7:6] Reserved, RES0
     (T0SZ    << 0);   // T0SZ

  asm volatile ("msr tcr_el1, %0; isb" : : "r" (r));
}


void mmu_ttrbr0(unsigned long r) {
  // TTBR_CNP bit required
  //
  // Typically VA split into lower/user and upper/kern (ttbr1_el1)
  // but only one neeeded

  asm volatile ("msr ttbr0_el1, %0" : : "r" (r));
}


void mmu_sctrlr(void) {

  asm volatile ("dsb ish; isb; mrs %0, sctlr_el1" : "=r" (r));

  r|=0xC00800;  // req res bits

  r&=~((1<<25)| // clr EE, LE-format tables
       (1<<24)| // clr E0E
       (1<<19)| // clr WXN
       (1<<12)| // clr I, no instr cache
       (1<<4) | // clr SA0
       (1<<3) | // clr SA
       (1<<2) | // clr C, no-cache
       (1<<1)); // clr A, no-align

  r|=  (1<<0); // set M, enable MMU

  asm volatile ("msr sctlr_el1, %0; isb" : : "r" (r));

}
