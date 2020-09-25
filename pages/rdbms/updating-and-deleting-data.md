---
title: Updating and deleting data
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-updating-and-deleting-data.html
folder: rdbms
---

Sometimes you will want to update or delete data in a table. The SQL code to do this uses a `WHERE` clause that is exactly the same as for a regular `SELECT`. A very important tip: first do a `SELECT` on your table with the `WHERE` clause that you'll use for the update or deletion just to make sure that you'll change the correct rows. When you've made changes to the wrong rows you won't be able to go back (unless you use the Lambda architecture principles as we will explain in the [third session](https://vda-lab.github.io/2019/10/lambda-architecture)).

## UPDATE
Imagine that we've been storing the information on our individuals as above, but have not been consistent in capitalising the ethnicity. In some cases, a person can be of `asian` descent; in other cases he or she can be `Asian`. The same would go for the other ethnicities. To clean this up, let's put everything in lower case. For argument's sake we'll only look at `Asian` here. First let's check what we should get with a `SELECT`.
{% highlight sql %}
SELECT * FROM individuals
WHERE ethnicity == 'Asian';
{% endhighlight %}

This will give us the rows that we will change. Are these indeed the ones? Then go forward with the update:

{% highlight sql %}
UPDATE individuals
SET ethnicity = 'asian'
WHERE ethnicity == 'Asian';
{% endhighlight %}

The `WHERE` clause is the same. The general syntax for an update looks like this:

{% highlight sql %}
UPDATE <table>
SET <column> = <new value>
WHERE <conditions>;
{% endhighlight %}

In this example the column that is updated (ethnicity) is the same as the one in the `WHERE` clause. This does not have to be the case. What would the following do?

{% highlight sql %}
UPDATE genotypes
SET genotype_amb = 'R'
WHERE genotype == 'A/G';
{% endhighlight %}

## DELETE
`DELETE` is similar to `UPDATE` but simpler: you don't use the `SET` pragma. Same as with updating data, make sure that your `WHERE` clause is correct! Test this with a `SELECT` beforehand.

The general syntax:

{% highlight sql %}
DELETE FROM <table>
WHERE <conditions>;
{% endhighlight %}

For example:

{% highlight sql %}
DELETE FROM genotypes
WHERE genotype_amb == 'N';
{% endhighlight %}

{% include custom/series_rdbms_next.html %}
