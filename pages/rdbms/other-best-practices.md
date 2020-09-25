---
title: Other best practices
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-other-best-practices.html
folder: rdbms
---

There are some additional guidelines that you can use in creating your database schema, although different people use different guidelines. Everyone ends up with their own approach. What _I_ do:

* **No capitals** in table or column names
* Every **table name** is **plural** (e.g. `genes`)
* The **primary key** of each table should be `id`
* Any **foreign key** should be the **singular of the table name, plus "_id"**. So for example, a genotypes table can have a sample_id column which refers to the id column of the samples table.

In some cases, I digress from the rule of "every table name is plural", especially if a table is really meant to link to other tables together. A table genotypes which has an id, sample_id, snp_id, and genotype could e.g. also be called `sample2snp`.

{% include custom/series_rdbms_next.html %}
