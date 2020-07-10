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
apt-get install libfftw3-dev -y && \
cd /usr/lib/x86_64-linux-gnu/ && \
ln -s libfftw3.so.3 libfftw.so

RUN cd /root/lammps-3Mar20/src/ && \
make mpi-stubs && \
make yes-all && make no-lib

RUN rm /root/lammps-3Mar20/src/MAKE/Makefile.mpi
COPY Makefiles/Makefile.mpi /root/lammps-3Mar20/src/MAKE/
RUN cd /root/lammps-3Mar20/src/ && make mpi

RUN cd /root/lammps-3Mar20/src/ && make mac
RUN cd /root/lammps-3Mar20/src/ && make serial

RUN rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.big
COPY Makefiles/Makefile.big /root/lammps-3Mar20/src/MAKE/OPTIONS/
RUN cd /root/lammps-3Mar20/src/ && make big 

RUN rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.fftw
COPY Makefiles/Makefile.fftw /root/lammps-3Mar20/src/MAKE/OPTIONS/
RUN cd /root/lammps-3Mar20/src/ && make fftw

RUN rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.g++_mpich
COPY Makefiles/Makefile.g++_mpich /root/lammps-3Mar20/src/MAKE/OPTIONS/
RUN cd /root/lammps-3Mar20/src/ && make g++_mpich

#RUN cp /root/openmpi-4.0.4/include/mpi_portable_platform.h /usr/include/ && \
#cp /root/openmpi-4.0.4/include/mpi.h /usr/include/ && \
#cp /root/mpich/lib/libmpich.so /usr/lib/ && \
#cp /root/mpich/lib/libmpl.so /usr/lib/ && \
#cd /root/lammps-3Mar20/src && \
#make mode=shlib g++_mpich_link

RUN rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.g++_openmpi
COPY Makefiles/Makefile.g++_openmpi /root/lammps-3Mar20/src/MAKE/OPTIONS/
RUN cd /root/lammps-3Mar20/src/ && make g++_openmpi

RUN cp /root/openmpi-4.0.4/lib/libmpi.so /usr/lib/ && \
cp /root/openmpi-4.0.4/lib/libmpi.so /usr/lib/libmpi_cxx.so && \
make g++_openmpi_link

RUN rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.gpu
COPY Makefiles/Makefile.gpu /root/lammps-3Mar20/src/MAKE/OPTIONS/
RUN cd /root/lammps-3Mar20/src/ && make gpu
