Thu Nov 10 09:22:26 PST 2016

Open CV computer vision http://opencv.org/

Side note- STL (standard template library) is used here. Templates in C++
provide a way to write code that operates on different types.

R bindings: https://github.com/swarm-lab/videoplayR

> Currently videoplayR provides only a small fraction of the image processing
> capabilities of OpenCV. The number of functions will increase little by
> little as my needs for more advanced features develop or as other R
> developers provide their own code to be included in the package (hint: pull
> requests to the project repository are very, very welcome:
> https://github.com/swarm-lab/videoplayR/pulls)

This package seems deprecated, moving to a different package that seems to
download and install opencv.

Nice OO porting to R:
https://github.com/swarm-lab/Rvision/blob/master/src/arithmetic.hpp
