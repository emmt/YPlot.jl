# YPlot.jl

A simplified plotting package for Julia.  For now, the backend is
[PyPlot](https://github.com/stevengj/PyPlot.jl), the syntax is somewhat
reminiscent of Yorick.


## Wish List

* Add a database of preferences (using a dictionary) which can be optionaly
  saved to the disk.  The backend should be part of the preferences.

* Simplify the indication of ranges for plotting (using tuples as Julia ranges
  have restrictions).

* Add `plc` for plotting contours.
