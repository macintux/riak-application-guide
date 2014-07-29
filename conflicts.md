# Conflict resolution

Conflict resolution is an inherent part of nearly any Riak
application, whether or not the developer knows it.

## Causality

Causality in a distributed data store is wonderfully useful when it
can be determined. If I retrieve a value, update it, and send it back
with metadata indicating when I got the value, Riak can determine
whether the new write is directly descended from what it already has
on disk.

With strong consistency, this context is mandatory: if the update to
an existing object is not explicitly derived from the latest version
of that object, it will be rejected.

With eventual consistency, Riak will take a new write regardless of
its context (aka **vector clock**).

## Siblings

With eventual consistency, if the vector clock cannot determine a
causal relationship between two copies of an object, Riak will create
**siblings**. Effectively, such an object is no longer a simple opaque
data blob, but rather two (or more) distinct blobs (siblings) waiting
to be resolved.

## Conflict resolution strategies

There are basically 6 distinct approaches for dealing with conflicts
in Riak, and well-written applications will typically use a
combination of these strategies depending on the nature of the data.[^conflict-tuning]

[^conflict-tuning]: If each bucket has its own conflict resolution
strategy, requests against that bucket can be tuned appropriately. For
an example, see [Tuning for immutable data].

* Ignore the problem and let Riak pick a winner based on timestamp and
  context if concurrent writes are received (aka "last write wins").
* Immutability: never update values, and thus never risk conflicts.
* Instruct Riak to retain conflicting writes and resolve them with
  custom business logic in the application.
* Instruct Riak to retain conflicting writes and resolve them using
  client-side data types designed to resolve conflicts automatically.
* Instruct Riak to retain conflicting writes and resolve them using
  server-side data types designed to resolve conflicts automatically.

And, as of Riak 2.0, strong consistency can be used to avoid conflicts
(but as we'll discuss below there are significant downsides to doing
so).


### Last write wins

Prior to Riak 2.0, the default behavior was for Riak to resolve
siblings by default (see [Tuning parameters] for the parameter
`allow_mult`). With Riak 2.0, the default behavior changes to
retaining siblings for the application to resolve, although this will
not impact legacy Riak applications running on upgraded clusters.

For some use cases, letting Riak pick a winner is perfectly fine, but
make sure you're monitoring your system clocks and are comfortable
losing occasional (or not so occasional) updates.

### Data types

It has always been possible to define data types on the client side to
merge conflicts automatically.

With Riak 1.4, Basho started introducing distributed data types
(formally known as **CRDTs**, or conflict-free replicated data types)
to allow the cluster to resolve conflicting writes automatically. The
first such type was a simple counter; Riak 2.0 adds sets and maps.

These types are still bound by the same basic constraints as the rest
of Riak. For example, if the same set is updated on either side of a
network split, requests for the set will respond differently until the
split heals; also, these objects should not be allowed to grow to
multiple megabytes in size.

### Strong consistency

As of Riak 2.0, it is possible to indicate that values should be
managed using a consensus protocol, so a quorum of the servers
responsible for that data must agree to a change before it is
committed.

This is a useful tool, but keep in mind the tradeoffs: writes will be
slower due to the coordination overhead, and Riak's ability to
continue to serve requests in the prence of network partitions and
server failures will be compromised.

For example, if a majority of the primary servers for the data are
unavailable, Riak will refuse to answer read requests if the surviving
servers are not certain the data they contain is accurate.

Thus, use this only when necessary, such as when the consequences of
conflicting writes are painful to cope with. An example of the need
for this comes from Riak CS: because users are allowed to create new
accounts, and because there's no convenient way to resolve username
conflicts if two accounts are created at the same time with the same
name, it is important to coordinate such requests.

## Conditional requests

It is possible to use conditional requests with Riak, but these are
fragile due to the nature of its availability/eventual consistency
model. The only way to achieve true "only accept this write if the
value hasn't changed since I've seen it" semantics is via strong
consistency.

### Raw HTTP

#### GET

When retrieving values from Riak via HTTP, a last-modified timestamp
and an [ETag](https://en.wikipedia.org/wiki/HTTP_ETag) are
included. These may be used for future `GET` requests; if the value
has not changed, a `304 Not Modified` status will be returned.

For example, let's assume you receive the following headers.

    Last-Modified: Thu, 17 Jul 2014 21:01:16 GMT
    ETag: "3VhRP0vnXbk5NjZllr0dDE"

Note that the quotes are part of the ETag.

If the ETag is used via the `If-None-Match` header in the next request:

    $ curl -i --header 'If-None-Match: "3VhRP0vnXbk5NjZllr0dDE"' http://localhost:8098/buckets/training/keys/baz
    HTTP/1.1 304 Not Modified
    Vary: Accept-Encoding
    Server: MochiWeb/1.1 WebMachine/1.10.5 (jokes are better explained)
    ETag: "3VhRP0vnXbk5NjZllr0dDE"
    Date: Mon, 28 Jul 2014 19:48:13 GMT

Similarly, the last-modified timestamp may be used with `If-Modified-Since`:

    $ curl -i --header 'If-Modified-Since: Thu, 17 Jul 2014 21:01:16 GMT' http://localhost:8098/buckets/training/keys/baz
    HTTP/1.1 304 Not Modified
    Vary: Accept-Encoding
    Server: MochiWeb/1.1 WebMachine/1.10.5 (jokes are better explained)
    ETag: "3VhRP0vnXbk5NjZllr0dDE"
    Date: Mon, 28 Jul 2014 19:51:39 GMT

#### PUT & DELETE

When adding, updating, or removing content, the HTTP headers
`If-None-Match`, `If-Match`, `If-Modified-Since`, and
`If-Unmodified-Since` can be used to specify ETags and timestamps.

If the specified condition cannot be met, a `412 Precondition Failed`
status will be the result.

### Client libraries via protocol buffers

The protocol buffers interface that most recent Riak clients use
supports vector clocks as a point of comparison for operations,
effectively equivalent to `If-None-Match` and `If-Match` via the HTTP
interface.

See your library's documentation for details.

## Locks and constraints

As we'll see in [Modeling transactions], even without strong consistency it is
possible to define ACID-like transactions in Riak at the application
level.

Two mechanisms which are **not** guaranteed to work without strong
consistency are locks and constraints on values, although researchers
are investigating mechanisms for creating boundary conditions in
eventually-consistent data stores using CRDTs.

## Conflicting resolution

Resolving conflicts when data is being rapidly updated can feel
Sysiphean.

It's always possible that two different clients will attempt to
resolve the same conflict at the same time, or that another client
will update a value between the time that one client retrieves
siblings and it attempts to resolve them. In either case you may have
new conflicts created by conducting conflict resolution.

Consider this yet another plug to consider immutability.

## Further reading

* [Clocks Are Bad, Or, Welcome to the Wonderful World of Distributed Systems](http://basho.com/clocks-are-bad-or-welcome-to-distributed-systems/) (Basho blog)
* [Index for Fun and for Profit](http://basho.com/index-for-fun-and-for-profit/) (Basho blog)
* [Indexing the Zombie Apocalypse With Riak](http://basho.com/indexing-the-zombie-apocalypse-with-riak/) (Basho blog)
* [Readings in conflict-free replicated data types](http://christophermeiklejohn.com/crdt/2014/07/22/readings-in-crdts.html) (Chris Meiklejohn's blog)
