---
title: Querying key/value data
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-arangodb-querying-keyvalue-data.html
folder: nosql
---

As mentioned above, key/value stores are very quick for returning documents given a certain key. ArangoDB can be used as a key/value store as well. Remember from above that a key/value store should only do these things:

* Create a document with a given key
* Return a document given a key
* Delete a document given a key

Let's try these out. But before we do so, it'd be cleaner if we created a new collection just for this purpose. Go to `Collections` and create a new collection named `keyvalues`.

ArangoDB uses its own query language, called `AQL`, to access the data in the different collections. Go to the `Queries` section in the web interface.

## Creating a key/value pair
{% highlight sql %}
INSERT {_key: "a", value: "some text"} INTO keyvalues
{% endhighlight %}
This created our first key/value pair! The value can be anything, as we mentioned above:

{% highlight sql %}
INSERT {_key: "b", value: [1,2,3,4,5]} INTO keyvalues
INSERT {_key: "c", value: {first: 1, second: 2}} INTO keyvalues
{% endhighlight %}


## Retrieving a key/value pair
To retrieve a document given a certain key (in this case "`c`"), we can run the query
{% highlight sql %}
RETURN DOCUMENT('keyvalues/c').value
{% endhighlight %}

How this works will get much more clear as we move further down in this post...

## Removing a key/value pair
To remove a key/value pair (e.g. the pair for key `b`), we run the following:
{% highlight sql %}
REMOVE b FROM keyvalues
{% endhighlight %}

Retrieving and removing key/value pairs are very fast in ArangoDB, because the `_key` attribute is indexed by default.

{% include custom/series_nosql_next.html %}
