---
title: Data modelling
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-document-databases-data-modelling.html
folder: nosql
---

The data model depends on your use case, and your choice will greatly affect the complexity and performance of the queries. Let's for example look at the genotypes from the [previous session]({{ site.baseurl }}/2019/08/extended-introduction-to-relational-databases). There are 2 options to choose between: you can create documents per individual, or per SNP.

Per individual, a document could look like this:
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

In contrast, a document per SNP looks like:
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

We'll go into loading data into and querying data from a document-related database [later](http://localhost:4000/2019/09/arangodb#6-arangodb-as-a-document-oriented-database).

If your data documents are structured along individuals, it will bve cvery fast to get all genotypes for a given individual, but very slow to get all genotypes for a given SNP. Therefore, in a big data setting, it is not unusual to have both, and to generate one of these collections based on the other.

{% include custom/series_nosql_next.html %}
