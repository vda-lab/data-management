---
title: General NoSQL concepts
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-general-concepts.html
folder: nosql
---
## The end of SQL?
So does this mean that we should leave SQL behind? No. What we'll be looking at is _polyglot persistence_: depending on what data you're working with, some of that might still be stored in an SQL database, while other parts are stored in a document store and graph database (see below). So instead of having a single database, we can end up with a collection of databases to support a single application.

![polyglot persistence]({{ site.baseurl }}/assets/polyglot_persistence.png)
<small>Source: https://martinfowler.com/articles/nosql-intro-original.pdf</small>

This figure shows how in the hypothetical case of a retailer's web application we might be using a combination of 8 different database technologies to store different types of information. Note that RDBMS are still part of the picture!

You'll often hear the term NoSQL as in "No-SQL", but this should be interpreted as "Not-Only-SQL".

## General NoSQL concepts
NoSQL databases have received increasing attention in the more and more data-driven world. They allow for modelling of more complex data in a more scalable and agile way. Although it is impossible to lump all NoSQL technologies on a single heap, there are some concepts that apply.

### NoSQL is not just one technology
As mentioned above, NoSQL is not just a single technology; it is more an _approach_ than a technology. The image below shows a (new very outdated) overview of many of the database technologies used, including MongoDB, neo4j, ArangoDB, etc. But the NoSQL _approach_ is also about storing csv-files when that makes sense.

![overview NoSQL technologies]({{site.baseurl}}/assets/confused-by-the-glut-of-new-databases.jpg)

### Keep components simple
If we look at the extreme case of a legacy Oracle SQL database for clinical studies at e.g. a pharmaceutical company, we will typically see that such system is a single behemoth of a system, which requires several database managers to just keep the server(s) running and operating optimally. In contrast, in a NoSQL setup, we often try to keep the different components as simple as possible.

### Separation of concerns
An important question to answer here is where to put the functionality of your application? In the last example: do you let the database compute (with e.g. SQL statements) the things you need in the graphical interface directly? Do you let the graphical user interface get the raw data from the database and do all the necessary munging of that data at the user end? Or do you insert a separate layer in between (i.e. the computational layer mentioned above)? It’s all about a separation of concerns.

In general, RDBMS have been around for a long time and are very mature. As a result, a lot of functionality has been added to the database tier. In applications using NoSQL solutions, however, much of the application functionality is in a middle tier.

![tiers]({{site.baseurl}}/assets/tiers.png)

### Thinking strategically about RAM, SSD and disk
To make sure that the performance of your application is adequate for your purpose, you have to think about where to store your data. Data can be kept in RAM, on a solid-state drive (SSD), the hard disk in your computer, or in a file somewhere on the network. This choice has an immense effect on performance. It’s easy to visualise this: consider that you are in Hasselt

- getting something from RAM = getting it from your backyard
- getting something from SSD = getting it from somewhere in your neighbourhood
- getting something from disk = traveling to Saudi Arabia to get it
- getting something over the network = traveling to Jupiter to get it

It might be clear to you that cleverly keeping things in RAM is a good way to speed up your application or analysis :-) Which brings us to the next point:

### Keep your cache current using consistent hashing
So keeping things in RAM makes it possible to very quickly access them. This is what you do when you load data into a variable in your python/R/SAS/ruby/perl/… code.

Caching is used constantly by the computer you’re using at this moment as well.

An important aspect of caching is calculating a key that can be used to retrieve the data (remember key/value stores?). This can for example be done by calculating a checksum, which looks at each byte of a document and returns a long sequence of letters and numbers. Different algorithms exists for this, such as MD5 or SHA-1. Changing a single bit in a file (this file can be binary or not) will completely change the checksum.

Let’s for example look at the checksum for the file that I’m writing right now. Here are the commands and output to get the MD5 and SHA-1 checksums for this file:

```
janaerts$ md5 2019-10-31-lambda-architecture.md
MD5 (2019-10-31-lambda-architecture.md) = a271e75efb769d5c47a6f2d040e811f4
janaerts$ shasum 2019-10-31-lambda-architecture.md
2ae358f1ac32cb9ce2081b54efc27dcc83b8c945  2019-10-31-lambda-architecture.md
```

As you can see, these are quite long strings and MD5 and SHA-1 are indeed two different algorithms to create a checksum. The moment that I wrote the “A” (of “As you can see”) at the beginning of this paragraph, the checksum changed completely. Actually, below are the checksums after adding that single “A”. Clearly, the checksums are completely different.

```
janaerts$ md5 2019-10-31-lambda-architecture.md
MD5 (2019-10-31-lambda-architecture.md) = b597d18879c46c8838ad2085d2c7d2f9
janaerts$ shasum 2019-10-31-lambda-architecture.md
45c5a96dd506b884866e00ba9227080a1afd6afc  2019-10-31-lambda-architecture.md
```

This consistent hashing can for example also be used to assign documents to specific database nodes.

In principle, it _is_ possible that 2 different documents have the same hash value. This is called hash collision. Don’t worry about it too much, though. The MD5 algorithm generates a 128 bit string, which occurs once every 10^38 documents. If you generate a billion documents per second it would take 10 trillion times the age of the universe for a single accidental collision to occur…

Of course a group of researchers at Google tried to break this, and [they were actually successful](https://shattered.it/) on February 23th 2017.

![shattered]({{site.baseurl}}/assets/shattered.png)

To give you an idea of how difficult this is:

- it had taken them 2 years of research
- they performed 9,223,372,036,854,775,808 (9 quintillion) compressions
- they used 6,500 years of CPU computation time for phase 1
- they used 110 years of CPU computation time for phase 2

### ACID vs BASE
#### ACID
RDBMS systems try to follow the ACID model for reliable database transactions. ACID stands for atomicity, consistency, isolation and durability. The prototypical example of a database that needs to comply to the ACID rules is one which handles bank transactions.

![bank]({{site.baseurl}}/assets/bank.png)

- _Atomicity_: Exchange of funds in example must happen as an all-or-nothing transaction
- _Consistency_: Your database should never generate a report that shows a withdrawal from saving without the corresponding addition to the checking account. In other words: all reporting needs to be blocked during atomic operations.
- _Isolation_: Each part of the transaction occurs without knowledge of any other transaction
- _Durability_: Once all aspects of transaction are complete, it’s permanent.

For a bank transaction it is crucial that either all processes (withdraw and deposit) are performed or none.

The software to handle these rules is very complex. In some cases, 50-60% of the codebase for a database can be spent on enforcement of these rules. For this reason, newer databases often do not support database-level transaction management in their first release.

As a ground rule, you can consider ACID pessimistic systems that focus on consistency and integrity of data above all other considerations (e.g. temporarily blocking reporting mechanisms is a reasonable compromise to ensure systems return reliable and accurate information).

#### BASE
BASE stands for:

- _Basic Availability_: Information and service capability are “basically available” (e.g. you can always generate a report).
- _Soft-state_: Some inaccuracy is temporarily allowed and data may change while being used to reduce the amount of consumed resources.
- _Eventual consistency_: Eventually, when all service logic is executed, the systems is left in a consistent state.
A good example of a BASE-type system is a database that handles shopping carts in an online store. It is no problem fs the back-end reports are inconsistent for a few minutes (e.g. the total number of items sold is a bit off); it’s much more important that the customer can actually purchase things.

This means that BASE systems are basically optimistic as all parts of the system will eventually catch up and be consistent. BASE systems therefore tend to be much simpler and faster as they don’t have to deal with locking and unlocking resources.

{% include custom/series_nosql_next.html %}
