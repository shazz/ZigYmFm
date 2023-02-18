const std = @import("std");
const ymfm = @cImport({
    @cInclude("libymfm.h");
});

const ChipType = enum(u16) {
    CHIP_YM2149 = 0,
    CHIP_YM2151 = 1,
    CHIP_YM2203 = 2,
    CHIP_YM2413 = 3,
    CHIP_YM2608 = 4,
    CHIP_YM2610 = 5,
    CHIP_YM2612 = 6,
    CHIP_YM3526 = 7,
    CHIP_Y8950 = 8,
    CHIP_YM3812 = 9,
    CHIP_YMF262 = 10,
    CHIP_YMF278B = 11,
};

const YM2149Registers = enum(u32) {
    CHANNEL_A_FINE_FREQ = 0,
    CHANNEL_A_ROUGH_FREQ = 1,
    CHANNEL_B_FINE_FREQ = 2,
    CHANNEL_B_ROUGH_FREQ = 3,
    CHANNEL_C_FINE_FREQ = 4,
    CHANNEL_C_ROUGH_FREQ = 5,
    CHANNEL_NOISE_FREQ = 6,
    IO_MIXER_SETTINGS = 7,
    CHANNEL_A_LEVEL = 8,
    CHANNEL_B_LEVEL = 9,
    CHANNEL_C_LEVEL = 10,
    ENVELOPE_FINE_FREQ = 11,
    ENVELOPE_ROUGH_FREQ = 12,
    ENVELOPE_SHAPE = 13,
    PORT_A_DATA = 14,
    PORT_B_DATA = 15
};

const AUDIO_BUFFER_SIZE = 2000;

pub fn main() void {

    const clock: u32 = 2000000;
    const chip_index: u16 = 0;
    var buffer: [AUDIO_BUFFER_SIZE]i32 = std.mem.zeroes([AUDIO_BUFFER_SIZE]i32);
    const ym2149: u16 = @enumToInt(ChipType.CHIP_YM2149);
    var data: u8 = 0;

    // add a YM2149
    var sampling_rate: u32 = ymfm.ymfm_add_chip(ym2149, clock);
    std.debug.print("Sampling Rate: {}\n", .{sampling_rate});

    
    // set channel A freq
    data = 0;
    ymfm.ymfm_write(ym2149, chip_index, @enumToInt(YM2149Registers.CHANNEL_A_FINE_FREQ), data);
    data = 10;
    ymfm.ymfm_write(ym2149, chip_index, @enumToInt(YM2149Registers.CHANNEL_A_ROUGH_FREQ), data);

    // set channel A level
    data = 15;
    ymfm.ymfm_write(ym2149, chip_index, @enumToInt(YM2149Registers.CHANNEL_A_LEVEL), data);    

    // generate some sound
    var tick:u16 = 0;
    while (tick < 100) : ( tick += 1) {
        ymfm.ymfm_generate(ym2149, chip_index, &buffer);

        var i: u16 = 0;
        while(i < 5) : ( i += 1) {
                std.debug.print("{} Buffer[{}]: {}\n", .{tick, i, buffer[i]});
        }
    }

}

