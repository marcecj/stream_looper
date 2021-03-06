# Stream Looper
Marc Joliet <marcec@gmx.de>

## Introduction

Stream Looper is a simple looping program.  It continuously records an audio
stream into a buffer and loops an arbitrary contiguous region within it.  Stream
Looper is written in [FAUST](http://faust.grame.fr).

I wrote this purely for fun and to try out the FAUST DSP language.  I do not
claim any originality here.  In fact, [Kluppe](http://kluppe.klingt.org)
implements the functionality of Stream Looper (in addition to loads of other
features) in a nice graphical way.  However, I did not want to develop a complex
application in the first place; I just wanted to try writing a simple stream
looper in FAUST.

Originally, I had imagined it to be a sample based looper. I formulated the gist
of it as follows:

> Here's an idea: a simple sampler that has an adjustable auto-repeat and that
> syncs to a master beat, so you can control breakbeats with a knob. It should be
> able to load multiple samples and have one JACK output per sample.

Of course, by now I don't know what I meant by "auto-repeat". However, I suppose
I was writing about what is referred to as "Period" below. Anyhow, as
implemented it is obviously not a sampler.  It is probably best to instead
compile Stream Looper into an LV2 plug-in and load it into one of the many
pre-existing samplers/sequencers.

## Compilation

You can either use the provided [SCons](http://scons.org) based build system,
whose invocation in this case is simply

    scons

The SCons build system will automatically pass appropriate options to the FAUST
compiler, such as `-vec` to produce auto-vectorisable code.  The default FAUST
architecture is jack-qt, see the output of `scons --help` for more information.

This relies on an externally available FAUST SCons tool that I found
[here](https://github.com/kaoskorobase/skUG/blob/master/site_scons/site_tools/faust.py).

Of course, you can always just use any of the myriad of `faust2*` scripts that
are distributed with FAUST.  This requires more knowledge of the FAUST options,
though (see `faust --help`).

## Usage

As mentioned above, Stream Looper works by recording an input signal into an
internal buffer and looping within that buffer.  Playback never stops.

### UI-independent Controls

FAUST can generate various types of programs, and they will share the same
controls, be it as command-line options, Pd messages, or graphical sliders.  The
following description holds for _all_ of them.

You can control two things: the way the loop is played, and the way it is
recorded.  Specifically, you control the region within the buffer in which the
read and write pointers loop.  In both cases, there there are two sliders to
control this behaviour, put into the groups "Recording" and "Playback":

- "Period" sets the duration of the loop, and
- "Start" defines the loop's starting point within the buffer.

Moving the "Playback/Start" slider around can produce an effect not unlike vinyl
scratching, with the difference that the buffer is constantly being played back.
The "Recording/Period" slider can be used to increase the rate at which the
playback loop changes.  The "Recording/Start" is a bit pointless, but can
produce glitch effects.  Usually you won't want to change it, but you can if you
want to.

Furthermore, there are three check boxes:

- "Bypass" bypasses the internal buffer and plays the input signal directly
- "Pause Recording", well, pauses recording so that you can play around with a
  static buffer ("Playback/Start" makes the most sense here).
- "Limit to Rec Period" limits the playback pointer period to the write pointer
  period.  This is so you can decrease the write pointer period and not have old
  material in the buffer start to play.

### OSC controls

Stream Looper can be controlled via OSC thanks to FAUST's built-in support.  You
can find the available addresses, their current values and their value range by
sending a `get` message to the wildcard address `/stream_looper/*`, which
yields:

    /stream_looper//Playback/Period 32768 1 32768
    /stream_looper//Playback/Start 1 1 32768
    /stream_looper//Recording/Period 32768 1 32768
    /stream_looper//Recording/Start 1 1 32768
    /stream_looper/Bypass 0 0 1
    /stream_looper/Limit_to_Rec_Period 1 0 1
    /stream_looper/Pause_Recording 0 0 1

NOTE for those who know FAUST: the double slashes in the first four addresses
arise from the use of an unnamed `hgroup()`.

### MIDI controls

In addition to the controls available via OSC, all of the parameters can be
controlled via MIDI CC messages, at least for the FAUST architectures that make
use of the UI element meta-data.  In FAUST version 0.9.58, these are, as far as
I can tell: dssi, lv2, lv2synth, ms-jack-gtk and vsti-mono.

The CC# to UI control mapping is:

- 0 maps to "Playback Period"
- 1 maps to "Playback Start"
- 2 maps to "Recording Period"
- 3 maps to "Recording Start"
- 4 maps to "Pause"
- 5 maps to "Bypass"
- 6 maps to "Limit to Rec Period"

### Logitech RumblePad &trade; 2 Pure Data UI

For my own use I wrote a Pd UI through which you can control Stream Looper with
a RumblePad 2 controller.  It has two variants:

1. One that uses Stream Looper as a Pd external, called `rumblepad_ui.pd`.  In
   this case, you must compile Stream Looper with `faust2puredata` or `scons
   FAUST_ARCHITECTURE=puredata ...` first before you can use it.  Technically
   you could also use `faust2pd`, if I understand it correctly, as the Pd object
   name stays the same, but it is superfluous for the purposes of this UI.
2. One called `rumblepad_osc_ui.pd` that communicates with Stream Looper via
   OSC, e.g., when compiled as a stand-alone JACK application.

The controller mappings are set up as follows:

- The left joystick controls "Period" for the playback (vertical axis) and
  recording group (horizontal axis).
- The right joystick controls "Start" for the playback (vertical axis) and
  recording group (horizontal axis).
- Button 1 switches "Pause Recording" on when held down.
- Button 2 toggles "Bypass" every time it is pressed.
- Button 3 toggles "Pause Recording" every time it is pressed.
- Button 4 toggles "Limit to Rec Period" every time it is pressed.
- Button 9 toggles whether the vertical axis of the right joystick is ignored.
- Button 10 toggles whether the horizontal axis of the right joystick is
  ignored.

"Pause Recording" and "Limit to Rec Period" are off by default, while "Bypass"
is on by default so that moving the joystick doesn't constantly change the
playback.  Also, since its effects are usually unwanted, the right joystick is
ignored by default.

## TODO

I still want the following features:

- Sync to beat, in which case the "Period" slider will function in terms of bars
  or similar unit. Ideally, "Pause Recording" will wait until the bar is
  finished before pausing.
- Perhaps add a slider to control the amount of smoothing on the "Start" slider.
- Add LV2 support to the build system. Until then, use the `faust2lv2` script
  that comes with FAUST.
- Fix the artifacts that arise when changing the write period. Possible
  solutions (disregarding implementation):
  - set both the read and write period to maximum as long as the slider is being
    held by the mouse
  - only update the write period once the pointer is at zero again
  - ...
  - Actually, I'm not sure anymore whether this is really a problem.
