# Denormalization

Normal forms are the holy grail of schema design in the relational
world. Duplication is misery, we learn. Disk space is constrained, so
let foreign keys and join operations and views reassemble your data.

Conversely, when you step into a world *without* join operations,
**stop normalizing**. In fact, go the other direction, and duplicate
your data as much as you need to. Denormalize all the things!

I'm sure you immediately thought of a few objections to
denormalization; I'll do what I can to dispel your fears. Read on,
Macduff.

## Disk space

Let me get the easy concern out of the way: don't worry about disk
space. I'm not advocating complete disregard for it, but one of the
joys of operating a Riak database is that adding more computing
resources and disk space is not a complex, painful operation that
risks downtime for your application or, worst of all, manual sharding
of your data.

Need more disk space? Add another server. Install your OS, install
Riak, tell the cluster you want to join it, and then pull the
trigger. Doesn't get much easier than that.

## Performance over time

If you've ever created a *really* large table in a relational
database, you have probably discovered that your performance is
abysmal. Yes, indexes help with searching large tables, but
maintaining those indexes are **expensive** at large data sizes.

Riak includes a data organization structure vaguely similar to a
table, called a *bucket*, but buckets don't carry the indexing overhead of a relational table. As you dump more and more data into a bucket, write (and read) performance is constant.

Not growing at a constant rate, but quite literally
constant. Flat. Fast. Cheap. Easy.

## Performance per request

Yes, writing the same piece of data multiple times is slower than
writing it once, by definition.

However, for many Riak use cases, writes are asynchronous, happening
all the time in the background. Where performance is really a concern
is when you're trying to read your data so you can take action on it
(or display it–we all know how impatient your users can be)

Unless your application is receiving many hundreds or thousands of new
pieces of data per second to be stored, you should have plenty of time
to write those entries individually, even if you write them multiple
times to different keys to make future queries faster. If you really
*are* receiving so many objects for storage that you don't have time
to write them individually, you can buffer and write blocks of them in
chunks.

In fact, a common data pattern is to assemble multiple objects into
larger collections for later retrieval regardless of the ingest rate.

## What about updates?

One key advantage to normalization is that you only have to update any
given piece of data once.

As it turns out, updates to denormalized data are not nearly as big of
a deal as you might suspect in Riak.

Many use cases that require large quantities of storage deal with
mostly immutable data, such as log entries, sensor readings, and media
storage.

Any information which must be updated frequently should be confined to
small objects dedicated to the mutable information.

<!-- Would be nice to have an example here -->

We'll talk much more about data modeling to account for mutable and
immutable data.

