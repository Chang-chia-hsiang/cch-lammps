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
tar xvf download && \
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz && \
gunzip openmpi-4.0.4.tar.gz && \
tar xvf openmpi-4.0.4.tar && \
cd openmpi-4.0.4/ && \
./configure --prefix=$HOME/openmpi-4.0.4/ && \
make all && make install  && \
cd /root/ && rm openmpi-4.0.4.tar && \
RUN printf '\nPATH=$PATH:$HOME/openmpi-4.0.4/bin' >> ~/.bashrc && \
source ~/.bashrc && \
cd ~/lammps-3Mar20/src/ && \
apt install fftw3 -y && \
ln -s /usr/lib/x86_64-linux-gnu/libfftw3.so.3 /usr/lib/x86_64-linux-gnu/libfftw.so && \
make mpi-stubs && \
make yes-all && make no-lib && \
make mpi && make mac && make serial && \
cd /root/lammps-3Mar20/examples/
