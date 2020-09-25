---
title: Key/value stores
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-keyvalue-stores.html
folder: nosql
---

Key/value stores are a very simple type of database. The only thing they do, is link an arbitrary blob of data (the value) to a key (a string). This blob of data can be a piece of text, an image, etc. It is not possible top run queries. Key-value stores therefore basically act as dictionaries:

![]({{site.baseurl}}/assets/gouge.png)

A key/value store only allows 3 operations: `put`, `get` and `delete`. Again: you can _not_ query.

![]({{site.baseurl}}/assets/keyvalue-1.png)

For example:

![]({{site.baseurl}}/assets/keyvalue-2.png)

This type of database is very scalable, and allows for fast retrieval of values regardless of the number of items in the database. In addition, you can store whatever you want as a value; you don't have to specify the data type for that value.

There basically exist only 2 rules when using a key/value store:
1. Keys should be unique: you can _never_ have two things with the same key.
1. Queries on values are not possible: you cannot select a key/value pair based on something that is in the value. This is different from e.g. a relational database, where you use a `WHERE` clause to constrain a result set. The value should be considered as opaque.

<img src="{{site.baseurl}}/assets/keyvalue-3.png" width="600px"/>

Although (actually: because) they are so simple, there are very specific use cases for key/value stores, for example to store webpages: the key is the URL, the value is the HTML. If you go to a webpage that you visited before, your web browser will first check if it has stored the contents of that website locally beforehand, before doing the costly action of downloading the webpage over the internet.

## Implementations

Many implementations of key/value stores exist, probably the easiest to use being Redis ([http://redis.io](http://redis.io)). Try it out on [http://try.redis.io](http://try.redis.io). [ArangoDB](www.arangodb.org) is a multi-model database which also allows to store key/values (see below).

{% include custom/series_nosql_next.html %}
