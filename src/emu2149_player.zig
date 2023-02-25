const std = @import("std");
const emu2149 = @cImport({
    @cInclude("emu2149.h");
});

// const dump_ym2149_b = @embedFile("assets/2149/thundercats.ymr");
// const dump_ym2149_b = @embedFile("assets/2149/androids.ymr");
const dump_ym2149_b = @embedFile("assets/2149/crazycomets2.ymr");

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