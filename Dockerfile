FROM centos:centos7.8.2003

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
    yum -y install devtoolset-9-toolchain && \
    scl enable devtoolset-9 bash && \
    yum clean all

# Download and install latest cmake.
RUN mkdir -p /tmp/cmake_download && \
    pushd /tmp/cmake_download && \
    wget -nv 'https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Linux-x86_64.sh' && \
    bash cmake-3.17.3-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir && \
    popd && \
    rm -rf /tmp/cmake_download

# Download and install mpi.
RUN source /opt/rh/devtoolset-9/enable && \
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

# Download and install Python build dependencies.
RUN yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel libffi libffi-devel

# Download and install Python 3.5.
RUN source /opt/rh/devtoolset-9/enable && \
    mkdir -p /opt/Python35 && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget -nv 'https://www.python.org/ftp/python/3.5.8/Python-3.5.8.tgz' && \
    tar -xzf Python-3.5.8.tgz && \
    cd Python-3.5.8 && \
    ./configure --prefix=/opt/Python35/ --enable-shared && \
    make -s && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download && \
    yum clean all
# Update the library search path such that the so is found by python.
ENV LD_LIBRARY_PATH="/opt/Python35/lib:${LD_LIBRARY_PATH}"
# Install pip packages for Python 3.5.
RUN /opt/Python35/bin/pip3.5 install six progressbar2==3.37.1 wheel


# Download and install Python 3.6.
RUN source /opt/rh/devtoolset-9/enable && \
    mkdir -p /opt/Python36 && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget -nv 'https://www.python.org/ftp/python/3.6.10/Python-3.6.10.tgz' && \
    tar -xzf Python-3.6.10.tgz && \
    cd Python-3.6.10 && \
    ./configure --prefix=/opt/Python36/ --enable-shared && \
    make -s && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download && \
    yum clean all
# Update the library search path such that the so is found by python.
ENV LD_LIBRARY_PATH="/opt/Python36/lib:${LD_LIBRARY_PATH}"
# Install pip packages for Python 3.6.
RUN /opt/Python36/bin/pip3.6 install six progressbar2==3.37.1 wheel

# Download and install Python 3.7.
RUN source /opt/rh/devtoolset-9/enable && \
    mkdir -p /opt/Python37 && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget -nv 'https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tgz' && \
    tar -xzf Python-3.7.7.tgz && \
    cd Python-3.7.7 && \
    ./configure --prefix=/opt/Python37/ --enable-shared && \
    make -s && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download && \
    yum clean all
# Update the library search path such that the so is found by python.
ENV LD_LIBRARY_PATH="/opt/Python37/lib:${LD_LIBRARY_PATH}"
# Install pip packages for Python 3.7.
RUN /opt/Python37/bin/pip3.7 install six progressbar2==3.37.1 wheel

# Download and install Python 3.8.
RUN source /opt/rh/devtoolset-9/enable && \
    mkdir -p /opt/Python38 && \
    mkdir -p /tmp/python_download && \
    pushd /tmp/python_download && \
    wget -nv 'https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz' && \
    tar -xzf Python-3.8.3.tgz && \
    cd Python-3.8.3 && \
    ./configure --prefix=/opt/Python38/ --enable-shared && \
    make -s && \
    make altinstall && \
    popd && \
    rm -rf /tmp/python_download && \
    yum clean all
# Update the library search path such that the so is found by python.
ENV LD_LIBRARY_PATH="/opt/Python38/lib:${LD_LIBRARY_PATH}"
# Install pip packages for Python 3.8.
RUN /opt/Python38/bin/pip3.8 install six progressbar2==3.37.1 wheel

# Download and install Qt 5.12.6 LTS.
RUN yum -y install which perl fontconfig fontconfig-devel freetype-devel libX11-devel libXext-devel libXfixes-devel libXi-devel libXrender-devel libxcb libxcb-devel xcb-util xcb-util-devel libxkbcommon-devel libxkbcommon-x11-devel mesa-libGL-devel && \
    mkdir -p /tmp/qt_download && \
    pushd /tmp/qt_download && \
    wget -nv 'http://download.qt.io/official_releases/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz' && \
    tar -xf qt-everywhere-src-5.15.0.tar.xz && \
    popd && \
    mkdir -p /tmp/qt_download/build && \
    pushd /tmp/qt_download/build && \
    source /opt/rh/devtoolset-9/enable && \
    ../qt-everywhere-src-5.15.0/configure -prefix /root/qt_5_15_0 \
        -opensource -confirm-license -shared \
        -qt-harfbuzz \
        -system-freetype \
        -nomake examples -nomake tests \
        -skip qt3d \
        -skip qtactiveqt \
        -skip qtandroidextras \
        -skip qtcharts \
        -skip qtconnectivity \
        -skip qtdatavis3d \
        -skip qtdeclarative \
        -skip qtdoc \
        -skip qtgamepad \
        -skip qtgraphicaleffects \
        -skip qtlocation \
        -skip qtlottie \
        -skip qtmultimedia \
        -skip qtnetworkauth \
        -skip qtpurchasing \
        -skip qtquick3d \
        -skip qtquickcontrols \
        -skip qtquickcontrols2 \
        -skip qtquicktimeline \
        -skip qtremoteobjects \
        -skip qtscript \
        -skip qtscxml \
        -skip qtsensors \
        -skip qtserialbus \
        -skip qtserialport \
        -skip qtspeech \
        -skip qttools \
        -skip qtvirtualkeyboard \
        -skip qtwebchannel \
        -skip qtwebengine \
        -skip qtwebglplugin \
        -skip qtwebsockets \
        -skip qtwebview \
        -skip qtxmlpatterns && \
    make -s && \
    make install && \
    popd && \
    rm -rf /tmp/qt_download && \
    yum clean all

# Finally, we need lsb_release and git for our cmake file.
RUN yum -y install redhat-lsb-core git && \
    yum clean all
