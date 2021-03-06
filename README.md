# MATLAB & mexopencv integration bundle #

(C) 2017-2019, Rok Mandeljc


## Summary

This project aims to provide an easy-to-use mexopencv bundle for rapid
OpenCV prototyping with MATLAB. It provides self-contained (source)
versions of OpenCV and mexopencv, along with build scripts and startup
scripts for Linux and Windows.

The main idea is that instead of building mexopencv against system's
OpenCV and having to worry about its version and feature compatibility,
a private version of compatible OpenCV and corresponding mexopencv
is built using the provided build script. In addition, the provided
startup scripts take care of setting correct library paths, avoiding the
issues with missing or conflicting library imports.


## Prerequisites

The bundle was primarily developed and tested on 64-bit Linux (Fedora 29)
with Matlab R2016b, but has also been tested on 64-bit Windows 8.1 with
Visual Studio 2015 and Matlab R2016a, and 64-bit Windows 10 with
Visual Studio 2017 and Matlab R2017b. Matlab R2018a and later are
currently not supported on Windows due to bug in mexopencv's build scripts!


### Linux

A recent 64-bit Linux distribution with basic compilation toolchain
(git, gcc, CMake, make) is required.

In addition, dependencies for building the git checkout of OpenCV are
required. On Fedora, the basic set of development libraries I use can
be installed via:
```Shell
sudo dnf install \
    git \
    cmake \
    gcc-c++ \
    zlib-devel \
    libwebp-devel \
    libjpeg-devel \
    libpng-devel \
    libtiff-devel \
    jasper-devel \
    OpenEXR-devel \
    ffmpeg-devel \
    gstreamer-devel \
    gstreamer-plugins-base-devel \
    libv4l-devel \
    tbb-devel \
    eigen3-devel \
    openblas-devel
```

### Windows

A recent version of Matlab and working MEX compiler is required.

Make sure that Matlab executable is in PATH; i.e., that you
can start it by running ```matlab``` from Windows command prompt (cmd).

Ensure that MEX compiler is properly set up in Matlab, and that it
points to the correct Visual Studio installation. You can check this
by running the following inside Matlab:
```Matlab
mex -setup C++
```
and follow its instructions for choosing the correct compiler.

In addition, you will need git and CMake. Make sure that the path to
CMake executable is in PATH.


## Installation

Checkout the repository to a target location:
```Shell
git clone https://github.com/rokm/matlab_mexopencv matlab_mexopencv
cd matlab_mexopencv
git submodule update --init --recursive
cd ..
```
The above commands should also pull in all external dependencies
(opencv, opencv-contrib, mexopencv) as git submodules from their
corresponding repositories.

### Linux

To simplify the build process, use the provided ```build_all.sh``` script.

First, export the path to your Matlab installation:
```Shell
export MATLABDIR=/usr/local/MATLAB/R2016b
```

Then, run the build script:
```Shell
./matlab_mexopencv/build_all.sh
```

The shell script will attempt to:
- build OpenCV and install it inside the pre-determined sub-directory
  inside the target (checkout) directory
- build mexopencv (using make)

If no errors occurred, the script will print a message about successfully
finishing the build process.

On Linux, the OpenCV shared libraries (required by mexopencv) need to be
in your LD_LIBRARY_PATH before Matlab is started. For convenience, a
startup script is provided which takes care of that for you. Therefore,
to start Matlab, run the following startup script:
```Shell
./matlab_mexopencv/start_matlab.sh
```
It will set up LD_LIBRARY_PATH and run the ```startup.m``` Matlab script
to properly set up paths to external dependencies.

Note that the script can be called from an arbitrary working directory,
i.e., it is not restricted to the code checkout directory.

The startup script assumes that the path to Matlab installation is
stored in MATLABDIR environment variable; one way to ensure this is
to set it up in your .bash_profile.


### Windows

Similarly to Linux, a build batch script is available. Open the Windows
Prompt (cmd), and move inside the working directory.

Make sure that Matlab and CMake are in the PATH.

Then, set the Visual Studio version and architecture (required for CMake),
and run the build script:
```Batchfile
set "DEFAULT_CMAKE_GENERATOR=Visual Studio 14"
set "DEFAULT_CMAKE_ARCH=x64"

matlab_mexopencv\build_all.bat
```

The script will attempt to:
- build OpenCV and install it inside the pre-determined sub-directory
  inside the code directory
- run Matlab and build mexopencv

If no errors occurred, the script will print a message about successfully
finishing the build process.

On Windows (in contrast to Linux; see above), Matlab can be started
normally - but make sure that the ```startup.m``` is executed before
using the functions and objects from this project.


## Compatibility issues on Linux

Matlab bundles a lot of dynamic libraries in its installation directories,
which unfortunately tends to cause compatibility issues with MEX files
that are compiled against host libraries.

## libstdc++

A commonly-encountered issue is related to bundled libstdc++, in cases
when the host system ships with newer version of glibc. In this case,
the libraries we build ourselves (e.g., our build of OpenCV) is linked
against host libstdc++, which contains symbols of higher version than
the ones that are later found in Matlab's libstdc++.

This is usually remedied by removing Matlab's libstdc++, which will
cause it to use the host's version of the library. In practice, it is
best to simply move the problematic libraries to a backup folder, e.g.:
```Shell
cd /usr/local/MATLAB/R2016b
cd sys/os/glnxa64
sudo mkdir bak
sudo mv libgcc_s.so.1 libquadmath.so.0 libquadmath.so.0.0.0 libstdc++.so.6 libstdc++.so.6.0.20 bak/
```

## Other Matlab-provided libraries

Another, larger set of Matlab-bundled libraries can be found under bin
directory in Matlab's installation directory.

Of those bundled libraries, I tend to remove libfreetype (so that system
version is used instead) to avoid warnings about a missing symbol information.

On Fedora 29, I also found that unless Matlab's version of TBB is removed,
OpenCV compiled against system's version of TBB crashes Matlab when a
mexopencv MEX file is loaded. (Alternative is to modify the build_all.sh
to include -DWITH_TBB=OFF flag when building OpenCV).

```Shell
cd /usr/local/MATLAB/R2016b
cd bin/glnxa64
sudo mkdir bak
sudo mv libfreetype* bak/
sudo mv libtbb* bak/
```
