# How not to write a Riak application

Writing a Riak application is very much **not** like writing an
application that relies on a relational database. The core ideas and
vocabulary from database theory still apply, of course, but many of
the decisions that inform the application layer are inverted.

Effectively all of these anti-patterns make some degree of sense when
writing an application against a SQL database. None of them lend
themselves to great Riak applications.

## Dynamic querying

Riak offers query features such as secondary indexes (**2i**),
MapReduce, and full-text search, but throwing a large quantity of data
into Riak and expecting those tools to find whatever you need is
setting yourself (and Riak) up to fail. Performance will be poor,
especially as you scale.

**Reads and writes in Riak should be as fast with ten billion values
in storage as with ten thousand.**

Key/value operations seem primitive (and they are) but you'll find
they are flexible, scalable, and very very fast (and predictably so).

Treat 2i and friends as tools to be applied judiciously, design the
main functionality of your application as if they don't exist, and
your software will continue to work at blazing speeds when you have
petabytes of data stored across dozens of servers.

## Normalization

Normalizating data is generally a useful approach in a relational
database, but unlikely to lead to happy results with Riak.

Riak lacks foreign keys constraints and join operations, two vital
parts of the normalization story, so reconstructing a single record
from multiple objects would involve multiple read requests; certainly
possible and fast enough on a small scale, but not ideal for larger
requests.

Instead, imagine the performance of your application if most of your
requests were a single, trivial read. Preparing and storing the
answers to queries you're going to ask later is a best practice for
Riak.

## Ducking conflict resolution

One of the first hurdles Basho faced when releasing Riak was educating
developers on the complexities of eventual consistency and the need to
intelligently resolve data conflicts.

Because Riak is optimized for high availability, *even when servers
are offline or disconnected from the cluster due to network failures*,
it is not uncommon for two servers to have different versions of a
piece of data.

The simplest approach to coping with this is to allow Riak to choose a
winner based on timestamps. It can do this more effectively if
developers follow Basho's guidance on sending updates with *vector
clock* metadata to help track causal history, but often concurrent
updates cannot be automatically resolved via vector clocks, and
trusting server clocks to determine which write was the last to arrive
is a **terrible** conflict resolution method.

Even if your server clocks are magically always in sync, are your
business needs well-served by blindly applying the most recent update?
Some databases have no alternative but to handle it that way, but we think
you deserve better.

Typed buckets in Riak 2.0 default to retaining conflicts and requiring
the application to resolve them, but we're also providing replicated
data types to automate conflict resolution on the servers.

If you want to minimize the need for conflict resolution, modeling
with as much immutable data as possible is a big win.

[Conflict resolution] covers this in much more detail.

## Mutability

For years, functional programmers have been singing the praises of
immutable data, and it confers significant advantages when using a
distributed data store like Riak.

Most obviously, conflict resolution is dramatically simplified when
objects are never updated.

Even in the world of single-server database servers, updating records
in place carries costs. Most databases lose all sense of history when
data is updated, and it's entirely possible for two different clients
to overwrite the same field in rapid succession leading to unexpected
results.

Some data is always going to be mutable, but thinking about the
alternative can lead to better design.

## SELECT * FROM &lt;table&gt;

A perfectly natural response when first encountering a populated
database is to see what's in it. In a relational database, you can
easily retrieve a list of tables and start browsing their records.

As it turns out, this is a terrible idea in Riak.

Not only is Riak optimized for unstructured, opaque data, it is also
not designed to allow for trivial retrieval of lists of buckets (very
loosely analogous to tables) and keys.

Doing so can put a great deal of stress on a large cluster and can
significantly impact performance.

It's a rather unusual idea for someone coming from a relational
mindset, but being able to algorithmically determine the key that you
need for the data you want to retrieve is a major part of the Riak
application story.

## Large objects

Because Riak sends multiple copies of your data around the network for
every request, values that are too large can clog the pipes, so to
speak, causing significant latency problems.

Basho generally recommends 1-4MB objects as a soft cap; larger sizes
are possible with careful tuning, however.

We'll return to object size when discussing [Conflict resolution]; for
the moment, suffice it to say that if you're planning on storing
*mutable* objects in the upper ranges of our recommendations, you're
particularly at risk of latency problems.

For significantly larger objects,
[Riak CS](http://basho.com/riak-cloud-storage/) offers an Amazon
S3-compatible (and also OpenStack Swift-compatible) key/value object
store that uses Riak under the hood.

## Running a single server

This is more of an operations anti-pattern, but it is a common
misunderstanding of Riak's architecture.

It is quite common to install Riak in a development environment using
its `devrel` build target, which creates 5 full Riak stacks (including
Erlang virtual machines) to run on one server to simulate a cluster.

However, running Riak on a single server for benchmarking or
production use is counterproductive, regardless of whether you have 1
stack or 5 on the box.

It is possible to argue that Riak is more of a database coordination
platform than a database itself. It uses Bitcask or LevelDB to persist
data to disk, but more importantly, it commonly uses *at least* 64
such embedded databases in a cluster.

Needless to say, if you run 64 databases simultaneously on a single
filesystem you are risking significant I/O and CPU contention unless
the environment is carefully tuned (and has some pretty fast disks).

Perhaps more importantly, Riak's core design goal, its raison d'être,
is high availability via data redundancy and related
mechanisms. Writing three copies of all your data to a single
server is mostly pointless, both contributing to resource contention
and throwing away Riak's ability to survive server failure.

## Further reading

* [Why Riak](http://docs.basho.com/riak/latest/theory/why-riak/) (docs.basho.com)
* [Data Modeling](http://docs.basho.com/riak/latest/dev/data-modeling/) (docs.basho.com)
* [Clocks Are Bad, Or, Welcome to the Wonderful World of Distributed Systems](https://basho.com/clocks-are-bad-or-welcome-to-distributed-systems/) (Basho blog)
