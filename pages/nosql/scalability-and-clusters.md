---
title: Scalability and clusters
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-scalability-and-clusters.html
folder: nosql
---
The 2000s has seen a boom in the amount of data generated and stored. There are basically two approaches to cope with this: _scale up_ or _scale out_. What you do when scaling _up_ is to just buy a bigger server on which we can run the database server. This works up to a point, but (a) there are clear limits in size, and (b) it is very expensive. In the other option, scaling _out_, we take multiple commodity (and therefore cheap) machines and set them up as a cluster where each of the machines has to store only part of the data. Unfortunately, RDBMS are not designed with this in mind.

## Querying data
Best practices in relational database design call for a normalised design (see in our [previous post](REF)). This means that the different concepts in the data are separated out into tables, and can be _joined_ together again in a query. Unfortunately, joins can be very expensive. For example, the Ensembl database (www.ensembl.org) is a fully normalised omics database, containing a total of 74 tables. For example, to get the exon positions for a given gene, one needs to run 3 joins.

![joins]({{ site.baseurl }}/assets/rdbms-joins.png)

(Actually: note that this ends at `seq_region` and not at chromosome. To get to the chromosome actually requires two more joins but those are too complex to explain in the context of this session...)

The query to get the exon positions for `FAM39B protein`:
{% highlight sql %}
SELECT e.seq_region_start
FROM gene g, transcript t, exon_transcript et, exon e
WHERE g.description = 'FAM39B protein'
AND g.gene_id = t.gene_id
AND t.transcript_id = et.transcript_id
AND et.exon_id = e.exon_id;
{% endhighlight %}

## Writing data
Suppose that you begin to store genomic mutations in a mysql database. All goes well, until you notice that the database becomes too large for the computer you are running mysql on. There are different solutions for this:
1. Buy a bigger computer (= _vertical scaling_) which will typically be much more expensive
1. _Shard_ your data across different databases on different computers (= _horizontal scaling_): data for chromosome 1 is stored in a mysql database on computer 1, chromosome 2 is stored in a mysql database on computer 2, etc. Unfortunately, this does mean that in your application code (i.e. when you're trying to access this data from R or python), you need to know what computer to connect to. It gets worse if you later notice that one of these other servers becomes the bottleneck. Then you'd have to get additional computers and e.g. store the first 10% of chromosome 1 on computer 1, the next 10% on computer 2, etc. Again: this makes it very complicated in your R and/or python scripts as you have to know what is stored where.

<img src="{{ site.baseurl }}/assets/scalability.png" width="400px" />

{% include custom/series_nosql_next.html %}
