# Locks, a cautionary tale

While assembling this guide, I tried to develop a data model that
would allow for reliable locking without strong consistency. That
attempt failed, but rather than throw the idea away entirely, I
decided to include it here to illustrate the complexities of coping
with eventual consistency.

Basic premise: multiple workers may be assigned data sets to process,
but each data set should be assigned to no more than one worker.

Broadly speaking, in the absence of strong consistency the closest an
application can get is to leverage the `pr` and `pw` parameters
(primary read, primary write) with a value of `quorum` (or `n_val`,
but the impact for this discussion is largely the same, and `quorum`
gives the application the opportunity to proceed when one primary
server is offline or otherwise unavailable).

So, common features to all of these models:

* Lock for any given data set is a known key
* Value is a unique identifier for the worker

## Lock, a first draft

### Sequence

`allow_mult=false`

1. Worker reads with `pr=quorum` to determine whether a lock exists
2. If it does, move on to another data set
3. If it doesn't, create a lock with `pw=quorum`
4. Process data set to completion
5. Remove the lock

### Failure scenario

1. Worker #1 reads the non-existent lock
2. Worker #2 reads the non-existent lock
3. Worker #2 writes its ID to the lock
4. Worker #1 writes its ID to the lock
5. Both workers process the data set

## Lock, a second draft

`allow_mult=false`

### Sequence

1. Worker reads with `pr=quorum` to determine whether a lock exists
2. If it does, move on to another data set
3. If it doesn't, create a lock with `pw=quorum`
4. Read lock again with `pr=quorum`
5. If the lock exists with another worker's ID, move on to another
   data set
6. Process data set to completion
7. Remove the lock

### Failure scenario

1. Worker #1 reads the non-existent lock
2. Worker #2 reads the non-existent lock
3. Worker #2 writes its ID to the lock
4. Worker #2 reads the lock and sees its ID
5. Worker #1 writes its ID to the lock
6. Worker #1 reads the lock and sees its ID
7. Both workers process the data set


If you've done any programming with threads before, you'll recognize
this as a common problem with non-atomic lock operations.

## Lock, a third draft

`allow_mult=true`

### Sequence

1. Worker reads with `pr=quorum` to determine whether a lock exists
2. If it does, move on to another data set
3. If it doesn't, create a lock with `pw=quorum`
4. Read lock again with `pr=quorum`
5. If the lock exists with another worker's ID **or** the lock
contains siblings, move on to another data set
6. Process data set to completion
7. Remove the lock

### Failure scenario

1. Worker #1 reads the non-existent lock
2. Worker #2 reads the non-existent lock
3. Worker #2 writes its ID to the lock
5. Worker #1 writes its ID to the lock
6. Worker #1 reads the lock and sees a conflict
4. Worker #2 reads the lock and sees a conflict
7. Both workers move on to another data set
