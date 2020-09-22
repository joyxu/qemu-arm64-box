/*
Also try on QEMU monitor:

	xp 0x<vaddr>

Only works for kmalloc.

static inline phys_addr_t virt_to_phys(volatile void *address)

- https://stackoverflow.com/questions/5748492/is-there-any-api-for-determining-the-physical-address-from-virtual-address-in-li
- https://stackoverflow.com/questions/43325205/can-we-use-virt-to-phys-for-user-space-memory-in-kernel-module
- https://stackoverflow.com/questions/39134990/mmap-of-dev-mem-fails-with-invalid-argument-but-address-is-page-aligned
*/

#include <asm/io.h> /* virt_to_phys */
#include <linux/debugfs.h>
#include <linux/delay.h> /* usleep_range */
#include <linux/kernel.h>
#include <linux/kthread.h>
#include <linux/module.h>
#include <linux/seq_file.h> /* single_open, single_release */
#include <linux/slab.h> /* kmalloc, kfree */

static volatile u32 *k;
static volatile u32 i;

static struct dentry *debugfs_file;

static int show(struct seq_file *m, void *v)
{
	seq_printf(m,
		"k 0x%llx\n"
		"addr_k %p\n"
		"virt_to_phys_k 0x%llx\n"
		"i 0x%llx\n"
		"addr_i %p\n"
		"virt_to_phys_i 0x%llx\n",
		(unsigned long long)*k,
		k,
		(unsigned long long)virt_to_phys((void *)k),
		(unsigned long long)i,
		&i,
		(unsigned long long)virt_to_phys((void *)&i)
	);
	return 0;
}

static int open(struct inode *inode, struct  file *file)
{
	return single_open(file, show, NULL);
}

static const struct file_operations fops = {
	.llseek = seq_lseek,
	.open = open,
	.owner = THIS_MODULE,
	.read = seq_read,
	.release = single_release,
};

static int myinit(void)
{
 	k = kmalloc(sizeof(k), GFP_KERNEL);
 	*k = 0x12345678;
 	i = 0x12345678;
	debugfs_file = debugfs_create_file(
		"lkmc_virt_to_phys", S_IRUSR, NULL, NULL, &fops);
	return 0;
}

static void myexit(void)
{
	debugfs_remove(debugfs_file);
	kfree((void *)k);
}

module_init(myinit)
module_exit(myexit)
MODULE_LICENSE("GPL");
