---
title: Implementations
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-document-databases-implementations.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

A quick look at the Wikipedia page for ["Document-oriented database"](https://en.wikipedia.org/wiki/Document-oriented_database#Implementations) quickly shows us that there is a long list (>30) implementations. Each of these has their own strengths and use cases. They include [AllegroGraph](https://allegrograph.com/), [ArangoDB](http://arangodb.com/), [CouchDB](https://couchdb.apache.org/), [MongoDB](https://www.mongodb.com/), [OrientDB](http://orientdb.org/), [RethinkDB](http://rethinkdb.com/) and so on.

![]({{site.baseurl}}/assets/logo_allegrograph.png)![]({{site.baseurl}}/assets/logo_arangodb.png)![]({{site.baseurl}}/assets/logo_couchdb.png)![]({{site.baseurl}}/assets/logo_mongodb.png)![]({{site.baseurl}}/assets/logo_orientdb.png)![]({{site.baseurl}}/assets/logo_rethinkdb.png)

Probably the best known document store is mongodb ([http://mongodb.com](http://mongodb.com)). This database system is single-model in that it does not handle key/values and graphs; it's only meant for storing documents. Further in this tutorial we will however use ArangoDB because we can use it for different types of data (including graphs and key/values).

{% include custom/series_nosql_next.html %}
