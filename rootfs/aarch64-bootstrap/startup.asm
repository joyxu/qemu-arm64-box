.extern stack_top
.globl _start
_start:
    # initialize Stack Pointer
	ldr x30, =stack_top
	mov sp, x30

    # relocate vector table
    adr x0, vectors
    msr vbar_el1, x0

	bl main

hang:
	b hang

vectors:
    .align  7
    b   _do_bad_sync    /* Current EL Synchronous Thread */

    .align  7
	b   _do_bad_irq		/* Current EL IRQ Thread */

    .align  7
	b   _do_bad_fiq		/* Current EL FIQ Thread */

    .align  7
    b   _do_bad_error   /* Current EL Error Thread */

    .align  7
	b   _do_sync		/* Current EL Synchronous Handler */

    .align  7
	b   _do_irq			/* Current EL IRQ Handler */

    .align  7
	b   _do_fiq			/* Current EL FIQ Handler */

    .align  7
	b   _do_error		/* Current EL Error Handler */


.extern exception_handler
_do_bad_sync:
_do_bad_irq:
_do_bad_fiq:
_do_bad_error:
_do_sync:
_do_irq:
_do_fiq:
_do_error:
    mrs x0, esr_el1
    bl exception_handler
