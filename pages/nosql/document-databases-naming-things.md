---
title: Naming things
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-document-databases-naming-things.html
folder: nosql
---
The way that things are named in document stores is a bit different than in RDBMS, but in general a _collection_ in a document store corresponds to a _table_ in a RDBMS, and a _document_ corresponds to a _row_.

As a comparison, consider the following examples of a relational database vs a document database for storing blog data.

### Blog information stored in RDBMS

_Table_ `posts`

| id | author_id | date | title | text |
|---|---|---|---|---|
| 1 | 4 | 4-5-2020 | COVID-19 lockdown | It seems that... |
| 4 | 4 | 5-5-2020 | Schools closed | As the number of COVID-19 cases is growing, ... |
| ... | ... | ... | ... | ... |

_Table_ `authors`

| id | name | email |
|---|---|---|
| 1 | Santa Claus | santa.claus@northpole.org |
| 2 | Easter Bunny | easterbunny@easter.org |
| ... | ... | ... |

Each _table_ has _rows_.

### Blog information stored in document database

_Collection_ `posts`
```json
{ title: "COVID-19 lockdown",
  date: "4-5-2020",
  author: {
    name: "Geert Molenberghs",
    email: "geert@gmail.com"
  },
  text: "It seems that..." },
{ title: "Schools closed",
  date: "5-5-2020",
  author: {
    name: "Geert Molenberghs",
    email: "geert@gmail.com"
  },
  text: "As the number of COVID-19 cases is growing, ..."}
```

This is _one_ _collection_ with two _documents_.

{% include custom/series_nosql_next.html %}
