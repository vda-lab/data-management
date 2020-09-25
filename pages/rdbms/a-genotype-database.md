---
title: A genotype database
keywords: rdbms
sidebar: rdbms_sidebar
toc: false
permalink: rdbms-a-genotype-database.html
folder: rdbms
---
Let's look at another example. Let's say you want to store individuals and their genotypes. In Excel, you could create a sheet that looks like this with genotypes for 3 polymorphisms in 2 individuals:

| individual   | ethnicity | rs12345 | rs12345_amb | chr_12345 | pos_12345 | rs98765 | rs98765_amb | chr_98765 | pos_98765 | rs28465 | rs28465_amb | chr_28465 | pos_28465 |
|:------------ |:--------- |:------- |:----------- |:--------- |:--------- |:------- |:----------- |:--------- |:--------- |:------- |:----------- |:--------- |:--------- |
| individual_A | caucasian | A/A     | A           | 1         | 12345     | A/G     | R           | 1         | 98765     | G/T     | K           | 5         | 28465     |
| individual_B | caucasian | A/C     | M           | 1         | 12345     | G/G     | G           | 1         | 98765     | G/G     | G           | 5         | 28465     |

Let's actually create this database using the sqlite DB Browser mentioned above.

![DB Browser main view]({{ site.baseurl }}/assets/dbbrowser_main.png)

We first select `New database` and after giving it a name, click `Create table`. This is where we'll describe what the columns should be.

We create a table called `genotypes` with the following columns:
- `individual` of type `TEXT`
- `ethnicity` of type `TEXT`
- `rs12345` of type `TEXT`
- `rs12345_amb` of type `TEXT`
- `chr_12345` of type `TEXT`
- `pos_12345` of type `INTEGER`
- `rs98765` of type `TEXT`
- `rs98765_amb` of type `TEXT`
- `chr_98765` of type `TEXT`
- `pos_98765` of type `INTEGER`
- `rs28465` of type `TEXT`
- `rs28465_amb` of type `TEXT`
- `chr_28465` of type `TEXT`
- `pos_28465` of type `INTEGER`

We should now see the following:
![db browser genotypes]({{ site.baseurl }}/assets/dbbrowser_1.png)

This table can also be created using the following SQL command (more on this later):

{% highlight sql %}
CREATE TABLE genotypes (individual STRING,
                        ethnicity STRING,
                        rs12345 STRING,
                        rs12345_amb STRING,
                        chr_12345 STRING,
                        pos_12345 INTEGER,
                        rs98765 STRING,
                        rs98765_amb STRING,
                        chr_98765 STRING,
                        pos_98765 INTEGER,
                        rs28465 STRING,
                        rs28465_amb STRING,
                        chr_28465 STRING,
                        pos_28465 INTEGER);
{% endhighlight %}

This only sets up the structure. We still need to actually load the data for these two individuals. We will use SQL `INSERT` statements for this. Click on `Execute SQL`, paste the code below, and run it.

{% highlight sql %}
INSERT INTO genotypes (individual,
                       ethnicity,
                       rs12345,
                       rs12345_amb,
                       chr_12345,
                       pos_12345,
                       rs98765,
                       rs98765_amb,
                       chr_98765,
                       pos_98765,
                       rs28465,
                       rs28465_amb,
                       chr_28465,
                       pos_28465)
           VALUES ('individual_A','caucasian','A/A','A','1',12345, 'A/G','R','1',98765, 'G/T','K','5',28465);
INSERT INTO genotypes (individual,
                       ethnicity,
                       rs12345,
                       rs12345_amb,
                       chr_12345,
                       pos_12345,
                       rs98765,
                       rs98765_amb,
                       chr_98765,
                       pos_98765,
                       rs28465,
                       rs28465_amb,
                       chr_28465,
                       pos_28465)
            VALUES ('individual_B','caucasian','A/C','M','1',12345, 'G/G','G','1',98765, 'G/G','G','5',28465);
{% endhighlight %}

![db browser2]({{ site.baseurl }}/assets/dbbrowser_2.png)

Note that every SQL command is ended with a **semi-colon**...

We can now check that everything is loaded by clicking on `Browse Data` (we'll come back to getting data out later):

![db browser3]({{ site.baseurl }}/assets/dbbrowser_3.png)

Done! For every new SNP we just add a new column, right? Wrong... In contrast to the student example above where there are - let's say - 100 courses, a genotyping experiment can return results for _millions_ of positions. Imaging having a table with millions of columns.
{% include custom/series_rdbms_next.html %}
