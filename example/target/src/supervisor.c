
// Minimal seL4 root task with UART debug output for RISC-V
// Compile with:
//   riscv64-unknown-elf-gcc -nostdlib -static -o root_task root_task.c

#include <sel4/sel4.h>

/* UART base address for QEMU virt board (adjust for real hardware) */
#define UART_BASE 0x10000000U
/* UART registers (placeholders, use real addresses per platform) */
#define UART_THR (*(volatile unsigned long *)(UART_BASE + 0x00))
#define UART_LSR (*(volatile unsigned long *)(UART_BASE + 0x14))

/* Simple function to write a null-terminated string to UART */
static void uart_write(const char *s)
{
    const char *cur;
    for (cur = s; *cur != '\0'; cur++)
    {
        /* Wait until transmit holding register is empty */
        while ((UART_LSR & 0x20) == 0)
        {
        }

        UART_THR = *cur;
    }
}

int _start(void)
{
    // seL4_BootInfo *bootinfo = seL4_GetBootInfo();
    /* Print a simple message */
    uart_write("Root task started on RISC-V\n");

    while (1)
    {
        seL4_Yield();
    }
    return 0;
}
