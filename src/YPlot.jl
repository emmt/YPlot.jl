module YPlot

export
    pli,
    plimg,
    plimg!,
    plmat,
    plmat!,
    plg,
    clf,
    fig

using Compat
using PyCall
using LaTeXStrings

import PyPlot
import PyPlot: clf
const plt = PyPlot;

#plt.pygui(true)

abstract type Origin end
struct OriginUpper  <: Origin end
struct OriginLower <: Origin end

origintype(val::AbstractString) =
    (val == "upper" ? OriginUpper :
     val == "lower" ? OriginLower :
     throw(ArgumentError("invalid value \"$val\" for origin")))

origintype(val::Symbol) =
    (val == :upper ? OriginUpper :
     val == :lower ? OriginLower :
     throw(ArgumentError("invalid value `:$val` for origin")))


# Defaults settings for images and matrices.

image_extent(::Type{T}, width::Integer, height::Integer) where {T<:Origin} =
    extent(T, 0.5, width + 0.5, 0.5, height + 0.5)

image_extent(org::Union{Symbol,AbstractString}, args...) =
    image_extent(origintype(org), args...)

image_extent(::Type{T}, A::AbstractMatrix) where {T<:Origin} =
    image_extent(T, size(A))

image_extent(::Type{T}, dims::NTuple{2,Integer}) where {T<:Origin} =
    image_extent(T, dims...)

image_origin() = :lower
image_aspect() = :equal

matrix_extent(::Type{T}, nrows, ncols) where {T<:Origin} =
    extent(T, 0.5, ncols + 0.5, 0.5, nrows + 0.5)

matrix_extent(org::Union{Symbol,AbstractString}, args...) =
    matrix_extent(origintype(org), args...)

matrix_extent(::Type{T}, A::AbstractMatrix) where {T<:Origin} =
    matrix_extent(T, size(A))

matrix_extent(::Type{T}, dims::NTuple{2,Integer}) where {T<:Origin} =
    matrix_extent(T, dims...)

matrix_origin() = :upper
matrix_aspect() = :equal

extent(::Type{OriginLower}, xmin::Real, xmax::Real, ymin::Real, ymax::Real) =
    (xmin, xmax, ymin, ymax)

extent(::Type{OriginUpper}, xmin::Real, xmax::Real, ymin::Real, ymax::Real) =
    (xmin, xmax, ymax, ymin)

"""
```julia
plmat( A [title,] [ylabel, xlabel,]; kwds...)
plmat!(A [title,] [ylabel, xlabel,]; kwds...)
plimg( A [title,] [xlabel, ylabel,]; kwds...)
plimg!(A [title,] [xlabel, ylabel,]; kwds...)
```

plot the 2D array `A` as a *matrix* (`plmat` and `plmat!`) or as an *image*
(`plimg` and `plimg!`).

The `plmat` and `plmat!` methods use defaults for the axis extent and
orientation suitable for a matrix; while the `plimg` and `plimg!` methods use
defaults suitable for an image.

The `plmat!` and `plimg!` methods plot over the existing figure; while `plmat`
and `plimg` methods clear the figure before plotting.

Keywords:

- `fig` specifies the figure to plot in.  Default is to use the last one.

- `clear` specifies whether to clear the figure before plotting.  Default is
  `false` for `plmat!` and `plimg!` and `true` for `plmat` and `plimg`.

- `min` and `max` specify the lower and upper values to plot.

- `cmap` specifies the colormap to use.  Default is `"viridis"` (see
  http://matplotlib.org/examples/color/colormaps_reference.html for available
  colormaps).

- `cbar` specifies whether to add a color bar.  Default is `false`.

- `title`, `xlabel` and `ylabel` specify the plot title and axis labels.
  Thes can also be specifeied

- `interp` specifies the interpolation method.  By default, the nearest
  neighbor is used.

- `aspect` specifies the aspect ration of the axis.  Can be `"auto"`, `"equal"`
  or a scalar. By default, `"equal"`.

- `origin` specifies the origin of coordinates.  Default is `"upper"` for a
  matrix and `"lower"` for an image.

- `extent = (x0,x1,y0,y1)` specifies the coordinate ranges.  By default, the
  extent is set so that coordinates correspond to Julia indices.

"""
function plmat(A::AbstractMatrix;
               fig = nothing,
               cbar::Bool = false,
               clear::Bool = true,
               interp = :nearest,
               cmap = :viridis,
               min = nothing,
               max = nothing,
               origin = matrix_origin(),
               extent = matrix_extent(origin, A),
               aspect = matrix_aspect(),
               title = "",
               xlabel = "",
               ylabel = "")
    preparefigure(fig, clear)
    plt.imshow(A, vmin=min, vmax=max, interpolation=interp,
               cmap=cmap, aspect=aspect, origin=origin, extent=extent)
    cbar && plt.colorbar()
    addtitles(title, xlabel, ylabel)
end

plmat(A::AbstractMatrix, title::AbstractString; kwds...) =
    plmat(A; title=title, kwds...)

function plmat(A::AbstractMatrix, ylabel::AbstractString,
               xlabel::AbstractString; kwds...)
    plmat(A; xlabel=xlabel, ylabel=ylabel, kwds...)
end

function plmat(A::AbstractMatrix, title::AbstractString,
               ylabel::AbstractString, xlabel::AbstractString; kwds...)
    plmat(A; title=title, xlabel=xlabel, ylabel=ylabel, kwds...)
end

function plimg(A::AbstractMatrix;
               origin = image_origin(),
               extent = image_extent(origin, A),
               aspect = image_aspect(),
               kwds...)
    plmat(permutedims(A);
          aspect=aspect, extent=extent, origin=origin, kwds...)
end

plimg(A::AbstractMatrix, title::AbstractString; kwds...) =
    plimg(A; title=title, kwds...)

function plimg(A::AbstractMatrix, xlabel::AbstractString,
               ylabel::AbstractString; kwds...)
    plimg(A; xlabel=xlabel, ylabel=ylabel, kwds...)
end

function plimg(A::AbstractMatrix, title::AbstractString,
               xlabel::AbstractString, ylabel::AbstractString; kwds...)
    plimg(A; title=title, xlabel=xlabel, ylabel=ylabel, kwds...)
end

plmat!(args...; kwds...) = plmat(args...; clear=false, kwds...)
plimg!(args...; kwds...) = plimg(args...; clear=false, kwds...)

@doc @doc(plmat) plmap!
@doc @doc(plmat) plimg
@doc @doc(plmat) plimg!

"""
    fig()
or
    fig(f)
create a new plotting figure or select an existing figure.

"""
fig() = plt.figure()
fig(::Nothing) = plt.figure()
fig(f::Union{Integer,plt.Figure}) = plt.figure(f)

"""
     clf()

clears the current figure, while

     clf(f)

selects figure `f` and clears it.

"""
clf(::Nothing) = plt.clf()
clf(f::Union{Integer,plt.Figure}) = (plt.figure(f); plt.clf())


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
    preparefigure(fig, clear)
    plt.plot(x, y, s, linewidth=linewidth)
    addtitles(title, xlabel, ylabel)
end

preparefigure(::Nothing, clear::Bool) = (clear &&  plt.clf(); nothing)
preparefigure(fig::Union{Integer,plt.Figure}, clear::Bool) =
    (plt.figure(fig); clear &&  plt.clf(); nothing)

function addtitles(title::AbstractString, xlabel::AbstractString,
                   ylabel::AbstractString)
    length(title)  > 0 && plt.title(title)
    length(xlabel) > 0 && plt.xlabel(xlabel)
    length(ylabel) > 0 && plt.ylabel(ylabel)
    nothing
end

# Deprecations.
@deprecate pli plimg

end # module
