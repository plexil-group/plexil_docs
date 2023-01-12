.. _ResourceModel:

Resource Model
==================

*10 Jan 2023*

This chapter describes the |PLEXIL| resource model for commands, and
its associated language constructs. See the :ref:`Resource Arbiter
<ResourceArbiter>` chapter for execution-related aspects of this
model.

.. contents::

Introduction
------------

.. note::

    Several issues have been identified in the resource model
    described herein. The information in this section is subject to
    change in a future release.

|PLEXIL| supports reasoning about bounded resource availability and
use. The *resource model* allows specifying the resource requirements
of the commands in a plan, and initial resource availability (and
other characteristics) in a data file. The |PLEXIL| Executive can
check resource requirements against availability at the time of
execution and arbitrate between competing requirements, rejecting
commands when the combined usage of any resource would exceed resource
availability.

A *resource* is an entity of finite availability, which may be used in
execution of a command.

Resources can be characterized as *unary* or *non-unary*. A *unary*
resource is so-called because it can only be allocated as a single
unit; the resource is either fully available, or fully allocated. Only
one command at a time may use a unary resource.

A *non-unary* resource can be partially or completely allocated.
Multiple commands may use a non-unary resource at once, as long as the
total use does not exceed the available quantity of the resource.

Resource usage can be characterized as *renewable* or *consumable*.
Resource usage is consumable if the amount used by a command is no
longer available after the command finishes.  Resource usage is
renewable if the amount used becomes available again at completion of
the command.

Some examples can illustrate these concepts.

Consider a shared key to a locked room. Only one user at a time can
hold the key. The user returns the key when they are done with it. The
key is a *unary* resource, because only one key is available. The key
is used in a *renewable* way, because it becomes available again once
a user is finished with it.

Another example: A simple electrical system consists of a battery, a
fuse connecting the battery to the rest of the system, and several
devices drawing energy from the battery. The battery is not
rechargeable; when it is completely discharged, it must be
replaced. The fuse will blow if the battery is discharged too rapidly;
the fuse must be replaced when it blows.

We can model this system as having two resources: the energy stored in
the battery, and the power rating of the fuse. When turned on, each
device uses power at a fixed rate, and uses energy as the product of
its power usage rate and the length of time it is turned on.

The consequences of exceeding the fuse rating or exhausting the
battery are severe. If we consume power too rapidly, the fuse will
blow, and the system will be disconnected from the battery. If we
discharge the battery completely, there is no energy left to run the
system. In either event, the result is a non-functional
system. Therefore, we need to enforce limits on both battery energy
and fuse power usage.

In this example, both battery energy and fuse power are *non-unary*
resources. Multiple devices can use energy simultaneously, and
multiple devices can use power simultaneously, within their respective
limits.

Fuse power is used in a *renewable* way. Power drawn by a device
counts against the fuse rating while the device is on, but not when
the device is turned off.

Conversely, battery energy is *consumed*. The energy used while the
device is on is no longer available after the device is turned
off. The battery is left with a lower energy level.

A resource may be used in both renewable and consumable
fashion. Example: A rental car agency at a particular site has an
initial inventory of cars, which are rented one to a customer (i.e. a
non-unary resource). Usually when a car is rented from that site, it
is returned to the same site. This is a renewable use. But a car can
also be rented for a one-way trip, and thus will not be returned to
the initial site when the rental period is complete. From the
site's perspective, this is a consumable use.

Approach
--------

Resource handling in |PLEXIL| has these aspects.

#. Specification of *command resource requirements* in the |PLEXIL|
   plan. A Command node can specify requirements on multiple
   resources, and a priority in the event of resource contention. The
   command is executed only if all of its resource requirements can be
   met when the containing Command node enters the ``EXECUTING`` state.

#. Each command has an associated *command handle* variable. The
   command handle stores the result of resource arbitration and
   command execution.

#. An optional *resource data file* sets the initial quantity of each
   resource (and other resource characteristics to be discussed). The
   resource file is read at |PLEXIL| Executive startup. Resources not
   specified in a resource file are given an initial quantity of 0.0.

#. A *resource arbiter* tracks resource usage during plan
   execution. The arbiter compares command resource requests against
   current resource levels, and selects a subset of commands to
   execute such that resource limits are not exceeded. The arbiter
   sets the command handles of rejected commands to
   ``COMMAND_DENIED``.

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

This example states that the command ``c1()`` requires exclusive
(renewable) use of the left arm and the right arm (unary resources)
while it is executing, and consumes at most 20.0 units of memory.

The ``Priority`` value influences arbitration in the event that
multiple commands request the same resource(s) in the same major step,
and there is not enough of the resource for all of them. Commands with
a lower numerical priority are preferred. If multiple commands have
the same priority, their requests are evaluated in an arbitrary
order. Commands started in a previous execution step are never
preempted, even if their priority is worse (numerically larger) than a
newly executed command.

**Note:** As implemented in the |PLEXIL| Executive, the resource
 arbiter considers only the Priority field of the first resource
 specification. All other Priority fields are ignored.

**Note:** The Priority field will move from the command resource to
 the Node in a future PLEXIL release.

A resource specification without an ``UpperBound`` value is presumed
to be unary, i.e. its resource requirement defaults to 1.0.

The ``ReleaseAtTermination`` field specifies whether the resource is
released at command completion. Its default value is ``true``. In the
above example, the ``c1`` command will not release (will consume) the
``memory`` resource when it terminates.

Several sample plans are given in the Examples section below.

.. _resource_arbitration:

Resource Arbitration
~~~~~~~~~~~~~~~~~~~~

Commands are issued at the end of a :ref:`macro step
<micro_steps_macro_steps_and_the_quiescence_cycle>`, when the
containing Command node enters ``EXECUTING`` state. All the commands
eligible for execution at the end of the macro step are sent to the
*resource arbiter*. The arbiter considers each of the commands and
their resource requirements, and accepts a subset that can be
performed without exhausting resource availability. The accepted
commands are then sent to the external system.

Each command rejected by the arbiter has its command handle set to
``COMMAND_DENIED``. In the absence of an ``EndCondition``, the Command
node will transition to ``ITERATION_ENDED`` state; in the absence of a
``PostCondition``, its outcome will be ``SUCCESS``.  A |PLEXIL| plan
can specify the next course of action in the event a command is
rejected.  For example, the command could be reissued, etc.

The resource arbiter is explained in further detail in :ref:`Chapter 10 <ResourceArbiter>`.

.. _command_handles:

Command Handles
~~~~~~~~~~~~~~~

A *command handle* represents the execution status of a command. They
provide a way to keep track of the particular stage a command node is
in after it transitions to the *Executing* state.

From the time a Command node becomes executable until the time the
external system completes executing the command, several things can
happen. First, the command's resource requirements are analyzed by the
resource arbiter, to determine whether the requirements of all
concurrent commands can be met. If the arbiter accepts the command, the
interface adapter sends the command (via whatever means) to the external
system. Finally, the external system can report whether the command
succeeded or failed.

It will be worthwhile to inform the executive as to what stage of its
journey the command is in for more reasons than just book-keeping. The
plan could, for instance, use a particular state of the command to start
or stop other nodes.

Command handles may take one of the following values:

-  COMMAND_DENIED
-  COMMAND_ACCEPTED
-  COMMAND_RCVD_BY_SYSTEM
-  COMMAND_SENT_TO_SYSTEM
-  COMMAND_SUCCESS
-  COMMAND_FAILED
-  COMMAND_ABORTED
-  COMMAND_ABORT_FAILED
-  COMMAND_INTERFACE_ERROR

When the resource arbiter rejects a command due to inadequate resources,
the command handle is set to COMMAND_DENIED.

When a command is issued by the executive, the interface may send any
legal command handle value as feedback. The |PLEXIL| Exec doesn't put any
interpretation on these values, with the exception of COMMAND_DENIED.

A hypothetical application could use them in the following ways:

-  COMMAND_ACCEPTED when the interface begins to process the command;
-  COMMAND_SENT_TO_SYSTEM when the interface has sent the command to the
   external system;
-  COMMAND_RCVD_BY_SYSTEM when the external system receives the command;
-  COMMAND_SUCCESS when the external system has successfully executed
   the command;
-  COMMAND_FAILED when the command issued to the external system fails
   to execute.

The default EndCondition of Command nodes is ``True``. If an
EndCondition is supplied, the effective expression used for the
EndCondition is:

::

   Self.command_handle == COMMAND_DENIED
    || Self.command_handle == COMMAND_FAILED
    || <user EndCondition>

Command handles are stored in a variable that can be used in any node as
a decision variable. This is illustrated in the sample plan shown below.
Here, there are two Command nodes, *Drive* and *NextWaypoint*. Using a
StartCondition, we can make the NextWaypoint node issue a command
*after* the Drive node receives the COMMAND_RCVD_BY_SYSTEM signal from
the external system.

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


Aborting a command
------------------

A command may be *aborted* when its Command node fails (i.e. the
InvariantCondition of the node or any direct ancestor node becomes
``False``) or is interrupted (the ExitCondition of the node or a
direct ancestor becomes ``True``). How a command abort is actually
handled is determined by the interface adapter for the given |PLEXIL|
application. See the the section on :ref:`interfacing
<InterfacingOverview>` for more information.

The command handle is ignored in the event of an abort. A Boolean status
variable, the *abort acknowledgment variable*, is used to determine when
the abort is complete. The Command node transitions to ``ITERATION_ENDED``
when the abort has been acknowledged by the interface adapter.

.. _examples:

Examples
-------------

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
