# qe-ssh-ab

Quantum Espresso reachable through ssh , all binaries (serial and parallel), no source.

**Only for the bravehearted  its size is ~ 1.3 GB**

*(It is based on ubuntu:16.04 )*


**Quantum Espresso** is a widely used package for electronic structure calculations.

Further information is  available on its website : [www.quantum-espresso.org](http://www.quantum-espresso.org/).

---

This image is for a **QE** container that is reachable through ssh.


You can run the container in background  with :
```
  $ CONT=`docker run -P -d -t rinnocente/qe-ssh-ab`
```
in this way (-P) the std ssh port (=22) is mapped on a free port of the host. We can access the container discovering the port of the host on which the container ssh service is mapped :
```
  $ PORT=`docker port $CONT 22 |sed -e 's#.*:##'`
  $ ssh -p $PORT qe@127.0.0.1
```
the initial password for the 'qe' user is 'mammamia', don't forget to change it immediately.

The **QE** container has the   QuantumEspresso  binaries and parallel binaries.
As with smaller images it still has the files for a quick test.
When you are inside the container you can simply run the test typing :
```
  $ ./pw.x <relax.in
```
The normal way in which you use this container is sharing an input-output directory between your host  and the container. In this case you create a subdir in your host :
```
  $ mkdir ~/qe-in-out
```
and when you run the container you share this directory with the container as a volume :
```
 $ CONT=`docker run -v ~/qe-in-out:/home/qe/qe-in-out -P -d -t rinnocente/qe-ssh-ab`
 $ PORT=`docker port $CONT|sed -e 's#.*:##'`
 $ ssh -p $PORT qe@127.0.0.1
```
---
The container does not die when you logout the ssh session because it is backgrounded.

You need to explicitly stop it if you want to re-use it later :
```
$ docker stop $CONT
```

Or even remove it if you don't want to re-use it :
```
$ docker rm -f $CONT
```
---
The Dockerfile is on github : [Dockerfile](https://github.com/rinnocente/qe-ssh-ab)

### NB. this container is reachable via ssh through **your host port $PORT**, eventually from Internet at large.

---
This is a  package with  all  serial binaries and also all the parallel binaries (with openmpi) :
```
/home/qe 
         |-- bin                 (serial binaries)
         |   |-- average.x
         |   |-- bands.x
         |   .
         |   .
         |-- mpibin             (parallel binaries)
         |   |-- average.x
         |   |-- bands.x
         |   .
         |   .
         |-- pw.x               (files for a small test : program)
         |-- relax.in                                  (: input)
         |-- C.pz-rrkjus.UPF                           (: pseudo-pot)
         |-- O.pz-rrkjus.UPF                           (: pseudo-pot)
         
```

In the `bin` subdir of ```/home/qe``` there are the serial binaries that can be run directly without any further ado (being ```/home/qe/bin``` inserted in the ```PATH``` env variable).

OpenMPI is installed on the container and in the ```mpibin``` dir there are the parallel binaries using openMPI e.g.  ```mpirun -np 1 mpibin/pw.x <relax.in``` will run the parallel version of ```pw.x```


![qe](http://www.quantum-espresso.org/wp-content/uploads/2011/12/Quantum_espresso_logo.jpg)

