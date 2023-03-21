.. _ResourceModel:

Resource Model
==================

*20 Mar 2023*

This chapter describes the |PLEXIL| resource model for commands, and
associated language constructs.

.. contents::

Introduction
------------

.. note::

    Several issues have been identified in the resource model
    described herein. The information in this section is subject to
    change in a future release.

The |PLEXIL| language supports reasoning about bounded resource
availability and use.  The *resource model* allows specifying the
resource requirements of the commands in a plan, and initial resource
availability (and other characteristics) in a data file.  The |PLEXIL|
Executive checks resource requirements against existing allocations
and resource limits at the time of execution, and arbitrates between
competing requirements, rejecting commands when the combined usage of
any resource would exceed that resource's limit.


Concepts
--------

A *resource* is an entity of finite availability, which may be used in
execution of a command.

Resources can be characterized as *unary* or *non-unary*:

- A *unary* resource must be allocated as a single unit; either it is
  fully available, or fully allocated.  Only one command at a time may
  use a unary resource.

- A *non-unary* resource can be fractionally allocated, and shared by
  multiple commands, as long as the total usage does not exceed the
  available quantity of the resource.

Resource usage can be characterized as *renewable* or *consumable*:

- Resource usage is *renewable* if the amount allocated to a command
  becomes available again after the command finishes.

- Resource usage is *consumable* if the amount allocated to a command
  is no longer available after the command finishes.

Some examples illustrate these concepts:

- An office has a locked storeroom, which can only be opened by a
  shared key.  Only one user at a time can hold the key, and the user
  returns the key to a known location when they are done with it.  The
  key is a *unary* resource, because only one key is available, and it
  cannot be divided, nor can it be held by multiple users at once.
  The key is used in a *renewable* way, because it becomes available
  again once a user is finished with it.

- A non-unary resource may be used in both renewable and consumable
  fashion.  A location of a car rental agency has an initial inventory
  of cars (the resource), which are rented one to a customer.  This is
  a *non-unary* resource usage, because a customer does not rent the
  entire inventory.  Usually when a car is rented from the location,
  it is returned to the same location.  This is a *renewable* use of
  the inventory.  But a car can also be rented for a one-way trip, in
  which case it will not be returned to the original location when the
  rental period is complete.  From the location's perspective, this is
  a *consumable* use of its inventory.

- An electrical system consists of a battery, a fuse connecting the
  battery to the rest of the system, and several switched devices.
  The battery starts with a fixed charge, and is not rechargeable. The
  fuse will blow if power is drawn too rapidly.  Each device uses
  power at a particular rate when it is turned on, and each device
  uses energy as the product of its power usage and the length of time
  it is turned on.

  This system could be modeled as having two resources: the *energy*
  stored in the battery, and the *power* rating of the fuse.

  If the fuse blows, or the battery is discharged completely, the
  system ceases to function.  Therefore, a plan to control the system
  must respect usage limits on both battery energy and fuse power.

  In this example, both battery energy and fuse power are *non-unary*
  resources.  Multiple devices can use energy simultaneously, and
  multiple devices can use power simultaneously, as long as the
  combined utilization remains within their respective limits.

  Fuse power is used in a *renewable* way.  Power drawn by a device
  counts against the fuse rating while the device is on, but not when
  the device is turned off.

  Conversely, battery energy is *consumed*.  The energy used while the
  device is on is no longer available after the device is turned
  off. The battery is left with a lower energy level.

Approach
--------

Resource handling in |PLEXIL| has these aspects:

#. A Command node in a |PLEXIL| plan can specify *resource
   requirements* on one or more resources, and a *priority* used in
   the event of resource contention.  The command is executed only if
   all of its resource requirements can be satisfied at the instant
   the containing Command node enters the ``EXECUTING`` state.

#. Each command has an associated *command handle* variable to record
   the results of resource arbitration and command execution.

#. An optional *resource data file* specifies initial quantities of
   each resource (and other resource characteristics to be discussed).
   The resource file is read at |PLEXIL| Executive startup.  Resources
   not specified by a resource file are assigned an initial quantity
   of 1.0.

#. A *resource arbiter* tracks resource usage during plan execution.
   The arbiter compares new resource requests against resource limits
   and existing allocations, and selects the maximal subset of
   commands which can be executed without exceeding resource limits.
   The arbiter sets the command handles of rejected commands to
   ``COMMAND_DENIED``.  For more detail on the resource arbiter, see
   the :ref:`Resource Arbiter <ResourceArbiter>` chapter.


.. _resource_specification:

Resource Specification
~~~~~~~~~~~~~~~~~~~~~~

A command's resource requirements are specified in a |PLEXIL| plan in
the following way.

::

   Resource
     // required fields
     Name = <String expr>,
     Priority = <Integer expr> // smaller numerical value = better priority
     // optional fields
     , UpperBound = <Real expr> // default=1.0
     , ReleaseAtTermination = <Boolean expr>  // default = true
     ; 

For example:

::

   Command c1();

   C1:
   {
     Resource Name = "left_arm", Priority = 10;
     Resource Name = "right_arm", Priority = 10;
     Resource Name = "memory",
       UpperBound = 20.0,
       ReleaseAtTermination = false,
       Priority = 10;

     c1();
   }

This example states that the command ``c1()`` requires use of the left
arm and the right arm (as unary resources) while it is executing
(renewable use), and permanently consumes at most 20.0 units of
memory (as a non-unary resource).

The mandatory ``Priority`` property influences the order of
arbitration in the event that multiple commands request the same
resource(s) in the same macro step.  Commands with a lower numerical
priority are preferred.  If multiple commands have the same priority
value, their requests are evaluated in an arbitrary order.  Commands
started in a previous macro step are never preempted, irrespective of
their priority.

.. note::

   As implemented in the |PLEXIL| Executive, the resource arbiter
   considers only the Priority field of the first resource
   requirement.  The Priority fields of all other resource
   requirements are ignored.

.. note::

   The Priority field will move from the command resource to a Node
   attribute in a future PLEXIL release.

The ``UpperBound`` property specifies the amount of the resource
request.  A resource request without an ``UpperBound`` is presumed to
be unary, i.e. its resource usage defaults to 1.0.

The ``ReleaseAtTermination`` property specifies whether the resource is
released at command completion. Its default value is ``true``. In the
above example, the ``c1`` command will not release (will consume) the
``memory`` resource when it terminates.

Several sample plans are given in the Examples sections referenced below.


.. _resource_arbitration:

Resource Arbitration
~~~~~~~~~~~~~~~~~~~~

Commands are issued at the end of a :ref:`macro step
<micro_steps_macro_steps_and_the_quiescence_cycle>`, when the
containing Command node enters ``EXECUTING`` state. All the commands
eligible for execution at the end of the macro step are sent to the
*resource arbiter*. The arbiter considers each of the commands and
their resource requirements, and accepts the maximal subset that can
be performed without exceeding resource availability. The accepted
commands are then sent to the external system.

Each command rejected by the arbiter has its command handle set to
``COMMAND_DENIED``. In the absence of an ``EndCondition``, the Command
node will transition to ``ITERATION_ENDED`` state; in the absence of a
``PostCondition``, its outcome will be ``SUCCESS``.

A |PLEXIL| plan can specify the next course of action in the event a
command is rejected.  For example, the command could be reissued, etc.

The resource arbiter is explained in further detail in :ref:`Chapter
10 <ResourceArbiter>`.


.. _command_handles:

Command Handles
~~~~~~~~~~~~~~~

A *command handle* variable is associated with each command, and
records the results of resource arbitration and execution.

#. When a Command node enters the ``EXECUTING`` state, the command
   handle variable is initialized to the distinguished value
   *unknown*.

#. A command with no resource requirements is sent directly to the
   external interface for execution by the external system.

#. A command with resource requirements is considered by the resource
   arbiter, to determine whether the requirements can be met at that
   instant.  The arbiter can *accept* or *deny* the command.  If
   accepted, the command is sent to the external interface for
   execution by the external system.  If denied, the command's command
   handle is set to ``COMMAND_DENIED``, and the command is not sent to
   the external interface.

#. Finally, the external system acknowledges each executed command.
   The command handle is set to the acknowledgement value.

It will be worthwhile to inform the executive as to what stage of its
journey the command is in for more reasons than just book-keeping. The
plan could, for instance, use a particular state of the command to start
or stop other nodes.

Command handles may take one of the following values:

-  ``COMMAND_ACCEPTED``
-  ``COMMAND_ABORTED``
-  ``COMMAND_ABORT_FAILED``
-  ``COMMAND_DENIED``
-  ``COMMAND_FAILED``
-  ``COMMAND_INTERFACE_ERROR``
-  ``COMMAND_RCVD_BY_SYSTEM``
-  ``COMMAND_SENT_TO_SYSTEM``
-  ``COMMAND_SUCCESS``

The |PLEXIL| Executive sets the command handle values in these
situations:

- When the resource arbiter rejects a command due to inadequate
  resources, the command handle is set to ``COMMAND_DENIED``.

- When a Command node fails or is exited, the node enters the
  ``FAILING`` state, and the external interface issues a *command
  abort*.  If the external system acknowledges the abort with a
  ``true`` value, the command handle is set to ``COMMAND_ABORTED``.
  If the abort is acknowledged with a ``false`` value, the command
  handle is set to ``COMMAND_ABORT_FAILED``.

- When an error is detected in the external interface, the command
  handle is set to ``COMMAND_INTERFACE_ERROR``.

- When an external system acknowledges a command with a legal command
  handle value, the command handle is set to that value.

.. note::

    An external system is free to acknowledge commands with any legal
    command handle value.  However, we recommend using only
    ``COMMAND_FAILED`` to indicate some external error, and either
    ``COMMAND_SUCCESS`` or ``COMMAND_SENT_TO_SYSTEM`` to indicate
    successful completion (or transmission) of the command.


Command handles and Command node completion
-------------------------------------------

When the EndCondition of a Command node in the ``EXECUTING`` state
becomes ``true``, the node transitions to the ``FINISHING`` state.
The node will remain in this state until any command handle value has
been assigned in one of the ways described above.  At that time, the
node transitions to the ``ITERATION_ENDED`` state.

The default EndCondition of a Command node is ``true``.

If an explicit EndCondition is supplied, the effective expression used
for the EndCondition is:

::

   Self.command_handle == COMMAND_DENIED
    || Self.command_handle == COMMAND_FAILED
    || Self.command_handle == COMMAND_INTERFACE_ERROR
    || <user EndCondition>


Aborting a command
------------------

When a Command node fails or is exited, it transitions to the
``FAILING`` state, and its command is *aborted* .  The node
subsequently transitions to ``ITERATION_ENDED`` after the abort has
been acknowledged by the external system.

The command handle is set to ``COMMAND_ABORTED`` if the
acknowledgement value is ``true``, or ``COMMAND_ABORT_FAILED`` if the
acknowledgement is ``false``.  See :ref:`interfacing
<InterfacingOverview>` for more information.

Any resources allocated to an aborted command will remain allocated
until an acknowledgement of the abort is received from the external
system.


Using command handles in condition expressions
----------------------------------------------

Command handle variables can be used in expressions in the Command
note itself, sibling nodes, or parent nodes.

The sample plan below illustrates one possible use.  The plan has two
Command nodes, ``Drive`` and ``NextWaypoint``.  Using a
StartCondition, we can make the NextWaypoint node issue a command
*after* the Drive node receives the ``COMMAND_RCVD_BY_SYSTEM`` signal
from the external system.

::

   Integer Command drive();
   Command next_waypoint();

   SimpleDrive:
   Concurrence
   {
     Drive:
     {
       Integer returnValue = -1;
       EndCondition returnValue == 10;
       PostCondition Drive.command_handle == COMMAND_SUCCESS;
       returnValue = drive();
     }

     NextWaypoint:
     {
       StartCondition Drive.command_handle == COMMAND_RCVD_BY_SYSTEM;
       next_waypoint();
     }
   }


.. _examples:

Examples
--------

.. toctree::
   :maxdepth: 1
   :hidden:

   Simple Unary Resources <ResourceModel/SimpleUnaryResources>
   Non-Unary Resources <ResourceModel/NonUnaryResources>
   Renewable Resources <ResourceModel/RenewableResources>
   Hierarchial Resources <ResourceModel/HierarchialResources>

-  Example 1: :ref:`Simple unary resources <SimpleUnaryResources>`
-  Example 2: :ref:`Non-unary resources <NonUnaryResources>` is a
   variation of the previous example with one of the resources
   represented as a non-unary resource.
-  Example 3: :ref:`Hierarchical resources <HierarchialResources>`
   illustrates a command with interrelated resources.
-  Example 4: :ref:`Renewable resources <RenewableResources>` illustrates
   a command that *generates* resources (as opposed to consuming them).
