.. _RenewableResources:

Renewable Resources
=======================

*21 Mar 2023*

Commands may *produce*, or *renew*, resources, in addition to
consuming resources. Consider the resource requirements of these
commands:

-  Command ``c1`` requires ``<sys_memory, 0.75>``
-  Command ``c2`` requires ``<sys_memory, -0.125>``
-  Command ``c3`` requires ``<sys_memory, 0.375>``

In our example, commands ``c1`` and ``c3`` *consume* 0.75 and 0.375
units of sys_memory respectively, while ``c2`` *produces* 0.125 units of
sys_memory.

Commands ``c1`` and ``c3`` can't execute simultaneously, because their
total sys_memory usage, 1.125, would exceed the limit of 1.0. But if
``c2`` is started after ``c1``, its production of sys_memory reduces
total usage enough to allow ``c3`` to execute.

Note that this can only work if the commands are started on successive
macro steps. Resource consumption and production are accounted for
separately by the resource arbiter, starting from the resources
already allocated at the beginning of the macro step.  If all 3 nodes
begin execution at once, no matter how the resource priorities are
arranged, the resource arbiter will reject 2 of the 3 commands.

The entire PLEXIL plan (filed in plexil/examples/resource4.ple) is
given below.

::

    Integer Command c1;
    Integer Command c2;
    Integer Command c3;

    SimpleTask:
    Concurrence
    {
      C1: {
        Integer returnValue = -1;
        EndCondition returnValue == 10;
        PostCondition C1.command_handle == COMMAND_SUCCESS;
        Resource Name = "sys_memory",
          UpperBound = 0.75,
          Priority = 20;
        returnValue = c1();
      }
      C2: {
        Integer returnValue = -1;
        StartCondition Sibling(C1).state == EXECUTING;
        EndCondition returnValue == 10;
        PostCondition C2.command_handle == COMMAND_SUCCESS;
        Resource Name = "sys_memory",
          UpperBound = -0.125,
          Priority = 40;
        returnValue = c2();
      }
      C3: {
        Integer mem_priority = 30;
        Integer returnValue = -1;
        StartCondition Sibling(C2).state == EXECUTING;
        EndCondition returnValue == 10;
        PostCondition C3.command_handle == COMMAND_SUCCESS;
        Resource Name = "sys_memory",
          UpperBound = 0.375,
          Priority = mem_priority;
        returnValue = c3();
      }
    }

