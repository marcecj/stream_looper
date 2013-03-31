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
Pp = vslider("Period [midi:ctrl 00]", N, 1, N, 1):int;
Rp = vslider("Period [midi:ctrl 02]", N, 1, N, 1):int;
Ps = vslider("Start [midi:ctrl 01]", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
Rs = vslider("Start [midi:ctrl 03]", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
pause  = checkbox("Pause Recording [midi:ctrl 04]");
bypass = checkbox("Bypass [midi:ctrl 05]");
limit_pp_by_rp = checkbox("Limit to Rec Period [midi:ctrl 06]");

// UI groups
recording_controls = hgroup("Recording", Rp, Rs);
playback_controls  = hgroup("Playback", Pp, Ps);
sliders = hgroup("", recording_controls, playback_controls);

// write and read pointers
//
// When the "pause" checkbox is checked, the write pointer is set to N, which is
// outside of the read pointer range. This effectively pauses recording, i.e.
// makes the table static.
shifted_counter(P1,P2,S) = +(1) ~ %(min(P1,P2)) : -(1) : +(S) : %(N);
nw(P,S) = pause, shifted_counter(P,P,S), N : select2;
nr(P,S) = P, select2(limit_pp_by_rp, P, (sliders:_,!,!,!)), S : shifted_counter;

// the read/write table and its controls
write_control = sliders : _,_,!,! : nw;
play_control  = sliders : !,!,_,_ : nr;
rec_table = N+1, x0, write_control, _, play_control : rwtable;

// If the "bypass" checkbox is checked, the table is bypassed and the input
// signal is just forwarded through.
table_select = _ <: bypass, rec_table, _ : select2;

process = table_select, table_select;
