declare name        "Rapid Looper";
declare version     "0.1";
declare author      "Marc Joliet";
declare license     "MIT";
declare copyright   "(c)Marc Joliet 2013";

import("filter.lib");

// constants
x0 = 0.0;
N  = 2<<14;

// UI control elements
P  = vslider("Period", N, 1, N, 1):int;
S  = vslider("Start", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
pause   = checkbox("Pause Recording");
bypass  = checkbox("Bypass");
sliders = hgroup("", P, S);

// write and read pointers
//
// When the "pause" checkbox is checked, the write pointer is set to N, which is
// outside of the read pointer range. This effectively pauses recording, i.e.
// makes the table static.
nw = pause, (+(1) ~ %(N) : -(1)), N : select2;
nr(P,S) = +(1) ~ %(min(N,P)) : -(1) : +(S) : %(N);

// the read/write table and its controls
rec_table = _, sliders : (N+1, x0, nw, _, nr : rwtable);

// If the "bypass" checkbox is checked, the table is bypassed and the input
// signal is just forwarded through.
table_select = _ <: bypass, rec_table, _ : select2;

process = table_select, table_select;
