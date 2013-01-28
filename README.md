# Stream Looper
Marc Joliet <marcec@gmx.de>

## Introduction

Stream Looper is a simple looping program.  It continuously records an audio
stream into a buffer and loops an arbitrary contiguous region within it.  Stream
Looper is written in [FAUST](http://faust.grame.fr).

Originally, I had imagined it to be a sample based looper. I formulated the gist
of it as follows:

> Here's an idea: a simple sampler that has an adjustable auto-repeat and that
> syncs to a master beat, so you can control breakbeats with a knob. It should be
> able to load multiple samples and have one JACK output per sample.

Of course, by now I don't know what I meant by "auto-repeat". However, I suppose
I was writing about what is referred to as "Period" above. Anyhow, as
implemented it is obviously not a sampler.  It is probably best to instead
compile Stream Looper into an LV2 plug-in and load it into one of the many
pre-existing samplers/sequencers.

## Usage

As mentioned above, Stream Looper works by recording an input signal into an
internal buffer and looping within that buffer.  Playback never stops.  There
are two sliders to control the looping behaviour:

- "Period" sets the duration of the loop, and
- "Start" defines the loop's starting point from within the buffer.

Moving the "Start" slider around can produce an effect not unlike vinyl
scratching, with the difference that the buffer is constantly being played back.

Furthermore, there are two check boxes:

- "Bypass" bypasses the internal buffer and plays the input signal directly
- "Pause Recording", well, pauses recording so that you can play around with a
  static buffer.

## TODO

I still want to following features:

- Sync to beat, in which case the "Period" slider will function in terms of bars
  or similar small unit. Ideally, "Pause Recording" will wait until the bar is
  finished before pausing.
- Perhaps add a slider to control the amount of smoothing on the "Start" slider.
- Add LV2 and Pd support to the build system. Until then, use the faust2lv2 and
  faust2pd scripts that comes with FAUST.
