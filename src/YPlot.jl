module YPlot

export
    pli,
    plg,
    clf,
    fig,
    plt

# FIXME: There is a conflict between using Tk and Gtk backend, use Qt backend
# for now...
using PyCall
pygui(:qt); # can be: :wx, :gtk, :qt

using LaTeXStrings

import PyPlot
import PyPlot: clf
const plt = PyPlot;

plt.pygui(true)

"""
    fig()
or
    fig(f)
create a new plotting figure or select an existing figure.

"""
fig() = plt.figure()
fig(::Void) = plt.figure()
fig(f::Union{Integer,plt.Figure}) = plt.figure(f)

"""
     clf()

clears the current figure, while

     clf(f)

selects figure `f` and clears it.

"""
clf(::Void) = plt.clf()
clf(f::Union{Integer,plt.Figure}) = (plt.figure(f); plt.clf())


default_extent(width, height) = (0.5, width + 0.5, 0.5, height + 0.5)

"""
    pli(z; kwds...)

plots 2D array `z` as an *image*.  Available keywords are:

- `fig` specifies the figure to plot in, defaault is to use the last one.
- `clear` specifies whether to clear the figure before plotting, default is
  true.
- `min` and `max` specify the lower and upper values to plot.
- `cmap` specifies the colormap to use. Default is "viridis" (see
  http://matplotlib.org/examples/color/colormaps_reference.html
  for available colormaps).
- `cbar` specifies whether to add a color bar.
- `title`, `xlabel` and `ylabel` specify the plot title and axis labels.
- `interp` specifies the interpolation method.  By default, the nearest
  neighbor is used.
- `origin` specifies the origin of coordinates.
- `extent = (x0,x1,y0,y1)` specifies the coordinate ranges.  By default, the
  pixel indices are used.
"""
function pli{T}(z::AbstractArray{T,2};
                fig = nothing,
                clear::Bool = true,
                min = nothing, max = nothing,
                cmap = :viridis, interp = :nearest, origin = :lower,
                cbar::Bool = false,
                title::AbstractString = "",
                xlabel::AbstractString = "",
                ylabel::AbstractString = "",
                extent = default_extent(size(z)...))
    _preplot(fig, clear)
    plt.imshow(transpose(z), vmin=min, vmax=max, interpolation=interp,
               cmap=cmap, origin=origin, extent=extent)
    cbar && plt.colorbar()
    addtitles(title, xlabel, ylabel)
end

"""
    plg(x, y [, s]; kwds...)

plots 2D curve of `y` versus `x` using symbol/color `s`.  Available keywords
are:

- `fig` specifies the figure to plot in, defaault is to use the last one.
- `clear` specifies whether to clear the figure before plotting, default is
  false.
- `title`, `xlabel` and `ylabel` specify the plot title and axis labels.
- `linewidth` specifies the line width.
"""
function plg(x, y, s=nothing;
             fig = nothing,
             clear::Bool = false,
             linewidth::Real = 1,
             title::AbstractString = "",
             xlabel::AbstractString = "",
             ylabel::AbstractString = "")
    _preplot(fig, clear)
    plt.plot(x, y, s, linewidth=linewidth)
    addtitles(title, xlabel, ylabel)
end

_preplot(::Void, clear::Bool) = (clear &&  plt.clf(); nothing)
_preplot(fig::Union{Integer,plt.Figure}, clear::Bool) =
    (plt.figure(fig); clear &&  plt.clf(); nothing)

function addtitles(title::AbstractString, xlabel::AbstractString,
                   ylabel::AbstractString)
    length(title) > 0 && plt.title(title)
    length(xlabel) > 0 && plt.xlabel(xlabel)
    length(ylabel) > 0 && plt.ylabel(ylabel)
    nothing
end

# plt.gcf() # get current figure
# plt.gca() # get current axes
#
# plt.clf() # clear current figure
# plt.gla() # clear current axes
#
# plt.figure(n) # select figure number n
# plt.subplot(yxn) # select subplot n (y = number of rows, x = number of columns)
#
# plt.gcf()[:number] # yields figure number
#
# x = linspace(0,2*pi,1000); y = sin(3*x + 4*cos(2*x));
# plt.plot(x, y, color="firebrick", linewidth=2.0, linestyle="--");
# plt.title(L"A sinusoidally modulated sinusoid: $y = \sin(3\,x + 4 \cos(2\,x))$");
#
# fig1 = plt.imshow(img)
# fig2 = plt.contour(img)

end # module
