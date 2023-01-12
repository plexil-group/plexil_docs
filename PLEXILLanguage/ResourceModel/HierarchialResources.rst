.. _HierarchialResources:

Hierarchial Resources 
========================

*10 Jan 2023*

In applications where a large number of command resources are used,
and some of the resources are interdependent, it might be cumbersome
to specify each resource element in the plan individually.

The |PLEXIL| resource file format allows interdependence between
resources to be specified as a weighted directed acyclic graph. When a
particular resource requirement is referenced in the plan, all the
descendants of that resource also get pulled in; the descendants'
requests are automatically scaled by the specified weights.

Consider the resource hierarchy in this diagram:
  
.. figure:: ../../_static/images/Hierarchicalresources.jpg

The relationships in the diagram are reflected in an example resource
data file, in plexil/examples/resources/resource.data, whose contents
are:

::

   %Contains the resource hierarchy
   % name initial-resource [child-weight child-name]*
   body 1.0 1.0 head 1.0 arms 1.0 legs
   head 1.0 1.0 vision 1.0 audio 1.0 brain
   vision 1.0 1.0 cameraL 1.0 cameraR 0.3 cpu
   audio 1.0 1.0 sonar 0.2 cpu
   brain 1.0 0.5 cpu 0.4 memory
   arms 1.0 1.0 handL 1.0 handR
   handL 1.0 1.0 digitsL
   handR 1.0 1.0 digitsR
   legs 1.0 1.0 legL 1.0 legR 0.3 memory
   digitsL 5.0
   digitsR 5.0
   legL 1.0
   legR 1.0
   cameraL 1.0
   cameraR 1.0
   sonar 1.0
   cpu 1.0
   memory 1.0
   sys_memory 1.0


Now consider the plan below (found in
plexil/examples/resources/resource3.ple) in the context of this
resource file

::

   Integer Command c1;
   Integer Command c2;
   Integer Command c3;

   SimpleTask: 
   Concurrence {
     C1: {
       Integer returnValue = -1;
       EndCondition returnValue == 10;
       PostCondition C1.command_handle == COMMAND_SUCCESS;
       Resource Name = "head", Priority = 20;
       returnValue = c1();
     }
     C2: {
       Integer returnValue = -1;
       RepeatCondition C2.command_handle == COMMAND_DENIED;
       PostCondition C2.command_handle == COMMAND_SUCCESS;
       EndCondition returnValue == 10;
       Resource Name = "memory",
         UpperBound = 0.3,
         Priority = 25;
       returnValue = c2();
     }
     C3: {
       Integer returnValue = -1;
       PostCondition C3.command_handle == COMMAND_SUCCESS;
       EndCondition returnValue == 10;
       Resource Name = "vision", Priority = 30;
       returnValue = c3();
     }
   }


The plan consists of three Command nodes executing concurrently:
``C1``, ``C2``, and ``C3``. Node ``C1`` requires the ``head`` resource
with priority 20, node ``C3`` requires the ``vision`` resource with
priority 30, and node ``C2`` requires 0.3 units of the ``memory``
resource with priority 25.

Let's look at each of these commands' respective requirements in the
context of the above resource structure and the commands' priorities.

Node ``C1`` requires 1.0 units of the ``head`` resource, which in turn
requires 1.0 units each of dependent resources ``vision``, ``audio``,
and ``brain``. At the next level, each unit of ``vision`` requires 1.0
units each of ``cameraL`` and ``cameraR``, and V units of ``cpu``.  In
the resource data file above, V = 0.3. Next, each unit of ``audio``
requires 1.0 units of ``sonar`` and A units of ``cpu``. Here A =
0.2. Finishing out the indirect dependencies, each unit of ``brain``
requires B1 units of ``cpu`` and B2 units of ``memory``. In the
resource data above, B1 = 0.5 and B2 = 0.4.

So the total resource requirements of node ``C1`` are: ``head``: 1.0;
``vision``: 1.0; ``audio``: 1.0; ``brain``: 1.0; ``cameraL``: 1.0;
``cameraR``: 1.0; ``sonar``: 1.0; ``cpu``: 0.3 + 0.2 + 0.4 = 0.9;
``memory``: 0.4.

Following the same chain of reasoning, node ``C2`` directly requires
``memory``: 0.3.

Node ``C3`` requires: ``vision``: 1.0, ``cameraL``: 1.0; ``cameraR``:
1.0; ``cpu``: 0.3.

Of the 3 nodes, ``C1`` has the best priority, 20. Therefore its
requirements are processed before those of ``C2`` and ``C3``. As all
of its requirements can be satisfied from the available resources,
``C1`` is allowed to execute. This results in all of ``head``,
``vision``, ``audio``, ``brain``, ``cameraL``, ``cameraR``, and
``sonar``, 0.9 units of ``cpu``, and 0.4 units of ``memory`` getting
allocated to ``C1``. 0.1 units of ``cpu`` and 29.6 units of ``memory``
remain available.

Next in priority order, at priority 25, ``C2`` requires 0.3 units of
``memory``. With 29.6 units remaining, this request can be satisfied,
so the arbiter grants the allocation of ``memory`` to ``C2``, and
allows it to execute. This leaves 29.3 units of ``memory`` available.

Last, at priority 30, several resources required by ``C3`` have
already been completely allocated to ``C1``; these are ``vision``,
``cameraL``, and ``cameraR``. Therefore permission to execute ``C3``
is denied by the arbiter.
