#include <stdint.h>
#include <stdbool.h>
#include <microkit.h>

int stuff = 3;

void init(void)
{
    microkit_dbg_puts("EMPTY: empty app started\n");
}

void notified(microkit_channel channel)
{
}