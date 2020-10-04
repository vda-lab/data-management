---
title: Data modelling
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-graph-databases-data-modelling.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

In general, vertices are used to represent _things_ and edges are used to represent _connections_. Vertex properties can include e.g. metadata such as timestamp, version number etc; edges properties often include the weight of a connection, but can also cover things like the quality of a relationship and other metadata of that relationship.

Below is an example of a graph:
![graph]({{site.baseurl}}/assets/graph.png)

Basically all types of data can be modelled as a graph. Consider our buildings table from above:

| id  | name      | address | city  | type   | nr_rooms | primary_or_secondary |
|:--  |:--------- |:------- |:----- |:-----  |:-------- |:-------------------- |
| 1   | building1 | street1 | city1 | hotel  | 15       |                      |
| 2   | building2 | street2 | city2 | school |          | primary              |
| 3   | building3 | street3 | city3 | hotel  | 52       |                      |
| 4   | building4 | street4 | city4 | church |          |                      |
| 5   | building5 | street5 | city5 | house  |          |                      |
| ... | ...       | ...     | ...   | ...    | ...      | ...                  |

This can also be represented as a network, where:
- every building is a vertex
- every value for a property is a vertex as well
- the column becomes the relation

For example, the information for the first building can be represented as such:

![]({{site.baseurl}}/assets/examplegraph.png)

There is actually a formal way of describing this called RDF, but we won't go into that here...

{% include custom/series_nosql_next.html %}
