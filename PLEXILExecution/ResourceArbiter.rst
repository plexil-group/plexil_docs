.. _ResourceArbiter:

ResourceArbiter
=================

*21 Mar 2023*

This chapter describes in greater detail |PLEXIL|'s *resource arbiter*,
which was introduced in the :ref:`Resource Model <ResourceModel>` chapter.

.. contents::

Design
------

The Resource Arbiter, a component of the |PLEXIL| Executive, tracks
resource usage during plan execution against resource limits, and
prevents the execution of commands whose resource requirements would
violate those limits.  The diagram below gives an overall idea of the
resource model implemented in the executive. (Note: *UE*, which stands
for *Universal Executive*, is an outdated name for the *PLEXIL
Executive*).

.. figure:: ../_static/images/Resourcemodel.jpg

The resource arbiter sits between the Executive and the external
interface, and mediates command execution.  The Executive sends
commands and their resource requirements to the resource arbiter.  The
arbiter's task is to select the largest subset of commands which can
be executed without exceeding resource limits.  The selected commands
are forwarded to the external interface; commands not selected are
marked as denied.  The |PLEXIL| language allows a plan to check for
this possibility, and to attempt to retry denied commands at a later
time.

Capabilities
------------

The resource arbiter provides the following capabilities:

-  Tracks resource usage throughout plan execution;

-  Arbitrates commands competing for resources;

-  Takes command priority into account during arbitration;

-  Prevents resource over-allocation.

The resource arbiter does not:

-  Query the external system;

-  Consider command duration.

.. _the_basic_algorithm:

The Basic Algorithm
-------------------

#. Commands may *consume* a positive quantity, or *produce* a negative
   quantity, of a resource.
#. Requested resources are considered to be consumed (produced) when a
   command begins execution.
#. Requested resources are considered returned (removed) when that
   command finishes execution, if the resource request's
   ``ReleaseAtTermination`` parameter is ``true`` (the default),
   otherwise the resource allocation remains in effect indefinitely.
#. The arbiter considers the resource requirements of all Command
   nodes which have transitioned to ``EXECUTING`` in the same macro
   step.
#. The arbiter evaluates resource requests in priority order, from
   best (smallest numerical priority value) to worst (largest value).
   If multiple commands have the same priority, the arbiter will
   evaluate their requests in an unspecified order.
#. The arbiter considers resource consumption (positive requests) and
   production (negative requests) separately during a single macro
   step, starting from the amount of each resource allocated prior to
   arbitration.
#. The sum of the previous allocation of a resource, and a command's
   consumptive (positive) request, may not exceed the resource's
   declared maximum (default 1.0).
#. The sum of the previous allocation of a resource, and a command's
   productive (negative) request, may not go below 0.
#. The arbiter accepts a command only if *all* the command's resource
   requests can be satisifed at the instant its requests are evaluated.
#. The arbiter accepts the maximal subset of commands whose resource
   requirements, combined with the resources already allocated to
   previously executed commands, will not violate resource limits.
#. Accepted commands are sent to the external system.
#. Rejected commands have their command handle values set to
   ``COMMAND_DENIED``.  Their Command *nodes* will have executed, but
   no commands will be issued to the external system.

Limitations of the current implementation
-----------------------------------------

The implemented behavior of the resource arbiter differs from the
|PLEXIL| language specification as follows:

#. The resource arbiter uses the priority value of a command's first
   resource requirement, and ignores the priorities of any remaining
   requirements.
#. Lower bounds of resource requirements are ignored.

A future |PLEXIL| release will eliminate per-resource priorities and
resource lower bounds from the language.

.. _resource_configuration_file:

Resource Configuration File
---------------------------

The resource arbiter obtains the identity of resources from the
command itself.  When all commands using a particular resource have
completed, the resource arbiter purges the resource from its database.

The default initial value for a resource is 1.0.

*A priori* resource availability, and other properties, can be
specified in a *resource data file*, read by the resource arbiter at
|PLEXIL| Executive startup.  The default location for this file is
``resource.data`` in the current working directory.  Other locations
for the resource data file can be specified on the Executive command
line by using the ``-r`` option.

In its simplest form, the resource data file contains a list of
resource names with their total availability.

The resource file can also specify interdependencies between
resources.  These dependencies can be represented in the form of a
weighted Directed Acyclic Graph.  The schematic shown below shows the
general structure of such a graph and the format of the configuration
file. The weights represent the absolute value of the resource usage.
  
.. figure:: ../_static/images/Dagresources3.jpg

Using the example above, whenever 1 unit of ``resource1`` is
requested, *w1_2* units of ``resource2``, *w1_3* units of
``resource3``, and *w1_4* units of ``resource4`` are also requested
automatically.

Because ``resource2`` has its own dependent resources, *w1_2* units of
``resource5`` and ``resource6``, and *w1_2 x w2_7* units of
``resource7`` are also requested.

Similarly, ``resource3`` has a dependent resource ``resource8``, and
for every unit of ``resource3`` requested, a unit of ``resource8`` is
also requested.

Summing up the above example, for every unit of ``resource1``
requested, automatic requests are generated for:

* *w1_2* units of ``resource2``,
* *w1_3* units of ``resource3``,
* *w1_4* units of ``resource4``,
* *w1_2* units of ``resource5``,
* *w1_2* units of ``resource6``,
* *w1_2 x w2_7* units of ``resource7``, and
* *w1_3* units of ``resource8``.

Several example resource data files can be found in the directory
``plexil/examples/resources``.
