
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

## Rules to live by

As with all such lists, these are guidelines rather than hard rules,
but take them seriously. We'll talk later about alternative
approaches.

(@keys) Know thy keys.

(@views) Write your own views.

Views require join operations, right?


<!-- foreign keys -->

(@small) Take small bites.

(@indexes) Create your own indexes.

## Immutability

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
