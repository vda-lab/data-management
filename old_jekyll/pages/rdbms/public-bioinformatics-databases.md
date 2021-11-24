---
title: Public bioinformatics databases
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-public-bioinformatics-databases.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

Sqlite is a light-weight system for running relational databases. If you want to make your data available to other people it's often better to use systems such as MySQL. The data behind the Ensembl and UCSC genome browsers, for example, is stored in a relational database and directly accessible through SQL as well.

If you install a mysql client (see www.mariadb.org or www.mysql.com), you can access these public databases as well. Another option is to run mysql using docker.

To access the last release of human from Ensembl: `mysql -h ensembldb.ensembl.org -P 5306 -u anonymous homo_sapiens_core_70_37`. To get an overview of the tables that we can query: `show tables`. Using docker this would be `docker run -it --rm mysql mysql -h ensembldb.ensembl.org -u anonymous -P 5306 homo_sapiens_core_70_37`.

To access the `hg38` release of the UCSC database (which is also a MySQL database): `mysql -h genome-mysql.soe.ucsc.edu -ugenome -A hg38`. With docker: `docker run -it --rm mysql mysql -h genome-mysql.soe.ucsc.edu -u genome -A hg38`. You can then for example find out where the gene CYP3A4 is located with

{% highlight sql %}
SELECT name, name2, chrom, strand, txStart, txEnd, cdsStart, cdsEnd
FROM refGene
WHERE name2 = 'CYP3A4';
{% endhighlight %}

Output will be:
```
mysql> SELECT name, name2, chrom, strand, txStart, txEnd, cdsStart, cdsEnd
    -> FROM refGene
    -> WHERE name2 = 'CYP3A4';
+--------------+--------+-------+--------+----------+----------+----------+----------+
| name         | name2  | chrom | strand | txStart  | txEnd    | cdsStart | cdsEnd   |
+--------------+--------+-------+--------+----------+----------+----------+----------+
| NM_001202855 | CYP3A4 | chr7  | -      | 99756966 | 99784184 | 99758132 | 99784081 |
| NM_017460    | CYP3A4 | chr7  | -      | 99756966 | 99784184 | 99758132 | 99784081 |
+--------------+--------+-------+--------+----------+----------+----------+----------+
2 rows in set (0.16 sec)
```

<small><i>Note: Installing the complete mysql system will install the server and client, and it can be difficult to remove if necessary afterwards. An alternative is to install it using [docker](http://www.docker.com). Run the server with `docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:latest` and connect to it using `docker exec -it some-mysql bash`. You can then access the Ensembl and UCSC databases as described above.</i></small>

{% include custom/series_rdbms_next.html %}
