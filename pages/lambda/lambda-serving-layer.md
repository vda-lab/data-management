---
title: Serving layer
keywords: lambda
sidebar: lambda_sidebar
toc: true
permalink: lambda-serving-layer.html
folder: lambda
series: lambda-series
weight: 9
---

The serving layer contains one or more versions of the data in a form that we want for specific questions. Let's look at the friends example from above. We want to keep the original data in the batch layer, but also want to have easier versions to work with. These versions are computed by the batch layer, and are made available in what is called the _serving layer_.

![friends-1]({{ site.baseurl }}/assets/friends-1.png)

The "friend_counts" table, for example, can then be queried easily to get the number of friends for every individual. The serving layer therefore contains _versions of the data optimised for answering specific questions_.

This recomputation can be triggered by different things: it might start automatically when the previous round of recomputation has finished, it might start automatically whenever new data has been added, or (as in the example at the end of this post) it might be done on the fly when you're for example using SQL views.

## Making multiple views
Remember when we talked about [data modeling]({{ site.baseurl }}/2019/09/beyond-sql#44-data-modelling) in document-databases, that the way that the documents are embedded can have huge effects on performance. In our example there, genotypes could be organised by individual or by SNP.

{% highlight json %}
{ name: "Tom",
  ethnicity: "African",
  genotypes: [
    { snp: "rs0001",
      genotype: "A/A",
      position: "1_8271" },
    { snp: "rs0002",
      genotype: "A/G",
      position: "1_127279" },
    { snp: "rs0003",
      genotype: "C/C",
      position: "1_82719" },
    ...
  ]}
{ name: "John",
  ethnicity: "Caucasian",
  ...
{% endhighlight %}

versus

{% highlight json %}
{ snp: "rs0001",
  position: "1_8271",
  genotypes: [
    { name: "Tom",
      ethnicity: "African",
      genotype: "A/A" },
    { name: "John",
      ethnicity: "Caucasian",
      genotype: "A/A" },
    ...
  ]}
{% endhighlight %}

In a lambda architecture, if you know that you have to be able to answer both "what are the genotypes for a particular individual" and "what are the genotypes for a particular SNP" regularly, you'll just create both versions of the data in the serving layer. You might think that this is dangerous because you might end up with inconsistencies when you have to update something. This was one of the reasons that we went for normalisation when we were talking about [relational databases](http://vda-lab.be/2019/08/extended-introduction-to-relational-databases). There is however a big difference here: when we need to make a change, that change is added to the _batch_ layer and would trickle down automatically to _both_ versions in the serving layer.

## Recomputation updates
The code necessary to create these "views" on the data is typically very simple. The batch layer continuously _recomputes_ these views, which are then exposed in the serving layer (called _batch views_). These computations are conceptually very simple, because they always take all the data into consideration and basically _delete the view and replace it with a completely new version_. These are so-called _recomputation updates_, which are very different from _incremental updates_, in which the view remains where it is and only those parts that changed are updated. If the recomputation update is finished, it basically starts all over again.

## Serving layer is out of date
This approach does have a drawback, and that is that the data in the serving layer will always be out of date: the recomputation takes the data that is in the batch layer _at the moment the computation begins_, and does not look at any data that is added afterwards. Consider the image below. Let's say that at timepoint t1 we have a serving layer and start its recomputation from the batch layer, and the recomputation is finished at t4. At timepoint t2 new data is added to the batch layer, but is not considered in the recomputation because that only took data into account that was in the batch layer at the start of the recomputation. At t3 we want to query the database (via the serving layer), and will miss the dark and the red datapoints because they are not in the serving layer yet. If we'd perform the same query at timepoint t4 we would include the dark grey datapoint.

<img src="{{ site.baseurl }}/assets/servinglayer-outofdate2.png" width="400px" />

Similarly, adding a record in the friends batch layer will take some time to become visible in the serving layer.

![friends-2]({{ site.baseurl }}/assets/friends-2.png)

In many cases, having a serving layer that is slightly out of date is not really a problem. Think for example of the online store shopping cart mentioned above.

If it is really necessary to have the result of queries to be constantly up-to-date, we need a speed layer as well.

{% include custom/series_lambda_next.html %}
