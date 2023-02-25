const std = @import("std");
const emu2413 = @cImport({
    @cInclude("emu2413.h");
});

pub fn play_libemu2413() !void {

    // create wav file
    const file = try std.fs.cwd().createFile(
        "libemu2413.wav",
        .{ .read = true },
    );
    defer file.close();

    // Get a buffered writer to write in this file
    var buf_writer = std.io.bufferedWriter(file.writer());
    const writer = buf_writer.writer();    

    // create SNG
    const msx_clk: u32 = 3579545;
    const sample_rate: u32 = 44100;
    const datalength: u32 = sample_rate * 8;

    const opll: *emu2413.OPLL = emu2413.OPLL_new(msx_clk, sample_rate);
    // var aopll: emu2413.OPLL = undefined;
    // const opll: *emu2413.OPLL = &aopll;

    // Set clock 
    // emu2413.OPLL_reset(opll);

    // Set instrument
    emu2413.OPLL_writeReg(opll, 0x30, 0x30); // select PIANO Voice to ch1.
    emu2413.OPLL_writeReg(opll, 0x10, 0x80); // set F-Number(L).
    emu2413.OPLL_writeReg(opll, 0x20, 0x15); // set BLK & F-Number(H) and keyon.

    var wave_buffer: [datalength]i16 = undefined; //std.mem.zeroes([datalength]i16);

    var i: usize = 0;
    while (i < datalength) : ( i += 1) {

        wave_buffer[i] = emu2413.OPLL_calc(opll);
        std.debug.print("{} frame generated\n", .{ i } );
    }
    
    try writer.writeAll(std.mem.asBytes(&wave_buffer));
    try buf_writer.flush();
} 