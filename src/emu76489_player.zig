const std = @import("std");
const emu76489 = @cImport({
    @cInclude("emu76489.h");
});

// const dump_sng_b = @embedFile("assets/76489/sn76489_goemon.raw");
// const dump_sng_b = @embedFile("assets/76489/sn76489_zeliard.raw");
const dump_sng_b = @embedFile("assets/76489/sn76489_androids.raw");
// const dump_sng_b = @embedFile("assets/76489/sn76489_gardia.raw");
// const dump_sng_b = @embedFile("assets/76489/sn76489_badapple.raw");

pub fn play_libemu76489() !void {

    // create wav file
    const file = try std.fs.cwd().createFile(
        "wav/libemu76489.wav",
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
    // emu76489.SNG_set_clock(sng, 4e6);
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