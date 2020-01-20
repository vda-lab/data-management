---
title: The end of SQL?
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-the-end-of-sql.html
folder: nosql
series: nosql-series
weight: 4
---

So does this mean that we should leave SQL behind? No. What we'll be looking at is _polyglot persistence_: depending on what data you're working with, some of that might still be stored in an SQL database, while other parts are stored in a document store and graph database (see below). So instead of having a single database, we can end up with a collection of databases to support a single application.

![polyglot persistence]({{ site.baseurl }}/assets/polyglot_persistence.png)
<small>Source: https://martinfowler.com/articles/nosql-intro-original.pdf</small>

This figure shows how in the hypothetical case of a retailer's web application we might be using a combination of 8 different database technologies to store different types of information. Note that RDBMS are still part of the picture!

You'll often hear the term NoSQL as in "No-SQL", but this should be interpreted as "Not-Only-SQL".

{% include custom/series_nosql_next.html %}
