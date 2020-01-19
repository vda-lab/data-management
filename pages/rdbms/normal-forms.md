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

## First normal form

To get to the first normal form:

* **Eliminate duplicative columns** from the same table, i.e. convert from wide format to long format (see in the above example).

The columns rs123451, rs98765 and rs28465 are duplicates; they describe exactly the same type of thing (albeit different instances) and we need to eliminate these. And we can do that by creating new records (rows) for each SNP. In addition, each row should have a **unique key**. Best practices tell us to use autoincrementing integers, the **primary key should contain no information in itself**.

| id | individual   | ethnicity | snp     | genotype | genotype_amb | chromosome | position |
|:-- |:------------ |:--------- |:------- |:-------- |:------------ |:---------- |:-------- |
| 1  | individual_A | caucasian | rs12345 | A/A      | A            | 1          | 12345    |
| 2  | individual_A | caucasian | rs98765 | A/G      | R            | 1          | 98765    |
| 3  | individual_A | caucasian | rs28465 | G/T      | K            | 5          | 28465    |
| 4  | individual_B | caucasian | rs12345 | A/C      | M            | 1          | 12345    |
| 5  | individual_B | caucasian | rs98765 | G/G      | G            | 1          | 98765    |
| 6  | individual_B | caucasian | rs28465 | G/G      | G            | 5          | 28465    |

Create the table in the same way as above using the DB Browser with the following columns:
- `individual` `TEXT`
- `ethnicity` `TEXT`
- `snp` `TEXT`
- `genotype` `TEXT`
- `genotype_amb` `STRING`
- `chromosome` `TEXT`
- `position` `INTEGER`

... or use the command line:

{% highlight sql %}
DROP TABLE genotypes;
CREATE TABLE genotypes (id INTEGER PRIMARY KEY, individual STRING, ethnicity STRING, snp STRING, genotype STRING, genotype_amb STRING, chromosome STRING, position INTEGER);
{% endhighlight %}
Note that in this case we _do_ have to define the `id` column ourselves, whereas the DB Browser creates a `rowid` column automatically.

{% highlight sql %}
INSERT INTO genotypes (individual, ethnicity, snp, genotype, genotype_amb, chromosome, position)
                    VALUES ('individual_A','caucasian','rs12345','A/A','A','1',12345);
INSERT INTO genotypes (individual, ethnicity, snp, genotype, genotype_amb, chromosome, position)
                    VALUES ('individual_A','caucasian','rs98765','A/G','R','1',98765);
INSERT INTO genotypes (individual, ethnicity, snp, genotype, genotype_amb, chromosome, position)
                    VALUES ('individual_A','caucasian','rs28465','G/T','K','1',28465);
INSERT INTO genotypes (individual, ethnicity, snp, genotype, genotype_amb, chromosome, position)
                    VALUES ('individual_B','caucasian','rs12345','A/C','M','1',12345);
INSERT INTO genotypes (individual, ethnicity, snp, genotype, genotype_amb, chromosome, position)
                       VALUES ('individual_B','caucasian','rs98765','G/G','G','1',98765);
INSERT INTO genotypes (individual, ethnicity, snp, genotype, genotype_amb, chromosome, position)
                    VALUES ('individual_B','caucasian','rs28465','G/G','G','1',28465);
{% endhighlight %}

The fact that `id` is defined as INTEGER PRIMARY KEY makes it increment automatically if not defined specifically. So loading data without explicitly specifying the value for id automatically takes care of everything.
The same goes for `rowid`. _In the explanations and code below, replace `id` with `rowid` if you used the DB Browser instead of the command line to create the tables._

## Second normal form

There is **still a lot of duplication** in this data. In record 1 we see that individual_A is of Caucasian ethnicity; a piece of information that is duplicated in records 2 and 3. The same goes for the positions of the SNPs. In records 1 and 4 we can see that the SNP rs12345 is located on chromosome 1 at position 12345. But what if afterwards we find an error in our data, and rs12345 is actually on chromosome 2 instead of 1? In a table as the one above we would have to look up all these records and change the value from 1 to 2. Enter the second normal form:

* **Remove subsets of data that apply to multiple rows** of a table and place them in separate tables.
* **Create relationships between these new tables** and their predecessors through the use of **foreign keys**.

So how could we do that for the table above? Each row contains **3 different types of things**: information about an individual (i.c. name and ethnicity), a SNP (i.c. the accession number, chromosome and position), and a genotype linking those two together (the genotype column, and the column containing the IUPAC ambiguity code for that genotype). To get to the second normal form, we need to put each of these in a separate table:

* The name of each table should be **plural** (not mandatory, but good practice).
* Each table should have a **primary key**, ideally named `id`. Different tables can contain columns that have the same name; column names should be unique within a table, but can occur across tables.
* The individual column is renamed to name, and snp to accession.
* In the genotypes table, individuals and SNPs are linked by referring to their primary keys (as used in the individuals and snps tables). Again best practice: if a **foreign key** refers to the id column in the individuals table, it should be named **individual_id** (note the singular).
* The foreign keys individual_id and snp_id in the genotypes table must be of the same type as the id columns in the individuals and snps tables, respectively.

![primary and foreign keys]({{ site.baseurl }}/assets/primary_foreign_keys.png)

The `individuals` table:

| id | name         | ethnicity |
|:-- |:------------ |:--------- |
| 1  | individual_A | caucasian |
| 2  | individual_B | caucasian |

The `snps` table:

| id | accession | chromosome | position |
|:-- |:--------- |:---------- |:-------- |
| 1  | rs12345   | 1          | 12345    |
| 2  | rs98765   | 1          | 98765    |
| 3  | rs28465   | 5          | 28465    |

The `genotypes` table:

| id | individual_id | snp_id | genotype | genotype_amb |
|:-- |:------------- |:------ |:-------- |:------------ |
| 1  | 1             | 1      | A/A      | A            |
| 2  | 1             | 2      | A/G      | R            |
| 3  | 1             | 3      | G/T      | K            |
| 4  | 2             | 1      | A/C      | M            |
| 5  | 2             | 2      | G/G      | G            |
| 6  | 2             | 3      | G/G      | G            |

So the `snp_id` _foreign key_ `2` in row number 2 in the `genotypes` table links this record to the row with `id` _primary key_ `2` in the `snps` table.

### Types of table relationships
So how do you know in which table to create the foreign keys? Should there be a `snp_id` in the `genotypes` table? Or a `genotype_id` in the `snps` table? That all depends on the **type of relationship** between two tables. This type can be:

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

To generate the `individuals`, `snps` and `genotypes` tables of the second normal form, use the DB Browser again or do this command line. You can get the information you need to create the individual columns from the piece of code below, taking into account:
- that you do not have to create the `id` column
- that you will have to select `TEXT` in the dropdown box instead of `STRING`

{% highlight sql %}
DROP TABLE individuals;
DROP TABLE snps;
DROP TABLE genotypes;
CREATE TABLE individuals (id INTEGER PRIMARY KEY, name STRING, ethnicity STRING);
CREATE TABLE snps (id INTEGER PRIMARY KEY, accession STRING, chromosome STRING, position INTEGER);
CREATE TABLE genotypes (id INTEGER PRIMARY KEY, individual_id INTEGER, snp_id INTEGER, genotype STRING, genotype_amb STRING);
{% endhighlight %}

To then load the data:

{% highlight sql %}
INSERT INTO individuals (name, ethnicity) VALUES ('individual_A','caucasian');
INSERT INTO individuals (name, ethnicity) VALUES ('individual_B','caucasian');
INSERT INTO snps (accession, chromosome, position) VALUES ('rs12345','1',12345);
INSERT INTO snps (accession, chromosome, position) VALUES ('rs98765','1',98765);
INSERT INTO snps (accession, chromosome, position) VALUES ('rs28465','5',28465);
INSERT INTO genotypes (individual_id, snp_id, genotype, genotype_amb) VALUES (1,1,'A/A','A');
INSERT INTO genotypes (individual_id, snp_id, genotype, genotype_amb) VALUES (1,2,'A/G','R');
INSERT INTO genotypes (individual_id, snp_id, genotype, genotype_amb) VALUES (1,3,'G/T','K');
INSERT INTO genotypes (individual_id, snp_id, genotype, genotype_amb) VALUES (2,1,'A/C','M');
INSERT INTO genotypes (individual_id, snp_id, genotype, genotype_amb) VALUES (2,2,'G/G','G');
INSERT INTO genotypes (individual_id, snp_id, genotype, genotype_amb) VALUES (2,3,'G/G','G');
{% endhighlight %}

## Third normal form

In the third normal form, we try to **eliminate unnecessary data** from our database; data that could be **calculated** based on other things that are present. In our example table genotypes, the `genotype` and `genotype_amb` columns basically contain the same information, just using a different encoding. We could (should) therefore remove one of these. This is similar to having a column with country names (e.g. 'Belgium') and one with country codes (e.g. 'Bel') in the individuals table: you'd want to remove one of those.

Our final `individuals` table would look like this:

| id | name         | ethnicity |
|:-- |:------------ |:--------- |
| 1  | individual_A | caucasian |
| 2  | individual_B | caucasian |

The `snps` table:

| id | accession | chromosome | position |
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
