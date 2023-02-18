#include <stdio.h>
#include <stdint.h>
#include "libymfm.h"


int main()
{
    printf("Hello World");
  
    uint32_t res;
    uint32_t clock = 8000;
    res = ymfm_add_chip(CHIP_YM2149, clock);

    return 0;
}