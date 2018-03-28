FROM centos:centos6

RUN yum update -y

RUN yum -y install wget mesa-libGL-devel fontconfig

# Download and install newer gcc compiler.
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-3-toolchain && \
    scl enable devtoolset-3 bash

RUN source /opt/rh/devtoolset-3/enable && gcc --version

# Download and install latest cmake.
RUN mkdir -p /tmp/cmake_download && \
    pushd /tmp/cmake_download && \
    wget 'https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh' && \
    bash cmake-3.10.2-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir && \
    popd && \
    rm -rf /tmp/cmake_download

# Download and install Qt 5.7.
ADD qt-installer-noninteractive.qs /tmp/qt_download/script.qs
RUN mkdir -p /tmp/qt_download && \
    pushd /tmp/qt_download && \
    wget 'http://download.qt.io/archive/qt/5.7/5.7.1/qt-opensource-linux-x64-5.7.1.run' && \
    chmod +x ./qt-opensource-linux-x64-5.7.1.run && \
    ./qt-opensource-linux-x64-5.7.1.run --script ./script.qs -platform minimal && \
    popd && \
    rm -rf /tmp/qt_download

# Download and install Python 3.5.
RUN yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel && \
    source /opt/rh/devtoolset-3/enable && \
    export current_dir=$pwd && \
    mkdir ${current_dir}/python_install && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget https://www.python.org/ftp/python/3.5.3/Python-3.5.3.tgz && \
    tar -xzf Python-3.5.3.tgz && \
    cd Python-3.5.3 && \
    ./configure --prefix=${current_dir}/python_install && \
    make && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download

# Download and install mpi.
RUN source /opt/rh/devtoolset-3/enable && \
    export current_dir=$pwd && \
    mkdir ${current_dir}/mpich-3.2-install && \
    mkdir -p /tmp/mpi_download && \
    pushd /tmp/mpi_download && \
    wget http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz && \
    tar -xzf mpich-3.2.tar.gz && \
    mkdir mpich-3.2-build && \
    pushd mpich-3.2-build/ && \
    ../mpich-3.2/configure -prefix=${current_dir}/mpich-3.2-install |& tee c.txt && \
    make |& tee m.txt && \
    make install |& tee mi.txt && \
    export PATH=${current_dir}/mpich-3.2-install/bin:$PATH && \
    popd && \
    popd && \
    rm -rf /tmp/mpi_download


RUN yum clean all
