#include "spinlock.h"


void spin_lock(slock* l) {
	register *arg1 asm("a0") = l;
	asm volatile(
		".set mips2 \n\t"
		"test_and_set: \n\t"
		"ADDIU $8, $0, 1 \n\t"
		"LL $9, 0($4) \n\t"
		"BNEZ $9, test_and_set \n\t"
		"SLL $0, $0, 0 \n\t"
		"SC $8, 0($4) \n\t"
		"BEQZ $8, test_and_set \n\t"
		"SLL $0, $0, 0 \n\t"
		: "=r" (arg1)
		);

}
void spin_unlock(slock* l) {
	register *arg1 asm("a0") = l;
	asm volatile(
		".set mips2\n\t"
		"SW $0, 0($4) \n\t"
		: "=r" (arg1)
		);
}
