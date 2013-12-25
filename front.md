% Riak Application Development
% John R. Daily

# Preface

In the summer of 2012, I discovered
[Sijin Joseph's *Programmer Competency Matrix*](http://sijinjoseph.com/programmer-competency-matrix/)
and it spurred me to finally learn a functional programming language.

I grabbed a copy of
[Bruce Tate's *Seven Languages in Seven Weeks*](http://pragprog.com/book/btlang/seven-languages-in-seven-weeks). With my background in server and network administration, and a bit of server-side software
development experience, the first language that really piqued my
interest was Erlang.

Learning Erlang led me to discover Basho and NoSQL technologies, and
ultimately a job as technical evangelist for Basho, where I helped
edit
[Eric Redmond's *A Little Riak Book*](http://littleriakbook.com/). Helping
write Riak's documentation and interacting with developers has led me
to two conclusions:

* It's really *not* necessary to be a distributed systems expert to
  write applications for Riak.
* It nonetheless *is* necessary to think differently when designing
  Riak applications, and we at Basho haven't (yet) done a great job of
  making that fact obvious or surmountable.

Hence this guide.

Thanks to Mark Phillips for hiring me at Basho, Eric Redmond for
inspiring me to write this guide, and the entire Basho crew for
demanding and demonstrating excellence.

# Introduction

Riak is not a relational database. It is not a document store. It has
characteristics in common with other databases, but it is very much
its own beast, and writing
performant^[Yes, I'll argue *performant* is a proper word, thankyewverymuch],
scalable applications requires more than just a list of API functions:
it requires a different way of thinking about assembling and managing
data.

If you need to be convinced that Riak is the solution for you, this is
not the guide you're looking for. The Little Riak Book, Basho engineers, and satisfied
customers are better resources; my goal here is to help people avoid common
pitfalls that await the novice Riak developer. Designing applications
to work well with a distributed key/value store is not (yet) a common skill.

Because Riak is evolving rapidly to encompass new features and use cases, this
guide will steer clear of low-level details that can be found on
Basho's documentation website.

Furthermore, this neither an operations guide nor an architecture
guide. Understanding how Riak works under the covers is useful, but it
should not be necessary for software development.

## What do I need to read?

While I'd hope that everyone will read this whole document, I have
enough partially-read books on my shelves (analog and digital) to know
better.

Above all, read [How not to write a Riak application]. If the
anti-patterns make sense, feel free to skip [Denormalization] and jump
directly to [Data modeling].

If [Data modeling] and the preceding content makes sense, then the
guide has achieved its primary purpose of encouraging a different
mindset when thinking about how Riak applications should be designed.

Be sure to read [Write failures] (under [Request tuning]), because
Riak errors and write failures are two very different things.

The other particularly critical content is under
[Conflict resolution], because while it is possible to develop
applications that ignore the problem, such applications are probably
working correctly only when everything else in the environment is
working correctly.

