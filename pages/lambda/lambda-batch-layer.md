---
title: Batch layer
keywords: lambda
sidebar: lambda_sidebar
toc: true
permalink: lambda-batch-layer.html
folder: lambda
series: lambda-series
weight: 8
---

The _batch layer_ needs to be able to (1) store an immutable, constantly growing master dataset, and (2) compute arbitrary functions on that dataset. You might sometimes hear the term "data lake", which refers to a similar concept.

## Immutable data storage
What does "immutable" mean? This data is _never_ updated, only added upon. In SQL databases, you can update records like this (suppose that John Doe moved from California to New York):
{% highlight sql %}
UPDATE individuals
SET address = "302 Fairway Place",
    city = "Cold Spring Harbor",
    state = 'NY'
WHERE first_name = 'John'
AND last_name = 'Doe';
{% endhighlight %}

What this does is _change_ the address in the database; the previous address in California is lost. In other words, the data is "mutated".

Before the update:

| first_name | last_name | address         | city       | state |
|:---------- |:--------- |:--------------- |:---------- |:----- |
| ...        | ...       | ...             | ...        | ...   |
| John       | Doe       | 101 Lake Avenue | Chowchilla | CA    |
| ...        | ...       | ...             | ...        | ...   |

After the update:

| first_name | last_name | address           | city               | state |
|:---------- |:--------- |:----------------- |:------------------ |:----- |
| ...        | ...       | ...               | ...                | ...   |
| John       | Doe       | 302 Fairway Place | Cold Spring Harbor | NY    |
| ...        | ...       | ...               | ...                | ...   |

In contrast, an immutable database would keep the original data as well; _records can only be added, not changed_. One way of doing this is to add timestamp to all records.

Let's look at another example: friendships (which might change quicker or not than changes of address; that depends on the person...).

Instead of having a table with friendships, you record the data in a more raw form. For example:

| id | who  | timestamp | action | to_who   |
|:-- |:---- |:--------- |:------ |:-------- |
| 1  | Tom  | 20100402  | add    | Frank    |
| 2  | Tony | 20100404  | add    | Frank    |
| 3  | Tom  | 20100407  | remove | Frank    |
| 4  | Tim  | 20100409  | add    | Frank    |
| 5  | Tom  | 20100602  | add    | Freddy   |
| 6  | Tony | 20100818  | add    | Francis  |
| 7  | Tony | 20101021  | add    | Flint    |
| 8  | Tony | 20110101  | add    | Fletcher |

This is often called a _facts table_: the information in this table _will always be true_. Indeed, on June 2nd in 2010 Tom and Freddy became friends, whether or not they are still friends at this moment. Contrast that to the example above: John Doe will not always live at the address in California. Another way of thinking about this is that in the mutable version you record the _state_, whereas in the immutable version you record the _changes to an underlying state_.

As an exercise, what would an immutable version of the address example look like?

In these examples we're adding records to a table, but the lambda layer can be implemented in many different ways. Rows can be added to a csv file; files can be added to a given directory; etc.

_Everything starts with this immutable master dataset_.

## Computing arbitrary functions
Any query that we run is basically a function over the dataset: the query `SELECT * FROM individuals WHERE name = "John Doe";` runs a filter function over the dataset in the `individuals` table. Looking at the above part on immutability, you might think "This is dumb. Just to find out who Tom's friends are we have to go over the complete dataset and add/remove friends as we go." Indeed, a table like the following would be much easier if you want to know how many friends everyone has (suppose you're running the query on the first of November, 2019):

| id | who  | nr_of_friends |
|:-- |:---- |:------------- |
| 1  | Tom  | 1             |
| 2  | Tony | 4             |
| 3  | Tim  | 1             |

To know how many friends Tom has, the query would look like this:
{% highlight sql %}
SELECT nr_of_friends
FROM second_table
WHERE who = 'Tom';
{% endhighlight %}

Using the first table, it would have been:
{% highlight sql %}
SELECT COUNT('x') FROM (
  SELECT to_who
  FROM first_table
  WHERE who = 'Tom'
  AND action = 'add'
  AND timestamp < 20191101
  MINUS
  SELECT to_who
  FROM first_table
  WHERE who = 'Tom'
  AND action = 'REMOVE'
  AND timestamp < 20191101 );
{% endhighlight %}

Clearly, you want to use the shorter version of the two. However, the smaller table does not allow you to get the actual list of friends, or to get the number of friends that Tom had on the 8th of April 2010. That's what we mean with "the batch layer should be able to compute arbitrary functions".

But wait... Does that mean that we have to write such a complex query every time we want to get data from the database? No. That's where the serving layer comes in.

{% include custom/series_lambda_next.html %}
