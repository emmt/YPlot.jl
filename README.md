# YPlot.jl

A simplified plotting package for Julia.  For now, the backend is
[PyPlot](https://github.com/stevengj/PyPlot.jl), the syntax is somewhat
reminiscent of Yorick.

Examples:
```julia
using YPlot
A = randn(4,7)
plmat(A, "As a matrix", "row index", "column index"; fig=1)
plimg(A, "As an image", "x", "y"; cbar=true, fig=2)
```

will display the 2D array `A` as a matrix in figure 1 and as an image (with a
color bar) in figure
2.


## Wish List

* Add a database of preferences (using a dictionary) which can be optionaly
  saved to the disk.  The backend should be part of the preferences.

* Simplify the indication of ranges for plotting (using tuples as Julia ranges
  have restrictions).

* Add `plc` for plotting contours.
