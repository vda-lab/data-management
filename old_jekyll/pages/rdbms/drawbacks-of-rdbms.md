---
title: Drawbacks of relational databases
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-drawbacks-of-rdbms.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

Relational databases are great. They can be a big help in storing and organizing your data. But they are not the ideal solution in all situations.

## Scalability
Relational databases are only scalable in a limited way. The fact that you try to normalise your data means that your data is distributed over different tables. Any query on that data often requires extensive joins. This is OK, until you have tables with millions of rows. A join can in that case a *very* long time to run.

[Although outside of the scope of this lecture.] One solution sometimes used is to go for a star-schema rather than a fully normalised schema. Or using a NoSQL database management system that is horizontally scalable (document-oriented, column-oriented or graph databases).

## Modeling
Some types of information are difficult to model when using a relational paradigm. In a relational database, different records can be linked across tables using foreign keys. If you're however really interested in the relations themselved (*e.g.* social graphs, protein-protein-interaction, ...) you are much better of to use a real graph database (*e.g.* neo4j) instead of a relational database. In a graph database finding all neighbours-of-neighbours in a graph of 50 members (basically) takes as long as in a graph with 50 million members.

## Drawback exercise
Suppose you want to model a social graph. People have names, and know other people. Every "know" is reciprocal (so if I know you then you know me). The data might look like this:

<pre>
Tim knows Terry
Tom knows Terry
Terry knows Gerry
Gerry knows Rik
Gerry knows James
James knows John
Fred knows James
Frits knows Fred
</pre>

In table format:

| knower | knowee |
|:-------|:-------|
| Tim    | Terry  |
| Tom    | Terry  |
| Terry  | Gerry  |
| Gerry  | Rik    |
| Gerry  | James  |
| James  | John   |
| Fred   | James  |
| Frits  | Fred   |
| Gerry  | Frits  |

If you *really* want to have this in a relational database, how would you find out who are the friends of the friends of James? First, we'd need to find out who James' friends are:

{% highlight sql %}
SELECT knower FROM friends WHERE knowee = 'James'
UNION
SELECT knowee FROM friends WHERE knower = 'James';
{% endhighlight %}

Using this as a subquery, we can then find out who the friends of those friends are:
{% highlight sql %}
SELECT knower FROM friends
WHERE knowee IN (
  SELECT knower FROM friends WHERE knowee = 'James'
  UNION
  SELECT knowee FROM friends WHERE knower = 'James'
)
UNION
SELECT knowee FROM friends
WHERE knower IN (
  SELECT knower FROM friends WHERE knowee = 'James'
  UNION
  SELECT knowee FROM friends WHERE knower = 'James'
);
{% endhighlight %}

If we want to know how big the group is, we'll have to nest this _again_ as a subquery:

{% highlight sql %}
SELECT COUNT(*) FROM (
  SELECT knower FROM friends
  WHERE knowee IN (
    SELECT knower FROM friends WHERE knowee = 'James'
    UNION
    SELECT knowee FROM friends WHERE knower = 'James'
  )
  UNION
  SELECT knowee FROM friends
  WHERE knower IN (
    SELECT knower FROM friends WHERE knowee = 'James'
    UNION
    SELECT knowee FROM friends WHERE knower = 'James'
  )
);
{% endhighlight %}

You can imagine that there must be better ways of doing this. Remember this example when you'll learn about graph databases...

{% include custom/series_rdbms_next.html %}
