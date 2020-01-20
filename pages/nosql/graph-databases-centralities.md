---
title: Centralities
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-graph-databases-centralities.html
folder: nosql
series: nosql-series
weight: 14
---

Another important way of describing nodes is based on their _centrality_, i.e. how _central_ they are in the network. There exist different versions of this centrality:
- _degree centrality_: how many other vertices a given vertex is connected to. This is the same as node degree.
- _betweenness centrality_: how many critical paths go through this node? In other words: without these nodes, there would be no way for to neighbours to communicate.

$$
C_{B}(i)=\frac{\sum\limits_{j \neq k} g_{jk} (i)}{g_{jk}} \xrightarrow[]{normalize} C'_B = \frac{C_B(i)}{(n-1)(n-2)/2}
$$

, where the denominator is the number of vertex pairs excluding the vertex itself. $$g_jk(i)$$ is number of shortest paths between $$j$$ and $$k$$, going through i; $$g_jk$$ is the total number of shortest paths between $$j$$ and $$k$$.


- _closeness centrality_: how much is the node in the "middle" of things, not too far from the center. This is the inverse total distance to all other nodes.

$$
C_C(i) = \frac{1}{\sum\limits_{j=1}^N d(i,j)} \xrightarrow[]{normalize} C'_C(i) = \frac{C_C(i)}{N-1}
$$

In the image below, nodes in A are coloured based on betweenness centrality, in B based on closeness centrality, and in D on degree centrality.

![centralities]({{ site.baseurl }}/assets/centralities.png)
<br/><small>Source of image: to add</small>

{% include custom/series_nosql_next.html %}
