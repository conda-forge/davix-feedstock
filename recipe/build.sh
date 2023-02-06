#!/bin/bash
# https://github.com/cern-fts/davix/issues/104
tar xvf davix-0.8.4.tar.gz
cd davix-0.8.4
cp LICENSE ..
patch -p1 <$RECIPE_DIR/0001-system-curl.patch
patch -p1 <$RECIPE_DIR/0002-Fix-lib-suffix.patch

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./deps/libneon
set -ex

mkdir build-dir
cd build-dir

if [ "$(uname)" == "Linux" ]; then
    cmake_args="-DCMAKE_AR=${GCC_AR}"
else
    cmake_args=""
fi

# Python 2 really is a build dependency so we don't care what platform it targets
unset _CONDA_PYTHON_SYSCONFIGDATA_NAME

cmake ${CMAKE_ARGS} -LAH \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DLIB_INSTALL_DIR="${PREFIX}/lib" \
    -DUUID_INCLUDE_DIR=${PREFIX}/include \
    -DUUID_LIBRARY=${PREFIX}/lib/libuuid.a \
    -DENABLE_THIRD_PARTY_COPY=ON \
    -DGSOAP_WSDL2H=$BUILD_PREFIX/bin/wsdl2h \
    -DGSOAP_SOAPCPP2=$BUILD_PREFIX/bin/soapcpp2 \
    -DEMBEDDED_LIBCURL=OFF \
    ${cmake_args} \
    ..

make -j${CPU_COUNT}

make install
