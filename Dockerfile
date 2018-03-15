FROM centos:centos6

RUN yum update -y

# Download and install latest cmake.
RUN mkdir -p /tmp/cmake_download && \
    pushd /tmp/cmake_download && \
    wget 'https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh' && \
    bash cmake-3.10.2-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir && \
    popd && \
    rm -rf /tmp/cmake_download

# Download and install Qt 5.7.
# RUN mkdir -p /tmp/qt_download && \
#     pushd /tmp/qt_download && \
#     wget 'http://download.qt.io/archive/qt/5.7/5.7.1/qt-opensource-linux-x64-5.7.1.run' && \
#     ./qt-opensource-linux-x64-5.7.1.run && \
#     popd && \
#     rm -rf /tmp/qt_download

RUN yum clean all