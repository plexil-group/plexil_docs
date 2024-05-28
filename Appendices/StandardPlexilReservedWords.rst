.. _StandardPlexilReservedWords:

Reserved Words in Standard PLEXIL
=================================

*28 May 2024*

In |PLEXIL| release 4.6, the Standard |PLEXIL| compiler treats the
following strings as reserved words, which may not be used as
identifiers:

- ``Any``
- ``Boolean``
- ``COMMAND_ABORTED``
- ``COMMAND_ABORT_FAILED``
- ``COMMAND_ACCEPTED``
- ``COMMAND_DENIED``
- ``COMMAND_FAILED``
- ``COMMAND_INTERFACE_ERROR``
- ``COMMAND_RCVD_BY_SYSTEM``
- ``COMMAND_SENT_TO_SYSTEM``
- ``COMMAND_SUCCESS``
- ``Checked``
- ``CheckedSequence``
- ``Child``
- ``Command``
- ``Comment``
- ``Concurrence``
- ``Date``
- ``Duration``
- ``END``
- ``EXECUTING``
- ``EXITED``
- ``FAILING``
- ``FAILURE``
- ``FINISHED``
- ``FINISHING``
- ``INACTIVE``
- ``INTERRUPTED``
- ``INVARIANT_CONDITION_FAILED``
- ``ITERATION_ENDED``
- ``In``
- ``InOut``
- ``Integer``
- ``LibraryAction``
- ``LibraryCall``
- ``LibraryNode``
- ``Lookup``
- ``LookupNow``
- ``LookupOnChange``
- ``LowerBound``
- ``MessageReceived``
- ``Name``
- ``NoChildFailed``
- ``NodeExecuting``
- ``NodeFailed``
- ``NodeFinished``
- ``NodeInactive``
- ``NodeInvariantFailed``
- ``NodeIterationEnded``
- ``NodeIterationFailed``
- ``NodeIterationSucceeded``
- ``NodeParentFailed``
- ``NodePostconditionFailed``
- ``NodePreconditionFailed``
- ``NodeSkipped``
- ``NodeSucceeded``
- ``NodeWaiting``
- ``OnCommand``
- ``OnMessage``
- ``PARENT_EXITED``
- ``PARENT_FAILED``
- ``POST_CONDITION_FAILED``
- ``PRE_CONDITION_FAILED``
- ``Parent``
- ``Priority``
- ``Real``
- ``ReleaseAtTermination``
- ``Resource``
- ``Returns``
- ``SKIPPED``
- ``START``
- ``SUCCESS``
- ``Self``
- ``Sequence``
- ``Sibling``
- ``String``
- ``SynchronousCommand``
- ``Timeout``
- ``Try``
- ``UncheckedSequence``
- ``Update``
- ``UpperBound``
- ``WAITING``
- ``Wait``
- ``XOR``
- ``abs``
- ``arrayMaxSize``
- ``arraySize``
- ``ceil``
- ``command_handle``
- ``do``
- ``else``
- ``elseif``
- ``endif``
- ``failure``
- ``false``
- ``floor``
- ``for``
- ``if``
- ``isKnown``
- ``max``
- ``min``
- ``mod``
- ``outcome``
- ``real_to_int``
- ``round``
- ``sqrt``
- ``state``
- ``strlen``
- ``true``
- ``trunc``
- ``while``

|PLEXIL| release 6 removes these reserved words from the above list:

- ``LowerBound``

|PLEXIL| 6 adds these reserved words:

- ``Mutex``
- ``Using``
