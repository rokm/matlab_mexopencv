#!/bin/bash

# Matlab directory; set only if not already set
MATLABDIR=${MATLABDIR:-/usr/local/MATLAB/R2016b}

# Get the project's root directory (i.e., the location of this script)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# Quit on error
set -e

########################################################################
#                             Build OpenCV                             #
########################################################################
# Fedora dependencies:
#  libtiff-devel libjpeg-devel libwebp-devel jasper-devel OpenEXR-devel
#  ffmpeg-devel
#  eigen3-devel tbb-devel openblas-devel

echo "Building OpenCV..."

OPENCV_SOURCE_DIR="${ROOT_DIR}/external/opencv"
OPENCV_CONTRIB_SOURCE_DIR="${ROOT_DIR}/external/opencv_contrib"
OPENCV_BUILD_DIR="${OPENCV_SOURCE_DIR}/build"
OPENCV_INSTALL_DIR="${ROOT_DIR}/external/opencv-bin"

# Make sure the submodule has been checked out
if [ ! -f "${OPENCV_SOURCE_DIR}/.git" ]; then
    echo "The opencv submodule does not appear to be checked out!"
    exit 1
fi

# Build and install
mkdir -p "${OPENCV_BUILD_DIR}"

cmake \
    -H"${OPENCV_SOURCE_DIR}" \
    -B"${OPENCV_BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="${OPENCV_INSTALL_DIR}" \
    -DOPENCV_EXTRA_MODULES_PATH="${OPENCV_CONTRIB_SOURCE_DIR}/modules" \
    -DCMAKE_SKIP_RPATH=ON \
    -DWITH_UNICAP=OFF \
    -DWITH_OPENNI=OFF \
    -DWITH_TBB=ON \
    -DWITH_LAPACK=OFF \
    -DWITH_GDAL=OFF \
    -DWITH_QT=OFF \
    -DWITH_GTK=OFF \
    -DWITH_OPENGL=OFF \
    -DWITH_CUDA=OFF \
    -DWITH_OPENCL=OFF \
    -DWITH_GPHOTO2=OFF \
    \
    -DBUILD_opencv_apps=OFF \
    -DBUILD_opencv_calib3d=ON \
    -DBUILD_opencv_core=ON \
    -DBUILD_opencv_cudaarithm=OFF \
    -DBUILD_opencv_cudabgsegm=OFF \
    -DBUILD_opencv_cudacodec=OFF \
    -DBUILD_opencv_cudafeatures2d=OFF \
    -DBUILD_opencv_cudafilters=OFF \
    -DBUILD_opencv_cudaimgproc=OFF \
    -DBUILD_opencv_cudalegacy=OFF \
    -DBUILD_opencv_cudaobjdetect=OFF \
    -DBUILD_opencv_cudaoptflow=OFF \
    -DBUILD_opencv_cudastereo=OFF \
    -DBUILD_opencv_cudawarping=OFF \
    -DBUILD_opencv_cudev=OFF \
    -DBUILD_opencv_dnn=ON \
    -DBUILD_opencv_features2d=ON \
    -DBUILD_opencv_flann=ON \
    -DBUILD_opencv_highgui=ON \
    -DBUILD_opencv_imgcodecs=ON \
    -DBUILD_opencv_imgproc=ON \
    -DBUILD_opencv_java=OFF \
    -DBUILD_opencv_ml=ON \
    -DBUILD_opencv_objdetect=ON \
    -DBUILD_opencv_photo=ON \
    -DBUILD_opencv_python2=OFF \
    -DBUILD_opencv_python3=OFF \
    -DBUILD_opencv_shape=ON \
    -DBUILD_opencv_stitching=ON \
    -DBUILD_opencv_superres=ON \
    -DBUILD_opencv_ts=OFF \
    -DBUILD_opencv_video=ON \
    -DBUILD_opencv_videoio=ON \
    -DBUILD_opencv_videostab=ON \
    -DBUILD_opencv_viz=OFF \
    -DBUILD_opencv_world=OFF \
    \
    -DBUILD_opencv_aruco=ON \
    -DBUILD_opencv_bgsegm=ON \
    -DBUILD_opencv_bioinspired=ON \
    -DBUILD_opencv_ccalib=OFF \
    -DBUILD_opencv_cnn_3dobj=OFF \
    -DBUILD_opencv_contrib_world=OFF \
    -DBUILD_opencv_cvv=OFF \
    -DBUILD_opencv_datasets=ON \
    -DBUILD_opencv_dnn_modern=OFF \
    -DBUILD_opencv_dnns_easily_fooled=OFF \
    -DBUILD_opencv_dpm=ON \
    -DBUILD_opencv_face=ON \
    -DBUILD_opencv_freetype=OFF \
    -DBUILD_opencv_fuzzy=OFF \
    -DBUILD_opencv_hdf=OFF \
    -DBUILD_opencv_img_hash=ON \
    -DBUILD_opencv_line_descriptor=ON \
    -DBUILD_opencv_matlab=OFF \
    -DBUILD_opencv_optflow=ON \
    -DBUILD_opencv_phase_unwrapping=OFF \
    -DBUILD_opencv_plot=ON \
    -DBUILD_opencv_reg=OFF \
    -DBUILD_opencv_rgbd=OFF \
    -DBUILD_opencv_saliency=ON \
    -DBUILD_opencv_sfm=OFF \
    -DBUILD_opencv_stereo=OFF \
    -DBUILD_opencv_structured_light=OFF \
    -DBUILD_opencv_surface_matching=OFF \
    -DBUILD_opencv_text=ON \
    -DBUILD_opencv_tracking=ON \
    -DBUILD_opencv_xfeatures2d=ON \
    -DBUILD_opencv_ximgproc=ON \
    -DBUILD_opencv_xobjdetect=ON \
    -DBUILD_opencv_xphoto=ON

make -j4 -C "${OPENCV_BUILD_DIR}"
make install -C "${OPENCV_BUILD_DIR}"


########################################################################
#                            Build mexopencv                           #
########################################################################
echo "Building mexopencv..."
export PKG_CONFIG_PATH=${OPENCV_INSTALL_DIR}/lib64/pkgconfig:${PKG_CONFIG_PATH}

make all contrib -j4 MATLABDIR="${MATLABDIR}" LDFLAGS="LDFLAGS='-Wl,--as-needed $LDFLAGS'" -C "${ROOT_DIR}/external/mexopencv"


# End of script
echo "Great success! Build script finished without errors!"

