
# Conflict resolution

## Small objects

## Siblings and vector clocks

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
