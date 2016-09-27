#
# Quantum Espresso : a program for electronic structure calculations
#    ssh version. All binaries (serial and parallel)
#
#
# For many reasons we need to fix the ubuntu release:
FROM ubuntu:16.04
#
MAINTAINER roberto innocente <inno@sissa.it>
#
# this directive was inserted  not long ago (https://github.com/docker/docker/issues/14634)
# it permits to define ARGs to be used only during the build and not in operations.
# if it is not supported then the "DEBIAN_FRONTEND=noninteractive" definition
# should be placed in front of every apt install to silence the warning messages
# apt  would produce
#
ARG DEBIAN_FRONTEND=noninteractive
#
# we replace the standard http://archive.ubuntu.com repository
# that is very slow, with the new mirror method :
# deb mirror://mirror.ubuntu.com/mirrors.txt ...
#
ADD  http://people.sissa.it/~inno/qe/sources.list /etc/apt/
RUN  chmod 644 /etc/apt/sources.list
#
# we update the apt database
#
RUN  apt update 
#
#
# we update the package list 
# and install vim openssh, sudo, wget, gfortran, openblas, blacs,
# fftw3, openmpi , ...
# and run ssh-keygen -A to generate all possible keys for the host
#
RUN apt install -yq vim \
		openssh-server \
		sudo \
		wget \
        	ca-certificates \
		gfortran-5 \
		libgfortran-5-dev \
		openmpi-bin  \
		libopenmpi-dev \
        	libopenblas-base \
        	libopenblas-dev \
        	libfftw3-3 \
        	libfftw3-double3  \
		libblacs-openmpi1 \
		libblacs-mpi-dev \
		net-tools \
		make \
		autoconf \
	&& ssh-keygen -A
#
# we create the user 'qe' and add it to the list of sudoers
RUN  adduser -q --disabled-password --gecos qe qe \
	&& echo "qe 	ALL=(ALL:ALL) ALL" >>/etc/sudoers \
#
# we add /home/qe to the PATH of user 'qe'
	&& echo "export PATH=/home/qe/bin:${PATH}" >>/home/qe/.bashrc \
	&& mkdir -p /home/qe/.ssh/  \
	&& chown qe:qe /home/qe/.ssh
#
# we move to /home/qe
WORKDIR /home/qe
#
# we copy the 'qe' files and the needed shared libraries to /home/qe
# then we unpack them : the 'qe' directly there, the shared libs
# from /
RUN wget  --no-verbose  http://people.sissa.it/~inno/qe/qe.tgz \ 
	  http://people.sissa.it/~inno/qe/bin/qe-all-bins.tgz \
	  http://people.sissa.it/~inno/qe/mpibin.tgz \
	&& tar xzf qe.tgz \
	&& tar xzf qe-all-bins.tgz \
	&& tar xzf mpibin.tgz \
#
# we chown -R the files in /home/qe, make pw.x executable, set 'qe' passwd
	&& chown -R qe:qe /home/qe   \
	&& (echo "qe:mammamia"|chpasswd) \
#
# we remove the archives we copied
	&& rm qe.tgz qe-all-bins.tgz \
	mpibin.tgz 
#

RUN sed -i 's#^StrictModes.*#StrictModes no#' /etc/ssh/sshd_config \
	&& service   ssh  restart  

EXPOSE 22

#
# the container can be now reached via ssh
CMD [ "/usr/sbin/sshd","-D" ]

