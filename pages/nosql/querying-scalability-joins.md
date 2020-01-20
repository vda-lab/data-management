---
title: Querying scalability
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-querying-scalability-joins.html
folder: nosql
series: nosql-series
weight: 1
---

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

{% include custom/series_nosql_next.html %}
