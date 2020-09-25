---
title: Additional functions
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-additional-functions.html
folder: rdbms
---

## LIMIT

If you only want to get the first 10 results back (e.g. to find out if your complicated query does what it should do without running the whole actual query), use LIMIT:

{% highlight sql %}
sqlite> SELECT * FROM snps LIMIT 2;
{% endhighlight %}

## NULL

SNPs are spread across a chromosome, and might or might not be located within a gene.

![snps not in genes]({{ site.baseurl }}/assets/snps_not_in_genes.png)

What if you want to search for the SNPs that are not in genes? Imagine that our `snps` table has an additional column with the gene name, like this:

| id | accession | chromosome | position | gene   |
|:-- |:--------- |:---------- |:-------- |:------ |
| 1  | rs12345   | 1          | 12345    | gene_A |
| 2  | rs98765   | 1          | 98765    | gene_A |
| 3  | rs28465   | 5          | 28465    | gene_B |
| 4  | rs92873   | 7          | 7382     |        |
| 5  | rs10238   | 11         | 291732   | gene_C |
| 6  | rs92731   | 17         | 10283    | gene_C |

We cannot `SELECT * FROM snps WHERE gene = "";` because that is searching for an empty string which is not the same as a missing value. To get to rs92873 you can issue `SELECT * FROM snps WHERE gene IS NULL;` or to get the rest `SELECT * FROM snps WHERE GENE IS NOT NULL;`. Note that it is `IS NULL` and **not** `= NULL`...

## AND, OR

Your queries might need to **combine different conditions**, as we've already seen above:

- `AND`: both must be true
- `OR`: either one is true
- `NOT`: reverse the value

{% highlight sql %}
SELECT * FROM snps WHERE chromosome = '1' AND position < 40000;
SELECT * FROM snps WHERE chromosome = '1' OR chromosome = '5';
SELECT * FROM snps WHERE chromosome = '1' AND NOT position < 40000;
{% endhighlight %}

The result is affected by the order of the operations. Parentheses indicate that an operation should be performed first. Without parentheses, operations are performed left-to-right.

For example, if a = 3, b = -1 and c = 2, then:
- (( a > 4 ) AND  ( b < 0 )) OR ( c > 1 )  evaluates to true
-  ( a > 4 ) AND (( b < 0 )  OR ( c > 1 )) evaluates to false

De Morgan's laws apply to SQL. The rules allow the expression of conjunctions and disjunctions purely in terms of each other via negation. For example:
- `NOT (A AND B)` becomes `NOT A OR NOT B`
- `NOT (A OR B)` becomes `NOT A AND NOT B`

## IN
The `IN` clause defines a set of values. It is a shortcut to combine several entries with an `OR` condition.

For example, instead of writing
{% highlight sql %}
SELECT *
FROM customer
WHERE first_name = 'Tim' OR first_name = 'David' OR first_name = 'Jay';
{% endhighlight %}
you can use
{% highlight sql %}
SELECT *
FROM customer
WHERE first_name IN ('Tim', 'David', 'Jay');
{% endhighlight %}

## DISTINCT

Whenever you want the **unique values** in a column: use DISTINCT in the SELECT clause:

{% highlight sql %}
SELECT category FROM animal;
{% endhighlight %}

| category |
|:-------- |
| Fish |
| Dog |
| Fish |
| Cat |
| Cat |
| Dog |
| Fish |
| Dog |
| Dog |
| Dog |
| Fish |
| Cat |
| Dog |
| ... |

{% highlight sql %}
SELECT DISTINCT category FROM animal;
{% endhighlight %}

| distinct(category) |
|:------ |
| Bird |
| Cat |
| Dog |
| Fish |
| Mammal |
| Reptile |
| Spider |

DISTINCT automatically sorts the results.

## ORDER BY
The order by clause allows you to, well, order your output. By default, this is in ascending order. To order from large to small, you can add the `DESC` tag. It is possible to order by multiple columns, for example first by chromosome and then by position;
{% highlight sql %}
SELECT * FROM snps ORDER BY chromosome;
SELECT * FROM snps ORDER BY accession DESC;
SELECT * FROM snps ORDER BY chromsome, position;
{% endhighlight %}

## COUNT

For when you want to count things:

{% highlight sql %}
SELECT COUNT(*) FROM genotypes WHERE genotype_amb = 'G';
{% endhighlight %}

## MAX(), MIN(), AVG()

...act as you would expect (only works with numbers, obviously):

{% highlight sql %}
SELECT MAX(position) FROM snps;
{% endhighlight %}

Output is:

| max(position) |
|:-- |
| 291732  |

## AS
In some cases you might want to rename the output column name. For instance, in the example above you might want to have `maximum_position` instead of `max(position)`. The `AS` keyword can help us with that.

{% highlight sql %}
SELECT MAX(position) AS maximum_position FROM snps;
{% endhighlight %}

## GROUP BY

GROUP BY can be very useful in that it first **aggregates data**. It is often used together with `COUNT`, `MAX`, `MIN` or `AVG`:

{% highlight sql %}
SELECT genotype_amb, COUNT(*) FROM genotypes GROUP BY genotype_amb;
SELECT genotype_amb, COUNT(*) AS c FROM genotypes GROUP BY genotype_amb ORDER BY c DESC;
{% endhighlight %}

| genotype_amb | c |
|:------------ |:- |
| G            | 2 |
| A            | 1 |
| K            | 1 |
| M            | 1 |
| R            | 1 |

{% highlight sql %}
SELECT chromosome, MAX(position) FROM snps GROUP BY chromosome ORDER BY chromosome;
{% endhighlight %}

| chromosome | MAX(position) |
|:---------- |:------------- |
| 1          | 98765         |
| 2          | 11223         |
| 5          | 28465         |

## HAVING
Whereas the `WHERE` clause puts conditions on certain columns, the `HAVING` clause puts these on groups created by `GROUP BY`.

For example, given the following `snps` table:

| id | accession | chromosome | position | gene   |
|:-- |:--------- |:---------- |:-------- |:------ |
| 1  | rs12345   | 1          | 12345    | gene_A |
| 2  | rs98765   | 1          | 98765    | gene_A |
| 3  | rs28465   | 5          | 28465    | gene_B |
| 4  | rs92873   | 7          | 7382     |        |
| 5  | rs10238   | 11         | 291732   | gene_C |
| 6  | rs92731   | 17         | 10283    | gene_C |

{% highlight sql %}
SELECT chromosome, count(*) as c
FROM snps
GROUP BY chromosome;
{% endhighlight %}

will return

| chromosome | c |
|:---------- |:- |
| 1          | 2 |
| 5          | 1 |
| 7          | 1 |
| 11         | 1 |
| 17         | 1 |

whereas
{% highlight sql %}
SELECT chromosome, count(*) as c
FROM snps
GROUP BY chromosome
HAVING c > 1
{% endhighlight %}

will return

| chromosome | c |
|:---------- |:- |
| 1          | 2 |

The `HAVING` clause must follow a `GROUP BY`, and precede a possible `ORDER BY`.

## UNION, INTERSECT

It is sometimes hard to get the exact rows back that you need using the WHERE clause. In such cases, it might be possible to construct the output based on taking the **union or intersection** of two or more different queries:

{% highlight sql %}
SELECT * FROM snps WHERE chromosome = '1';
SELECT * FROM snps WHERE position < 40000;
SELECT * FROM snps WHERE chromosome = '1' INTERSECT SELECT * FROM snps WHERE position < 40000;
{% endhighlight %}

| id | accession | chromosome | position |
|:-- |:--------- |:---------- |:-------- |
| 1  | rs12345   | 1          | 12345    |

## LIKE

Sometimes you want to make fuzzy matches. What if you're not sure if the ethnicity has a capital or not?

{% highlight sql %}
SELECT * FROM individuals WHERE ethnicity = 'African';
{% endhighlight %}

returns no results...

{% highlight sql %}
SELECT * FROM individuals WHERE ethnicity LIKE '%frican';
{% endhighlight %}

Note that different databases use different characters as wildcard. For example: `%` is a wildcard for MS SQL Server representing any string, and `*` is the corresponding wildcard character used in MS Access. Check the documentation for the RDBMS that you're using (sqlite, MySQL/MariaDB, MS SQL Server, MS Access, Oracle, ...) for specifics.

## Subqueries

As we mentioned in the beginning, the general setup of a SELECT is:

{% highlight sql %}
SELECT <column_names>
FROM <table>
WHERE <condition>;
{% endhighlight %}

But as you've seen in the examples above, the **output from any SQL query is itself basically a table**. So we can actually **use that output table to run another SELECT**. For example:

{% highlight sql %}
SELECT *
FROM (
       SELECT *
       FROM snps
       WHERE chromosome IN ('1','5'))
WHERE position < 40000;
{% endhighlight %}

Of course, you can use UNION and INTERSECT in the subquery as well...

Another example:

{% highlight sql %}
SELECT COUNT(*)
FROM (
       SELECT DISTINCT genotype_amb
       FROM genotypes);
{% endhighlight %}

{% include custom/series_rdbms_next.html %}
