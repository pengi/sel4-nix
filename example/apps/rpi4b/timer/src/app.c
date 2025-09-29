#include <stdint.h>
#include <stdbool.h>
#include <microkit.h>

typedef struct
{
    volatile uint32_t reserved[0x100];
    volatile uint32_t LOAD;
    volatile uint32_t VALUE;
    volatile uint32_t CONTROL;
    volatile uint32_t IRQCNTL;
    volatile uint32_t RAWIRQ;
    volatile uint32_t MSKIRQ;
    volatile uint32_t RELOAD;
    volatile uint32_t PREDIV;
    volatile uint32_t FREECNT;
} arm_timer_t;

arm_timer_t *reg_arm_timer;

static int count;

void init(void)
{
    /* 50MHz / 16 => 3125000 Hz */
    reg_arm_timer->LOAD = 3125000-1; /* 1sec */
    reg_arm_timer->CONTROL =
        (1 << 1) | /* 32 bit mode */
        (1 << 2) | /* prescale 16 */
        (1 << 5) | /* IE */
        (1 << 7);  /* ENABLE */

    microkit_dbg_puts("TIMER: timer app started\n");

    count = 0;
}

void notified(microkit_channel channel)
{
    microkit_dbg_puts("TIMER: notified ");
    microkit_dbg_put32(count);
    microkit_dbg_putc(' ');
    microkit_dbg_put32(channel);
    microkit_dbg_putc('\n');

    count++;

    switch (channel)
    {
    case 16:
        reg_arm_timer->IRQCNTL = 1; /* Clear interrupt */
        microkit_irq_ack(channel);
        break;
    }
}