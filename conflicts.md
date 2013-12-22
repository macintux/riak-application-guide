
# Conflict resolution

## Small objects

## Siblings and vector clocks

## Conditional requests

It is possible to use conditional requests with Riak, but these are
fragile due to the nature of its availability/eventual consistency
model.

...

## Data types

With Riak 1.4, Basho started introducing distributed data types to
allow the cluster to resolve conflicting writes automatically. The
first such types was a simple counter, but Riak 2.0 includes sets and
maps.

These types are still bound by the same basic constraints as the rest
of Riak. For example, if the same set is updated on either side of a
network split, requests for the set will respond differently until the
split heals; also, these objects should not be allowed to grow to
multiple megabytes in size.

## Strong consistency

As of Riak 2.0, it is possible to indicate that values should be
managed using a consensus protocol, so a quorum of the servers
responsible for that data must agree to a change before it is
committed.

This is a useful tool, but keep in mind the tradeoffs: writes will be
slower due to the coordination overhead, and Riak's ability to
continue to serve requests in the prence of network partitions and
server failures will be compromised.

For example, if a majority of the primary servers for the data are
unavailable, Riak will refuse to answer read requests, because the
surviving servers have no way of knowing whether the data they contain
is accurate.

Thus, use this only when necessary, such as when the cost for
conflicting writes is too high. An example of the need for this comes
from Riak CS: because users are allowed to create new accounts, and
because there's no convenient way to resolve username conflicts if two
accounts are created at the same time with the same name, it is
important to coordinate such requests.

### Locks and constraints

As we'll see in [Modeling transactions], even without strong consistency it is
possible to define ACID-like transactions in Riak at the application
level.

Two mechanisms which are **not** guaranteed to work without strong
consistency are locks and *financial boundary* constraints. (WTF would
these actually be called?)

For financial operations, it may be necessary (or at least desirable)
to prevent a balance from dropping below a certain value (e.g.,
zero). This cannot be done with eventual consistency, because even
with transactions it is always possible for a balance to be decreased
on both sides of a network partition.

Even with `PW=2` and conditional requests weird things can
happen. Remember that `PW` requests can error out even when data is
written durably.
