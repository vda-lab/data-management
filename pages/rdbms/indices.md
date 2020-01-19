---
title: Indices
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-indices.html
folder: rdbms
series: rdbms-series
weight: 14
---

There might be columns that you will often use for filtering. For example, you expect to regularly run queries that include a filter on ethnicity. To speed things up you can create an index on that column.

{% highlight sql %}
CREATE INDEX idx_ethnicity ON genotypes (ethnicity);
{% endhighlight %}

{% include custom/series_rdbms_next.html %}
