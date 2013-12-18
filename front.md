% Riak Application Development
% John R. Daily

# Preface

In the summer of 2012, I gave up on my quest to learn iOS and Mac GUI
development. Despite my long-standing love for Apple hardware and
software, I have no real interest in graphics programming, and lacked
the incentive to continue.

Around the same time, I discovered [Sijin Joseph's *Programmer
Competency Matrix*](http://sijinjoseph.com/programmer-competency-matrix/)
and it spurred me to revisit another goal I'd long had: to finally
learn a functional programming language.

I thus grabbed a copy of
[Bruce Tate's *Seven Languages in Seven Weeks*](http://pragprog.com/book/btlang/seven-languages-in-seven-weeks). The
first language that really piqued my interest was Erlang, which meshed
well with my background and interest in server-side development.

Erlang led me to a job as technical evangelist for Basho, where I
helped edit
[Eric Redmond's *A Little Riak Book*](http://littleriakbook.com/). Helping
with Riak's documentation and interacting with developers interested
in using Riak has led me to two conclusions:

* It's really *not* necessary to be a distributed systems expert to
  write applications for Riak.
* It nonetheless *is* necessary to think differently when designing
  Riak applications, and we at Basho haven't (yet) done a great job of
  making that fact obvious or surmountable.

Hence this book/guide.

Thanks to Mark Phillips for hiring me at Basho, Eric Redmond for
inspiring me to write more, and the entire Basho crew for demanding
excellence.

# Introduction

Riak is not a relational database. It is not a document store. It has
characteristics in common with other databases, but it is very much
its own beast, and writing
performant^[Yes, I'll argue *performant* is a proper word, thankyewverymuch],
scalable applications requires more than just a list of API functions:
it requires a different way of thinking about assembling and managing
data.

Like any active software project, Riak is rapidly evolving to
encompass new features and use cases. This guide will steer clear of
low-level details that can be found in Basho's documentation website;
rather, its goal is to capture the essence of what it means to develop
applications against a distributed, eventually-consistent key/value
database.

Furthermore, this neither an operations guide nor an architecture
guide. Understanding how Riak works under the covers is useful, but it
should not be necessary for software development.

