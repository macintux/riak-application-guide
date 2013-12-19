
# Data modeling

It's hard to escape the relational mindset when designing an
applications that rely on a database, but once you set that aside in
favor of key/value modeling you discover interesting patterns that you
can use outside of Riak, even in SQL
databases.^[Feel free to use a relational database when you're willing to sacrifice the scalability, performance, and availability of Riak...but why would you?]

## Predictable keys



## Views

Views require join operations, right?


<!-- foreign keys -->

## Small data objects


## Indexes

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
