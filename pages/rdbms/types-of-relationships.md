---
title: Types of relationships
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-types-of-relationships.html
folder: rdbms
series: rdbms-series
weight: 11
---

Relationships between tables are often categorised as:
- _one-to-one_: one row in one table is linked to exactly one row in another table (e.g. ISBN number in first table to book in second table)
- _one-to-many_: one row in a table can be linked to 0, 1 or multiple rows in another table (e.g. a mother can have 1 or more children)
- _many-to-many_: 0, 1 or many rows in one table can be linked to 0, 1 or many rows in another (e.g. links between books and authors)

<img src="{{ site.baseurl }}/assets/one-to-one.png" width="400px" /><br/>
<img src="{{ site.baseurl }}/assets/one-to-many.png" width="400px" /><br/>
<img src="{{ site.baseurl }}/assets/many-to-many.png" width="400px" />

{% include custom/series_rdbms_next.html %}
