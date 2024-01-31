.. _Requirements:

************
Requirements
************

*30 Jan 2024*

This page describes the hardware and software required to build and run
the |PLEXIL| Executive and its supporting programs.

This document describes the ``releases/plexil-4.6`` branch of
|PLEXIL|.  Other branches will have different requirements.

.. contents::


.. _development_environment:

Development environment
=======================

Any modern Unix-like system with the required development software
should be able to build and run the |PLEXIL| Executive and its
associated programs.

The source distribution requires about 200 MB of file system space
when fully built out.


.. _operating_systems:

Operating systems
~~~~~~~~~~~~~~~~~

The development team regularly builds and maintains |PLEXIL| on the
following operating systems:

- Linux (Red Hat Enterprise Linux, versions 5 and newer; Oracle Linux,
  version 7 and newer; Ubuntu Linux 12.04 LTS and newer) on Intel
  x86-64 and AMD64 hardware
- macOS versions 10.8 and newer, on x86-64 Macs

The |PLEXIL| Executive has been successfully built and tested on these
additional platforms:

- Windows Subsystem for Linux 2 (WSL 2); see the :download:`detailed instructions <../_static/images/Using_PLEXIL_with_WSL_2_Install_Instructions.pdf>` (PDF).

- `Cygwin <http://cygwin.com/>`_, a Unix-like development environment
  for Microsoft Windows.

- `FreeBSD <https://www.freebsd.org/>`_

The |PLEXIL| development team welcomes feedback and patches from users
of platforms other than Linux and macOS.  While we make every effort
to assure portability, we lack the resources to fully support other
platforms.


.. _development_software:

Development software
~~~~~~~~~~~~~~~~~~~~

The |PLEXIL| Executive and the StandAlone Simulator are written in
portable standard C++ and C.  |PLEXIL| C++ and C source files for
release 4.6 should compile without errors on any C++03 (technically
"C++98 as modified by the 2003 corrigendum") and C99 standards
compliant compiler, and should run unmodified in most POSIX-compliant
environments.

.. note::

   A C++11 compliant compiler is required for the 'releases/plexil-6'
   branch.  The 'develop' branch requires a C++14 compiler or newer.

Compiler suites the |PLEXIL| team uses in development, which are known
to work across multiple releases and platforms:

-  `gcc (GNU Compiler Collection) <https://gcc.gnu.org/>`_
-  `clang (LLVM project C/C++ compiler) <https://clang.llvm.org/>`_

There are no known issues on Linux or macOS systems using either
compiler suite and its standard runtime libraries (GCC: libc,
libstdc++, and related; LLVM: libc++).

Other development tools required by |PLEXIL| are common in many Linux
or macOS development environments.  They are usually available through
native package managers on Linux distributions, `MacPorts
<https://www.macports.org/>`_ or `Homebrew <https://brew.sh/>`_ on
macOS, or the ports systems on BSD-derived platforms.

The following are required to build |PLEXIL| from the tarball releases:

-  POSIX-compliant 'tar' utility with support for gzip compression
-  POSIX-compliant shell (e.g. `GNU
   bash <https://www.gnu.org/software/bash/>`_,
   `Dash <https://wiki.archlinux.org/title/Dash>`_,
   `zsh <http://zsh.sourceforge.net/>`_,
   `Busybox <https://www.busybox.net/>`_, etc.)
-  A 'make' utility, e.g. `GNU Make <https://www.gnu.org/software/make/>`_
-  `CMake <https://cmake.org/>`_ (optional)

.. note::

   The autotools-generated build scripts included in the tarball
   *should* work with other 'make' variants, e.g. BSD 'make', but are
   not tested with those variants.

If you are building from raw source, e.g. a git clone, you will also
need:

-  `GNU gperf <https://www.gnu.org/software/gperf/>`_ perfect hash
   generator
-  CMake, or
-  The `GNU autotools <https://www.gnu.org/software/automake/faq/autotools-faq.html>`_:
   `autoconf <https://www.gnu.org/software/autoconf/>`_,
   `automake <https://www.gnu.org/software/automake/>`_, and
   `libtool <https://www.gnu.org/software/libtool/>`_

.. note::

    The ``libtool`` utility provided with Apple's `Xcode
    <https://developer.apple.com/xcode/>`_ development tools is not an
    equivalent to, nor a substitute for, GNU libtool.  If you wish to
    build |PLEXIL| from raw source on macOS, you can either install
    GNU libtool or use CMake.  Both approaches are well tested.

The compilers and translators, |PLEXIL| Viewer, and several other
tools are written in portable Java.  A Java 8 or newer runtime is
required to run the prebuilt Java jars in the tarball distribution.
|PLEXIL| is regularly tested with the following Java JDK environments:

-  `OpenJDK <https://jdk.java.net/>`_ - Oracle licensed
-  `Eclipse Temurin <https://adoptium.net/>`_ - GNU General Public License v2.0, with the Classpath Exception

|PLEXIL| jar files may run successfully on other Java runtime
implementations, but the development team has no experience with them.

We recommend using a Long Term Support (LTS) Java release, such as
OpenJDK releases 8, 11, or 17.

The following software packages are required to build |PLEXIL| Java
software from source:

- Java development environment (compiler, etc.) for the chosen JDK
  runtime

- `Apache ant <https://ant.apache.org/>`_ version 1.7 or newer - the
  antlr add-ons are also required to build the Plexilscript compiler

To build the RoboSim graphical robot simulator example, additional `X
Window System <https://www.x.org/wiki/>`_ and
`OpenGL <https://www.opengl.org/>`_ packages are required:

-  libXi (X11 Input Extension) and its development header files
-  libXmu and its development header files
-  `mesa <https://www.mesa3d.org/>`_ - open source implementation of
   OpenGL
-  libGLU (OpenGL Utilities library) and its development header files
-  `freeglut <https://freeglut.sourceforge.net/>`_ (OpenGL Utilities
   Toolkit) and its development header files

The XML schema validation tool in the ``schema/validator``
subdirectory requires Python 3.5 or newer.  It is unlikely that a
typical |PLEXIL| end user will ever need this tool.  The development
team uses it for regression testing of compilers and translators.


.. _embedded_applications:

Embedded applications
=====================

The |PLEXIL| Executive has been successfully demonstrated on embedded
platforms, notably embedded Linux and the `VxWorks
<https://www.windriver.com/products/vxworks>`_ real-time operating
system.


.. _runtime_hardware:

Hardware
~~~~~~~~

The Executive code base is actively maintained on Intel/AMD x86
architectures under both 32- and 64-bit environments.  It has been
successfully built and tested on 32-bit PowerPC and ARM hardware.  It
should be portable to other 32- and 64-bit architectures with minimal
effort.

Support for IEEE 754 double precision floating point arithmetic is
required.  Hardware floating point is preferred, but software floating
point has been shown to work.

Runtime memory requirements vary by platform and application.  The
Executive should run adequately on most systems with at least 16 MB of
RAM, including embedded platforms.  Large |PLEXIL| plans may require
more RAM.


.. _embedded_operating_systems:

Embedded operating systems
--------------------------

The |PLEXIL| Executive has been demonstrated on these embedded platforms:

-  `VxWorks <https://www.windriver.com/products/vxworks>`_ real time
   operating system on 32-bit PowerPC
-  `Buildroot <https://buildroot.org/>`_ embedded Linux on 32-bit ARM


.. _cross_compilers:

Cross compilers
---------------

Many embedded development toolchains use GCC as a cross-compiler.  The
|PLEXIL| release 4.6 source code should build on any GCC release
`since 4.3 <https://gcc.gnu.org/projects/cxx-status.html>`_ without
errors.

.. note::

  Some older RTOS releases provide C header files which do not comply
  with the C99 standard.  These target platforms may require minor
  modification of the PLEXIL source code to include the appropriate
  header files.


.. _required_libraries:

Required libraries
~~~~~~~~~~~~~~~~~~

The PLEXIL Executive requires a C99-compliant C runtime, and a C++
runtime compatible with the C++ compiler.

The |PLEXIL| Executive has been demonstrated on embedded Linux with
`uClibc-ng <https://www.uclibc-ng.org/>`_, a lightweight open-source
standard C library on embedded Linux, and on VxWorks using the
standard VxWorks C runtime, with only minor modifications to the
Executive source.  Other standards-compliant C runtime libraries may
work, but the PLEXIL team has not tested them.

The PLEXIL team is aware of some reduced C++ Standard Library
implementations, but has no experience with them.  We welcome user
feedback.

Use of the following APIs is optional, and can be disabled at build
time:

- The POSIX dynamic linking and loading API (e.g. libdl). While useful
  for loading interface libraries at runtime, dynamic linking and
  loading is not essential.

- POSIX multithreading API (a.k.a. "pthreads").  The ``universalExec``
  and StandAlone Simulator applications require POSIX threads,
  mutexes, and semaphores.  Other thread APIs may be usable with
  modest effort; e.g. a thin abstraction layer allows the Executive to
  use either POSIX semaphores, or macOS's native Mach semaphores.

.. note::

   The Executive engine is exclusively single-threaded.  A subset of
   the Application Framework interfacing API can be used without
   threading.  A |PLEXIL| Executive application can be integrated into
   a single-threaded environment, e.g. a service worker thread, as
   part of a larger multithreaded application.  The NASA AOS
   PLEXIL-cFS app (link to be supplied) uses the |PLEXIL| Executive in
   this fashion.
