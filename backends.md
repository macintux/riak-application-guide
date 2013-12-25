# Backends

As a developer of a Riak application, you may or may not have control
over the backend that stores the data for your application. You
should, however, be aware of the tradeoffs.

## Bitcask

Bitcask has two particularly compelling qualities: very low (and
predictable) latency, and configurable expiry of keys (TTL). The
latter is particularly handy because deleting data from Riak is a
delicate and often slow operation.

Bitcask is very fast because each object retrieval is at most two lookups:
find the key in memory, and seek directly to the point on disk where
the latest copy of its object lives.

However, it currently lacks a feature that most developers think they
want: secondary indexing (2i).

Another downside to Bitcask is that all keys stored on the server must
be able to fit into RAM.

*Should say something about cost/configurability of merging.*

## LevelDB

Unlike Bitcask, which is home-grown by Basho, LevelDB originates with
Google, although it has been (and continues to be) *heavily*
customized to work well with Riak.

LevelDB offers 2i and does not require that all keys fit into memory,
but at the expense of higher (and less predictable) latency than
Bitcask. It can take several disk seeks to retrieve an object.

LevelDB does not (today) offer TTL.

## Memory

Riak can store all keys and values in RAM using the Memory backend,
which offers 2i and TTL, but **does not persist to disk**.

Because your data lives on multiple servers, it still offers
reasonably robust storage, but a power failure or rolling system
reboots can wipe out all of your data.

## Multi

It is possible for Riak to use a combination of the backends using a
multi-backend configuration. This, however, has a few downsides:

* Complex configuration[^cuttlefish]
* More contention for memory and other resources
* Buckets must be created against the proper backend before data
  arrives

[^cuttlefish]: Riak 2.0 includes a new configuration mechanism
intended to reduce complexity and eliminate some common operational
errors, but backend configuration is still handled at each server in a
cluster and must be managed carefully.

## Important backend operational notes

Technically these are out of scope for an application development
guide, but given the potential for bad things to happen™, it seems
useful to point these out here.

* As hinted under [Multi], if a bucket contains data, changing
  backends for that bucket does not migrate the data. Instead the old
  data becomes invisible to Riak.
* If the backend for a bucket is configured inconsistently across the
  cluster (e.g., Bitcask on some servers but LevelDB on others) then
  features such as 2i or TTL will only work on portions of your data set.
