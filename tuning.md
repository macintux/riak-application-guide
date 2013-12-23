# Request tuning

Riak is extensively (perhaps *too* extensively) configurable. Much of
that flexibility involves platform tuning accessible only via the host
operating system, but several core behavioral values can (and should)
be managed by applications.

With the notable exceptions of `n_val` (commonly referred to as `N`)
and `allow_mult`, the parameters described below can be specified with
each request. All of them can be configured per-bucket type (available
with Riak 2.0) or per-bucket.

## Key concepts

Any default value listed below as **quorum** is equivalent to
`n_val/2+1`, or **2** whenever `n_val` has not been modified.

**Primary** servers are the cluster members that, in the absence of any
network or server failure, are supposed to "own" any given key/value
pair.

Riak's key/value engine does not itself write values to storage. That
job is left to the **backends** that Riak supports: Bitcask, LevelDB,
and Memory.

No matter what the parameters below are set to, requests will be
sent to `n_val` servers on behalf of the client, **except** for
strongly-consistent read requests with Riak 2.0, which can be safely
retrieved from the current leader for that key/value pair.

## Tuning parameters

`n_val`
:   The number of copies of data that are written. This is independent of the number of servers in the cluster. Default: **3**.

`r`
:   The number of servers that must *successfully* respond to a read request before the client will be sent a response. Default: **`quorum`**

`w`
:   The number of servers that must *successfully* respond to a write request before the client will be sent a response. Default: **`quorum`**

`pr`
:    The number of *primary* servers that must successfully respond to a read request before the client will be sent a response. Default: **0**

`pw`
:    The number of *primary* servers that must successfully respond to a write request before the client will be sent a response. Default: **0**

`dw`
:    The number of servers that must respond indicating that the value has been successfully handed off to the *backend* for durable storage before the client will be sent a response. Default: **2**

`notfound_ok`
:    Specifies whether the absence of a value on a server should be treated as a successful assertion that the value doesn't exist (`true`) or as an error that should not count toward the `r` or `pr` counts (`false`). Default: **`true`**

`allow_mult`
:    Does this bucket retain conflicts for the application to resolve (`true`) or pick a winner using vector clocks and server timestamp even if the causality history does not indicate that it is safe to do so (`false`). See [Conflict resolution] for more. Default: **`false`** prior to Riak 2.0, **`true`** after

## Impact

Generally speaking, the higher the integer values listed above, the
more latency will be involved, as the server that received the request
will wait for more servers to respond before replying to the client.

Higher values can also increase the odds of a timeout failure or, in
the case of the primary requests, the odds that insufficient primary
servers will be available to respond.

## Write failures

***Please read this. Very important. Really.***

The semantics for write failure are *very different* under eventually
consistent Riak than they are with the optional strongly consistent
writes available in Riak 2.0, so I'll tackle each separately.

### Eventual consistency

In most cases when the client receives an error message on a write
request, *the write was not a complete failure*. Riak is designed to
preserve your writes whenever possible, even if the parameters for a
request are not met. **Riak will not roll back writes.**

Even if you attempt to read the value you just tried to write and
don't find it, that is not definitive proof that the write was a
complete failure. (Sorry.)

If the write is present on at least one server, *and* that server
doesn't crash and burn, *and* other writes don't supersede it later,
the key and value written should make their way to all servers
responsible for them.

### Strong consistency

Strong consistency is the polar opposite from the default Riak
behaviors. If a client receives an error when attempting to write a
value, it is a safe bet that the value is not stashed somewhere in the
cluster waiting to be propagated, **unless** the error is a timeout.

No matter what response you receive, if you read the key and get the
new value back, you can be confident that all future successful reads
(until the next write) will return that same value.

## Tuning for immutable data

If you constrain a bucket to contain nothing but immutable data, you
can tune for very fast responses to read requests by setting `r=1` and
`notfound_ok=false`.

This means that read requests will (as always) be sent to all `n_val`
servers, but the first server that responds with **a value other than
`notfound`** will be considered "good enough" for a response to the
client.

Ordinarily with `r=1` and the default value `notfound_ok=true` if the
first server that responds doesn't have a copy of your data you'll get
a `not found` response; if a failover server happens to be actively
serving requests, there's a very good chance it'll be the first to
respond since it won't yet have a copy of that key.

## Further reading

* [Buckets](http://docs.basho.com/riak/latest/theory/concepts/Buckets/) (docs.basho.com)
* [Eventual Consistency](http://docs.basho.com/riak/latest/theory/concepts/Eventual-Consistency/) (docs.basho.com)
* [Replication](http://docs.basho.com/riak/latest/theory/concepts/Replication/) (docs.basho.com)
* [Understanding Riak's Configurable Behaviors](http://basho.com/understanding-riaks-configurable-behaviors-part-1/) (Basho blog series)
