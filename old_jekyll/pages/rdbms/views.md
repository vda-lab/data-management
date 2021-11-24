---
title: Views
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-views.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

By decomposing data into different tables as we described above (and using the different normal forms), we can significantly improve maintainability of our database and make sure that it does not contain inconsistencies. But at the other hand, this means it's a lot of hassle to look at the actual data: to know what the genotype is for SNP `rs12345` in `individual_A` we cannot just look it up in a single table, but have to write a complicated query which joins 3 tables together. The query would look like this:

{% highlight sql %}
SELECT i.name, i.ethnicity, s.accession, s.chromosome, s.position, g.genotype_amb
FROM individuals i, snps s, genotypes g
WHERE i.id = g.individual_id
AND s.id = g.snp_id;
{% endhighlight %}

Output looks like this:

| name         | ethnicity | accession | chromosome | position | genotype_amb |
|:-------------|:----------|:----------|:-----------|:---------|:-------------|
| individual_A | caucasian | rs12345   | 1          | 12345    | A            |
| individual_A | caucasian | rs98765   | 1          | 98765    | R            |
| individual_A | caucasian | rs28465   | 5          | 28465    | K            |
| individual_B | caucasian | rs12345   | 1          | 12345    | M            |
| individual_B | caucasian | rs98765   | 1          | 98765    | G            |
| individual_B | caucasian | rs28465   | 5          | 28465    | G            |

There is however a way to make this easier: you can create **views** on the data. This basically saves the whole query and gives it a name. You do this by adding `CREATE VIEW some_name AS` to the front of the query, like this:

{% highlight sql %}
CREATE VIEW v_genotypes AS
SELECT i.name, i.ethnicity, s.accession, s.chromosome, s.position, g.genotype_amb
FROM individuals i, snps s, genotypes g
WHERE i.id = g.individual_id
AND s.id = g.snp_id;
{% endhighlight %}

You can think of this as if you had made a new table with the name `v_genotypes` that you can use just like any other table, for example:

{% highlight sql %}
SELECT *
FROM v_genotypes g
WHERE g.genotype_amb = 'R';
{% endhighlight %}

The difference with an actual table is, however, that the result of the view is actually not stored itself. Whenever you do `SELECT * FROM v_genotypes`, it will actually perform the whole query in the background.

Note: to make sure that I can tell by the name if something is a table or a view, I always add a `v_` in front of the name that I give to the view.

#### Pivot tables
In some cases, you want to violate the 1st normal form, and have different columns represent the same type of data. A typical example is when you want to analyze your data in R using a dataframe. Let's say we have expression values for different genes in different individuals. Being good programmers, we saved this data in the database like this:

| individual   | gene   | expression |
|:-------------|:-------|:-----------|
| individual_A | gene_A | 2819       |
| individual_A | gene_B | 1028       |
| individual_A | gene_C | 3827       |
| individual_B | gene_A | 1928       |
| individual_B | gene_B | 999        |
| individual_B | gene_C | 1992       |

In R, you will however probably want a dataframe that looks like this:

| gene   | individual_A | individual_B |
|:-------|:-------------|:-------------|
| gene_A | 2819         | 1928         |
| gene_B | 1028         | 999          |
| gene_C | 3827         | 1992         |

This is called a *pivot table*, and there are several ways to create these in SQLite. The method presented here is taken from http://bduggan.github.io/virtual-pivot-tables-opensqlcamp2009-talk/. To create such table (and store it in a view), you have to use `group_concat` and `group_by`:

{% highlight sql %}
CREATE VIEW v_pivot_expressions AS
SELECT gene,
       GROUP_CONCAT(CASE WHEN individual = 'individual_A' THEN expression ELSE NULL END) AS individual_A,
       GROUP_CONCAT(CASE WHEN individual = 'individual_B' THEN expression ELSE NULL END) AS individual_B
FROM expressions
GROUP BY gene;
{% endhighlight %}

{% include custom/series_rdbms_next.html %}
