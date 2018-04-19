# YPlot.jl

A very simple plotting package for Julia.  For now, the backend is
[PyPlot](https://github.com/stevengj/PyPlot.jl), the syntax is somewhat
reminiscent of Yorick.

The initial objective was to cope with the displaying 2D Julia arrays with axes
orientation and extent suitable for **matrix** (that is `A[i,j]` is indexed by
*row* `i` and *column* `j`) or **image** (that is `A[x,y]` is indexed by
*abscissa* index `x` and *ordinate* nidex `y`) conventions.

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
