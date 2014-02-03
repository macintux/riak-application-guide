# Dynamic querying

**Need lots of content here.**

## Secondary indexes (2i)

## Key & bucket lists

### Key ranges

http://docs.basho.com/riak/latest/dev/using/keyfilters/

## MapReduce

* Perils of JS (prefer Erlang)
* Difficult to find debug information

## Full-text search

<!-- Yes, the Riak Search link below is intended to link to a specific
version of the docs rather than "latest" since the content will
presumably change significantly once 2.0 is released. -->

Riak's full-text search engine exists in two very different forms with
similar interfaces: the original
[Riak Search](http://docs.basho.com/riak/1.4.0/dev/advanced/search/),
written in-house by Basho and designed to look like
[Solr](http://lucene.apache.org/solr/), and the
[Yokozuna](https://github.com/basho/yokozuna) project for Riak 2.0,
which **is** Solr, with Riak handling the responsibility of feeding
Solr new content for indexing as values are written, updated, and
deleted.

### Architectural differences

Basho's original Riak Search is term-based: searching for a specific
keyword would involve querying only those servers responsible for that
word. Searching for that same keyword using Yokozuna will involve a
"coverage query" of a representative subset of the cluster (like 2i),
which should be somewhat slower for a single term search, but for more
complex searches or large result sets that advantage will likely be
lost.


## Commit hooks

* Difficult to find debug information

## Custom hash functions
