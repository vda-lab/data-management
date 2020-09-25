---
title: Loading data
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-arangodb-loading-data.html
folder: nosql
---

## Document data
Let's load some data. Download the list of airports in the US from [http://vda-lab.be/assets/airports.json](http://vda-lab.be/assets/airports.json). This file looks like this:

{% highlight json %}
{"_key": "00M", "name": "Thigpen ", "city": "Bay Springs", "state": "MS", "country": "USA", "lat": 31.95376472, "long": "Thigpen ", "vip": false}
{"_key": "00R", "name": "Livingston Municipal", "city": "Livingston", "state": "TX", "country": "USA", "lat": 30.68586111, "long": "Livingston Municipal", "vip": false}
{"_key": "00V", "name": "Meadow Lake", "city": "Colorado Springs", "state": "CO", "country": "USA", "lat": 38.94574889, "long": "Meadow Lake", "vip": false}
...
{% endhighlight %}

Remember from above that document databases often use JSON as their format. To load this into ArangoDB:
1. Create a new collection (`Collections` -> `Add Collection`) with the name `airports`. The `type` should be `document`.<br/><img src="{{site.baseurl}}/assets/arangodb_createcollection.png" width="400px"/>
2. Click on the collection, and then the `Upload documents from JSON file` button at the top. ![]({{site.baseurl}}/assets/arangodb_upload.png)
3. Select the `airports.json` file that you just downloaded onto your computer.

You should end up with something like this:

<img src="{{site.baseurl}}/assets/arangodb_airports.png" width="600px"/>

Notice that every document has a `_key` defined.

## Link data
In addition to `_key`, ArangoDB documents can have other special keys. In a graph context, links are nothing more than regular documents, but which have a `_from` and `_to` key to refer to other documents that are the nodes. So links in ArangoDB are basically also just documents, but with the special keys `_from` and `_to`. This means that we can also query them as documents (which is what we will actually do in "[6.2 Querying document data](#62-querying-document-data)").

![]({{ site.baseurl }}/assets/nodes_and_link.png)

We have a flight dataset, that you can download from [here]({{site.baseurl}}/assets/flights.json). Similar to loading the airports dataset, we go to the `Collections` page in the webinterface, and click `Upload`. This time, however, we need to set the type to `Edge` rather than `Document`.

<img src="{{site.baseurl}}/assets/arangodb_createcollection_edges.png" width="600px" />

This is what a single flight looks like:
{% highlight json %}
{
  "_key": "1834",
  "_id": "flights/1834",
  "_from": "airports/ATL",
  "_to": "airports/CHS",
  "_rev": "_ZRp7f-S---",
  "Year": 2008,
  "Month": 1,
  "Day": 1,
  "DayOfWeek": 2,
  "DepTime": 2,
  "ArrTime": 57,
  "DepTimeUTC": "2008-01-01T05:02:00.000Z",
  "ArrTimeUTC": "2008-01-01T05:57:00.000Z",
  "UniqueCarrier": "FL",
  "FlightNum": 579,
  "TailNum": "N937AT",
  "Distance": 259
}
{% endhighlight %}

{% include custom/series_nosql_next.html %}
