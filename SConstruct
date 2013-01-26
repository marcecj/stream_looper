env_vars = Variables()
env_vars.AddVariables(
    EnumVariable("FAUST_ARCHITECTURE",
                 "The Faust architecture",
                 "sndfile",
                 ["sndfile", "pa-qt", "pa-gtk", "jack-qt", "jack-gtk"]),
    BoolVariable("osc", "Use Open Sound Control (OSC)", False),
    BoolVariable("openmp", "Use OpenMP pragmas", False),
    ("FAUST_FLAGS", "Faust compiler flags"),
    ("CXX", "The C++ compiler")
)

env = Environment(tools=["default", "qt4", "faust"],
                  variables=env_vars)

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

rapid_looper_src = [env.Faust("rapid_looper.dsp")]
if env["FAUST_ARCHITECTURE"] in ("jack-qt", "pa-qt"):
    rapid_looper_src.append(faustqt)
rapid_looper = env.Program(rapid_looper_src)

doc = env.PDF("rapid_looper-mdoc/pdf/rapid_looper.pdf",
              "rapid_looper-mdoc/tex/rapid_looper.tex")

env.Alias("rapid_looper", rapid_looper)
env.Alias("doc", doc)

Default("rapid_looper")

env.Clean(rapid_looper, "rapid_looper-mdoc")
