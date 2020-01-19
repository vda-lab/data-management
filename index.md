---
title: "Data Management"
keywords: homepage
permalink: index.html
---
Welcome to the course material for the Software and Data Management course at UHasselt. The contents of this post is licensed as CC-BY: feel free to copy/remix/tweak/... it, but please credit your source.

![CC-BY]({{ site.baseurl }}/assets/ccby.png)

**For a particular year's practicalities, see [http://vda-lab.be/teaching]({{ site.baseurl }}/teaching)**

*(Part of the content of this lecture is taken from the database lectures from the yearly Programming for Biology course at CSHL, and the EasySoft tutorial at http://bit.ly/x2yNDb, as well as from course slides created by Leandro Garcia Barrado)*

Data management is critical in any science, including biology. In this course, we will focus on relational (SQL) databases (RDBMS) as these are the most common. If time permits we might venture into the world of NoSQL databases (*e.g.* MongoDB, ArangoDB, neo4j) to allow storing of huge datasets.

For relational databases, I will discuss the basic concepts (tables, tuples, columns, queries) and explain the different normalisations for data. There will also be an introduction on writing SQL queries. Document-oriented and other NoSQL databases (such as MongoDB) can often also be accessed through either an interactive shell and/or APIs (application programming interfaces) in languages such as perl, ruby, java, clojure, ...

So what will we cover here?

## What is "data management"?
Data management encompasses 3 parts:
1. _What data do we need and how are we going to collect it?_ In a clinical trial, for example, data to be collected is described in the protocol and entered into the Case Report Form (CRF); in an epidemiological study, data can however come from very different sources. In a DNA sequencing setting, the DNA sequences generates the raw data in a standardised format.
1. _How to store it on a computer in an efficient way?_ This is about database design and database normalisation. That is described further in this post.
1. _How to retrieve information from DBMS in a reliable way?_ We access the data using the Structured Query Language (SQL), which is the topic of the next post.

## The actual content

* [Relational databases]({{ site.baseurl }}/rdbms_landing_page.html)
* [NoSQL]()
* [Lambda Architecture]()
