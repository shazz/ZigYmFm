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

const YM2149_clock: u32 = 2e6;
const fYM2149_clock: f32 = @intToFloat(f32, YM2149_clock);
const Notes = enum(u16) {
	C = @floatToInt(u16, (fYM2149_clock / (16*130.81))),
	D = @floatToInt(u16, (fYM2149_clock / (16*146.83))),
	E = @floatToInt(u16, (fYM2149_clock / (16*164.81))),
	F = @floatToInt(u16, (fYM2149_clock / (16*174.61))),
	G = @floatToInt(u16, (fYM2149_clock / (16*196.00))),
	A = @floatToInt(u16, (fYM2149_clock / (16*220.00))),
	B = @floatToInt(u16, (fYM2149_clock / (16*246.94)))
};

// const dump_ym2149_b = @embedFile("assets/2149/thundercats.ymr");
// const dump_ym2149_b = @embedFile("assets/2149/androids.ymr");
const dump_ym2149_b = @embedFile("assets/2149/crazycomets2.ymr");


pub fn play_do(ym2149: u16) void {
  
    // ft = fmaster/(16TP)
    var fine_freq: u8 = @intCast(u8, @enumToInt(Notes.A) & 0xff );
    var rough_freq: u8 = @intCast(u8, @enumToInt(Notes.A) >> 8 );

    std.debug.print("Setting Channels frequency registers with : freq={} rough={} fine={}\n", .{ @enumToInt(Notes.A), rough_freq, fine_freq});

    // set channel A freq
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_A_FINE_FREQ), fine_freq);
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_A_ROUGH_FREQ), rough_freq);

    // set channel B freq
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_B_FINE_FREQ), fine_freq);
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_B_ROUGH_FREQ), rough_freq);

    // set channel C freq
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_C_FINE_FREQ), fine_freq);
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_C_ROUGH_FREQ), rough_freq);        

    // set channels level (only first 4 bits relevant)
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_A_LEVEL), 0xf);    
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_B_LEVEL), 0x0);    
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.CHANNEL_C_LEVEL), 0x0);    

    // set envelope shape to mostly flat
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.ENVELOPE_SHAPE), 0xd);   

    // enable channels
    ymfm.ymfm_write(ym2149, 0, @enumToInt(YM2149Registers.IO_MIXER_SETTINGS), 0xf8);   
}


pub fn play_libymfm() !void {

    // Get YM2149 enum value, basically 0
    const ym2149: u16 = @enumToInt(ChipType.CHIP_YM2149);

    // create wav file
    const file = try std.fs.cwd().createFile(
        "wav/libymfm2149.wav",
        .{ .read = true },
    );
    defer file.close();

    // Get a buffered writer to write in this file
    var buf_writer = std.io.bufferedWriter(file.writer());
    const writer = buf_writer.writer();    

    // add a YM2149, YM2149_clock == 
    // var sampling_rate: u32 = ymfm.ymfm_add_chip(ym2149, YM2149_clock);
    var sampling_rate: u32 = ymfm.ymfm_add_chip(ym2149, YM2149_clock);

    std.debug.print("Sampling Rate: {} for master clock: {} Hz\n", .{ sampling_rate, YM2149_clock });
    std.debug.print("Dump length: {} 50Hz frames = {} seconds\n", .{ dump_ym2149_b.len / 14, dump_ym2149_b.len / 14 / 50 });
    std.debug.print("Ticks per frame: {}\n", .{ sampling_rate / 50 });

    // counters for the YM dump file
    var counter: u64 = 0;
    var dump_loop: u32 = 0;
    var audio_buffer: [31250 / 50]i32 = undefined;
    var last_frame: [14]u8 = std.mem.zeroes([14]u8);

    // the YM dump file is composed of 50Hz frames capturing the first 14 YM2149 registers
    // loop on those frames
    while(dump_loop < dump_ym2149_b.len / 14) : (dump_loop += 1) {

        // write the 14 registers
        var i: u32 = 0;
        while( i < 14) : ( i += 1) {
            const reg_val:u8 = dump_ym2149_b[counter];
            if(reg_val != last_frame[i])
                ymfm.ymfm_write(ym2149, 0, i, reg_val);  

            counter += 1;
            last_frame[i] = reg_val;
        }     

        // generate some sound for 50 Hz, so tick the YM (sampling_rate / 50) times
        // write every sample output to the file
        var tick: u32 = 0;
        var buffer: [2]i32 = undefined;
        while (tick < sampling_rate / 50) : ( tick += 1) {
            ymfm.ymfm_generate(ym2149, 0, &buffer);

            // store only left channel
            // const slice = buffer[0]; 
            // try writer.writeAll(std.mem.asBytes(&slice));  
            audio_buffer[tick] = buffer[0];
        }
        try writer.writeAll(std.mem.asBytes(&audio_buffer));       
        
    if(dump_loop % 1000 == 0) {
            std.debug.print("{} frames done\n", .{ dump_loop } );
        }

    }
    try buf_writer.flush();
}