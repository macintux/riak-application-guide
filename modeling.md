
# Data modeling

It's hard to escape the relational mindset when designing an
applications that rely on a database, but once you set that aside in
favor of key/value modeling you discover interesting patterns that you
can use outside of Riak, even in SQL databases.[^sql-databases]

[^sql-databases]: Feel free to use a relational database when you're
willing to sacrifice the scalability, performance, and availability of
Riak...but why would you?

If you thoroughly absorbed the earlier content, some of this may feel
redundant, but not all of us are able to grasp the implications of the
key/value model, and I suspect you'll find a few interesting ideas
here.

## Terminology

Bucket
:   Virtual namespaces for keys
Bucket types
:   Collections of buckets for customization or security
Denormalize
:   Introduce redundancy into a data set
Immutable data
:   Data which, once written, is never updated
Key
:   A string which uniquely (per bucket) identifies values in Riak
Object
:   Another term for **value**
Value
:   The data associated with a key


## Rules to live by

As with most such lists, these are guidelines rather than hard rules,
but take them seriously. We'll talk later about alternative
approaches.

(@keys) Know thy keys.

    The cardinal rule of any key/value data store: the fastest way to get
    data is to know the key you want.

    How do you pull that off? Well, that's the trick, isn't it?

    The best way to always know the key you want is to be able to
    programmatically reproduce it based on information you already
    have. Need to know the sales data for one of your client's
    magazines in December 2013? Store it in a **sales** bucket and
    name the key after the client, magazine, and month/year combo.

    Guess what? Retrieving it will be much faster than running a SQL
    `select` statement in a relational database.

    And if it turns out that the magazine didn't exist yet, and there
    are no sales figures for that month? No problem. A negative
    response, especially for immutable data, is among the fastest
    operations Riak offers.

(@views) Write your own views.

    The other name for this rule? *Know your queries.*

    Dynamic queries in Riak are expensive. Writing is cheap. Disk space is
    cheap.

    As your data flows into the system, generate the views you're going to
    want later. That magazine sales example from (@keys)? The December
    sales numbers are almost certainly aggregates of smaller values, but
    if you know in advance that monthly sales numbers are going to be
    requested frequently, when the last data arrives for that month the
    application can assemble the full month's statistics for later
    retrieval.

    Yes, getting accurate business requirements is non-trivial, but many
    Riak applications are version 2 or 3 of a system, written once the
    business discovered that the scalability story for MySQL, or Postgres,
    or MongoDB, simply wasn't up to the job of handling their growth.

(@small) Take small bites.

    Remember your parents' advice over dinner? They were right.

    When creating objects *that will be updated later*, constrain their
    scope and keep the number of contained elements to a small number,
    ideally just 1. We'll talk more about why when we discuss conflict
    resolution.

(@indexes) Create your own indexes.

    Riak offers metadata-driven indexes for values, but these face
    scaling challenges: in order to identify all objects for a given
    index value, roughly a third of the cluster must be involved.

    For many use cases, creating your own indexes is straightforward
    and much faster/more scalable, since you'll be managing and
    retrieving a single object.

    See [Conflict resolution] for more discussion of this.

(@immutable) Embrace immutability.

    As we discussed in [Mutability], immutable data offers a way out
    of some of the challenges of running a high volume, high velocity
    data store.

    If possible, segregate mutable from non-mutable data, ideally
    using different buckets for [request tuning][Request tuning].

    Because keys are only unique within a bucket, the same unique
    identifier can be used in different buckets to represent different
    information about the same entity (e.g., a customer address might
    be in an `address` bucket with the customer id as its key).

    [Datomic](http://www.datomic.com) is a unique data storage system
    that leverages immutability for all data, with Riak commonly used
    as a backend data store. It treats any data item in its system as
    a "fact," to be potentially superseded by later facts but never
    updated.

<!-- Think about a chapter break here -->
## Conditional requests

<!-- May be too deep in the weeds, but deserves at least a mention -->

It is possible to use conditional requests with Riak, but these are
fragile due to the nature of its availability/eventual consistency
model.

<!-- XXX Can't find good docs, and the FAQ indicates that `If-None-Match` isn't
supported in PB; still true? -->


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

<!-- YAY -->

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



## Hybrid solutions
