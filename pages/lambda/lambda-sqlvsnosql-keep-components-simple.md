---
title: Keep components simple
keywords: lambda
sidebar: lambda_sidebar
toc: false
permalink: lambda-sqlvsnosql-keep-components-simple.html
folder: lambda
---

NoSQL systems are often created by integrating a number of modular functions that work together, in contrast to traditional RDBMS which are typically more integrated (mammoth) systems. Such simple components are set up in such way that they can be easily combined. You can compare this to the (very clever) linux pipeline system. When working on the linux command line, even knowing only a very limited number of commands you can do very complex things by piping these commands together: the output of one command becomes the input of the next.

Consider, for example,
<pre>
cat data.csv | grep "chr1" | cut -f 2 | sort | uniq -c
</pre>

This pipeline takes all data from the file `data.csv`, only keeps the lines that contain `chr1`, takes the second column, sorts this column, and returns the unique entries and how many there are for each. The same could have been done with a single script that we'd call `count_of_unique_entries_in_column_2_for_chr1_in_datacsv.py`. But by combining a set of commands that each only address part of the problem we can be much more agile, and it's much easier to debug as well.

I like to think of NoSQL systems in a similar way: instead of using a single complex application, you glue together multiple simple components. In an application we wrote several years ago for clinical geneticists, we kept most data about patients, mutations and genes in a relational database. However, we also needed to access conservation scores across the genome. Basically this means that for every 3.1 billion bases in the genome we had 3 values. There is no way you'd use a relational database with 3x3.1 billion records in a table... For that we used a key/value store which is very good at this. This illustrates that in a NoSQL setting you look at what is necessary, and combine components that are good at solving parts of the problem. You can combine these afterwards in your application layer.

{% include custom/series_lambda_next.html %}
