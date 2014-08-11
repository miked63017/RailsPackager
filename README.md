RailsPackager
=============


An attempt to script the packaging of a rails app into an rpm using fpm. This is going to be far from universal to start, but I have plans to try to make it more modular as the need arises for me to install rails apps. The need for this came about when I wanted to setup showterm in a reproducable manner, and it required a much newer version of ruby that what was available for the CentOS machines I intended to use.


As it stands right now there are hardcoded dirs and other problems, but it works for my purpose in packaging showterm assuming you setup the dirs as they are needed.
