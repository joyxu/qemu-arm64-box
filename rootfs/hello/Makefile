CROSS_COMPILE=aarch64-linux-gnu-
CC=$(CROSS_COMPILE)gcc
AS=$(CROSS_COMPILE)as
LD=$(CROSS_COMPILE)ld

ODIR=../obj
APPNAME=hello

_OBJ = hello.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))


$(ODIR)/%.o: %.asm
	$(AS) -o $@ $^

$(ODIR)/$(APPNAME): $(OBJ)
	$(LD) -o $@ $^

all: $(APPNAME)

.PHONY: clean all

clean:
	rm -f $(ODIR)/*.o $(ODIR)/$(APPNAME)
