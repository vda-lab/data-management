---
title: Public bioinformatics databases
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-public-bioinformatics-databases.html
folder: rdbms
---

Sqlite is a light-weight system for running relational databases. If you want to make your data available to other people it's often better to use systems such as MySQL. The data behind the Ensembl genome browser, for example, is stored in a relational database and directly accessible through SQL as well.

To access the last release of human from Ensembl: `mysql -h ensembldb.ensembl.org -P 5306 -u anonymous homo_sapiens_core_70_37`. To get an overview of the tables that we can query: `show tables`.

To access the `hg19` release of the UCSC database (which is also a MySQL database): `mysql --user=genome --host=genome-mysql.cse.ucsc.edu hg19`.

{% include custom/series_rdbms_next.html %}
