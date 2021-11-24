---
title: Data modelling patterns
keywords: nosql
sidebar: nosql_sidebar
toc: true
permalink: nosql-document-databases-data-modelling-patterns.html
folder: nosql
---
<!-- see https://www.youtube.com/watch?v=yuPjoC3jmPA -->
<!-- see https://www.youtube.com/watch?v=bxw1AkH2aM4&t=1496s -->
<!-- see https://www.mongodb.com/blog/post/building-with-patterns-a-summary -->

{% include custom/series_nosql_previous.html %}

According to Wikipedia, "a [...] design pattern is a general, reusable solution to a commonly occurring problem". This is also true for designing the data model (of data schema) in document databases. Below, we will go over some of these design patterns. A more complete list and explanation is available on e.g. the [MongoDB blog](https://www.mongodb.com/blog/post/building-with-patterns-a-summary). Many of the examples below also come from that source.

## Attribute pattern
In the attribute pattern, we group similar fields (i.e. with the same value type) into a single array. Consider for example the following document on the movie "Star Wars":

{% highlight json %}
{ title: "Star Wars",
  new_title: "Star Wars: Episode IV - A New Hope",
  director: "George Lucas",
  release_US: "1977-05-20",
  release_France: "1977-10-19",
  release_Italy: "1977-10-20",
  ...
}
{% endhighlight %}

To make quick searches on the release date we'd have to put an index on every single key that starts with `release_`. Another approach is to put these together in a separate attribute:

{% highlight json %}
{ title: "Star Wars",
  new_title: "Star Wars: Episode IV - A New Hope",
  director: "George Lucas",
  releases: [
    { country: "US", date: "1977-05-20" },
    { country: "France", date: "1977-10-19" },
    { country: "Italy", date: "1977-10-20" },
    ...
  ]
}
{% endhighlight %}

In this case we only have to make a combined index on `releases.country` and `releases.date`.

## Bucket pattern
Do you always want to store each datapoint in a separate document? You don't have to. A good example is time-series data, e.g. from sensors. If those sensors return a value every second, you will end up with a _lot_ of documents. Especially if you're not necessarily interested in that resolution it makes sense to bucket the data.

For example, you _could_ store data from a temperature sensor like this:
{% highlight json %}
{ sensor_id: 1,
  datetime: "2020-10-12 10:10:58",
  value: 27.3 },
{ sensor_id: 1,
  datetime: "2020-10-12 10:10:59",
  value: 27.3 },
{ sensor_id: 1,
  datetime: "2020-10-12 10:11:00",
  value: 27.4 },
{ sensor_id: 1,
  datetime: "2020-10-12 10:11:01",
  value: 27.4 },
...
{% endhighlight %}

But obviously we're not really interested in the per-second readings. A more proper time period could be e.g. each 5 minutes. Your document would - using the bucket pattern - then look like this:
{% highlight json %}
{ sensor_id: 1,
  start: "2020-10-12 10:10:00",
  end: "2020-10-12 10:15:00",
  readings: [
    { timestamp: "2020-10-12 10:10:01", value: 27.3 },
    { timestamp: "2020-10-12 10:10:02", value: 27.3 },
    { timestamp: "2020-10-12 10:10:03", value: 27.3 },
    ...
    { timestamp: "2020-10-12 10:14:59", value: 27.4 },
  ]
}
{% endhighlight %}

This has several advantages:
- it fits more with the time granularity that we are thinking in
- it will be easy to compute aggregations in this granularity
- if we see that we don't need the high-resolution data after a while, we can safely delete the `readings` part if we need to (e.g. to safe on storage space)

## Computed pattern
Using buckets is actually a great segue into the computed pattern.

It is not unusual that you end up extracting information from a database and immediately make simple or complex calculations. At that point you can make the decision to store the pre-computed values in the database as well. Technically you're duplicating data (the original fields plus a derived field), but it might speed up your application a lot.

In the bucket pattern example above, we want to always look at the average temperature in those 5-minute intervals. We can calculate that every time we fetch the data from the database, but we can actually pre-calculate it as well and store that result in the document itself.

{% highlight json %}
{ sensor_id: 1,
  start: "2020-10-12 10:10:00",
  end: "2020-10-12 10:15:00",
  readings: [
    { timestamp: "2020-10-12 10:10:01", value: 27.3 },
    { timestamp: "2020-10-12 10:10:02", value: 27.3 },
    { timestamp: "2020-10-12 10:10:03", value: 27.3 },
    ...
    { timestamp: "2020-10-12 10:14:59", value: 27.4 },
  ]
  avg_reading: 27.326
}
{% endhighlight %}

## Extended reference
We use the extended reference when we need many joins to bring together frequently accessed data. For example, consider information on customers and orders. Because this is a many-to-many relationship, we would use a referencing approach, and store a particular customer and one of their orders like this (yet another example from the MongoDB website):

In the `customers` collection:
{% highlight json %}
{ _id: "cust_123",
  name: "Katrina Pope",
  address: "123 Main Str",
  city: "Somewhere",
  country: "Someplace",
  dateofbirth: "1992-11-03",
  social_networks: [
    { twitter: "@me123" }]
}
{% endhighlight %}

In the `orders` collection:
{% highlight json %}
{ _id: "order_1827",
  date: "2019-02-18",
  customer_id: "cust_123",
  order: [
    { product: "paper", qty: 1, cost: 3.49 },
    { product: "pen", qty: 5, cost: 0.99 }
  ]}
{% endhighlight %}

Now to know where the order should be shipped, we always need to make a join with the `customers` table to get the address. Using the extended reference pattern, we copy the necessary information (but nothing more) into the order itself:

In the `customers` collection:
{% highlight json %}
{ _id: "cust_123",
  name: "Katrina Pope",
  address: "123 Main Str",
  city: "Somewhere",
  country: "Someplace",
  dateofbirth: "1992-11-03",
  social_networks: [
    { twitter: "@me123" }]
}
{% endhighlight %}

In the `orders` collection, we now also have the `shipping_address` key which is a copy of information from the `customers` table:
{% highlight json %}
{ _id: "order_1827",
  date: "2019-02-18",
  customer_id: "cust_123",
  shipping_address: {
    name: "Katrina Pope",
    address: "123 Main Str",
    city: "Somewhere",
    country: "Someplace"
  },
  order: [
    { product: "paper", qty: 1, cost: 3.49 },
    { product: "pen", qty: 5, cost: 0.99 }
  ]}
{% endhighlight %}

## Polymorphic pattern
As we've seen before, we can create heterogeneous collections where different types of things or concepts are stored in the same collection. But even if each document is of the same type of thing, we might still need a different scheme for different documents. So this is true for documents that are similar but not identical. An example for athletes: each has a name, date of birth, etc, but only tennis players have the key `grand_slams_won`.

{% highlight json %}
{ name: "Serena Williams",
  date_of_birth: "1981-09-26",
  country: "US",
  nr_grand_slams_won: 23,
  highest_atp_ranking: 1 },
{ name: "Kim Clijsters",
  date_of_birth: "1983-06-08",
  country: "Belgium",
  nr_grand_slams_won: 4,
  highest_atp_ranking: 1 },
{ name: "Alberto Contador",
  date_of_birth: "1982-12-06",
  country: "Spain",
  nr_tourdefrance_won: 2,
  teams: ["Discovery Channel","Astana","Saxo Bank"] },
{ name: "Bernard Hinault",
  date_of_birth: "1954-11-14",
  country: "France",
  nr_tourdefrance_won: 5,
  teams: ["Gitane","Renault","La Vie Claire"] },
...
{% endhighlight %}

## Inverse referencing pattern
This is what we saw in the data modelling section for 1-to-immense relationships. Instead of e.g. storing log messages in a server document, store the server in the log messages:

`servers` collection:
{% highlight json %}
{ id: "server_17",
  location: "server room 2" }
{% endhighlight %}

`logs` collections:
{% highlight json %}
{ date: "Oct 14 07:50:29", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:35", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:37", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:39", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:39", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:42", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:39", host: "server_17",
  message: "Failed to bootstrap path  /System/Library, error = 2: No such file or directory" },
{ date: "Oct 14 07:50:43", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
...
{% endhighlight %}

{% include custom/series_nosql_next.html %}
