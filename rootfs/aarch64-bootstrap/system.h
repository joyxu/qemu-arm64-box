#ifndef SYSTEM_H
#define SYSTEM_H

#include <stdint.h>

// Data register of first UART (PL011)
#define UART0_DR		((volatile unsigned int *)(0x09000000))

#define msr(reg, value) \
	__asm("msr " reg ", %0" \
	    : : "r"(value) : "cc")

#define mrs(reg, value) \
	__asm("mrs %0, " reg \
	    : "=r"(value) : : "cc")

static inline void hvc(uint64_t func_id)
{
	__asm("ldr x0, %0\n"
	      "hvc #0"
	      : : "m"(func_id));
}

// Stop guest so Qemu terminates
static inline void system_off(void)
{
	hvc(0x84000008);
}

static inline void enable_simd()
{
	uint32_t cpacr = 3 << 20;
	msr("cpacr_el1", cpacr);
}

#endif // SYSTEM_H
