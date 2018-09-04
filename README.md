# YPlot.jl

A very simple plotting package for Julia.  For now, the backend is
[PyPlot](https://github.com/stevengj/PyPlot.jl), the syntax is somewhat
reminiscent of Yorick.

The initial objective was to cope with the displaying 2D Julia arrays with axes
orientation and extent suitable for **matrix** (that is `A[i,j]` is indexed by
*row* `i` and *column* `j`) or **image** (that is `A[x,y]` is indexed by
*abscissa* index `x` and *ordinate* index `y`) conventions.

Example:

```julia
using YPlot
A = randn(4,7)
plmat(A, "As a matrix", "row index", "column index"; fig=1)
plimg(A, "As an image", "x", "y"; cbar=true, fig=2)
```

will display the 2D array 4×7 array `A` as a matrix in figure 1 and as an image
(with a color bar) in figure 2.


## Wish List

* Add a database of preferences (using a dictionary) which can be optionaly
  saved to the disk.  The backend should be part of the preferences.

* Add `plc` for plotting contours.


## Installation

```julia
using Pkg
Pkg.add("https://github.com/emmt/YPlot.jl")
```

### Using PyPlot with system MatPlotLib on Ubuntu

When installing [PyCall](https://github.com/JuliaPy/PyCall.jl) which is
required by PyPlot, if environment variable `PYTHON` is set to an empty string,
a custom Python installation based on
[Conda.jl](https://github.com/Luthaf/Conda.jl) is installed.  This can take
quite a bit of disk space (4-5 Gb in my case per version of Julia) and you may
prefer to use a version of MatPlotLib already installed on your system.  I
explain below how to do that on [Ubuntu](https://www.ubuntu.com/) (or similar
like [Linux-Mint](https://linuxmint.com/)) Linux distribution.

***Important*** As of Julia 1.0 and PyPlot 2.2.2, interaction with Python3 is
broken (it freezes the REPL until mouse moves into the graphic window) and
Gtk3Agg backend is broken with Python2.7 even with the `python-cairocffi`
Debian package (error message: *TypeError: Couldn't find foreign struct
converter for 'cairo.Context'*).  Hence, my recommandation is to **use Python
2.7 with Qt5Agg or Tk frontends**.  Perhaps Qt4Agg or WWAgg work but I did not
tried.

Install packages (depending on which version of Python you want to use, the two
can coexist but see my recommandations above):

```sh
sudo apt-get install python-matplotlib libpython-dev python-pyqt5
```

or

```sh
sudo apt-get install python3-matplotlib libpython3-dev python3-pyqt5
```

depending on which version of Python you want to use.

Instead of `python-pyqt5` (resp. `python3-pyqt5`), alternative Debian packages
are `python-qt4` (resp. `python3-pyqt4`) for using with QT4 toolkit and/or
`python-tk` (resp. `python3-tk`) to use Tcl/Tk.  The `*-dev` packages are
needed to have symbolic links `libpython*.so` in `/usr/lib/x86_64-linux-gnu`.
If symbolic links `libpython*.so` do not exists in `/usr/lib`, create them
(needed for `PyCall` build to find the Python library):

```sh
sudo ln -s x86_64-linux-gnu/libpython*.so /usr/lib
```

Now, in Julia install PyCall and PyPlot (see
[here](https://stackoverflow.com/questions/16675865/difference-between-python3-and-python3m-executables)
for the different Python versions on Ubuntu):

```julia
ENV["PYTHON"] = "/usr/bin/python2.7" # or "/usr/bin/python3.6m" or "/usr/bin/python3.6"
ENV["MPLBACKEND"] = "Qt5Agg"
using Pkg
Pkg.add("PyCall")
Pkg.add("PyPlot")
```

You can also define `ENV["PYTHON"]` and `ENV["MPLBACKEND"]` in `~/.juliarc.jl`
or in `~/.Julia/config/startup.jl` (depending on Julia version) to start Julia
with the correct Python path and MatPlotLib backend.

My own `~/.Julia/config/startup.jl` has the following lines:

```julia
ENV["PYTHON"] = "/usr/bin/python2.7"
ENV["MPLBACKEND"] = "Qt5Agg"
```

If you change `ENV["PYTHON"]`, re-build PyCall. Remember that defining
`ENV["PYTHON"]=""`, will install a custom Conda environment (which may be huge,
4-5 Gb for me).  If you change `ENV["MPLBACKEND"]`, just restart Julia (or make
the change before your first `import`/`using` of PyPlot).

In case of problems, to check which backend you are using:

```julia
using PyPlot
PyPlot.backend # yields backend name
PyPlot.gui     # yields toolkit name
```

MatPlotLib backends (see file `init.jl` in `PyPlot/src` directory, "*Agg*"
means anti-aliasing and case does not matter) are:

* WX, WXAgg
* GTK, GTKAgg, GTKCairo
* GTK3, GTK3Agg, GTK3Cairo
* Qt4Agg, QT5Agg
* TkAgg
