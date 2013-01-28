valid_faust_arches = (
    "sndfile",
    "pa-qt",
    "pa-gtk",
    "jack-qt",
    "jack-gtk",
    "puredata",
)

env_vars = Variables()
env_vars.AddVariables(
    EnumVariable("FAUST_ARCHITECTURE",
                 "The FAUST architecture",
                 "sndfile", valid_faust_arches),
    BoolVariable("osc", "Use Open Sound Control (OSC)", True),
    BoolVariable("openmp", "Use OpenMP pragmas", False),
    ("FAUST_FLAGS", "FAUST compiler flags"),
    ("CXX", "The C++ compiler")
)

env = Environment(tools=["default", "faust"],
                  variables=env_vars)

if env["FAUST_ARCHITECTURE"].endswith("qt"):
    env.Tool("qt4")

if env["osc"]:

    env.Append(
        CPPDEFINES = ["OSCCTRL"],
        CPPPATH = ["/usr/lib/faust"],
        LIBPATH = ["/usr/lib/faust"],
        # NOTE: The order matters!
        LIBS = ["OSCFaust", "oscpack"],
    )

if env["openmp"]:

    env.Append(
        CCFLAGS = ["-fopenmp"],
        FAUST_FLAGS = ["-omp"],
        LIBS = ["gomp"],
    )

if env["FAUST_ARCHITECTURE"] == "pa-qt":

    env.EnableQt4Modules(["QtGui", "QtCore"])
    faustqt = env.Moc4("faustqt", "/usr/include/faust/gui/faustqt.h")

    env.Append(LIBS = ["portaudio"])

if env["FAUST_ARCHITECTURE"] == "pa-gtk":

    env.MergeFlags(["!pkg-config --cflags-only-I gtk+-2.0"])
    env.Append(LIBS = ["portaudio", "gtk-x11-2.0"])

if env["FAUST_ARCHITECTURE"] == "jack-qt":

    env.EnableQt4Modules(["QtGui", "QtCore"])
    faustqt = env.Moc4("faustqt", "/usr/include/faust/gui/faustqt.h")

    env.Append(LIBS = ["jack"])

elif env["FAUST_ARCHITECTURE"] == "jack-gtk":

    # Use pkg-config to get the required include paths (includes some
    # unnecessary paths, but what the hell)
    env.MergeFlags(["!pkg-config --cflags-only-I gtk+-2.0"])
    env.Append(LIBS = ["jack", "gtk-x11-2.0"])

elif env["FAUST_ARCHITECTURE"] == "sndfile":

    env.Append(LIBS = ["sndfile"])

env.Append(CPPPATH   = [env["FAUST_PATH"],
                        "/usr/share/include"],
           CCFLAGS   = ["-O3", "-pedantic", "-march=native",
                        "-Wall", "-Wextra", "-Wno-unused-parameter"],
           CXXFLAGS  = ["-std=c++0x"],
           LINKFLAGS = ["-Wl,--as-needed"],
           FAUST_FLAGS = ["-mdoc", "-vec"],
          )

# parallelization flags
if env["CXX"] == "g++" and env["CXXVERSION"] >= "4.5":
    env.Append(CCFLAGS=[
        "-ftree-vectorize",
        # "-ftree-vectorizer-verbose=2",
        "-floop-interchange",
        "-floop-strip-mine",
        "-floop-block",
    ])

stream_looper_src = [env.Faust("stream_looper.dsp")]
if env["FAUST_ARCHITECTURE"] in ("jack-qt", "pa-qt"):
    stream_looper_src.append(faustqt)

if env["FAUST_ARCHITECTURE"] == "puredata":
    env.Append(CPPDEFINES = "mydsp=stream_looper")
    stream_looper = env.SharedLibrary(
        stream_looper_src,
        SHLIBPREFIX="",
        SHLIBSUFFIX="~.pd_linux"
    )
else:
    stream_looper = env.Program(stream_looper_src)

doc = env.PDF("stream_looper-mdoc/pdf/stream_looper.pdf",
              "stream_looper-mdoc/tex/stream_looper.tex")

env.Alias("stream_looper", stream_looper)
env.Alias("doc", doc)

Default("stream_looper")

env.Clean(stream_looper, "stream_looper-mdoc")
