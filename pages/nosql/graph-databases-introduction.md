---
title: Introduction
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-graph-databases-introduction.html
folder: nosql
---

Graphs are used in a wide range of applications, from fraud detection (see the Panama Papers) and anti-terrorism and social marketing to drug interaction research and genome sequencing.

<img src="{{ site.baseurl }}/assets/hairball.png" width="400px"/>

Graphs or networks are data structures where the most important information is the _relationship_ between entities rather than the entities themselves, such as friendship relationships. Whereas in relational databases you typically aggregate operations on sets, in graph databases you'll more typically hop around relationships between records. Graphs are very expressive, and any type of data can be modelled as one (although that is no guarantee that a particular graph is fit for purpose).

Graphs come in all shapes and forms. Links can be directed or undirected, weighted or unweighted. They can be directed acyclic graphs (where no loops exist), consist of one or more connected components, and actually consist of multiple graphs themselves. The latter (so-called multi-layer networks) can e.g. be a first network representing friendships between people, a second network representing cities and how they are connected through public transportation, and both being linked by which people work in which cities.

<img src="{{ site.baseurl }}/assets/graph-types.png" width="600px" />

{% include custom/series_nosql_next.html %}
