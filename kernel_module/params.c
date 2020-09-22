/*
Allows passing parameters at insertion time.

Those parameters can also be read and modified at runtime from /sys.

	insmod /params.ko
	# dmesg => 0 0
	cd /sys/module/params/parameters
	cat i
	# => 1 0
	printf 1 >i
	# dmesg => 1 0
	rmmod params

	insmod /params.ko i=1 j=1
	# dmesg => 1 1
	rmmod params

	modinfo
	/params.ko
	# Output contains MODULE_PARAM_DESC descriptions.

modprobe insertion can also set default parameters via the /etc/modprobe.conf file. So:

	modprobe params

Outputs:

	12 34
*/

#include <linux/delay.h> /* usleep_range */
#include <linux/kernel.h>
#include <linux/kthread.h>
#include <linux/module.h>
#include <uapi/linux/stat.h> /* S_IRUSR | S_IWUSR */

static int i = 0;
static int j = 0;
module_param(i, int, S_IRUSR | S_IWUSR);
module_param(j, int, S_IRUSR | S_IWUSR);
MODULE_PARM_DESC(i, "my favorite int");
MODULE_PARM_DESC(j, "my second favorite int");

static struct task_struct *kthread;

static int work_func(void *data)
{
	while (!kthread_should_stop()) {
		pr_info("%d %d\n", i, j);
		usleep_range(1000000, 1000001);
	}
	return 0;
}

static int myinit(void)
{
	kthread = kthread_create(work_func, NULL, "mykthread");
	wake_up_process(kthread);
	return 0;
}

static void myexit(void)
{
	kthread_stop(kthread);
}

module_init(myinit)
module_exit(myexit)
MODULE_LICENSE("GPL");
