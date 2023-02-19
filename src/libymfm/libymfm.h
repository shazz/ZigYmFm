#include <stdint.h>

enum chip_type
{
    CHIP_YM2149,
    CHIP_YM2151,
    CHIP_YM2203,
    CHIP_YM2413,
    CHIP_YM2608,
    CHIP_YM2610,
    CHIP_YM2612,
    CHIP_YM3526,
    CHIP_Y8950,
    CHIP_YM3812,
    CHIP_YMF262,
    CHIP_YMF278B,
    CHIP_TYPES
};

uint32_t ymfm_add_chip(uint16_t chip_num, uint32_t clock);
void ymfm_write(uint16_t chip_num, uint16_t index, uint32_t reg, uint8_t data);
void ymfm_generate(uint16_t chip_num, uint16_t index, int32_t *buffer);
void ymfm_remove_chip(uint16_t chip_num);
void ymfm_add_rom_data(uint16_t chip_num, uint16_t access_type, uint8_t *buffer, uint32_t length, uint32_t start_address);

