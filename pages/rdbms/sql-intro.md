---
title: SQL - Structured Query Language
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-sql-intro.html
folder: rdbms
series: rdbms-series
weight: 16
---

Any interaction with data in RDBMS can happen through the Structured Query Language (SQL): create tables, insert data, search data, ... There are two subparts of SQL:

***DDL - Data Definition Language:***

{% highlight sql %}
CREATE DATABASE test;
CREATE TABLE snps (id INT PRIMARY KEY AUTOINCREMENT, accession STRING, chromosome STRING, position INTEGER);
ALTER TABLE...
DROP TABLE snps;
{% endhighlight %}

For examples: see above.

***DML - Data Manipulation Language:***

{% highlight sql %}
SELECT
UPDATE
INSERT
DELETE
{% endhighlight %}

Some additional functions are:

{% highlight sql %}
DISTINCT
COUNT(*)
COUNT(DISTINCT column)
MAX(), MIN(), AVG()
GROUP BY
UNION, INTERSECT
{% endhighlight %}

We'll look closer at getting data into a database and then querying it, using these four SQL commands.

{% include custom/series_rdbms_next.html %}
