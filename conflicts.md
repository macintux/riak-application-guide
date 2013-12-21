
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
