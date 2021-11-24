---
title: Impedance mismatch
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-impedance-mismatch.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

When discussing relational databases, we went through the exercise of normalising our database scheme to make sure that, among other things, we minimise the emergence of inconsistencies of the data, and allow ourselves to ask the database any question. But this is actually strange, right? We first deconstruct the data that we receive into normalised tables, only to need table joins to get anything useful back out. Also, any value in the database needs to be simple, and can for example should not be stored as a nested record or a list. For example, you would not store the children of a couple like this:

| id | mother | father | children       |
|----|--------|--------|----------------|
|  1 | John D | Jane D | [Tim,Tom,Tina] |

In contrast, a normalised way of storing this could be:

**individuals**

| id | name   |
|----|--------|
|  1 | John D |
|  2 | Jane D |
|  3 | Tim    |
|  4 | Tom    |
|  5 | Tina   |

**relationships**

| id | individual_id1 | individual_id2 | type       |
|----|----------------|----------------|------------|
|  1 |              3 |              1 | child_of   |
|  2 |              4 |              1 | child_of   |
|  3 |              5 |              1 | child_of   |
|  4 |              3 |              2 | child_of   |
|  5 |              4 |              2 | child_of   |
|  6 |              5 |              2 | child_of   |
|  7 |              1 |              2 | married_to |

That is called the _impedance mismatch_: there is a mismatch between how you think about the data, and how it needs to be stored in the relational database. The example below shows how all information that conceptually belongs to the same order is split up over multiple tables. This means that the developer needs to constantly switch between his/her mental model of the _application_ and that of the _database_ which can become very frustrating.

![impedance mismatch]({{site.baseurl}}/assets/impedance_mismatch.png)

<small><i>Impedance mismatch (taken from "NoSQL Distilled", Sadalage & Fowler)</i></small>

{% include custom/series_nosql_next.html %}
