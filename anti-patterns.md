
# How not to write a Riak application

## Dynamic querying

The most important concept this guide *must* convey is that nearly
everything you've learned about using relational databases, which is
what most of us learned both in and out of school, no longer applies.

Riak offers dynamic querying features such as secondary indexes
(**2i**), MapReduce, and full-text search, but throwing a large
quantity of data into Riak and expecting those tools to find whatever
you need is setting yourself (and Riak) up to fail. Performance will
be wretched, especially as you scale.

**Reads and writes in Riak should be as fast with ten billion values
in storage as with ten thousand.**

Key/value operations seem very primitive (and they are) but you'll
find they are flexible, scalable, and very very fast. Treat 2i and
friends as tools to be applied carefully, but design your application
as if they don't exist and your software will continue to work at
blazing speeds when you have petabytes of data stored across dozens of
servers.

## JSON all the things!

Many NoSQL databases leverage JSON as a way to allow developers to
provide semi-structured data without forcing them to use constrained
relational tables.

When looking at Riak, it's therefore natural to expect to store and
update large JSON documents.

Certainly you *can* do so: Riak is largely oblivious to the nature of
the data for which it is responsible, and so retrieving and updating a
JSON document is no different than any other type of content.

However, unless you are storing and retrieving JSON for other
applications to manipulate, complex JSON objects aren't generally a
good fit for Riak applications, because by consolidating different
data concerns into a single object you are placing at risk some of the
scaling characteristics of Riak (by adding the possibility of data
hotspots) and increasing the likelihood of data conflicts (two writers
making changes to the same object at the same time).

And, with an exception we'll discuss later in [Data types], Riak has
no notion of partial updates to documents, so you can't tweak an
individual field in a JSON object without retrieving and uploading the
full object.

<!--  XXX: minimizing translation(??) overhead? There's a term I want -->
<!--  here. Impedance mismatch? -->

## Normalization

Closely related to the first two anti-patterns, normalizating data is
generally a useful approach in a relational or document database, and
unlikely to lead to happy results with Riak.

Riak lacks foreign keys constraints[^link-walking] and join
operations, two vital parts of the normalization story, so
reconstructing a single record from multiple objects would involve
multiple read requests.

Riak is fast, but not fast enough to reconstruct a million records,
each involving multiple requests, in a timely fashion.

Instead, because adding significant amounts of disk storage to a Riak
cluster is as simple as building a new server, we'll talk in
[Denormalization] about going the other direction and creating
multiple copies of your data based on common queries.

[^link-walking]: Basho has long offered a mechanism called *link
walking* to allow developers to add metadata representing
relationships between objects for Riak to understand and retrieve on
demand.

    However, we generally don't recommend using them, in part because
there are no guarantees that the object thus referenced will still be
there. There are no foreign key constraints to prevent the application
from breaking all such links.

<!-- Are there other reasons to avoid links? -->

## Ducking conflict resolution

One of the first hurdles Basho faced when releasing Riak was educating
developers on the complexities of eventual consistency and the need to
intelligently resolve data conflicts.

Because Riak is optimized for high availability, even when servers are
offline or disconnected from the cluster due to network failures, it
is not uncommon for two servers to have different versions of a piece
of data.

The simplest approach to coping with this is to allow Riak to choose a
winner based on timestamps. It can do this more effectively if
developers follow Basho's guidance on sending updates with *vector
clock* metadata to help track causal history, but often concurrent
updates cannot be automatically resolved via vector clocks, and
trusting server clocks to determine which write was the last to arrive
is a **terrible** conflict resolution method.

Even if your server clocks are magically always in sync, are your
business needs well-served by blindly applying the most recent update?

## Mutability

For years, functional programmers have been singing the praises of
immutable data, and it confers significant advantages when using a
distributed data stores like Riak.

Most obviously, conflict resolution is dramatically simplified when
objects are never updated.

Even in the world of single-server database servers such as most
relational databases, updating records in place carries costs. The
database loses all sense of history when data is updated, and it's
entirely possible for two different clients to overwrite the same
field in rapid succession leading to unexpected results.

Twitter is famous for making MySQL work in a heavily distributed, high
traffic environment, and it does so in part by leveraging
immutability.

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

This is an unfortunate consequence of the underlying data model, and
hopefully one that will be addressed in future versions of Riak.

It's a rather unusual idea for someone coming from a relational
mindset, but being able to algorithmically determine the key that you
need for the data you want to retrieve is a major part of the Riak
application story.

## Running a single server

We're straying into operations anti-patterns, but this is a common
misunderstanding of Riak's architecture.

* File descriptors
* Partitions
* ARGH


## Adding layers in front of Riak

* Caching
* MQ

<!-- any other operational anti-patterns? -->
