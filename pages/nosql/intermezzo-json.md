---
title: Intermezzo - JSON
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-intermezzo-json.html
folder: nosql
series: nosql-series
weight: 5
---

Before we proceed, we'll have a quick look at the JSON ("JavaScript Object Notation") text format, which is often used in different database systems. JSON follows the same principle as XML, in that it describes the data in the object itself. An example JSON object:

{% highlight json %}
{ code:"I0D54A",
  name:"Big Data",
  lecturer:"Jan Aerts",
  keywords:["data management","NoSQL","big data"],
  students:[
    {student_id:"u0123456", name:"student 1"},
    {student_id:"u0234567", name:"student 2"},
    {student_id:"u0345678", name:"student 3"}]}
{% endhighlight %}

JSON has very simple syntax rules:
- Data is in key/value pairs. Each is in quotes, separated by a colon. In some cases you might omit the quotes around the key, but not always.
- Data is separated by commas.
- Curly braces hold objects.
- Square brackets hold arrays.

JSON values can be numbers, strings, booleans, arrays (i.e. lists), objects or NULL; JSON arrays can contain multiple values (including JSON objects); JSON objects contain one or more key/value pairs.

These are two JSON arrays:
{% highlight json %}
["data management","NoSQL","big data"]

[{student_id:"u0123456", name:"student 1"},
 {student_id:"u0234567", name:"student 2"},
 {student_id:"u0345678", name:"student 3"}]
{% endhighlight %}

And a simple JSON object:
{% highlight json %}
{student_id:"u0345678", name:"student 3"}
{% endhighlight %}

And objects can be nested as in the first example.

{% include custom/series_nosql_next.html %}
