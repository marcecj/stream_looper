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
S  = vslider("Start", 1, 1, N, 1):-(1):smooth(0.999):int;
pause   = checkbox("Pause");
bypass  = checkbox("Bypass");
sliders = hgroup("", P, S);

// write and read pointer
nx = pause, (+(1) ~ %(N) : -(1)), N : select2;
ny(P,S) = +(1) ~ %(min(N,P)) : -(1) : +(S) : %(N);

mytable = _,sliders : (N+1, x0, nx, _, ny : rwtable);

table_select = bypass, mytable, _ : select2;

process = (_ <: table_select), (_ <: table_select);
