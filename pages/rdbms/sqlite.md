---
title: SQLite
keywords: rdbms
sidebar: rdbms_sidebar
toc: false
permalink: rdbms-sqlite.html
folder: rdbms
series: rdbms-series
weight: 5
---
The relational database management system (RDBMS) that we will use is **SQLite**. It is very lightweight and easy to set up.

#### Using SQLite on the linux command line

To create a new database that you want to give the name 'new_database.sqlite', just call `sqlite3` with the new database name. `sqlite3 new_database.sqlite` The name of that file does not have to end with `.sqlite`, but it helps you to remember that this is an SQLite database. If you add tables and data in that database and quit, the data will automatically be saved.

There are two types of commands that you can run within SQLite: **SQL commands** (the same as in any other relational database management system), and **SQLite-specific commands**. The latter start with a period, and do **not** have a semi-colon at the end, in contrast to SQL commands (see later).

Some useful commands:

*   `.help` => Returns a list of the SQL-specific commands
*   `.tables` => Returns a list of tables in the database
*   `.schema` => Returns the schema of all tables
*   `.header on` => Add a header line in any output
*   `.mode column` => Align output data in columns instead of output as comma-separated values
*   `.quit`

#### Using DB Browser for SQLite

If you like to use a graphical user interface (or don't work on a linux or OSX computer), you can use the DB Browser for SQLite which you can download [here](https://sqlitebrowser.org/).

Note: In all code snippets that follow below, the `sqlite>` at the front represents the sqlite prompt, and should *not* be typed in...

{% include custom/series_rdbms_next.html %}
