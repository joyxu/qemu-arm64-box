MYOBJ := $(addsuffix .o, $(notdir $(basename $(filter-out %.mod.c, $(wildcard $(PWD)/*.c)))))
ccflags-y := -DDEBUG -g -std=gnu99 -Werror -Wno-declaration-after-statement -Wframe-larger-than=1000000000

KERNEL_BUILD_DIR =
NO_BUILD = procfs.o mmap.o poll.o myprintk.o vermagic.o debugfs.o
obj-m := $(filter-out $(NO_BUILD), $(MYOBJ))

.PHONY: all clean

all:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M='$(PWD)' modules

clean:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M='$(PWD)' clean
