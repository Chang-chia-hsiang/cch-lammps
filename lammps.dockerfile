FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
    vim tmux locate environment-modules tcl python3 python3-pip \
    git wget curl ssh net-tools \
    gcc g++ gfortran make cmake autoconf automake \
    libgtk2.*common libpango-1* libasound2* xserver-xorg cpio
RUN wget https://sourceforge.net/projects/lammps/files/latest/download && \
tar xvf download

RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz && \
tar zxvf openmpi-4.0.4.tar.gz && \
cd openmpi-4.0.4/ && \
./configure --prefix=$HOME/openmpi-4.0.4/ && \
make all && make install  && \
cd /root/ && rm openmpi-4.0.4.tar.gz

RUN wget http://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz && \
tar zxvf mpich-3.3.2.tar.gz && \
cd mpich-3.3.2/ && \
./configure --prefix=$HOME/mpich/ && \
make all && make install && \
cd /root/ && rm mpich-3.3.2.tar.gz

RUN apt install fftw3 -y && \
cd /usr/lib/x86_64-linux-gnu/ && \
ln -s libfftw3.so.3 libfftw.so

RUN cd /root/lammps-3Mar20/src && \
apt-get install libfftw3-dev && \
make fftw

ENV PATH=$PATH:$HOME/openmpi-4.0.4/bin

RUN cd /root/lammps-3Mar20/src/ && \
make mpi-stubs && \
make yes-all && make no-lib && \
make mpi && make mac && make serial && make big

ENV PATH=$PATH:$HOME/mpich/bin

RUN cd /root/lammps-3Mar20/src && \
make g++_mpich
