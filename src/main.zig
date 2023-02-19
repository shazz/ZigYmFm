const std = @import("std");
const ymfm = @cImport({
    @cInclude("libymfm.h");
});
const emu2149 = @cImport({
    @cInclude("emu2149.h");
});
const emu76489 = @cImport({
    @cInclude("emu76489.h");
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

const dump_ym2149_b = @embedFile("assets/androids.ymr");
// const dump_sng_b = @embedFile("assets/sn76489_goemon.raw");
// const dump_sng_b = @embedFile("assets/sn76489_zeliard.raw");
const dump_sng_b = @embedFile("assets/sn76489_androids.raw");
// const dump_sng_b = @embedFile("assets/sn76489_gardia.raw");

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

pub fn play_libemu2149() !void {

    // create wav file
    const file = try std.fs.cwd().createFile(
        "libemu2149_q0.wav",
        .{ .read = true },
    );
    defer file.close();

    // Get a buffered writer to write in this file
    var buf_writer = std.io.bufferedWriter(file.writer());
    const writer = buf_writer.writer();    

    // create PSG
    // const psg: *emu2149.PSG = emu2149.PSG_new(2e6, 44100); //3579545
    var apsg: emu2149.PSG = undefined;
    const psg: * emu2149.PSG = &apsg;

    // Set clock 
    emu2149.PSG_setClock(psg, 2*2e6);
    emu2149.PSG_setRate(psg, 44100);
    emu2149.PSG_setClockDivider(psg, 1);

    // Set Volume mode in YM style and set sample converter quality
    emu2149.PSG_setVolumeMode(psg, 1);
    emu2149.PSG_setQuality(psg, 0);

    // reset
    emu2149.PSG_reset(psg);

    // counters for the YM dump file
    var counter: u64 = 0;
    var dump_loop: u32 = 0;
    var audio_buffer: [44100 / 50]i16 = undefined;

    // the YM dump file is composed of 50Hz frames capturing the first 14 YM2149 registers
    // loop on those frames
    while(dump_loop < dump_ym2149_b.len / 14) : (dump_loop += 1) {

        // write the 14 registers
        var i: u32 = 0;
        while( i < 14) : ( i += 1) {
            emu2149.PSG_writeReg(psg, i, @intCast(u32, dump_ym2149_b[counter]));
            counter += 1;
        }     

        // generate some sound for 50 Hz, so tick the YM (44100 / 50) times
        var tick: u32 = 0;
        while (tick < 44100 / 50) : ( tick += 1) {
            audio_buffer[tick] = emu2149.PSG_mono_calc(psg);
        }

         // write sample outputs to the file
        try writer.writeAll(std.mem.asBytes(&audio_buffer));       
        
        if(dump_loop % 1000 == 0) {
            std.debug.print("{} frames done\n", .{ dump_loop } );
        }

    }
    try buf_writer.flush();
} 

pub fn play_libymfm() !void {

    // Get YM2149 enum value, basically 0
    const ym2149: u16 = @enumToInt(ChipType.CHIP_YM2149);

    // create wav file
    const file = try std.fs.cwd().createFile(
        "libymfm2149.wav",
        .{ .read = true },
    );
    defer file.close();

    // Get a buffered writer to write in this file
    var buf_writer = std.io.bufferedWriter(file.writer());
    const writer = buf_writer.writer();    

    // add a YM2149, YM2149_clock == 
    // var sampling_rate: u32 = ymfm.ymfm_add_chip(ym2149, YM2149_clock);
    var sampling_rate: u32 = ymfm.ymfm_add_chip(ym2149, 2);

    std.debug.print("Sampling Rate: {} for master clock: {} Hz\n", .{ sampling_rate, YM2149_clock });
    std.debug.print("Dump length: {} 50Hz frames = {} seconds\n", .{ dump_ym2149_b.len / 14, dump_ym2149_b.len / 14 / 50 });
    std.debug.print("Ticks per frame: {}\n", .{ sampling_rate / 50 });

    // counters for the YM dump file
    var counter: u64 = 0;
    var dump_loop: u32 = 0;
    // var audio_buffer: [44100 / 50]u8 = undefined;

    // the YM dump file is composed of 50Hz frames capturing the first 14 YM2149 registers
    // loop on those frames
    while(dump_loop < dump_ym2149_b.len / 14) : (dump_loop += 1) {

        // write the 14 registers
        var i: u32 = 0;
        while( i < 14) : ( i += 1) {
            ymfm.ymfm_write(ym2149, 0, i, dump_ym2149_b[counter]);  
            counter += 1;
        }     

        // generate some sound for 50 Hz, so tick the YM (sampling_rate / 50) times
        // write every sample output to the file
        var tick: u32 = 0;
        var buffer: [2]i32 = undefined;
        while (tick < 44100 / 50) : ( tick += 1) {
            ymfm.ymfm_generate(ym2149, 0, &buffer);

            // store only left channel
            const slice = buffer[0]; 
            try writer.writeAll(std.mem.asBytes(&slice));  
        }
        // try writer.writeAll(std.mem.asBytes(&audio_buffer));       
        
        if(dump_loop % 1000 == 0) {
            std.debug.print("{} frames done\n", .{ dump_loop } );
        }

    }
    try buf_writer.flush();
}

pub fn play_libemu76489() !void {

    // create wav file
    const file = try std.fs.cwd().createFile(
        "libemu76489.wav",
        .{ .read = true },
    );
    defer file.close();

    // Get a buffered writer to write in this file
    var buf_writer = std.io.bufferedWriter(file.writer());
    const writer = buf_writer.writer();    

    // create SNG
    // const sng: *emu76489.SNG = emu76489.SNG_new(2e6, 44100); 
    var asng: emu76489.SNG = undefined;
    const sng: * emu76489.SNG = &asng;

    // Set clock 
    emu76489.SNG_set_clock(sng, 3579545);
    emu76489.SNG_set_rate(sng, 44100);

    // Set sample converter quality
    emu76489.SNG_set_quality(sng, 0);

    // reset
    emu76489.SNG_reset(sng);

    // counters for the YM dump file
    var counter: u64 = 0;
    var dump_loop: u32 = 0;
    var audio_buffer: [44100 / 50]i16 = undefined;

    std.debug.print("Dump length: {} 50Hz frames = {} seconds\n", .{ dump_sng_b.len / 11, dump_sng_b.len / 11 / 50 });
    // the YM dump file is composed of 50Hz frames capturing the 11 registers
    // loop on those frames
    while(dump_loop < dump_sng_b.len / 11) : (dump_loop += 1) {

        // write the 11 registers
        var i: u32 = 0;
        while( i < 11) : ( i += 1) {
            emu76489.SNG_writeIO(sng, @intCast(u32, dump_sng_b[counter]));
            counter += 1;
        }     

        // generate some sound for 50 Hz, so tick the YM (44100 / 50) times
        var tick: u32 = 0;
        while (tick < 44100 / 50) : ( tick += 1) {
            audio_buffer[tick] = emu76489.SNG_calc(sng);
            //emu76489.SNG_calc_stereo(sng, audio_buffer[tick]) ;
        }

         // write sample outputs to the file
        try writer.writeAll(std.mem.asBytes(&audio_buffer));       
        
        if(dump_loop % 1000 == 0) {
            std.debug.print("{} frames done\n", .{ dump_loop } );
        }

    }
    try buf_writer.flush();
} 

pub fn main() !void {

    // try play_libymfm();
    // try play_libemu2149();
    try play_libemu76489();

}
