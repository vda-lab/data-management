---
title: Normal forms
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-normal-forms.html
folder: rdbms
series: rdbms-series
weight: 10
---
There are some good practices in developing relational database schemes which make it easier to work with the data afterwards. Some of these practices are represented in the "normal forms".

For reference, here's the original `genotypes` table again:

| individual   | ethnicity | rs12345 | rs12345_amb | chr_12345 | pos_12345 | rs98765 | rs98765_amb | chr_98765 | pos_98765 | rs28465 | rs28465_amb | chr_28465 | pos_28465 |
|:------------ |:--------- |:------- |:----------- |:--------- |:--------- |:------- |:----------- |:--------- |:--------- |:------- |:----------- |:--------- |:--------- |
| individual_A | caucasian | A/A     | A           | 1         | 12345     | A/G     | R           | 1         | 98765     | G/T     | K           | 5         | 28465     |
| individual_B | caucasian | A/C     | M           | 1         | 12345     | G/G     | G           | 1         | 98765     | G/G     | G           | 5         | 28465     |

## First normal form

To get to the first normal form:

* **Eliminate duplicative columns** from the same table, by splitting them out in separate tables.

The columns rs12345, rs98765 and rs28465 are duplicates; they describe exactly the same type of thing (albeit different instances) and we need to eliminate these. And we can do that by splitting the original table into two tables. In doing this, we need to *think what each table actually represents*. We

- give the tables a sensible name
- add a unique `id` number
- add additional necessary columns (here, for example, a `name` column in the `snps` table)
- rename columns so that they do not refer to the different duplicates anymore (e.g. `rs12345` becomes `name`)
- add foreign keys to link tables

Regarding the `id`: each row in a table should have a **unique key** within that table. Best practices tell us to use autoincrementing integers, and that the **primary key should contain no information in itself**.


`individuals` table:

| id | name         | ethnicity |
|:-- |:------------ |:--------- |
| 1  | individual_A | caucasian |
| 2  | individual_B | caucasian |

`genotypes` table:

| id | name    | individual_id | genotype | ambiguity_code | chromosome | position |
|:-- |:------- |:------------- |:-------- |:-------------- |:---------- |:-------- |
| 1  | rs12345 | 1             | A/A      | A              | 1          | 12345    |
| 2  | rs98765 | 1             | A/G      | R              | 1          | 98765    |
| 3  | rs28465 | 1             | G/T      | K              | 5          | 23456    |
| 4  | rs12345 | 2             | A/C      | M              | 1          | 12345    |
| 5  | rs98765 | 2             | G/G      | G              | 1          | 98765    |
| 6  | rs28465 | 2             | G/G      | G              | 5          | 23456    |

What we did:
* The name of each table should be **plural** (not mandatory, but good practice).
* Each table should have a **primary key**, ideally named `id`. Different tables can contain columns that have the same name; column names should be unique within a table, but can occur across tables.
* In the genotypes table, individuals are identified by their `id` in the `individuals` table which is their primary key. The `individual_id` column in the `genotypes` table is called the **foreign key** Again best practice: if a **foreign key** refers to the id column in the individuals table, it should be named **individual_id** (note the singular).
* The foreign key `individual_id` in the `genotypes` table must be of the same type as the id column in the `individuals` tables.

The commands to create these tables:

{% highlight sql %}
DROP TABLE genotypes;
CREATE TABLE genotypes (id INTEGER PRIMARY KEY, name STRING, individual_id INTEGER, genotype STRING, ambiguity_code STRING, chromosome STRING, position INTEGER);
CREATE TABLE individuals (id INTEGER PRIMARY KEY, name STRING, ethnicity STRING)
{% endhighlight %}

{% highlight sql %}
INSERT INTO individuals (name, ethnicity)
                    VALUES ('individual_A','caucasian');
INSERT INTO individuals (name, ethnicity)
                    VALUES ('individual_B','caucasian');
INSERT INTO genotypes (name, individual_id, genotype, ambiguity_code, chromosome, position)
                    VALUES ('rs12345',1,'A/A','A','1',12345);
INSERT INTO genotypes (name, individual_id, genotype, ambiguity_code, chromosome, position)
                    VALUES ('rs98765',1,'A/G','R','1',12345);
INSERT INTO genotypes (name, individual_id, genotype, ambiguity_code, chromosome, position)
                    VALUES ('rs28465',1,'G/T','K','5',23456);
INSERT INTO genotypes (name, individual_id, genotype, ambiguity_code, chromosome, position)
                    VALUES ('rs12345',2,'A/C','M','1',12345);
INSERT INTO genotypes (name, individual_id, genotype, ambiguity_code, chromosome, position)
                    VALUES ('rs98765',2,'G/G','G','1',12345);
INSERT INTO genotypes (name, individual_id, genotype, ambiguity_code, chromosome, position)
                    VALUES ('rs28465',2,'G/G','G','5',23456);
{% endhighlight %}

The fact that `id` is defined as INTEGER PRIMARY KEY makes it increment automatically if not defined specifically. So loading data without explicitly specifying the value for id automatically takes care of everything.
The same goes for `rowid`. _In the explanations and code below, replace `id` with `rowid` if you used the DB Browser instead of the command line to create the tables._

### Types of table relationships
So how do you know in which table to create the foreign key? Should there be an `individual_id` in the `genotypes` table? Or a `genotype_id` in the `individuals` table? That all depends on the **type of relationship** between two tables. This type can be:

- **one-to-one**, for example an single ISBN number can be linked to a single book and vice versa.
- **one-to-many**, for example a single company will have many employees, but a single employee will work only for a single company
- **many-to-many**, for example a single book can have multiple authors and a single author can have written multiple books

One-to-many is obviously the same as many-to-one but looking at it from the other direction...

When you have a _one-to-one relationship_, you can actually merge that information into the same table so in the end you won't even need a foreign key. In the book example mentioned above, you'd just add the ISBN number to the books table.<br/>
When you have a _one-to-many relationship_, you'd add the foreign key to the "many" table. In the example below a _single company_ will have _many employees_, so you add the foreign key in the employees table.

The `companies` table:

| id  | company_name  |
|:--- |:------------- |
| 1   | Big company 1 |
| 2   | Big company 2 |
| 3   | Big company 3 |
| ... | ...           |

The `employees` table:

| id  | name           | address                           | company_id |
|:--- |:-------------- |:--------------------------------- |:---------- |
| 1   | John Jones     | some_address, some_city           | 1          |
| 2   | Jim James      | another_address, some_city        | 1          |
| 3   | Fred Fredricks | yet_another_address, another_city | 1          |
| ... | ...            | ...                               | ...        |

When you have a _many-to-many relationship_ you'd typically extract that information into a new table. For the books/authors example, you'd have a single table for the books, a single table for the authors, and a separate table that links the two together. That "linking" table can also contain information that is specific for that relationship, but it does not have to. An example is the `genotypes` table above. There are many SNPs for a single individual, and a single SNP is measured for many individuals. That's why we created a separate table called `genotypes`, which in this case has additional columns that denote the value for a single individual for a single SNP. For the books/authors example, this would be:

The `books` table:

| id  | title                                                               | ISBN13        |
|:--- |:------------------------------------------------------------------- |:------------- |
| 1   | Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch | 9780060853983 |
| 2   | Going Postal (Discworld #33)                                        | 9780060502935 |
| 3   | Small Gods (Discworld #13)                                          | 9780552152976 |
| 4   | The Stupidest Angel: A Heartwarming Tale of Christmas Terror        | 9780060842352 |
| ... | ...                                                                 | ...           |

The `authors` table:

| id  | name              |
|:--- |:----------------- |
| 1   | Terry Pratchett   |
| 2   | Christopher Moore |
| 3   | Neil Gaiman       |
| ... | ...               |

The `author2book` table:

| id  | author_id | book_id |
|:--- |:--------- |:------- |
| 1   | 1         | 1       |
| 2   | 3         | 1       |
| 3   | 1         | 2       |
| 4   | 1         | 3       |
| 5   | 2         | 4       |
| ... | ...       | ...     |

The information in these tables says that:

- Terry Pratchett and Neil Gaiman co-wrote "Good Omens"
- Terry Pratchett wrote "Going Postal" and "Small Gods" by himself
- Christopher Moore was the single authors of "The Stupidest Angel"

Now back to our individuals and their genotypes...

## Second normal form

There is **still a lot of duplication** in this data. In the `genotypes` table we see in record 1 that the SNP `rs12345` is on chromosome 1 at position 12345; we see the exact same information again in record 4, where it is listed for individual nr 2. What if we are told after that we have created the table that `rs12345` is actually on chromsome 2 instead of 1? In a `genotypes` table as the one above we would have to look up all these records and change the value from 1 to 2. Enter the second normal form:

* **Remove dependencies within rows**

In the `genotypes` table, `chromosome` and `position` depend on `name`. For the second normal form we extract this into yet another table, called `snps`. So now we have:

`individuals` table:

| id | name         | ethnicity |
|:-- |:------------ |:--------- |
| 1  | individual_A | caucasian |
| 2  | individual_B | caucasian |

`snps` table:

| id | name    | chromosome | position |
|:-- |:------- |:---------- |:-------- |
| 1  | rs12345 | 1          | 12345    |
| 2  | rs98765 | 1          | 98765    |
| 3  | rs28465 | 5          | 23456    |

`genotypes` table:

| id | snp_id | individual_id | genotype | ambiguity_code |
|:-- |:------ |:------------- |:-------- |:-------------- |
| 1  | 1      | 1             | A/A      | A              |
| 2  | 2      | 1             | A/G      | R              |
| 3  | 3      | 1             | G/T      | K              |
| 4  | 1      | 2             | A/C      | M              |
| 5  | 2      | 2             | G/G      | G              |
| 6  | 3      | 2             | G/G      | G              |

The commands to create these tables:

{% highlight sql %}
DROP TABLE genotypes;
DROP TABLE individuals;
CREATE TABLE individuals (id INTEGER PRIMARY KEY, name STRING, ethnicity STRING);
CREATE TABLE snps (id INTEGER PRIMARY KEY, name STRING, chromosome STRING, position INTEGER);
CREATE TABLE genotypes (id INTEGER PRIMARY KEY, snp_id INTEGER, individual_id INTEGER, genotype STRING, ambiguity_code STRING);
{% endhighlight %}

{% highlight sql %}
INSERT INTO individuals (name, ethnicity)
                    VALUES ('individual_A','caucasian');
INSERT INTO individuals (name, ethnicity)
                    VALUES ('individual_B','caucasian');
INSERT INTO snps (name, chromosome, position)
                    VALUES('rs12345','1',12345);
INSERT INTO snps (name, chromosome, position)
                    VALUES('rs98765','1',98765);
INSERT INTO snps (name, chromosome, position)
                    VALUES('rs28465','5',23456);
INSERT INTO genotypes (snp_id, individual_id, genotype, ambiguity_code)
                    VALUES (1,1,'A/A','A');
INSERT INTO genotypes (snp_id, individual_id, genotype, ambiguity_code)
                    VALUES (2,1,'A/G','R');
INSERT INTO genotypes (snp_id, individual_id, genotype, ambiguity_code)
                    VALUES (3,1,'G/T','K');
INSERT INTO genotypes (snp_id, individual_id, genotype, ambiguity_code)
                    VALUES (1,2,'A/C','M');
INSERT INTO genotypes (snp_id, individual_id, genotype, ambiguity_code)
                    VALUES (2,2,'G/G','G');
INSERT INTO genotypes (snp_id, individual_id, genotype, ambiguity_code)
                    VALUES (3,2,'G/G','G');
{% endhighlight %}

So we end up with this schema:

![primary and foreign keys]({{ site.baseurl }}/assets/primary_foreign_keys.png)

## Removing calculated columns

Finally, we try to **eliminate unnecessary data** from our database; data that could be **calculated** based on other things that are present. In our example table genotypes, the `genotype` and `genotype_amb` columns basically contain the same information, just using a different encoding. We could (should) therefore remove one of these. This is similar to having a column with country names (e.g. 'Belgium') and one with country codes (e.g. 'Bel') in the individuals table: you'd want to remove one of those.

Our final `individuals` table would look like this:

| id | name         | ethnicity |
|:-- |:------------ |:--------- |
| 1  | individual_A | caucasian |
| 2  | individual_B | caucasian |

The `snps` table:

| id | name      | chromosome | position |
|:-- |:--------- |:---------- |:-------- |
| 1  | rs12345   | 1          | 12345    |
| 2  | rs98765   | 1          | 98765    |
| 3  | rs28465   | 5          | 28465    |

The `genotypes` table:

| id | individual_id | snp_id | genotype_amb |
|:-- |:------------- |:------ |:------------ |
| 1  | 1             | 1      | A            |
| 2  | 1             | 2      | R            |
| 3  | 1             | 3      | K            |
| 4  | 2             | 1      | M            |
| 5  | 2             | 2      | G            |
| 6  | 2             | 3      | G            |

To know what your database schema looks like, you can issue the `.schema` command in sqlite3. `.tables` gives you a list of the tables that are defined. If you're using the DB Browser tool, click on `Database Structure`.


{% include custom/series_rdbms_next.html %}
