# Request tuning

Riak is extensively (perhaps *too* extensively) configurable. Much of
that flexibility involves platform tuning accessible only via the host
operating system, but several core behavioral values can (and should)
be managed by applications.

With the notable exception of `n_val` (commonly referred to as `N`),
the parameters described below can be specified with each request. All
of them can be configured per-bucket type (available with Riak 2.0) or
per-bucket.

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
:   The number of copies of data that are written. This is independent
of the number of servers in the cluster. Default: 3.
`r`
:   The number of servers that must *successfully* respond to a read
request before the client will be sent a response. Default: `quorum`
`w`
:   The number of servers that must *successfully* respond to a write
request before the client will be sent a response. Default: `quorum`
`pr`
:   The number of *primary* servers that must successfully respond to a read
request before the client will be sent a response. Default: 0
`pw`
:   The number of *primary* servers that must successfully respond to a write
request before the client will be sent a response. Default: 0
`dw`
:   The number of servers that must respond indicating that the value
has been successfully handed off to the *backend* for durable storage
before the client will be sent a response. Default: 2
`notfound_ok`
:   Specifies whether the absence of a value on a server should be
treated as a successful assertion that the value doesn't exist
(`true`) or as an error that should not count toward the `r` or `pr`
counts (`false`). Default: `true`

## Impact

Generally speaking, the higher the integer values listed above, the
more latency will be involved, as the server that received the request
will wait for more servers to respond before replying to the client.

Higher values can also increase the odds of a timeout failure or, in
the case of the primary requests, the odds that insufficient primary
servers will be available to respond.

However, the only situation in which it is safe to assume that a write
actually failed is with strong consistency in Riak 2.0 turned on when
the client receives an error message. A timeout in that case, or any
sort of error/timeout *without* strong consistency, can conceal a
successful write, because Riak is designed to preserve your writes as
much as is possible.
