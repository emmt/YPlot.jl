module YPlot

export
    pli,
    plimg,
    plimg!,
    plmat,
    plmat!,
    plg,
    plh,
    clf,
    fig

#using PyCall
#using LaTeXStrings

import PyPlot
import PyPlot: clf
const plt = PyPlot;


const ArrayAxis = Union{Integer,AbstractRange{<:Integer}}
const ArrayAxes{N} = NTuple{N,ArrayAxis}

#plt.pygui(true)

abstract type Origin end
struct OriginUpper <: Origin end
struct OriginLower <: Origin end

Origin(val::AbstractString) =
    (val == "upper" ? OriginUpper() :
     val == "lower" ? OriginLower() :
     throw(ArgumentError("invalid value \"$val\" for origin")))

Origin(val::Symbol) =
    (val == :upper ? OriginUpper() :
     val == :lower ? OriginLower() :
     throw(ArgumentError("invalid value `:$val` for origin")))


# Defaults settings for images and matrices.

image_origin() = :lower
image_aspect() = :equal

matrix_origin() = :upper
matrix_aspect() = :equal

axis_extent(dim::Integer) = (0.5, dim + 0.5)
axis_extent(rng::AbstractRange{<:Integer}) =
    (first(rng) - step(rng)/2, last(rng) + step(rng)/2)

extent(org::Union{Symbol,AbstractString}, args...) =
    extent(Origin(org), args...)

extent(org::Origin, I1::ArrayAxis, I2::ArrayAxis) =
    extent(org, axis_extent(I1)..., axis_extent(I2)...)

extent(org::Origin, I::ArrayAxes{2}) = extent(org, I...)

extent(org::Origin, A::AbstractMatrix) = extent(org, axes(A))

extent(::OriginLower, xmin::Real, xmax::Real, ymin::Real, ymax::Real) =
    (xmin, xmax, ymin, ymax)

extent(::OriginUpper, xmin::Real, xmax::Real, ymin::Real, ymax::Real) =
    (xmin, xmax, ymax, ymin)

"""
    plmat( A [title,] [ylabel, xlabel,]; kwds...)
    plimg( A [title,] [xlabel, ylabel,]; kwds...)
    plmat!(A [title,] [ylabel, xlabel,]; kwds...)
    plimg!(A [title,] [xlabel, ylabel,]; kwds...)

plot the 2D array `A` as a *matrix* (`plmat` and `plmat!`) or as an *image*
(`plimg` and `plimg!`).

The `plmat` and `plmat!` methods use defaults for the axis extent and
orientation suitable for a matrix (1st and 2nd dimensions correspond
respectively to the rows and columns); while the `plimg` and `plimg!` methods
use defaults suitable for an image (1st and 2nd dimensions correspond
respectively to the horizontal and vertical axes).

The `plmat!` and `plimg!` methods plot over the existing figure; while `plmat`
and `plimg` methods clear the figure before plotting.

Keywords:

- `fig` specifies the figure to plot in.  Default is to use the last one.

- `clear` specifies whether to clear the figure before plotting. Default is
  `false` for `plmat!` and `plimg!` and `true` for `plmat` and `plimg`.

- `min` and `max` specify the lower and upper values to plot.

- `cmap` specifies the colormap to use. Default is `"viridis"` (see
  http://matplotlib.org/examples/color/colormaps_reference.html for available
  colormaps).

- `cbar` specifies whether to add a color bar. Default is `true` for numeraical
  arrays and `false` for array of Booleans.

- `title`, `xlabel` and `ylabel` specify the plot title and axis labels. Thes
  can also be specifeied

- `interp` specifies the interpolation method. By default, the nearest neighbor
  is used.

- `aspect` specifies the aspect ration of the axis. Can be `"auto"`, `"equal"`
  or a scalar. By default, `"equal"`.

- `origin` specifies the origin of coordinates. Default is `"upper"` for a
  matrix and `"lower"` for an image.

- `extent = (x0,x1,y0,y1)` specifies the coordinate ranges. By default, the
  extent is set so that coordinates correspond to Julia indices.

"""
function plmat(A::AbstractMatrix{T};
               fig = nothing,
               cbar::Bool = (T != Bool),
               clear::Bool = true,
               interp = :nearest,
               cmap = :viridis,
               min = nothing,
               max = nothing,
               origin = matrix_origin(),
               aspect = matrix_aspect(),
               extent = extent(origin, A),
               title = "",
               xlabel = "",
               ylabel = "") where {T}
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
               aspect = image_aspect(),
               extent = extent(origin, A),
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

"""
```julia
plh(x, y)
```

plots vector `y` versus vector `x` in *histogram* (or staircase) style.
The stairs are horizontally centered.

"""
function plh(x::AbstractVector{Tx},
             y::AbstractVector{Ty},
             args...; kwds...) where {Tx<:Real,Ty<:Real}
    @assert first(axes(x,1)) == 1
    n = length(x)
    @assert n ≥ 2
    @assert first(axes(y,1)) == 1
    @assert length(y) == n
    T = float(promote_type(Tx, Ty))
    xp = Array{T}(undef, 2n)
    yp = Array{T}(undef, 2n)
    local x1::T, x2::T
    h = T(1)/T(2)
    x1, x2 = T(x[1]), T(x[2])
    xp[1] = (3*x1 - x2)*h
    xp[2] = (x1 + x2)*h
    @inbounds for i in 2:n-1
        x1, x2 = x2, T(x[i+1])
        xp[2i-1] = xp[2i-2]
        xp[2i] = (x1 + x2)*h
    end
    xp[2n-1] = xp[2n-2]
    xp[2n] = (3*x2 - x1)*h

    @inbounds for i in 1:n
        yp[2i] = yp[2i-1] = T(y[i])
    end
    plt.plot(xp, yp, args...; kwds...)
end

# Deprecations.
@deprecate pli plimg

end # module
