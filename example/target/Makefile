SEL4?=../../result-3
TARGETPREFIX?=riscv64-none-elf-

CFLAGS=\
	-I $(SEL4)/libsel4/include

CC=$(TARGETPREFIX)gcc

OBJS=\
	obj/supervisor.o

LIBS=\
	$(SEL4)/bin/kernel.elf

app.elf: $(OBJS)
	$(CC) -o $@ $^ $(LIBS)

obj/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -o $@ $^