
# Data modeling

It's hard to escape the relational mindset when designing an
applications that rely on a database, but once you set that aside in
favor of key/value modeling you discover interesting patterns that you
can use outside of Riak, even in SQL
databases.^[Feel free to use a relational database when you're willing to sacrifice the scalability, performance, and availability of Riak...but why would you?]

If you thoroughly absorbed the earlier content, some of this may feel
redundant, but not all of us are able to grasp the implications of the
key/value model, and I suspect you'll find a few interesting ideas
here.

## Terminology

Key
:   Take a wild guess
Bucket
:   Virtual namespaces for keys
Bucket types
:   Will we need this?
Immutability
:   Seriously?
Denormalization
:   Now you're just getting silly

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
    have. Need to know the sales data for one of your client's magazines
    in December 2013? Store it in a *sales* bucket and name the key after
    the client, magazine, and month/year combo.

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

    Your parents were right.

    When creating objects *that will be updated later*, constrain their
    scope and keep the number of distinct elements to a small number,
    ideally just 1. We'll talk more about why when we discuss conflict
    resolution.

(@indexes) Create your own indexes.

(@immutable) Embrace immutability.

* segregate mutable from non-mutable data (ties back to small data objects)
* much big data comes from events, and events are by definition immutable
* datomic

<!-- Think about a chapter break here -->
## ORM

## Conditional requests

<!-- May be too deep in the weeds, but deserves at least a mention -->

## Strong consistency

<!-- YAY -->

## CRDTs

## Hybrid solutions
