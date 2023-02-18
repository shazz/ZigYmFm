# build cpp library
zig c++ ./src/libymfm/ymfm_misc.cpp ./src/lbymfm/ymfm_opl.cpp ./src/lbymfm/ymfm_opm.cpp ./src/lbymfm/ymfm_opn.cpp ./src/lbymfm/ymfm_opq.cpp ./src/lbymfm/ymfm_opz.cpp ./src/lbymfm/ymfm_adpcm.cpp ./src/lbymfm/ymfm_pcm.cpp ./src/lbymfm/ymfm_ssg.cpp

# build zig app
zig build-exe src/main.zig -I ./src 