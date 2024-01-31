.. _Installation:

************
Installation
************

*30 Jan 2024*

This page describes how to get and install |PLEXIL|.  Familiarity with
command line usage on a Unix-like operating system (e.g. Linux, macOS)
is assumed.

This document describes the ``releases/plexil-4.6`` branch of
|PLEXIL|.  Installation for other branches should be similar, but may
have different prerequisites.

.. contents::

.. _getting_plexil:

Getting PLEXIL
==============

There are two ways to get |PLEXIL|:

-  Download a compressed archive (*tarball*) containing sources and
   some prebuilt artifacts.

-  Clone the source code from the ``git`` repository hosted here on
   GitHub.

In either case, the |PLEXIL| Executive must be compiled from source. The
tarball format includes prebuilt Java jars for the Standard |PLEXIL| and
Plexilscript compilers, the |PLEXIL| Viewer, and the |PLEXIL| static
checker; therefore it is the recommended distribution format for
exploring |PLEXIL| for the first time.

.. _Tarball:

Tarball
~~~~~~~

PLEXIL release archive files are available for download from the
`releases page <https://github.com/plexil-group/plexil/releases>`_
at GitHub. They are built with the GNU ``tar`` utility, hence the
nickname "tarball".

Downloaded archives may be expanded by the archive utility on your
platform, or at the command line:

::

    tar xzf plexil-4.6-alpha.tar.gz

This will expand to a directory named ``plexil-4.6-alpha`` with all the
source and example files. This is the directory to use as
``PLEXIL_HOME`` in the procedures below.

Note that as the released version number changes, the directory name in
the archive will change accordingly.

.. _git:

git
~~~

|PLEXIL| source code may be checked out from the repository on
GitHub.

The following sequence of commands will get the latest stable version
of the source code (currently the ``releases/plexil-4.6`` branch) and
submodules into a new directory named ``plexil``::

    git clone -b releases/plexil-4.6 https://github.com/plexil-group/plexil.git plexil
    cd plexil
    git submodule update --init --recursive


.. _deprecated_repositories:

Deprecated repositories
^^^^^^^^^^^^^^^^^^^^^^^

|PLEXIL| was formerly hosted on SourceForge.  The SourceForge
repositories are no longer maintained since 2023.  Please update any
links to point to the GitHub repository instead.


.. _installing_plexil:

Installing PLEXIL
=================

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

These instructions presume a POSIX-compliant shell and GNU ``make``.

* Unpack or clone the sources. See `Tarball <Tarball_>`_ or `git <git_>`_ above.

.. note::

    PLEXIL may not build correctly if installed in a directory that 
    is a symbolic link, such as ``/tmp`` in macOS.

* Change into the source directory.

* Set up the shell environment. (This is not strictly necessary for the
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
