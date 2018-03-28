#ifndef EXCEPTION_H
#define EXCEPTION_H

#include <stdint.h>
#include "system.h"

// Exception Syndrome Register
#define ESR_ELx__EC_POS     (26U)
#define ESR_ELx__EC_MASK    (0x3f000000U)
#define ESR_ELx__IL_POS     (25U)
#define ESR_ELx__IL_MASK    (1 << 25)
#define ESR_ELx__ISS_MASK   (0x1ffffff)

static inline uint32_t current_el() {
	uint32_t el;
	mrs("CurrentEL", el);
	return (el >> 2) & 0x3;
}

#endif // EXCEPTION_H
