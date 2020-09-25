---
title: ArangoDB is a multimodel database
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-arangodb-multimodel-database.html
folder: nosql
---

As for RDBMS, there are many different implementations of document-oriented databases. Unfortunately, as the NoSQL field is much younger than the RDBMS area, things have not settled enough so that standards are formed. In the RDBMS world, there are many implementations such as Oracle, MySQL, PostgreSQL, Microsoft Access, etc, but they all conform to the same standard for querying their data: SQL. In the NoSQL world, however, this is very different and different implementations use very different query languages. For example, a search in the document store MongoDB (which is widely used) looks like this:
{% highlight csv %}
db.individuals.findAll({ethnicity: "African"}, {genotypes: 1})
{% endhighlight %}

whereas it would look like this in ArangoDB:
{% highlight sql %}
FOR i IN individuals
FILTER i.ethnicity = 'African'
RETURN i.genotypes
{% endhighlight %}

The same is true for graph databases. A query in the popular Neo4j database can look like this (in what is called the _cypher_ language):
{% highlight csv %}
MATCH (a)-[:WORKS_FOR]->(b:Company {name: "Microsoft"}) RETURN a
{% endhighlight %}
would be the following in _gremlin_:
{% highlight csv %}
g.V().out('works_for').inV().hasLabel("Company").has("name", "Microsoft")
{% endhighlight %}
whereas it would look like this in ArangoDB (in _AQL_):
{% highlight sql %}
FOR a IN individuals
  FOR v,e,p IN 1..1 OUTBOUND a GRAPH 'works_for'
    FILTER v.name = 'Microsoft'
    RETURN a
{% endhighlight %}

Further in this post we'll be using [ArangoDB](https://www.arangodb.com/) as our database, because - for this course - we can then at least stick with _one_ query language.

{% include custom/series_nosql_next.html %}
