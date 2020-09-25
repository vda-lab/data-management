---
title: Querying graph data
keywords: nosql
sidebar: nosql_sidebar
toc: true
permalink: nosql-arangodb-querying-graph-data.html
folder: nosql
---

Although both `airports` and `flights` are collections in ArangoDB, we set `flights` to be an "Edge" collection, which means that it should have a `_from` and a `_to` key as it is used to link documents in other collections to each other.

There are 2 types of graphs in ArangoDB: named graphs and anonymous graphs.

Before we run the queries below, we will first create a named graph. To do so, click on `Graphs` and then on `Add Graph`. You will be presented with the following box:

<img src="{{ site.baseurl }}/assets/arangodb_creategraph.png" width="600px"/>

Here, select the following:
- Name: flightsGraph
- Edge definitions: flights
- fromCollections: airports
- toCollections: airports
- Leave Vertex collections empty.

## Graph queries
Of course what are we with graphs if we can't ask graph-specific questions. At the beginning of this post, we looked at how difficult it was to identify all friends of friends of James. What would this look like in a graph database?

The `FOR` syntax looks a little different when you're querying a graph rather than a collection of documents. It's
{% highlight sql %}
FOR v,e,p IN 2..2 ANY "myKey" GRAPH "myGraph"
LIMIT 5
RETURN v._id
{% endhighlight %}

This means (going from right to left):
- take the graph `myGraph`
- start from the document with `_key` of `myKey`
- follow links in both directions (`ANY` is both `INBOUND` and `OUTBOUND`)
- for 2 steps (`2..2` means `min..max`)
- take the final vertex `v`, the last link that lead to it `e`, and the whole path `p` from start to finish
- and return the final vertex's id

The whole path `p` contains the full list of vertices from source to target, as well as the list of edges between them.

Note that the key  graph need to be in quotes. The result of the query
{% highlight sql %}
FOR v,e,p IN 2..2 ANY "airports/JFK" GRAPH "flights"
LIMIT 5
RETURN v._id
{% endhighlight %}
is:
{% highlight csv %}
[
  "airports/IAH",
  "airports/JFK",
  "airports/CLT",
  "airports/EWR",
  "airports/ATL"
]
{% endhighlight %}
This query is lightning fast compared to what we did with the friends of a friend using a relational database!!

Of course you can add additional filters as well, for example to only return those that are located in California:
{% highlight sql %}
FOR v,e,p IN 2..2 ANY 'airports/JFK' GRAPH 'flightsGraph'
LIMIT 5000
FILTER v.state == 'CA'
RETURN DISTINCT v._id
{% endhighlight %}

The `LIMIT 5000` is so that we don't go through the whole dataset here, as we're just running this for demonstration purposes. The result of this query:
{% highlight csv %}
[
  "airports/SAN",
  "airports/LAX",
  "airports/ONT",
  "airports/BFL",
  "airports/SNA",
  "airports/SMF",
  "airports/FAT",
  "airports/SBP",
  "airports/PSP",
  "airports/SBA",
  "airports/PMD",
  "airports/MRY",
  "airports/ACV",
  "airports/BUR",
  "airports/CIC",
  "airports/CEC",
  "airports/MOD",
  "airports/RDD"
]
{% endhighlight %}

You actually don't need to create the graph beforehand, and can use the edge collections directly:
{% highlight sql %}
FOR v,e,p IN 2..2 ANY 'airports/JFK' flights
LIMIT 5000
FILTER v.state == 'CA'
RETURN DISTINCT v._id
{% endhighlight %}

Here we don't use the keyword `GRAPH`,  collection is not in quotes.

## Rewriting the document query that used joins
Above we said that we'd rewrite a query that used the document approach to one that uses a graph approach. The original query listed all airports in California, and listed where any flights were going to and what the distance is.

{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  FOR f IN flights
    FILTER f._from == a._id
    RETURN DISTINCT {departure: a._id, arrival: f._to, distance: f.Distance}
{% endhighlight %}

We can approach this from a graph perspective as well. Instead of checking the `_from` key in the `flights` documents, we consider the flights as a graph: we take all Californian airports, and follow all outbound links with a distance of 1.

{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  FOR v,e,p IN 1..1 OUTBOUND a flights
    RETURN DISTINCT { departure: a._id, arrival: v._id, distance: e.Distance}
{% endhighlight %}

This gives the same results.
{% highlight csv %}
airports/ACV  airports/SFO  250
airports/ACV  airports/SMF  207
airports/ACV  airports/CEC  56
...
{% endhighlight %}

Remember that we actually had quite a bit of work if we wanted to show the airport _names_ instead of their codes:
{% highlight sql %}
FOR a1 IN airports
  FILTER a1.state == 'CA'
  FOR f IN flights
    FILTER f._from == a1._id
    FOR a2 in airports
      FILTER a2._id == f._to
      FILTER a2.state == 'CA'
      RETURN DISTINCT {
        departure: a1.name,
        arrival: a2.name,
        distance: f.Distance }
{% endhighlight %}

In constrast, we only need to make a minor change in the `RETURN` statement of the graph query:

{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  FOR v,e,p IN 1..1 OUTBOUND a flights
    RETURN DISTINCT { departure: a.name, arrival: v.name, distance: e.Distance}
{% endhighlight %}

## Shortest path
The `SHORTEST_PATH` function (see [here](https://www.arangodb.com/docs/stable/aql/graphs-kshortest-paths.html)) allows you to find the shortest path between two nodes. For example: how to get in the smallest number of steps from the airport of Pellston Regional of Emmet County (PLN) to Adak (ADK)?

{% highlight sql %}
FOR path IN OUTBOUND SHORTEST_PATH 'airports/PLN' TO 'airports/ADK' flights
RETURN path
{% endhighlight %}

The result looks like this:

{% highlight csv %}
_key  _id           _rev         name                                 city       state  country  lat          long          vip
PLN   airports/PLN  _ZbpOKyy--Q  Pellston Regional of Emmet County    Pellston   MI     USA      45.5709275   -84.796715    false
DTW   airports/DTW  _ZbpOKxu-_S  Detroit Metropolitan-Wayne County    Detroit    MI     USA      42.21205889  -83.34883583  false
IAH   airports/IAH  _ZbpOKyK---  George Bush Intercontinental         Houston    TX     USA      29.98047222  -95.33972222  false
ANC   airports/ANC  _ZbpOKxW-Am  Ted Stevens Anchorage International  Anchorage  AK     USA      61.17432028  -149.9961856  false
ADK   airports/ADK  _ZbpOKxW--o  Adak                                 Adak       AK     USA      51.87796389  -176.6460306  false
{% endhighlight %}

The above does not take into account the distance that is flown. We can add that as the weight:
{% highlight sql %}
FOR path IN OUTBOUND SHORTEST_PATH 'airports/PLN' TO 'airports/ADK' flights
OPTIONS {
  weightAttribute: "Distance"
}
RETURN path
{% endhighlight %}

This shows that flying of Minneapolis instead of Houston would cut down on the number of miles flown:

{% highlight csv %}
_key  _id           _rev         name                                 city         state  country  lat          long          vip
PLN   airports/PLN  _ZbpOKyy--Q  Pellston Regional of Emmet County    Pellston     MI     USA      45.5709275   -84.796715    false
DTW   airports/DTW  _ZbpOKxu-_S  Detroit Metropolitan-Wayne County    Detroit      MI     USA      42.21205889  -83.34883583  false
MSP   airports/MSP  _ZbpOKyi--9  Minneapolis-St Paul Intl             Minneapolis  MN     USA      44.88054694  -93.2169225   false
ANC   airports/ANC  _ZbpOKxW-Am  Ted Stevens Anchorage International  Anchorage    AK     USA      61.17432028  -149.9961856  false
ADK   airports/ADK  _ZbpOKxW--o  Adak                                 Adak         AK     USA      51.87796389  -176.6460306  false
{% endhighlight %}

## Pattern matching
What if we want to find a complex pattern in a graph, such as loops, triangles, alternative paths, etc (see [above](#subgraph-mapping))? Let's say we want to find any alternative paths of length 3: where there are flights from airport 1 to airport 2 and from airport 2 to airport 4, but also from airport 1 to airport 3 and from airport 3 to airport 4.

![saves]({{ site.baseurl }}/assets/saves.png)

Let's check if there are alternative paths of length 2 between JFK and San Francisco SFO:
{% highlight sql %}
FOR v,e,p IN 2..2 ANY "airports/JFK" flights
FILTER v._id == 'airports/SFO'
LIMIT 5000
RETURN DISTINCT p.vertices[1]._id
{% endhighlight %}

It seems that there are many, including Atlanta (ATL), Boston (BOS), Phoenix (PHX), etc.

For an in-depth explanation on pattern matching, see [here](https://www.arangodb.com/arangodb-training-center/graphs/pattern-matching/).

## Centrality
As mentioned above, not all ArangoDB functonality is available through the web interface. For centrality queries and community detection, we'll have to refer you to the [arangosh documentation](https://www.arangodb.com/docs/stable/programs-arangosh.html) and [community detection tutorial](https://www.arangodb.com/pregel-community-detection/).

{% include custom/series_nosql_next.html %}
