---
title: Joining vs embedding
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-joining-vs-embedding.html
folder: nosql
series: nosql-series
weight: 8
---

Whereas you use a table _join_ in a RDBMS to combine different concepts/tables, you'd use _linking_ (which is equivalent to a join) or _embedding_ in document stores.

A table join in RDBMS:

<img src="{{ site.baseurl }}/assets/joining.png" width="400px"/>

Linking and embedding in a document store:

<img src="{{ site.baseurl }}/assets/linking-embedding.png" width="400px"/>

This fact that we can use embedding has multiple advantages:
- The embedded objects are returned in the same query as the parent object, meaning that only 1 trip to the database is necessary. In the example above, if you'd query for a blog entry, you get the comments and tags with it for free.
- Objects in the same collection are generally stored sequentially on disk, leading to fast retrieval.
- If the document model matches your domain, it is much easier to understand than a normalised relational database.

In specific document-oriented databases like MongoDB, the fact that you start _linking_ between documents should give you some [code smell](https://en.wikipedia.org/wiki/Code_smell). This is because in MongoDB you cannot query documents and follow links between collections. This will have to be done in your (R, python, or other) application code. (This is actually one of the advantages of a multi-model database like ArangoDB which does make this possible.)

{% include custom/series_nosql_next.html %}
