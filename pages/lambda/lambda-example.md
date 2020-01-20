---
title: An example
keywords: lambda
sidebar: lambda_sidebar
toc: true
permalink: lambda-example.html
folder: lambda
series: lambda-series
weight: 11
---

The batch layer master dataset can consist of files in a filesystem, records in some SQL tables, or any other way that we can store data. And although the lambda architecture is linked to the idea of Big Data and NoSQL, nothing prevents us from using a simple SQL database in this architecture if that fits our needs. Actually, the idea of _views_ in a relational database corresponds to a serving layer, whereas the original tables in that case are the batch layer.

Consider the previous friends example.

{% highlight sql %}
CREATE VIEW v_nr_of_friends AS
SELECT COUNT('x') FROM (
  SELECT to_who
  FROM first_table
  WHERE action = 'add'
  AND timestamp < 20191101
  MINUS
  SELECT to_who
  FROM first_table
  WHERE action = 'remove'
  AND timestamp < 20191101 );
{% endhighlight %}

We have actually set up a local database to keep track of employee status and other information at the department. Although it is a relational database, it very much adheres to the lambda architecture paradigm. Here's how (a very small part of) it is set up:
- Everything revolves around _hiring contracts_ (i.e. information about when someone is hired, paid by which project, when the contract ends, etc). One person can have many consecutive contracts, for example when it's a yearly contract that gets renewed.
- Information about the _individual_ relates to their name, address, office number, work phone number, etc. Important: we do _not_ remove an individual from this table when they leave the university.
- We compute a view _v-current-individuals_ which - for each individual - checks if they have a current contract. This view therefore acts as the serving layer, as it is the one that we will actually query.

(For the way that the primary and foreign keys are set up in this example, see the normalisation explanation at [{{ site.baseurl }}/2019/08/extended-introduction-to-relational-databases]({{ site.baseurl }}/2019/08/extended-introduction-to-relational-databases)).

`contracts`

| id | individual_id  | start    | end      |
|:-- |:-------------- |:-------- |:-------- |
| 1  | 1              | 20170101 | 20171231 |
| 2  | 1              | 20180101 | 20181231 |
| 3  | 1              | 20190101 | 20191231 |
| 4  | 2              | 20170101 | 20171231 |
| 5  | 2              | 20180101 | 20181231 |
| 6  | 3              | 20190101 | 20191231 |
| 7  | 4              | 20160101 | 20161231 |

`individuals`

| id | name      | office | phone number |
|:-- |:--------- |:------ |:------------ |
| 1  | Tom       | A1     | 123-4567     |
| 2  | Tim       | A9     | 123-5678     |
| 3  | Tony      | A15    | 123-6789     |
| 4  | Tina      | B3     | 123-7890     |

When someone new starts in the department, they are added to the `individuals` table; when someone gets a new contract, this is added to the `contracts` table (obviously a record is also created there when some is added to the `individuals` table because they'll get their first contract at that moment...). Never is a record removed from either of these tables.

At the same time, we created an SQL view that computes the current individuals, i.e. those individuals that have a current contract. It looks something like this:
{% highlight sql %}
CREATE VIEW v_current_individuals AS
SELECT * FROM individuals i, contracts c
WHERE i.id = c.individual_id
AND c.start <= NOW()
AND c.end >= NOW();
{% endhighlight %}

A `SELECT * FROM v_current_individuals` therefore returns:

| id | name      | office | phone number |
|:-- |:--------- |:------ |:------------ |
| 1  | Tom       | A1     | 123-4567     |
| 3  | Tony      | A15    | 123-6789     |

We _could_ have set up the system in the regular way using updates, but we haven't. _If_ we had, the individuals table would have looked like this:

| id | name      | office | phone number | end of contract |
|:-- |:--------- |:------ |:------------ |:--------------- |
| 1  | Tom       | A1     | 123-4567     | 20191231        |
| 3  | Tony      | A15    | 123-6789     | 20191231        |

Notice that Tim and Tina are not in this table, because they would have been removed. Similarly, when Tom would sign a new contract, the `end of contract` column would have been updated. But imagine that someone is erroneously removed from the `individuals` table: we can't just add him or her again without finding out first what their address is, their office, etc. That data would have been lost

This example shows that in most real-life cases you want to have a mix of recomputation and updates, a mix between ACID and BASE. It's almost never black-and-white: although we do not remove an individual from the `individuals` table when they leave (batch-layer approach), we _do_ update an individual's record when they change address, office, or phone number (non-lambda architecture approach).

{% include custom/series_lambda_next.html %}
