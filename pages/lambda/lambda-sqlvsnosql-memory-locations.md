---
title: Think strategically about RAM, SSD and disk
keywords: lambda
sidebar: lambda_sidebar
toc: false
permalink: lambda-sqlvsnosql-memory-locations.html
folder: lambda
series: lambda-series
weight: 4
---

To make sure that the performance of your application is adequate for your purpose, you have to think about where to store your data. Data can be kept in RAM, on a solid-state drive (SSD), the hard disk in your computer, or in a file somewhere on the network. This choice has an _immense_ effect on performance. It's easy to visualise this: consider that you are in Hasselt
- getting something from RAM = getting it from your backyard
- getting something from SSD = getting it from somewhere in your neighbourhood
- getting something from disk = traveling to Saudi Arabia to get it
- getting something over the network = traveling to Jupiter to get it

It might be clear to you that cleverly keeping things in RAM is a good way to speed up your application or analysis :-) Which brings us to the next point:

{% include custom/series_lambda_next.html %}
