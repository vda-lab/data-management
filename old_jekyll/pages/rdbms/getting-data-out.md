---
title: Getting data out
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-getting-data-out.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

It may seem counter-intuitive to first break down the data into multiple tables using the normal forms as described above, in order to having to combine them afterwards again in a SQL query. The reason for this is simple: it allows you to ask the data any question much more easily, instead of being restricted to the format of the original data.

<img src="{{ site.baseurl }}/assets/normalisation-queries.png" width="600px"/>

## Queries

Why do we need queries? Because natural languages (e.g. English) are too vague: with complex questions, it can be hard to verify that the question
was interpreted correctly, and that the answer we received is truly
correct. The Structured Query Language (SQL) is a standardised system so that users and developers can learn one method that works on (almost) any system.

In order to write your queries, you'll need to know what the database looks like. A _relationship diagram_ including tables, columns and relations is very helpful here. See for example this relationship diagram for a pet store.

<img src="{{ site.baseurl }}/assets/relationship-diagram.png" width="600px"/>

Questions that we can ask the database include:
- Which animals were born after August 1?
- List the animals by category and breed.
- List the categories of animals that are in the Animal list.
- Which dogs have a donation value greater than $250?
- Which cats have black in their color?
- List cats excluding those that are registered or have red in their color.
- List all dogs who are male and registered or who were born before 01-June-2010 and have white in their color.
- What is the extended value (price * quantity) for sale items on sale 24?
- What is the average donation value for animals?
- What is the total value of order number 22?
- How many animals were adopted in each category?
- How many animals were adopted in each category with total adoptions of more than 10?
- How many animals born after June 1 were adopted in each category with total adoptions more than 10?
- List the CustomerID of everyone who bought or adopted something between April 1, 2010 and May 31, 2010.
- List the names of everyone who bought or adopted something between April 1, 2010 and May 31, 2010.
- List the name and phone number of anyone who adopted a registered white cat between two given dates.

Similarly, we already drew the relationship diagram for the genotypes.

![primary and foreign keys]({{ site.baseurl }}/assets/primary_foreign_keys.png)

Questions that we can ask:
- What is the number of individuals for each ethnicity?
- How many SNPs are there per chromosome?
- Approximately how long is chromosome 22 (by looking at the maximum SNP position)?
- What are the most/least common genotypes?
- ...

### Single tables

It is very simple to query a single table. The **basic syntax** is:

{% highlight sql %}
SELECT <column_name1, column_name2> FROM <table_name> WHERE <conditions>;
{% endhighlight %}

If you want to see **all columns**, you can use "\*" instead of a list of column names, and you can leave out the WHERE clause. The **simplest query** is therefore `SELECT * FROM <table_name>;`. So **the `<column_name1, column_name2>`  slices the table vertically while the WHERE clause slices it horizontally**.

Data can be filtered using a `WHERE` clause. For example:

{% highlight sql %}
SELECT * FROM individuals WHERE ethnicity = 'african';
SELECT * FROM individuals WHERE ethnicity = 'african' OR ethnicity = 'caucasian';
SELECT * FROM individuals WHERE ethnicity IN ('african', 'caucasian');
SELECT * FROM individuals WHERE ethnicity != 'asian';
{% endhighlight %}

What if you can't remember if the ethnicity was stored capitalised or not? In other words: was it 'caucasian' or 'Caucasian'? One way of approaching this is using the **`LIKE`** keyword. It behaves the same as `==`, but you can use wildcards (i.c. `%`) that can represent any character. For example, the following two are almost the same:

{% highlight sql %}
SELECT * FROM individuals WHERE ethnicity == 'Caucasian' OR ethnicity == 'caucasian';
SELECT * FROm individuals WHERE ethnicity LIKE '%aucasian';
{% endhighlight %}

I say "almost" the same, because the `%` can stand for more than one character. A `WHERE ethnicity LIKE '%sian'` would therefore return those individuals who are "Caucasian", "caucasian", "Asian" and "asian".

You often just want to see a **small subset of data** just to make sure that you're looking at the right thing. In that case: add a `LIMIT` clause to the end of your query, which has the same effect as using `head` on the linux command-line. Please *always* do this if you don't know what your table looks like because you don't want to send millions of lines to your screen.

{% highlight sql %}
SELECT * FROM individuals LIMIT 5;
SELECT * FROM individuals WHERE ethnicity = 'caucasian' LIMIT 1;
{% endhighlight %}

If you just want know the **number of records** that would match your query, use `COUNT(*)`:

{% highlight sql %}
SELECT COUNT(*) FROM individuals WHERE ethnicity = 'african';
{% endhighlight %}

Using the `GROUP BY` clause you can **aggregate** data. For example:

{% highlight sql %}
SELECT ethnicity, COUNT(*) from individuals GROUP BY ethnicity;
{% endhighlight %}

##### Combining tables

In the second normal form we separated several aspects of the data in different tables. Ultimately, we want to combine that information of course. This is where the primary and foreign keys come in. Suppose you want to list all different SNPs, with the alleles that have been found in the population:

{% highlight sql %}
SELECT individual_id, snp_id, genotype_amb FROM genotypes;
{% endhighlight %}

This isn't very informative, because we get the uninformative numbers for SNPs instead of SNP accession numbers. To run a query across tables, we have to call both tables in the FROM clause:

{% highlight sql %}
SELECT individuals.name, snps.accession, genotypes.genotype_amb FROM individuals, snps, genotypes;
{% endhighlight %}

| name | accession | genotype_amb |
|:-- |:------------ |:--------- |
| individual_A | rs12345 | A |
| individual_A | rs12345 | R |
| individual_A | rs12345 | K |
| individual_A | rs12345 | M |
| individual_A | rs12345 | G |
| individual_A | rs12345 | G |
| individual_A | rs98765 | A |
| individual_A | rs98765 | R |
| individual_A | rs98765 | K |
| individual_A | rs98765 | M |
| individual_A | rs98765 | G |
| individual_A | rs98765 | G |
| individual_A | rs28465 | A |
| individual_A | rs28465 | R |
| individual_A | rs28465 | K |
| individual_A | rs28465 | M |
| individual_A | rs28465 | G |
| individual_A | rs28465 | G |
| individual_B | rs12345 | A |
| individual_B | rs12345 | R |
| individual_B | rs12345 | K |
| individual_B | rs12345 | M |
| individual_B | rs12345 | G |
| individual_B | rs12345 | G |
| individual_B | rs98765 | A |
| individual_B | rs98765 | R |
| individual_B | rs98765 | K |
| individual_B | rs98765 | M |
| individual_B | rs98765 | G |
| individual_B | rs98765 | G |
| individual_B | rs28465 | A |
| individual_B | rs28465 | R |
| individual_B | rs28465 | K |
| individual_B | rs28465 | M |
| individual_B | rs28465 | G |
| individual_B | rs28465 | G |

Wait... This can't be correct: we get 36 rows back instead of the 6 that we expected. This is because _all_ combinations are made between _all_ rows of each table. We have to put some constraints on the rows that are returned.

{% highlight sql %}
SELECT individuals.name, snps.accession, genotypes.genotype_amb
FROM individuals, snps, genotypes
WHERE individuals.id = genotypes.individual_id
AND snps.id = genotypes.snp_id;
{% endhighlight %}

| name         | accession | genotype_amb |
|:------------ |:--------- |:------------ |
| individual_A | rs12345   | A            |
| individual_A | rs98765   | R            |
| individual_A | rs28465   | K            |
| individual_B | rs12345   | M            |
| individual_B | rs98765   | G            |
| individual_B | rs28465   | G            |

What happens here?

* The individuals, snps and genotypes tables are referenced in the FROM clause.
* In the SELECT clause, we tell the query what columns to return. We **prepend the column names with the table name**, to know what column we actually mean (snps.id is a different column from individuals.id).
* **In the WHERE clause, we actually provide the link between the tables**: the value for snp_id in the genotypes table should correspond with the id column in the snps table. This is the part that solves the above issue of returning all those nonsense rows. Imagine that we'd ask the id's themselves as well, then we'd get the list below. From that list, we can then filter the rows that adhere to the constraints we set.

{% highlight sql %}
SELECT individuals.id, genotypes.individual_id, snps.id, genotypes.snp_id, individuals.name, snps.accession, genotypes.genotype_amb
FROM individuals, snps, genotypes;
{% endhighlight %}

| individual.id | genotypes.individual_id | snps.id | genotypes.snp_id | name | accession | genotype_amb |
|:------------ |:--------- |:------------ |:----- |:----- |:----- |:----- |
| **1** | **1** | **1** | **1** | **individual_A** | **rs12345** | **A** |
| _1_ | _1_ | _-1-_ | _-2-_ | _individual_A_ | _rs12345_ | _R_ |
| _1_ | _1_ | _-1-_ | _-3-_ | _individual_A_ | _rs12345_ | _K_ |
| _-1-_ | _-2-_ | _1_ | _1_ | _individual_A_ | _rs12345_ | _M_ |
| _-1-_ | _-2-_ | _-1-_ | _-2-_ | _individual_A_ | _rs12345_ | _G_ |
| _-1-_ | _-2-_ | _-1-_ | _-3-_ | _individual_A_ | _rs12345_ | _G_ |
| _1_ | _1_ | _-2-_ | _-1-_ | _individual_A_ | _rs98765_ | _A_ |
| **1** | **1** | **2** | **2** | **individual_A** | **rs98765** | **R** |
| _1_ | _1_ | _-2-_ | _-3-_ | _individual_A_ | _rs98765_ | _K_ |
| _-1-_ | _-2-_ | _-2-_ | _-1-_ | _individual_A_ | _rs98765_ | _M_ |
| _-1-_ | _-2-_ | _2_ | _2_ | _individual_A_ | _rs98765_ | _G_ |
| _-1-_ | _-2-_ | _-2-_ | _-3-_ | _individual_A_ | _rs98765_ | _G_ |
| _1_ | _1_ | _-3-_ | _-1-_ | _individual_A_ | _rs28465_ | _A_ |
| _1_ | _1_ | _-3-_ | _-2-_ | _individual_A_ | _rs28465_ | _R_ |
| **1** | **1** | **3** | **3** | **individual_A** | **rs28465** | **K** |
| _-1-_ | _-2-_ | _-3-_ | _-1-_ | _individual_A_ | _rs28465_ | _M_ |
| _-1-_ | _-2-_ | _-3-_ | _-2-_ | _individual_A_ | _rs28465_ | _G_ |
| _-1-_ | _-2-_ | _3_ | _3_ | _individual_A_ | _rs28465_ | _G_ |
| _-2-_ | _-1-_ | _1_ | _1_ | _individual_B_ | _rs12345_ | _A_ |
| _-2-_ | _-1-_ | _-1-_ | _-2-_ | _individual_B_ | _rs12345_ | _R_ |
| _-2-_ | _-1-_ | _-1-_ | _-3-_ | _individual_B_ | _rs12345_ | _K_ |
| **2** | **2** | **1** | **1** | **individual_B** | **rs12345** | **M** |
| ... | ... | ... | ... | ... | ... | ... |

Having to type the table names in front of the column names can become tiresome. We can however create **aliases** like this:

{% highlight sql %}
SELECT i.name, s.accession, g.genotype_amb
FROM individuals i, snps s, genotypes g
WHERE i.id = g.individual_id
AND s.id = g.snp_id;
{% endhighlight %}

### JOIN

Sometimes, though, we have to join tables in a different way. Suppose that our snps table contains SNPs that are nowhere mentioned in the genotypes table, but we still want to have them mentioned in our output:

{% highlight sql %}
INSERT INTO snps (accession, chromosome, position) VALUES ('rs11223','2',11223);
{% endhighlight %}

If we run the following query:

{% highlight sql %}
SELECT s.accession, s.chromosome, s.position, g.genotype_amb
FROM snps s, genotypes g
WHERE s.id = g.snp_id
ORDER BY s.accession, g.genotype_amb;
{% endhighlight %}

We get the following output:

| chromosome | position | accession | genotype_amb |
|:---------- |:-------- |:--------- |:------------ |
| 1          | 12345    | rs12345   | A            |
| 1          | 12345    | rs12345   | M            |
| 1          | 98765    | rs98765   | G            |
| 1          | 98765    | rs98765   | R            |
| 5          | 28465    | rs28465   | G            |
| 5          | 28465    | rs28465   | K            |

But we actually want to have rs11223 in the list as well. Using this approach, we can't because of the `WHERE s.id = g.snp_id` clause. The solution to this is to use an **explicit join**. To make things complicated, there are several types: inner and outer joins. In principle, an inner join gives the result of the intersect between two tables, while an outer join gives the results of the union. What we've been doing up to now is look at the intersection, so the approach we used above is equivalent to an inner join:

{% highlight sql %}
SELECT s.accession, g.genotype_amb
FROM snps s INNER JOIN genotypes g ON s.id = g.snp_id
ORDER BY s.accession, g.genotype_amb;
{% endhighlight %}

gives:

| accession | genotype_amb |
|:--------- |:------------ |
| rs12345   | A            |
| rs12345   | M            |
| rs28465   | G            |
| rs28465   | K            |
| rs98765   | G            |
| rs98765   | R            |

A **left outer join** returns all records from the left table, and will include any matches from the right table:

{% highlight sql %}
SELECT s.accession, g.genotype_amb
FROM snps s LEFT OUTER JOIN genotypes g ON s.id = g.snp_id
ORDER BY s.accession, g.genotype_amb;
{% endhighlight %}

gives:

| accession | genotype_amb |
|:--------- |:------------ |
| rs11223   |              |
| rs12345   | A            |
| rs12345   | M            |
| rs28465   | G            |
| rs28465   | K            |
| rs98765   | G            |
| rs98765   | R            |

(Notice the extra line for rs11223!)

A full outer join, finally, return all rows from the left table, and all rows from the right table, matching any rows that should be.

## Export to file

Often you will want to export the output you get from an SQL-query to a file (e.g. CSV) on your operating system so that you can use that data for external analysis in R or for visualisation. This is easy to do. Suppose that we want to export the first 5 lines of the snps table into a file called `5_snps.csv`.

### Using DB Browser
There's a button for that...

![db browser export]({{ site.baseurl }}/assets/dbbrowser_4.png)

### On the command line
You do that like this:

{% highlight sql %}
.header on
.mode csv
.once 5_snps.csv
SELECT * FROM snps LIMIT 5;
{% endhighlight %}

If you now exit the sqlite prompt (with `.quit`), you should see a file in the directory where you were that is called `5_snps.csv`.

{% include custom/series_rdbms_next.html %}
