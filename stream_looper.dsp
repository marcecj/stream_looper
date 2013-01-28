declare name        "Stream Looper";
declare version     "0.1";
declare author      "Marc Joliet";
declare license     "MIT";
declare copyright   "(c)Marc Joliet 2013";

import("filter.lib");

// constants
x0 = 0.0;
N  = 2<<14;

// UI control elements
Pp = vslider("Period", N, 1, N, 1):int;
Rp = vslider("Period", N, 1, N, 1):int;
Ps = vslider("Start", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
Rs = vslider("Start", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
pause  = checkbox("Pause Recording");
bypass = checkbox("Bypass");

// UI groups
recording_controls = hgroup("Recording", Rp, Rs);
playback_controls  = hgroup("Playback", Pp, Ps);
sliders = hgroup("", recording_controls, playback_controls);

// write and read pointers
//
// When the "pause" checkbox is checked, the write pointer is set to N, which is
// outside of the read pointer range. This effectively pauses recording, i.e.
// makes the table static.
shifted_counter(P,S) = +(1) ~ %(P) : -(1) : +(S) : %(N);
nw(P,S) = pause, shifted_counter(P,S), N : select2;
nr(P,S) = shifted_counter(P,S);

// the read/write table and its controls
write_control = sliders : _,_,!,! : nw;
play_control  = sliders : !,!,_,_ : nr;
rec_table = N+1, x0, write_control, _, play_control : rwtable;

// If the "bypass" checkbox is checked, the table is bypassed and the input
// signal is just forwarded through.
table_select = _ <: bypass, rec_table, _ : select2;

process = table_select, table_select;
