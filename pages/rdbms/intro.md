---
title: Introduction to relational database management systems
keywords: rdbms
sidebar: rdbms_sidebar
toc: false
permalink: rdbms-intro.html
folder: rdbms
series: rdbms-series
weight: 4
---
There is a wide variety of database systems to store data, but the most-used in the relational database management system (RDBMS). These basically consist of tables that contain rows (which represent instance data) and columns (representing properties of that data). Any table can be thought of as an Excel-sheet.

Relational databases are the most wide-spread paradigm used to store data. They use the concept of tables with each **row** containing an **instance of the data**, and each **column** representing different **properties** of that instance of data. Different implementations exist, include ones by Oracle and MySQL. For many of these (including Oracle and MySQL), you need to run a database server in the background. People (or you) can then connect to that server via a client. In this session, however, we'll use **SQLite3**. SQLite is used by Firefox, Chrome, Android, Skype, ...

{% include custom/series_rdbms_next.html %}
