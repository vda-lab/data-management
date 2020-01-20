---
title: Writing scalability
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-writing-scalability.html
folder: nosql
series: nosql-series
weight: 2
---

Suppose that you begin to store genomic mutations in a mysql database. All goes well, until you notice that the database becomes too large for the computer you are running mysql on. There are different solutions for this:
1. Buy a bigger computer (= _vertical scaling_) which will typically be much more expensive
1. _Shard_ your data across different databases on different computers (= _horizontal scaling_): data for chromosome 1 is stored in a mysql database on computer 1, chromosome 2 is stored in a mysql database on computer 2, etc. Unfortunately, this does mean that in your application code (i.e. when you're trying to access this data from R or python), you need to know what computer to connect to. It gets worse if you later notice that one of these other servers becomes the bottleneck. Then you'd have to get additional computers and e.g. store the first 10% of chromosome 1 on computer 1, the next 10% on computer 2, etc. Again: this makes it very complicated in your R and/or python scripts as you have to know what is stored where.

<img src="{{ site.baseurl }}/assets/scalability.png" width="400px" />


{% include custom/series_nosql_next.html %}
