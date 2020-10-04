---
title: Nomenclature
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-graph-databases-nomenclature.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

A graph consists of vertices (aka nodes, aka objects) and edges (aka links, aka relations), where an edge is a connection between two vertices. Both vertices and edges can have properties.

$$
G = (V,E)
$$

Any graph can be described using different metrics:
- _order_ of a graph = number of nodes
- _size_ of a graph = number of edges
- graph _density_ = how much its nodes are connected. In a dense graph, the number of edges is close to the maximal number of edges (i.e. a fully-connected graph).
    - for undirected graphs, this is:
$$
\frac{2 |E|}{|V|(|V|-1)}
$$
    - for directed graphs, this is:
$$
\frac{|E|}{|V|(|V|-1)}
$$
- the _degree_ of a node = how many edges are connected to the node. This can be separated into _in-degree_ and _out-degree_, which are - respectively - the number of incoming and outgoing edges.
- the _distance_ between two nodes = the number of edges in the shortest path between them
- the _diameter_ of a graph = the maximum distance in a graph
- a _d-regular_ graph = a graph where the maximum degree is the same as the minimum degree _d_
- a _path_ = a sequence of edges that connects a sequence of different vertices
- a _connected graph_ = a graph in which there exists a direct connection between any two vertices

{% include custom/series_nosql_next.html %}
