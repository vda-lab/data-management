---
title: Normal forms
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-normal-forms.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

There are some good practices in developing relational database schemes which make it easier to work with the data afterwards. Some of these practices are represented in the "normal forms".

Let's consider the following table listing individuals, SNPs and genotypes. This is genetic data. As you know, everyone has very similar DNA (otherwise we wouldn't be human), but there are a lot of positions in that genome (about 1/1000) where people differ from each other (otherwise we would all be clones). A "single nucleotide polymorphism" (or "SNP") is such a position in the genome. A "genotype" is the actual nucleotides that someone has in his/her genome at that particular position. And because we have 2 copies of each chromosome, a genotype consists of 2 letters (A, C, G and T).

| individual | ethnicity | rs12345 | chromosome;position | rs12345_diseases | rs98765 | chromosome;position | rs28465 | chromosome;position |
|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|
| individual_A | caucasian | A/A | 1;12345 | COPD;asthma | A/G | 1;98765 | G/T | 5;28465 |
| individual_B | caucasian | A/C | 1;12345 | COPD;asthma | G/G | 1;98765 | G/G | 5;28465 |

## First normal form

To get to the first normal form:

* **Make columns atomic**: a single cell should contain only a single value
* **Values in a column should be of a single domain**: a single column should not have a mix of data
* **All columns should have unique names**
* **Columns should be not be hidden lists**: often clear because the column _name_ actually holds information

The above table violates several of these points:
- The `rs12345_diseases` columns holds non-atomic values: `COPD;asthma` is a list.
- The column name `chromosome;position` is used multiple times.
- The columns `rs12345`, `rs98765` and `rs28465` are effectively the same thing: they describe the genotypes for a particular SNP. The same is true for the `chromsome;position` columns (but that was already clear from the previous point).

The solution to these issues is to go from a _wide_ format to a _long_ format: remove columns by adding rows. For example, the information for the 3 different SNPs is now stored in different rows instead of different columns. The same is true for the non-atomic values: we just duplicate the row to be able to split up the diseases. This will end up with many rows but don't worry about that.

| individual | ethnicity | snp | genotype | chr | pos | disease |
|:--|:--|:--|:--|:--|:--|:--|:--|
| individual_A | caucasian | rs12345 | A/A | 1 | 12345 | COPD |
| individual_A | caucasian | rs12345 | A/A | 1 | 12345 | asthma |
| individual_B | caucasian | rs12345 | A/C | 1 | 12345 | COPD |
| individual_B | caucasian | rs12345 | A/C | 1 | 12345 | asthma |
| individual_A | caucasian | rs98765 | A/G | 1 | 98765 | |
| individual_B | caucasian | rs98765 | G/G | 1 | 98765 | |
| individual_A | caucasian | rs28465 | G/T | 5 | 28465 | |
| individual_B | caucasian | rs28465 | G/G | 5 | 28465 | |

The new schema:

![]({{site.baseurl}}/assets/1NF.png)

Everything is still contained in a single table, which will change when we go to the second normal form.

## Second normal form

* **Schema is in First Normal form**
* **There are no partial dependencies**

In the new table above, we see that there are several columns that are 1-to-1 dependent on another column. For example, if we know the individual, we know their ethnicity. If we know the SNP, we know the chromosome, position and any diseases involved. For the 2nd normal form, we extract these into separate tables. In doing this, think about the _concepts_ that you're trying to separate.

`genotypes` table:

| id | individual_id | snp_id | genotype |
|:--|:--|:--|:--|
| 1 | 1 | 1 | A/A |
| 2 | 1 | 1 | A/A |
| 3 | 2 | 1 | A/C |
| 4 | 1 | 2 | A/G |
| 5 | 2 | 2 | G/G |
| 6 | 1 | 3 | G/T |
| 7 | 2 | 3 | G/G |

`individuals` table:

| id | name | ethnicity |
|:--|:--|:--|
| 1 | individual_A | caucasian |
| 2 | individual_B | caucasian |

`snps` table:

| id | name | chr | pos | diseases |
|:--|:--|:--|:--|:--|
| 1 | rs12345 | 1 | 12345 | COPD |
| 2 | rs12345 | 1 | 12345 | asthma |
| 3 | rs98765 | 1 | 98765 | |
| 4 | rs28465 | 5 | 28465 | |


Some observations (and good practices):
- The name of each table should be **plural** (not mandatory, but good practice).
- Each table should have a **primary key**, ideally named `id`. Different tables can contain columns that have the same name; column names should be unique within a table, but can occur across tables.
- In the `genotypes` table, individuals are identified by their `id` in the `individuals` table which is their primary key. The `individual_id` column in the `genotypes` table is called the **foreign key**. Again best practice: if a foreign key refers to the `id` column in the `individuals` table, it should be named `individual_id` (note the singular).
- The name of each table should be plural (not mandatory, but good practice).
- The foreign key `individual_id` in the `genotypes` table must be of the same type as the `id` column in the `individuals` table.

By the way, we see that the first 2 rows in the `genotypes` table are exactly the same apart from the unique ID, so we can remove one (e.g. with ID `2`).

`genotypes` table:

| id | individual_id | snp_id | genotype |
|:--|:--|:--|:--|
| 1 | 1 | 1 | A/A |
| 3 | 2 | 1 | A/C |
| 4 | 1 | 2 | A/G |
| 5 | 2 | 2 | G/G |
| 6 | 1 | 3 | G/T |
| 7 | 2 | 3 | G/G |

The new schema:

![]({{site.baseurl}}/assets/2NF.png)

## Third normal form

* **Look for rows that are the same except for a non-key column**

In the `snps` table above, there are two rows that are exactly the same (not taking into account the `id` column), if it weren't for the `disease` field.

| 1 | rs12345 | 1 | 12345 | COPD |
| 2 | rs12345 | 1 | 12345 | asthma |

Such case indicates a one-to-many or many-to-many relationship: a single SNP can be involved in multiple diseases. Again we have duplication here: the fact that SNP `rs12345` is on chromosome 1 at position 12345 is captured twice. We can solve this by extracting another table, called `diseases`.

Although biologically incorrect, imagine that a disease can only be linked to a single SNP. This would be a one-to-many relationship: one SNP to many diseases. In that case we could create the following tables:

`snps` table:

| id | name | chr | pos |
|:--|:--|:--|:--|
| 1 | rs12345 | 1 | 12345 |
| 2 | rs12345 | 1 | 12345 |
| 3 | rs98765 | 1 | 98765 |
| 4 | rs28465 | 5 | 28465 |

`diseases` table:

| id | name | snp_id |
|:--|:--|:--|
| 1 | COPD | 1 |
| 2 | asthma | 1 |

We have now eliminated the `disease` column from the `snps` table so end up with 2 identical rows (rows 1 and 2) and can remove one of them.

| id | name | chr | pos |
|:--|:--|:--|:--|
| 1 | rs12345 | 1 | 12345 |
| 2 | rs12345 | 1 | 12345 |
| 3 | rs98765 | 1 | 98765 |
| 4 | rs28465 | 5 | 28465 |

But as we just mentioned, biologically speaking a single SNP can be involved in multiple diseases and a single disease can be influenced by multiple SNPs. This is a _many-to-many_ relationship. In this case, we can't just add a `snp_id` to the `diseases` table anymore (or you would have to use a non-atomic field which would violate the 1st normal form). You typically create a separate _link table_.

`snps` table:

| id | name | chr | pos |
|:--|:--|:--|:--|
| 1 | rs12345 | 1 | 12345 |
| 3 | rs98765 | 1 | 98765 |
| 4 | rs28465 | 5 | 28465 |

`diseases` table:

| id | name |
|:--|:--|
| 1 | COPD |
| 2 | asthma |

`disease2snp` table:

| id | snp_id | disease_id |
|:--|:--|:--|
| 1 | 1 | 1 |
| 2 | 1 | 2 |

### The final database

In the end, we have the following tables:

`snps` table:

| id | name | chr | pos |
|:--|:--|:--|:--|
| 1 | rs12345 | 1 | 12345 |
| 2 | rs98765 | 1 | 98765 |
| 3 | rs28465 | 5 | 28465 |

`diseases` table:

| id | name |
|:--|:--|
| 1 | COPD |
| 2 | asthma |

`disease2snp` table:

| id | snp_id | disease_id |
|:--|:--|:--|
| 1 | 1 | 1 |
| 2 | 1 | 2 |

`genotypes` table:

| id | individual_id | snp_id | genotype |
|:--|:--|:--|:--|
| 1 | 1 | 1 | A/A |
| 3 | 2 | 1 | A/C |
| 4 | 1 | 2 | A/G |
| 5 | 2 | 2 | G/G |
| 6 | 1 | 3 | G/T |
| 7 | 2 | 3 | G/G |

`individuals` table:

| id | name | ethnicity |
|:--|:--|:--|
| 1 | individual_A | caucasian |
| 2 | individual_B | caucasian |

The schema itself:

![]({{site.baseurl}}/assets/3NF.png)

### Types of table relationships
To come back to the one-to-many relationships... So how do you know in which table to create the foreign key? Should there be an `individual_id` in the `genotypes` table? Or a `genotype_id` in the `individuals` table? That all depends on the **type of relationship** between two tables. This type can be:

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


{% include custom/series_rdbms_next.html %}
