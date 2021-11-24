---
title: Referential integrity
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-referential-integrity.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

In a SQL database, it is important that there are no tables that contain a foreign key which cannot be resolved. For example in the `genotypes` table above, there should not be a row where the `individual_id` is `9` because there does not exist a record in the `individuals` table with an `id` of `9`.

This might occur when you originally have that record in the `individuals` table, but removed it (either accidentally or on purpose). Large database management systems like Oracle actually will complain when you try to do that, and do not allow you to remove that row before any row referencing it in another table is removed first. As SQLite is lightweight, however, you will have to take care of this yourself.

This also means that when loading data, you should first load the `individuals` and `snps` tables, and only load the `genotypes` table afterwards, because the ids of the specific individuals and snps is otherwise not known yet.

{% include custom/series_rdbms_next.html %}
