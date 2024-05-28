.. _PLEXIL_4_6_ReleaseNotes:

PLEXIL 4.6 Release Notes
========================

*30 Jan 2024*

|PLEXIL| 4.6 is a major evolutionary release, with improved
performance, reduced memory footprint, and mostly upward compatible
changes from previous releases in the 4.x series.  This document
describes changes since the 4.0.1 release.  See
:ref:`PLEXIL4ReleaseNotes` for changes prior to 4.0.1.


.. contents::

.. _plexil_4_6_obtaining:

Obtaining PLEXIL
----------------

* The `git repository at GitHub
  <https://github.com/plexil-group/plexil>`_ is now the only
  authoritative public repository for |PLEXIL|.  The previous git and
  Subversion repositories at Sourceforge are no longer maintained.

* The `pugixml <https://pugixml.org/>`_ XML library is now integrated
  as a git submodule.  Before attempting to build |PLEXIL| from a git
  clone, be sure to pull in submodules with::

    git submodule update --init --recursive


.. _plexil_4_6_packaging:

Packaging
---------

* Symbolic links have been removed from the source code tree.  This
  should ease building and using |PLEXIL| on platforms such as
  Microsoft Windows Subsystem for Linux.  (This change was part of the
  motivation for integrating pugixml as a submodule.)

* Support for the `CMake <https://cmake.org/>`_ build system has been
  implemented.  This should simplify integration of the |PLEXIL|
  Executive into projects using this popular build system.  CMake
  support is a priority for future releases.

* Both GNU autotools and CMake build systems now support building the
  Executive in statically or dynamically linked configurations.
  Continuous integration now tests both build systems in both
  configurations at every commit.

* The top-level Makefile no longer presumes the C and C++ compilers
  are named ``gcc`` and ``g++`` respectively.  Like most
  Makefile-based packages, the values of environment variables ``CC``
  and ``CXX`` are used.  If these are not bound, ``cc`` and ``c++``
  are used by default.  The development team routinely builds PLEXIL
  with a variety of GCC and clang (llvm) versions.

* ``make distclean`` at the top level of the PLEXIL distribution
  should delete all build artifacts, including GNU autotools-generated
  files.  This can be useful when an existing git clone is updated,
  and incompatible changes have been made in the source tree or build
  system.

* Many of the shell scripts in the distribution have been checked with
  the `shellcheck <https://www.shellcheck.net/>`_ static checker, and
  consequently many actual and potential bugs have been fixed.  Many
  scripts which previously required the GNU Bash shell now use only
  POSIX standard (Bourne) shell features.  These changes should
  improve portability to POSIX-compliant platforms which lack Bash,
  e.g. many embedded Linux systems, or which use an obsolete version
  of Bash, such as macOS.  Thanks to 2020 summer intern Bryce
  Campbell, whose testing on Microsoft Windows Subsystem for Linux
  motivated this cleanup.

* Many of the shell scripts no longer require ``PLEXIL_HOME`` to be
  set, and the ``scripts/plexil-setup.sh`` script to be sourced, prior
  to script execution.  Instead, the scripts will make an educated
  guess about its value, and will report an error if the guess is
  wrong.

* The Java programs in the distribution now require at least Java 8.


.. _plexil_4_6_language:

PLEXIL Language
---------------

Changes to all dialects of the |PLEXIL| language:

* The literal constants ``COMMAND_ABORTED``, ``COMMAND_ABORT_FAILED``,
  and ``COMMAND_INTERFACE_ERROR`` are now accepted as legal
  ``NodeCommandHandle`` values by the Executive, the Standard PLEXIL
  compiler, and the Extended PLEXIL translator.

* New node state and outcome predicates ``Executing``, ``Finished``,
  ``Inactive``, ``IterationEnded``, ``NoChildFailed``, ``Succeeded``,
  and ``Waiting`` accept either a ``NodeName`` or a ``NodeRef`` as
  their argument.

* New wildcards ``Any`` type for a single parameter name, and optional
  ``AnyParameters`` element for any number of parameters of any type,
  are supported in command and state declarations.

* New array accessor function ``ArrayMaxSize`` returns the declared
  size of the array as an ``Integer``.

* ``Equal`` and ``NotEqual``, and their Standard PLEXIL synonyms
  ``==`` and ``!=`` respectively, are now also implemented for arrays.

* ``LibraryNodeCall`` nodes can now reference the called node in
  conditions.


.. _plexil_4_6_standard_plexil:

Standard PLEXIL
---------------

* The ``SynchronousCommand`` action adds a ``Checked`` option, and a
  bug in the ``Timeout`` option has been fixed.  See
  :ref:`plexil_4_6_extended_plexil` for details.

* The ``Do`` action implements a classic "do-while" loop.  See
  :ref:`plexil_4_6_extended_plexil` for details.

* ``LibraryNode`` has been added as a synonym for ``LibraryAction``, by
  popular demand.

* Backward compatibility has been improved for the ``If`` action.  The
  compiler now properly supports both modern (C-like) and previous
  (``If ... Then ... Elseif ... Else ... Endif``) syntaxes.  The
  ``Endif`` keyword, if present, is treated as a noise word; any
  trailing semicolon after ``Endif`` is also treated as a noise word.
  New plans should omit ``Endif``.

* The Standard PLEXIL compiler now parses ISO 8601 date and duration
  syntax, and will complain about invalid ``Date`` or ``Duration``
  literals.

* The new action ``CheckedSequence`` has semantics identical to
  ``Sequence``.  A future release will alias ``Sequence`` to
  ``UncheckedSequence``.  We encourage you to start using
  ``CheckedSequence`` explicitly when appropriate.

* Expressions of indeterminate type at compile time (e.g. ``Lookup``
  of an undeclared state name) are now legal as ``Command`` name
  expressions.  They will still provoke a run time error if the
  expression does not return a ``String`` value.

* Tolerance for the ``Wait`` action now defaults to the requested
  delay time (was 1 second).

* The compiler's optimization phase is better at identifying
  degenerate nodes (e.g. nodes wrapping a ``Command`` or
  ``Assignment`` statement without conditions, declarations, or
  attributes), and omitting them from the generated output.

* The compiler can now output either formatted or unformatted Core
  PLEXIL XML, selectable at compile time.  The default is unformatted.
  Formatted output is selected by the ``-p`` or ``--pretty-print``
  command line option to the ``plexilc`` compiler driver script.

* The ``plexilpp`` script runs the C preprocessor on Extended Plexil
  code prior to compilation.  This is handy when you wish to share
  ``Command``, ``Lookup``, ``LibraryNode``, or ``LibraryAction``
  declarations across a number of |PLEXIL| plans

* The ``plexilc`` script now recognizes file names ending in ``.plp``
  as Standard PLEXIL with preprocessor directives, and runs
  ``plexilpp`` on such files prior to compilation.


.. _plexil_4_6_extended_plexil:

Extended PLEXIL
---------------

* The ``SynchronousCommand`` macro now implements a ``Checked`` option, as
  described above.  The wrapper ``NodeList`` node of a ``SynchronousCommand``
  with the ``Checked`` option fails if the wrapped ``Command`` node fails.  A
  bug in the ``Timeout`` option has also been fixed, and the schema
  amended to locate the ``Tolerance`` option inside the ``Timeout`` element.
  See the Extended PLEXIL schema (schema/extended-plexil.xsd) for the
  syntax, and the translator test suite for examples.  Thanks
  to J. Bohren of Honeybee Robotics for the suggestion.

* The new ``Do`` macro implements a classic 'do-while' loop.  The
  ``while`` conditional expression is used as the node's
  ``RepeatCondition``.  The translator test suite has been extended
  with examples.

* The new ``CheckedSequence`` macro expands identically to
  ``Sequence``.  A future release will alias ``Sequence`` to
  ``UncheckedSequence``.  We encourage you to start using
  ``CheckedSequence`` explicitly when appropriate.

* Tolerance for the ``Wait`` macro now defaults to the requested delay
  time (was 1 second).


.. _plexil_4_6_core_plexil_executive:

Core PLEXIL and the Executive
-----------------------------

* ``DeclareVariable`` and ``DeclareArray`` now accept variable
  references as well as literals as initial value specifiers.

* The Executive's XML parser now does more thorough checking of plans
  as they are loaded.  Reloading library nodes is now faster, as most
  checks are now done only once, when the library is first loaded.

* Numerous bug fixes.


.. _plexil_4_6_standard_interfaces:

Standard Interfaces
-------------------

* The TCA-IPC package included in this distribution is no longer
  maintained by its originators.  It is known not to build on Apple
  Silicon Macs.

* UUID generation for the IpcAdapter is now done via the POSIX
  standard random generator utility ``/dev/urandom``.  The previous
  version depended on a third-party software package, ``ooid``, which
  hadn't been updated in many years.

* ``Utility`` adapter Commands ``print`` and ``pprint`` now correctly send
  a command handle value of ``COMMAND_SUCCESS`` when they return.
  Previously this had been omitted, resulting in some plans failing to
  terminate after a ``print`` or ``pprint`` command.

* The ``Dummy`` adapter has been removed; the behavior it implemented is
  now the default for unimplemented interfaces.  References to it
  should be removed from interface configuration files.

* ``TimeAdapter``, which uses platform-native time APIs, has been
  refactored, and has been made robust against early wakeups.

* A new ``Launcher`` adapter allows plans to load and run other plans,
  and query execution status of those plans.  An illustrative example
  can be found in the ``examples/launcher`` directory.

* Word size confusion in ``UdpAdapter`` has been fixed, and commanding
  has been made more robust.

* ``LuvListener`` (a.k.a. the PLEXIL Viewer interface) should no
  longer print ``MARK`` at startup.  A segfault bug has been fixed.

* ``GanttListener`` is deprecated, and will be removed in a future
  release.


.. _plexil_4_6_external_interfacing:

External Interfacing
~~~~~~~~~~~~~~~~~~~~

* The PLEXIL Application Framework has been completely overhauled, in
  a (mostly) backward-compatible fashion.

  User-defined interface adapters no longer have to check and dispatch
  on Command or Lookup names.  The new API is based around command and
  lookup *handlers*, class instances or ordinary functions which can
  be specialized to particular commands and lookups.  Handlers can be
  registered to specific Command and Lookup names, or as a *default*
  handler for Commands and Lookups without specific handlers.

  Existing ``InterfaceAdapter`` specializations will continue to work
  in PLEXIL 4 series releases.  However, the forthcoming PLEXIL 6
  release will remove ``InterfaceAdapter::executeCommand()``,
  ``InterfaceAdapter::lookupNow()``, and related APIs, in favor of a
  handler-centric API similar to the one introduced in this release.

* The argument list to the
  ``ExecListener::implementNotifyNodeTransition()`` abstract member
  function has changed incompatibly. The old prototype was::

    void ExecListener::implementNotifyNodeTransition(NodeState prevState,
                                                     Node *node) const;

  The new prototype is::

    void ExecListener::implementNotifyNodeTransition(NodeState prevState,
                                                     NodeState newState,
                                                     Node *node) const;

  The change was made to improve performance in the Executive's core.
  Previously, this abstract method was called once for every node
  state transition during a micro cycle.  In this environment, the new
  node state value could be obtained directly from the ``Node`` instance.

  Now, for efficiency reasons, node state transitions are batched and
  reported at the end of each macro cycle.  By the time this member
  function is called, the state of the node may have changed multiple
  times.  So it is now necessary to save and explicitly pass both old
  and new states to the listener.

* New member function ``ExecApplication::allPlansFinished()`` returns
  true when at least one plan has been started, and all plans which
  had been started have finished.

* The ``LookupNames`` interface configuration element adds a
  ``TelemetryOnly`` attribute.  ``LookupNow`` for these names will not
  call the relevant adapter's ``lookupNow()`` method, but instead get
  values from the state cache.

* The Lookup state cache now stores all values received via
  ``InterfaceManager::handleValueChange()``, whether or not the supplied
  state has ever been looked up.  This change was implemented
  to support ``TelemetryOnly``.

* Type aliases are defined in the ``PLEXIL`` namespace for types
  ``Boolean``, ``Integer``, ``Real``, and ``String``.  User-developed
  interfaces should use these aliases in preference to the
  implementation types ``bool``, ``int``, ``int32_t``, ``double``, and
  ``std::string``.  This will help reduce platform dependence and
  insulate interface code from potential changes to the implementation
  types.
