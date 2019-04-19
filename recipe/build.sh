#!/bin/bash
set -ex

mkdir build-dir
cd build-dir

if [ "$(uname)" == "Linux" ]; then
    cmake_args="-DCMAKE_AR=${GCC_AR}"
else
    cmake_args=""
fi

cmake -LAH \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DLIB_INSTALL_DIR="${PREFIX}/lib" \
    -DUUID_INCLUDE_DIR=${PREFIX}/include \
    -DUUID_LIBRARY=${PREFIX}/lib/libuuid.a \
    ${cmake_args} \
    ..

make -j${CPU_COUNT}

make install

if [ "$(uname)" == "Linux" ]; then
    # The generated pkg-config file has the wrong lib directory, fix it...
    sed -i 's@${prefix}/lib64@${prefix}/lib@g' "${PREFIX}/lib/pkgconfig/davix.pc"
    cat "${PREFIX}/lib/pkgconfig/davix.pc"
fi

