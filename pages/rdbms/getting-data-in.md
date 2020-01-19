---
title: Getting data in
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-getting-data-in.html
folder: rdbms
series: rdbms-series
weight: 17
---

## INSERT INTO

There are several ways to load data into a database. The method used above is the most straightforward but inadequate if you have to load a large amount of data.

It's basically:

{% highlight sql %}
INSERT INTO <table_name> (<column_1>, <column_2>, <column_3>)
                         VALUES (<value_1>, <value_2>, <value_3>);
{% endhighlight %}

## Importing a datafile
But this becomes an issue if you have to load 1,000s of records. Luckily, it's possible to load data from a **comma-separated file** straight into a table. Suppose you want to load 3 more individuals, but don't want to type the insert commands straight into the sql prompt. Create a file (e.g. called `data.csv`) that looks like this:

<pre>individual_C,african
individual_D,african
individual_C,asian
</pre>

### Using DB Browser
Using the DB Browser, you can just go to `File` -> `Import` -> `Table from CSV File...`. Note that when you import a file like that, the system will automatically create the `rowid` column that will serve as the primary key.

### On the command line
SQLite contains a `.import` command to load this type of data. Syntax: `.import <file> <table>`. So you could issue:

{% highlight sql %}
.separator ','
.import data.csv individuals
{% endhighlight %}

Aargh... We get an **error**!

`Error: data.tsv line 1: expected 3 columns of data but found 2`

This is because the table contains an **ID column** that is used as primary key and that increments automatically. Unfortunately, SQLite cannot work around this issue automatically. One option is to add the new IDs to the text file and import that new file. But we don't want that, because it screws with some internal counters (SQLite keeps a counter whenever it autoincrements a column, but this counter is not adjusted if you hardwire the ID). A possible **workaround** is to create a temporary table (e.g. `individuals_tmp`) without the id column, import the data in that table, and then copy the data from that temporary table to the real individuals.

{% highlight sql %}
.schema individuals
CREATE TABLE individuals_tmp (name STRING, ethnicity STRING);
.separator ','
.import data.csv individuals_tmp
INSERT INTO individuals (name, ethnicity) SELECT * FROM individuals_tmp;
DROP TABLE individuals_tmp;
{% endhighlight %}

Your `individuals` table should now look like this (using `SELECT * FROM individuals;`):

| id | name         | ethnicity |
|:-- |:------------ |:--------- |
| 1  | individual_A | caucasian |
| 2  | individual_B | caucasian |
| 3  | individual_C | african   |
| 4  | individual_D | african   |
| 5  | individual_E | asian     |

{% include custom/series_rdbms_next.html %}
