
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

    Because keys are only unique within a bucket, the same unique
    identifier can be used in different buckets to represent different
    information about the same entity (e.g., a customer address might
    be in an `address` bucket with the customer id as its key).

(@namespace) Know thy namespaces.

    **Bucket types** (introduced in Riak 2.0) offer a way to secure
    and configure buckets. Buckets offer namespaces and configurable
    request parameters for keys. Both are good ways to segregate keys
    for data modeling.

    However, keys themselves define their own namespaces. If you want
    a hierarchy for your keys that looks like `sales/customer/month`,
    you don't need nested buckets: you just need to name your keys
    appropriately, as discussed in (@keys). `sales` can be your
    bucket, while each key is prepended with customer name and month.

(@views) Write your own views.

    The other name for this rule? **Know your queries.**

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

    When creating objects *that will be updated later*, constrain
    their scope and keep the number of contained elements low to
    reduce the odds of multiple clients attempting to update the data
    concurrently.

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

    [Datomic](http://www.datomic.com) is a unique data storage system
    that leverages immutability for all data, with Riak commonly used
    as a backend data store. It treats any data item in its system as
    a "fact," to be potentially superseded by later facts but never
    updated.

(@hybrid) Don't fear hybrid solutions.

    As much we would all love to have a database that is an excellent
    solution for any problem space, we're a long way from that goal.

    In the meantime, it's a perfectly reasonable (and very common)
    approach to mix and match databases for different needs. Riak is
    very fast and scalable for retrieving keys, but it's decidedly
    suboptimal at ad hoc queries. If you can't model your way out of
    that problem, don't be afraid to store your keys with searchable
    metadata in a relational or other database that makes ad hoc
    querying simple.

    Just make sure that you consider failure scenarios when doing so;
    it would be unfortunate to make Riak's effective availability a
    slave to another database's weakness.

## Further reading

* [Use Cases](http://docs.basho.com/riak/latest/dev/data-modeling/) (docs.basho.com)
