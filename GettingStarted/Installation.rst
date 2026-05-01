.. _Installation:

Installation
=============

*Updated 22 Apr 2026*

This page describes how to get and install |PLEXIL|. Familiarity with a
Unix-like operating system (e.g. Linux, macOS) is assumed.

.. contents::

.. _getting_plexil:

Getting PLEXIL
--------------

There are two ways to get |PLEXIL|:

-  Clone the source code from the ``git`` repository hosted here on
   GitHub, and then build the system.
-  Download a compressed archive (*tarball*) of the sources and prebuilt
   Java jar files.

In either case, the |PLEXIL| Executive and other C++ based tools must
be compiled from source. The tarball format includes prebuilt Java jar
files for the Standard |PLEXIL| and Plexilscript compilers, the
|PLEXIL| Viewer, and the |PLEXIL| static checker;

.. _git:

git
~~~

|PLEXIL| source code may be checked out from the repository on
GitHub.

The following command will get the latest stable version of the source
code (currently the ``releases/plexil-6`` branch):

::

    git clone -b releases/plexil-6 https://github.com/plexil-group/plexil.git plexil

This will create a directory named ``plexil`` with all the source files.

.. _Tarball:

Tarball
~~~~~~~

A tarball (compressed source archive file) will be made available soon.

The archive may be expanded by the archive utility on your platform, or
at the command line:

::

    tar xzf <tarball>

This will expand to a directory named ``plexil-6.1.2`` with all the
source and example files. This is the directory to use as
``PLEXIL_HOME`` in the procedures below.

Note that as the released version number changes, the directory name in
the archive will change accordingly.

.. _installing_plexil:

Installing PLEXIL
-----------------

The |PLEXIL| Executive and its examples are buildable with either `GNU
Make <https://www.gnu.org/software/make/>`_ or
`CMake <https://cmake.org/>`_. The C and C++ code complies with the
applicable language standards. See :ref:`Requirements <requirements>` for
details.

The top level ``README`` has additional information on configuring,
building, and running |PLEXIL|.

.. _basic_installation:

Basic installation
~~~~~~~~~~~~~~~~~~

These instructions presume a POSIX-compliant shell and GNU make.

* Unpack or clone the sources. See `Tarball <Tarball_>`_ or `git <git_>`_ above.

.. note::

    Plexil may not build correctly if installed in a directory that
    is a symbolic link, such as ``/tmp`` in macOS.

* Change into the source directory.

* Set up the environment. (This is not strictly necessary for the
   build, but will be for running programs.)

::

    PLEXIL_HOME="$PWD"
    export PLEXIL_HOME
    source "$PLEXIL_HOME/scripts/plexil-setup.sh"

* Build the desired components:

   #. For the |PLEXIL| Executive (universalExec), TestExec, compilers,
      checker, and |PLEXIL| Viewer: ``make tools``
   #. For all the above plus examples: ``make everything``

* The |PLEXIL| Executive and related programs will be installed into
   ``$PLEXIL_HOME/bin`` ; libraries are installed into ``$PLEXIL_HOME/lib``, and
   include files to ``$PLEXIL_HOME/include``. There are additional scripts
   (e.g. plexilexec, plexilc) in ``$PLEXIL_HOME/scripts`` .

.. _advanced_installation:

Advanced installation
~~~~~~~~~~~~~~~~~~~~~

The |PLEXIL| Executive can be configured for a wide variety of
applications and environments using either the GNU autotools or CMake.
See the top level README file for an outline.
