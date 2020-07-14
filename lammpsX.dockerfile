FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive

## preparation ##
RUN apt update && apt install -y \
    vim tmux locate environment-modules tcl python3 python3-pip \
    git wget curl ssh net-tools \
    gcc g++ gfortran make cmake autoconf automake \
    libgtk2.*common libpango-1* libasound2* xserver-xorg cpio
COPY Makefiles/Makefile.X /root/

## lammmps ##
RUN wget https://sourceforge.net/projects/lammps/files/latest/download && \
tar xvf download && \
rm download

## Makefiles fixed ##
RUN rm /root/lammps-3Mar20/src/MAKE/Makefile.mpi && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.big && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.fftw && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.g++_mpich && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.g++_openmpi && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.gpu && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.mgptfast && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.omp && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.opt && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.jpeg && \
rm /root/lammps-3Mar20/src/MAKE/OPTIONS/Makefile.png && \
rm /root/lammps-3Mar20/src/MAKE/MACHINES/Makefile.cygwin && \
rm /root/lammps-3Mar20/src/MAKE/MACHINES/Makefile.mac_mpi && \
rm /root/lammps-3Mar20/src/MAKE/MACHINES/Makefile.ubuntu
COPY Makefiles/Makefile.ubuntu /root/lammps-3Mar20/src/MAKE/MACHINES/
COPY Makefiles/Makefile.mac_mpi /root/lammps-3Mar20/src/MAKE/MACHINES/
COPY Makefiles/Makefile.cygwin /root/lammps-3Mar20/src/MAKE/MACHINES/
COPY Makefiles/Makefile.png /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.jpeg /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.opt /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.omp /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.mgptfast /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.gpu /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.g++_openmpi /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.g++_mpich /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.fftw /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.big /root/lammps-3Mar20/src/MAKE/OPTIONS/
COPY Makefiles/Makefile.mpi /root/lammps-3Mar20/src/MAKE/

## openmpi-4.0.4 ##
RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz && \
tar zxvf openmpi-4.0.4.tar.gz && \
cd openmpi-4.0.4/ && \
./configure --prefix=$HOME/openmpi-4.0.4/ && \
make all && make install  && \
cd /root/ && rm openmpi-4.0.4.tar.gz

## mpich-3.3.2 ##
RUN wget http://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz && \
tar zxvf mpich-3.3.2.tar.gz && \
cd mpich-3.3.2/ && \
./configure --prefix=$HOME/mpich/ && \
make all && make install && \
cd /root/ && rm mpich-3.3.2.tar.gz

## fftw3 ##
RUN apt install fftw3 -y && \
apt-get install libfftw3-dev -y && \
cd /usr/lib/x86_64-linux-gnu/ && \
ln -s libfftw3.so.3 libfftw.so

## packages ##
RUN cd /root/lammps-3Mar20/src/ && \
make mpi-stubs && \
make yes-all && make no-lib

## jpeg ##
RUN cd /usr/include/ && \
git clone https://github.com/Chang-chia-hsiang/libjpeg.git && \
mv libjpeg/* . && \
rm -rf libjpeg && \
apt-get install libjpeg-dev -y && \
cp /usr/include/x86_64-linux-gnu/jconfig.h /usr/include/

## png ##
RUN cd /usr/ && \
git clone https://github.com/Chang-chia-hsiang/libpng.git && \
git clone https://github.com/Chang-chia-hsiang/zlib.git && \
mv include/cmake/ include/cmake.jpeg/ && \
mv libpng/* include/ && \
mv zlib/contrib zlib/contrib.zlib && \
mv zlib/* include/ && \
rm -rf libpng zlib && \
apt-get install libpng-dev -y
COPY Headers/pnglibconf.h /usr/include/

## g++_mpich_link ##
RUN cp /root/lammps-3Mar20/src/STUBS/mpi.h /usr/include && \
apt-get install libmpich-dev -y

## g++_openmpi_link ##
RUN cp /root/openmpi-4.0.4/lib/libmpi.so /usr/lib/ && \
cp /root/openmpi-4.0.4/lib/libmpi.so /usr/lib/libmpi_cxx.so

## lmp_g++_openmpi_link ##
RUN cp /root/openmpi-4.0.4/lib/libmpi.so.40 /usr/lib/
