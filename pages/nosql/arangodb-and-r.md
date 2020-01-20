---
title: ArangoDB and R
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-arangodb-and-r.html
folder: nosql
series: nosql-series
weight: 25
---

See the links for documentation on how to use ArangoDB from R and other languages. Just as an illustration: here's a document query in R:
{% highlight R %}
all.cities <- cities %>% all_documents()
all.persons <- persons %>% all_documents()

if(all.cities$London$getValues()$capital){
  print("London is still the capital of UK")
} else {
  print("What's happening there???")
}
{% endhighlight %}

And a graph query:

{% highlight R %}
london.residence <- residenceGraph %>%
  traversal(vertices = c(all.cities$London), depth = 2)
london.residence %>% visualize()
{% endhighlight %}

will return:

![]({{ site.baseurl }}/assets/aRangodb-graph.png)

{% include custom/series_nosql_next.html %}
