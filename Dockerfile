FROM centos:centos6.6

# Download essentials for the following commands.
RUN yum update -y && \
    yum -y install wget tar && \
    yum clean all

# Fix for rpm issue.
# See https://medium.com/@fkei/docker-rpmdb-checksum-is-invalid-dcdpt-pkg-checksums-xxxx-amzn1-u-%E5%AF%BE%E5%87%A6%E6%B3%95-289b8c58d4a3
# and https://github.com/CentOS/sig-cloud-instance-images/issues/15
RUN rpm --rebuilddb && \
    yum install -y yum-plugin-ovl && \
    yum clean all

# Download and install newer gcc compiler.
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-7-toolchain && \
    scl enable devtoolset-7 bash && \
    yum clean all

# Download and install latest cmake.
RUN mkdir -p /tmp/cmake_download && \
    pushd /tmp/cmake_download && \
    wget -nv 'https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh' && \
    bash cmake-3.14.5-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir && \
    popd && \
    rm -rf /tmp/cmake_download

# Download and install mpi.
RUN source /opt/rh/devtoolset-7/enable && \
    export current_dir=$pwd && \
    mkdir ${current_dir}/mpich-3.2-install && \
    mkdir -p /tmp/mpi_download && \
    pushd /tmp/mpi_download && \
    wget -nv 'http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz' && \
    tar -xzf mpich-3.2.tar.gz && \
    mkdir mpich-3.2-build && \
    pushd mpich-3.2-build/ && \
    ../mpich-3.2/configure -prefix=${current_dir}/mpich-3.2-install |& tee c.txt && \
    make -s |& tee m.txt && \
    make install |& tee mi.txt && \
    popd && \
    popd && \
    rm -rf /tmp/mpi_download
# Update the path such that mpi is found.
ENV PATH="/mpich-3.2-install/bin:${PATH}"

# Download and install Python 3.5.
RUN yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel && \
    source /opt/rh/devtoolset-7/enable && \
    mkdir -p /opt/Python35 && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget -nv 'https://www.python.org/ftp/python/3.5.3/Python-3.5.3.tgz' && \
    tar -xzf Python-3.5.3.tgz && \
    cd Python-3.5.3 && \
    ./configure --prefix=/opt/Python35/ --enable-shared && \
    make -s && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download && \
    yum clean all
# Update the library search path such that the so is found by python.
ENV LD_LIBRARY_PATH="/opt/Python35/lib:${LD_LIBRARY_PATH}"
# Install pip packages for Python 3.5.
RUN /opt/Python35/bin/pip3.5 install six progressbar2 wheel

# Download and install Python 2.7.
RUN yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel && \
    source /opt/rh/devtoolset-7/enable && \
    mkdir -p /opt/Python27 && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget -nv 'https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz' && \
    tar -xzf Python-2.7.13.tgz && \
    cd Python-2.7.13 && \
    ./configure --prefix=/opt/Python27/ --enable-shared --enable-unicode=ucs4 && \
    make -s && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download && \
    yum clean all
# Update the library search path such that the so is found by python.
ENV LD_LIBRARY_PATH="/opt/Python27/lib:${LD_LIBRARY_PATH}"
# Install pip packages for Python 2.7.
RUN /opt/Python27/bin/python2.7 -m ensurepip --upgrade && \
    /opt/Python27/bin/pip2.7 install wheel

# Download and install Qt 5.7.
ADD qt-installer-noninteractive.qs /tmp/qt_download/script.qs
RUN yum -y install mesa-libGL-devel fontconfig && \
    mkdir -p /tmp/qt_download && \
    pushd /tmp/qt_download && \
    wget -nv 'http://download.qt.io/archive/qt/5.7/5.7.1/qt-opensource-linux-x64-5.7.1.run' && \
    chmod +x ./qt-opensource-linux-x64-5.7.1.run && \
    ./qt-opensource-linux-x64-5.7.1.run --script ./script.qs -platform minimal && \
    popd && \
    rm -rf /tmp/qt_download && \
    yum clean all

# Finally, we need lsb_release and git for our cmake file.
RUN yum -y install redhat-lsb-core git && \
    yum clean all