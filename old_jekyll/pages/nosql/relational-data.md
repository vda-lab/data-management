---
title: Relational data
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-relational-data.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

Here's an extreme example of impedance mismatch. Imagine you have a social graph and the data is stored in a relational database. People have names, and know other people. Every "know" is reciprocal (so if I know you then you know me too).

![friends]({{ site.baseurl }}/assets/friends-relational.png)

Let's see what it means to follow relationships in a RDBMS. What would this look like if we were searching for friends of James?

{% highlight sql %}
SELECT knowee FROM friends
WHERE knower IN (
  SELECT knowee FROM friends
  WHERE knower = 'James'
  )
UNION
SELECT knower FROM friends
WHERE knowee IN (
  SELECT knower FROM friends
  WHERE knowee = 'James'
  );
{% endhighlight %}
Quite verbose. What if we'd want to go one level deeper: all friends of friends of James?
{% highlight sql %}
SELECT knowee FROM friends
WHERE knower IN (
  SELECT knowee FROM friends
  WHERE knower IN (
    SELECT knowee FROM friends
    WHERE knower = 'James'
    )
  UNION
  SELECT knower FROM friends
  WHERE knowee IN (
    SELECT knower FROM friends
    WHERE knowee = 'James'
    )
  )
UNION
SELECT knower FROM friends
WHERE knowee IN (
  SELECT knower FROM friends
  WHERE knowee IN (
    SELECT knower FROM friends
    WHERE knowee = 'James'
    )
  UNION
  SELECT knowee FROM friends
  WHERE knower IN (
    SELECT knowee FROM friends
    WHERE knower = 'James'
    )
  );
{% endhighlight %}
This clearly does not scale, and we'll have to look for another solution.


{% include custom/series_nosql_next.html %}
