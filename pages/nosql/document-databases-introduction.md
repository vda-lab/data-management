---
title: Introduction to document stores
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-document-databases-introduction.html
folder: nosql
---

In contrast to relational databases (RDBMS) which define their columns at the _table_ level, document-oriented databases (also called document stores) define their fields at the _document_ level. You can imagine that a single row in a RDBMS table corresponds to a single document where the keys in the document correspond to the column names in the RDBMS. Let's look at an example table in a RDBMS containing information about buildings:

| id  | name      | address | city  | type   | nr_rooms | primary_or_secondary |
|:--  |:--------- |:------- |:----- |:-----  |:-------- |:-------------------- |
| 1   | building1 | street1 | city1 | hotel  | 15       |                      |
| 2   | building2 | street2 | city2 | school |          | primary              |
| 3   | building3 | street3 | city3 | hotel  | 52       |                      |
| 4   | building4 | street4 | city4 | church |          |                      |
| 5   | building5 | street5 | city5 | house  |          |                      |
| ... | ...       | ...     | ...   | ...    | ...      | ...                  |

This is a far from ideal way for storing this data because many cells will remain empty based on the type of building their rows represent: the `primary_or_secondary` column will be empty for every single building except for schools. Also: what if we want to add a new row for a type of building that we don't have yet? For example: a shop for which we also need to store the weekly closing day. To be able to do that, we'd need to first alter the whole table by adding a new column.

In document-oriented databases, these keys are however stored with the documents themselves. A typical way to represent this is as in JSON format, and can be represented as such:
{% highlight json %}
[
  { id: 1,
    name: "building1",
    address: "street1",
    city: "city1",
    type: "hotel",
    nr_rooms: 15 },
  { id: 2,
    name: "building2",
    address: "street2",
    city: "city2",
    type: "school"
    primary_or_secondary: "primary" },
  { id: 3,
    name: "building3",
    address: "street3",
    city: "city3",
    type: "hotel",
    nr_rooms: 52 },
  { id: 4,
    name: "building4",
    address: "street4",
    city: "city4",
    type: "church" },
  { id: 5,
    name: "building5",
    address: "street5",
    city: "city5",
    type: "house" },
  { id: 6,
    name: "building6",
    address: "street6",
    city: "city6",
    type: "shop",
    closing_day: "Monday" }
]
{% endhighlight %}
Notice that in the document for a house (`id` of 5), there is no mention of `primary_of_secondary` because it is not relevant as it is for a hotel.

{% include custom/series_nosql_next.html %}
