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

import PythonPlot
import PythonPlot: clf
const plt = PythonPlot;

const ArrayAxis = Union{Integer,AbstractRange{<:Integer}}
const ArrayAxes{N} = NTuple{N,ArrayAxis}

#plt.pygui(true)

"""
    YPlot.matrix_extent(A::AbstractMatrix) -> (left, right, bottom, top)

yields extent for displaying a matrix with origin at *upper* left corner so that cells
have the same indices as the 2-dimensional `A`.

"""
function matrix_extent(A::AbstractMatrix)
    I, J = axes(A)
    return (firstindex(J) - 0.5, lastindex(J) + 0.5,
            lastindex(I) + 0.5, firstindex(I) - 0.5)
end

"""
    YPlot.image_extent(A::AbstractMatrix) -> (left, right, bottom, top)

yields extent for displaying an image with origin at *lower* left corner so that cells
have the same indices as the 2-dimensional `A`.

"""
function image_extent(A::AbstractMatrix)
    I, J = axes(A)
    return (firstindex(I) - 0.5, lastindex(I) + 0.5,
            firstindex(J) - 0.5, lastindex(J) + 0.5)
end

"""
    plmat(A, [title,] [ylabel, xlabel]; kwds...)

plots the 2-dimensional array `A` as a *matrix*, that is with the first element at the
upper-left corner and with 1st and 2nd dimensions corresponding respectively to the rows
and columns.

Keywords:

- `fig` specifies the figure to plot in. Default is to use the last one.

- `clear` specifies whether to clear the figure before plotting. Default is `true`.

- `min` and `max` specify the lower and upper values to plot.

- `cmap` specifies the colormap to use. Default is `"viridis"` (see
  http://matplotlib.org/examples/color/colormaps_reference.html for available colormaps).

- `cbar` specifies whether to add a color bar. Default is `true` for numeraical arrays and
  `false` for array of Booleans.

- `title`, `xlabel` and `ylabel` specify the plot title and axis labels.

- `interp` specifies the interpolation method. By default, the nearest neighbor is used.

- `aspect` specifies the aspect ration of the axis. Can be `"auto"`, `"equal"` or a
  scalar. By default, `"equal"`.

- `extent = (left, right, bottom, top)` specifies the coordinate limits. By default, the
  extent is set so that coordinates correspond to Julia indices.

See [`plmat!`](@ref) and [`plimg`](@ref).

"""
function plmat(A::AbstractMatrix{T};
               fig = nothing,
               cbar::Bool = (T != Bool),
               clear::Bool = true,
               interp = "nearest",
               cmap = "viridis",
               min = nothing,
               max = nothing,
               aspect = "equal",
               extent = matrix_extent(A),
               title = "",
               xlabel = "",
               ylabel = "") where {T}
    fig = plt.figure(fig, clear=clear)
    plt.matshow(A; fignum=fig,
                origin="upper", extent=extent, aspect=aspect,
                vmin=min, vmax=max, cmap=cmap, interpolation=interp)
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

"""
    plmat!(A, args...; kwds...)

overplots 2-dimensional array `A` as a *matrix*. This is the same as:

    plmat(A, args...; clear=false, kwds...)

See [`plmat`](@ref) for other arguments and keywords.

"""
plmat!(A::AbstractMatrix, args...; kwds...) = plmat(args...; clear=false, kwds...)

"""
    plimg(A, [title,] [xlabel, ylabel]; kwds...)

plots the 2-dimensional array `A` as an *image*, that is with the first pixel at the
lower-left corner and with 1st and 2nd dimensions corresponding respectively to the
horizontal and vertical axes

Keywords:

- `fig` specifies the figure to plot in. Default is to use the last one.

- `clear` specifies whether to clear the figure before plotting. Default is `true`.

- `min` and `max` specify the lower and upper values to plot.

- `cmap` specifies the colormap to use. Default is `"viridis"` (see
  http://matplotlib.org/examples/color/colormaps_reference.html for available colormaps).

- `cbar` specifies whether to add a color bar. Default is `true` for numeraical arrays and
  `false` for array of Booleans.

- `title`, `xlabel` and `ylabel` specify the plot title and axis labels.

- `interp` specifies the interpolation method. By default, the nearest neighbor is used.

- `aspect` specifies the aspect ration of the axis. Can be `"auto"`, `"equal"` or a
  scalar. By default, `"equal"`.

- `origin` specifies the origin of coordinates. Default is `"upper"` for a matrix and
  `"lower"` for an image.

- `extent = (left, right, bottom, top)` specifies the coordinate limits. By default, the
  extent is set so that coordinates correspond to Julia indices.

See [`plimg!`](@ref) and [`plmat`](@ref).

"""
function plimg(A::AbstractMatrix{T};
               fig = nothing,
               cbar::Bool = (T != Bool),
               clear::Bool = true,
               interp = "nearest",
               cmap = "viridis",
               min = nothing,
               max = nothing,
               aspect = "equal",
               extent = image_extent(A),
               title = "",
               xlabel = "",
               ylabel = "") where {T}
    fig = plt.figure(fig, clear=clear)
    plt.imshow(permutedims(A);
               origin="lower", extent=extent, aspect=aspect,
               vmin=min, vmax=max, cmap=cmap, interpolation=interp)
    cbar && plt.colorbar()
    addtitles(title, xlabel, ylabel)
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

"""
    plimg!(A, args...; kwds...)

overplots 2-dimensional array `A` as an *image*. This is the same as:

    plimg(A, args...; clear=false, kwds...)

See [`plimg`](@ref) for other arguments and keywords.

"""
plimg!(A::AbstractMatrix, args...; kwds...) = plimg(A, args...; clear=false, kwds...)

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

plots 2D curve of `y` versus `x` using symbol/color `s`. Available keywords are:

- `fig` specifies the figure to plot in, defaault is to use the last one.

- `clear` specifies whether to clear the figure before plotting, default is false.

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
    fig = plt.figure(fig, clear=clear)
    plt.plot(x, y, s, linewidth=linewidth)
    addtitles(title, xlabel, ylabel)
end

preparefigure(::Nothing, clear::Bool) = (clear && plt.clf(); nothing)
preparefigure(fig::Union{Integer,plt.Figure}, clear::Bool) =
    (plt.figure(fig, clear=clear); nothing)

function addtitles(title::AbstractString, xlabel::AbstractString,
                   ylabel::AbstractString)
    length(title)  > 0 && plt.title(title)
    length(xlabel) > 0 && plt.xlabel(xlabel)
    length(ylabel) > 0 && plt.ylabel(ylabel)
    nothing
end

"""
    plh(x, y)

plots vector `y` versus vector `x` in *histogram* (or staircase) style. The stairs are
horizontally centered.

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
