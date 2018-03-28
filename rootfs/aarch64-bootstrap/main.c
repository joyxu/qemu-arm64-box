#include <stdint.h>
#include "system.h"
#include "exception.h"
#include "mini-printf.h"

static char charbuf[64];
#define printf(...) { \
	snprintf(charbuf, sizeof(charbuf), __VA_ARGS__); \
	char* s = charbuf; \
	while(*s != '\0') { \
	    *UART0_DR = (unsigned int)(*s++); \
	} \
} while(0)

void exception_handler(uint64_t esr)
{
	uint8_t ec = (esr & ESR_ELx__EC_MASK) >> ESR_ELx__EC_POS;
	printf("Exception class: 0x%02x\n", ec);

	uint8_t il = (esr & ESR_ELx__IL_MASK) >> ESR_ELx__IL_POS;
	printf("Instruction length: %d bit\n", (il ? 32 : 16));

	uint32_t iss = (esr & ESR_ELx__ISS_MASK);
    printf("Instruction spec. syndrome: 0x%05x\n", iss);

    system_off();
}

void init()
{
	// we'll receive an exception if GCC tries to access any SIMD register
	// before we haven't enabled SIMD
	enable_simd();
}

int main()
{
	init();
	printf("Current EL: %d\n", current_el());

	// terminate Qemu
	system_off();

	return 0;
}
