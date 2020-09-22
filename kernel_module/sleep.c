/*
Usage:

	insmod /sleep.ko
	rmmod sleep

dmesg prints an integer every second until rmmod.

Since insmod returns, this also illustrates how the work queues are asynchronous.
*/

#include <linux/delay.h> /* usleep_range */
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/types.h> /* atomic_t */
#include <linux/workqueue.h>

static struct workqueue_struct *queue;
static atomic_t run = ATOMIC_INIT(1);

static void work_func(struct work_struct *work)
{
	int i = 0;
	while (atomic_read(&run)) {
		pr_info("%d\n", i);
		usleep_range(1000000, 1000001);
		i++;
		if (i == 10)
			i = 0;
	}
}

static int myinit(void)
{
	DECLARE_WORK(work, work_func);
	queue = create_workqueue("myworkqueue");
	queue_work(queue, &work);
	return 0;
}

static void myexit(void)
{
	atomic_set(&run, 0);
	destroy_workqueue(queue);
}

module_init(myinit)
module_exit(myexit)
MODULE_LICENSE("GPL");
