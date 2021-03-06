---
title: Graph mining
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-graph-databases-mining.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

Graphs are very generic data structures, but are amenable to very complex analyses. These include the following.

## Community detection
A community in a graph is a group of nodes that are densely connected internally. You can imagine that e.g. in social networks we can identify groups of friends this way.

![communities]({{ site.baseurl }}/assets/graph-communities.png)

Several approaches exist to finding communities:
* _null models_: a community is a set of nodes for which the connectivity deviates the most from the null model
* _block models_: identify blocks of nodes with common properties
* _flow models_: a community is a set of nodes among which a fl ow persists for a long time once entered

The _infomap_ algorithm is an example of a flow model (for a demo, see [http://www.mapequation.org/apps/MapDemo.html](http://www.mapequation.org/apps/MapDemo.html)).

## Link prediction
When data is acquired from a real-world source, this data might be incomplete and links that should actually be there are not in the dataset. For example, you gather historical data on births, marriages and deaths from church and city records. There is therefore a high chance that you don't have all data. Another domain where this is important is in protein-protein interactions.

Link prediction can be done in different ways, and can happen in a dynamic or static setting. In the _dynamic setting_, we try to predict the likelihood of a future association between two nodes; in the _static setting_, we try to infer missing links. These algorithms are based on a similarity matrix between the network nodes, which can take different forms:

* _graph distance_: the length of the shortest path between 2 nodes
* _common neighbours_: two strangers who have a common friend may be introduced by that friend
* _Jaccard's coefficient_: the probability that 2 nodes have the same neighbours
* _frequency-weighted common neighbours (Adamic/Adar predictor_): counts common features (e.g. links), but weighs rare features more heavily
* _preferential attachment_: new link between nodes with high number of links is more likely than between nodes with low number of links
* _exponential damped path counts (Katz measure)_: the more paths there are between two nodes and the shorter these paths are, the more similar the nodes are
* _hitting time_: random walk starts at node A => expected number of steps required to reach node B
* _rooted pagerank_: idem, but periodical reset to prevent that 2 nodes that are actually close are connected through long deviation

## Subgraph mapping
Subgraph mining is another type of query that is very important in e.g. bioinformatics. Some example patterns:

- [A] three-node feedback loop
- [B] tree chain
- [C] four-node feedback loop
- [D] feedforward loop
- [E] bi-parallel pattern
- [F] bi-fan

![network motifs]({{ site.baseurl }}/assets/network-motifs.png)

It is for example important when developing a drug for a certain disease by knocking out the effect of a gene that that gene is not in a bi-parallel pattern (`V2` in image `E` above) because activation of node `V4` is saved by `V3`.

{% include custom/series_nosql_next.html %}
