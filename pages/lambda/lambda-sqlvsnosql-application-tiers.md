---
title: Use different application tiers
keywords: lambda
sidebar: lambda_sidebar
toc: false
permalink: lambda-sqlvsnosql-application-tiers.html
folder: lambda
series: lambda-series
weight: 3
---

This is closely related to the lambda architecture that we'll dig into further below.

Splitting up functionality in different tiers helps a lot to simplify the design of your application. By segregating an application into tiers you have the option of modifying or adding a specific layer instead of reworking an entire application, leading to a separation of concerns. The lambda architecture is a prime example of this. Also consider an application with a graphical user interface, which consists of a database layer, a computational layer which converts the raw data in the database to something that can be displayed, and the graphical user interface.

An important question to answer here is where to put the functionality of your application? In the last example: do you let the database compute (with e.g. SQL statements) the things you need in the graphical interface directly? Do you let the graphical user interface get the raw data from the database and do all the necessary munging of that data at the user end? Or do you insert a separate layer in between (i.e. the computational layer mentioned above)? It's all about a _separation of concerns_.

In general, RDBMS have been around for a long time and are very mature. As a result, a lot of functionality has been added to the database tier. In applications using NoSQL solutions, however, much of the application functionality is in a middle tier.

![tiers]({{ site.baseurl }}/assets/tiers.png)

{% include custom/series_lambda_next.html %}
