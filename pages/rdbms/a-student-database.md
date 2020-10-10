---
title: A student database
keywords: rdbms
sidebar: rdbms_sidebar
toc: false
permalink: rdbms-a-student-database.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

## The simplest version

Let's say we want to store which students follow the S&DM course. We want to keep track of their first name, last name, student ID, and whether or not they follow the course. This should allow for some easy queries, such as listing all people who take the course, or returning the number of people who do so.
In this case, a _flat database_ would suffice; i.e. a _single_ table can hold all information.

| first_name   | last_name | student_id | takes_course |
|:------------ |:--------- |:---------- |:------------ |
| Martin       | Van Deun  | S0001      | Y            |
| Sarah        | Smith     | S0002      | Y            |
| Mary         | Kopals    | S0003      | N            |
| ...          | ...       | ...        | ...          |

## A slightly less simple setting
Consider that we want to store which students follow which courses in MSc Statistics. So we'd like to keep:
- first name, last name, student ID
- courses a student takes (CPS, LinMod, S&DM, ...)

This should allow for queries e.g. to find out which people follow a particular course, the average number of courses a student takes, etc.

Let's take the same approach as above, and we simply add a column for each course.

| first_name   | last_name | student_id | takes_GLM | takes_SDM | takes_CPS | ... | takes_LDA |
|:------------ |:--------- |:---------- |:--------- |:--------- |:--------- |:--- |:--------- |
| Martin       | Van Deun  | S0001      | Y         | Y         | Y         | ... | N         |
| Sarah        | Smith     | S0002      | Y         | Y         | N         | ... | Y         |
| Mary         | Kopals    | S0003      | N         | Y         | Y         | ... | Y         |
| ...          | ...       | ...        | ...       | ...       | ...       | ... | ...       |

This way of working (called the _wide format_) does present some issues, though.
- We will end up with a huge table. Imagine there are 20 courses at UHasselt and 80 at other universities in Flanders that the student can follow. In addition, suppose there are 50 students. This would mean that we need (3 + 100)\*50 = 5,150 cells to store this data.
- There can be a lot of wasted space, for example courses that nobody takes.

An alternative is to use the _long format_:

| first_name   | last_name | student_id | takes_course |
|:------------ |:--------- |:---------- |:------------ |
| Martin       | Van Deun  | S0001      | REG          |
| Martin       | Van Deun  | S0001      | ANOVA        |
| Martin       | Van Deun  | S0001      | Bayesian     |
| ...          | ...       | ...        | ...          |
| Martin       | Van Deun  | S0001      | LDA          |
| Sarah        | Smith     | S0002      | REG          |
| ...          | ...       | ...        | ...          |

This solves the issue of not having to store the information when a course is _not_ taken, decreasing the number of cells needed from 5,150 to 2,000.

This is still not ideal though, as this design still suffers from a lot of redundancy: the first name, last name and student ID are provided over and over again. Imagine that we'd keep home address (street, street number, zip code, city, country) as well, that would look like this:

| first_name   | last_name | student_id | street       | number  | zip     | city          | takes_course |
|:------------ |:--------- |:---------- |:------------ |:------- |:------- |:------------- |:------------ |
| Martin       | Van Deun  | S0001      | Some Street  | 1       | 1234    | MajorCity     | REG          |
| Martin       | Van Deun  | S0001      | Some Street  | 1       | 1234    | MajorCity     | ANOVA        |
| Martin       | Van Deun  | S0001      | Some Street  | 1       | 1234    | MajorCity     | Bayesian     |
| ...          | ...       | ...        | ...          | ...     | ...     | ...           | ...          |
| Martin       | Van Deun  | S0001      | Main Street  | 1       | 1234    | SmallVillage  | LDA          |
| Sarah        | Smith     | S0002      | Main Street  | 1       | 1234    | SmallVillage  | REG          |
| ...          | ...       | ...        | ...          | ...     | ...     | ...           | ...          |

What if Martin Van Deun moves from Some Street 1 in MajorCity to Another Street 42 in AnotherCity? Then we would have to edit all the rows in this table that contain this information, which almost guarantees that you will end up with inconsistencies.

{% include custom/series_rdbms_next.html %}
