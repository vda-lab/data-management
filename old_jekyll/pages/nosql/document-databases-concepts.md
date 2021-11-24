---
title: Concepts
keywords: nosql
sidebar: nosql_sidebar
toc: true
permalink: nosql-document-databases-concepts.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

## Naming things: collections and documents
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
{% highlight json %}
{ title: "COVID-19 lockdown", date: "4-5-2020",
  author: { name: "Geert Molenberghs", email: "geert@gmail.com" },
  text: "It seems that..." },
{ title: "Schools closed", date: "5-5-2020",
  author: { name: "Geert Molenberghs", email: "geert@gmail.com" },
  text: "As the number of COVID-19 cases is growing, ..."}
{% endhighlight %}

This is _one_ _collection_ with two _documents_.

## Documents are schemaless
As mentioned [before]({{ site.baseurl }}/nosql-general-concepts.html), one of the important differences between RDBMS and document databases, is that documents are _schemaless_. Actually, we should say that they have a _flexible schema_. What does this mean? Consider the case where we are collecting data on bird migrations (as for example [https://www.belgianbirdalerts.be/](https://www.belgianbirdalerts.be/)). In an RDMBS, we could put this information in a `sightings` table.

<small><i>sightings</i></small>

| id | species_la | species_en | date_time | municipality |
|----|---------|------|----------|
|  1 | Emberiza pusilla | Little Bunting | Dwerggors | 30-09-2020 15:37 | Zeebrugge, BE |
|  2 | Sylvia nisoria | Barred Warbler | Sperwergrasmus | 2020-10-01 13:45 | Zeebrugge, BE |
| ... | ... | ... | ... | ... |

What if we want to store the Dutch name as well? Then we'd need to alter the table schema to have a new column to hold that information: `ALTER TABLE sightings ADD species_du TEXT;`. After adding this column and updating the value in that particular column, we get the following:

<small><i>sightings</i></small>

| id | species_la | species_en | species_du | date_time | municipality |
|----|---------|------|----------|
|  1 | Emberiza pusilla | Little Bunting | Dwerggors | 30-09-2020 15:37 | Zeebrugge, BE |
|  2 | Sylvia nisoria | Barred Warbler | Sperwergrasmus | 2020-10-01 13:45 | Zeebrugge, BE |
| ... | ... | ... | ... | ... |

So far so good: this table still looks clean. Now imagine that we want to improve the reporting, and actually include the longitude and latitude instead of just the municipality. Also, we want to split up the date from the time. To do this, we have to alter the schema of the `sightings` table to include these new columns. Only after we changed this schema, we can input data using the new information:

<small><i>sightings</i></small>

| id | species_la | species_en | species_du | date_time | municipality | date | time | lat | long |
|----|---------|------|----------|
|  1 | Emberiza pusilla | Little Bunting | Dwerggors | 30-09-2020 15:37 | Zeebrugge, BE | | | | |
|  2 | Sylvia nisoria | Barred Warbler | Sperwergrasmus | 2020-10-01 13:45 | Zeebrugge, BE | | | | |
| ... | ... | ... | ... | ... | | | | |
|  56 | Elanus caeruleus | Black-winged Kite | Grijze Wouw | | | 2020-10-02 | 15:15 | 50.96577 | 3.92744 |
|  57 | Ficedula parva | Red-breasted Flycatcher | Kleine Vliegenvanger | | | 2020-10-04 | 10:34 | 51.33501 | 3.23154 |
|  58 | Phalaropus lobatus | Red-necked Phalarope | Grauwe Franjepoot | | | 2020-10-04 | 10:48 | 51.14660 | 2.73363 |
|  59 | Locustella certhiola | Pallas's Grasshopper Warbler | Siberische Sprinkhaanzanger | | | 2020-10-04 | 11:53 | 51.33950 | 3.22775 |
| ... | ... | ... | ... | ... | | | ... | ... |

Executing an `ALTER TABLE` on a relational database is a _huge_ step. Having a well-defined schema is core to a RDBMS, so changing it should not be done lightly.

In contrast, nothing would need to be done to store this new information if we had been using a document-database. Consider our initial data:

{% highlight json %}
{ id: 1,
  species_la: "Emberiza pusilla", species_en: "Little Bunting",
  date_time: "30-09-2020 15:37", municipality: "Zeebrugge, BE"},
{ id: 2,
  species_la: "Sylvia nisoria", species_en: "Barred Warbler",
  date_time: "2020-10-01 13:45", municipality: "Zeebrugge, BE"},
...
{% endhighlight %}

If we want to change from reporting municipality to latitude and longitude, we just add those instead on new documents:
{% highlight json %}
{ id: 1,
  species_la: "Emberiza pusilla", species_en: "Little Bunting",
  date_time: "30-09-2020 15:37", municipality: "Zeebrugge, BE" },
{ id: 2,
  species_la: "Sylvia nisoria", species_en: "Barred Warbler",
  date_time: "2020-10-01 13:45", municipality: "Zeebrugge, BE" },
...
{ id: 56,
  species_la: "Elanus caeruleus", species_en: "Black-winged Kite", species_du: "Grijze Wouw",
  date: "2020-10-02", time: "15:15",
  lat: 50.96577, long: 3.92744 },
{ id: 57,
  species_la: "Ficedula parva", species_en: "Red-breasted Flycatcher", species_du: "Kleine Vliegenvanger",
  date: "2020-10-04", time: "10:34",
  lat: 51.33501, long: 3.23154 },
...
{% endhighlight %}

### Explicit vs implicit schema
Important: Even though a document database does not enforce a strict schema, there is still an _implicit schema_: it's the combination of keys and possible values that can be present in a document. The application (or you) need to know that the English species name is stored with the key `species_en`. It should not be a mix of `species_en` in some cases, `species_english` in others, or `english_name` or `english_species_name`, etc. That would make it impossible to for example get a list of all species that were sighted.

## Embedding vs referencing
When modelling data in a relational database, we typically try to create a _normalised database schema_. In such schema, different concepts are stored in different tables, and information is linked by referencing rows in different tables.

Consider the example of a blog. This information concerns different concepts: the blog itself, posts on that blog, authors, comments, and tags. This can be modelled like this in a relational database:

<img src="{{ site.baseurl }}/assets/blog_rdbms_schema.png" width="300px"/>


Each concept is stored in a separate table. To get all comments on posts written by John Doe, we can do this (we won't go into actual schemas here):
{% highlight sql %}
SELECT c.date, c.comment
FROM authors a, blog_entries b, comments c
WHERE a.id = b.author_id
AND b.id = c.entry_id
AND a.name = "John Doe";
{% endhighlight %}

In document databases, we have to find a balance between _embedding_ and _referencing_.

On the one extreme end, we can follow the same approach as in relational databases, and create a separate collection for each concept. So there would be a collection for `blogs`, one for `blog_entries`, for `authors`, for `comments` and `tags`. At the other extreme end, we can _embed_ some of this information. For example, a single blog entry can have the author name and email, the comments and tags _inside_ it.

A referencing-heavy approach:

<img src="{{ site.baseurl }}/assets/joining.png" width="300px"/>

A mixed reference-embed approach:

<img src="{{ site.baseurl }}/assets/linking-embedding.png" width="400px"/>

### On cross-collection queries
In many document database-implementations (e.g. mongodb) it is not possible to query across collections, which can make using referenced data much more difficult. A query in mongodb, for example, will look like this (don't worry about the exact syntax; it should be clear what this tries to do):
{% highlight json %}
db.comments.find({author_id: 5})
{% endhighlight %}

This will return all comments written by the author with ID 5. To get all comments on posts written by author John Doe we would have to do the following if we'd use a full referencing approach:
- Find out what the ID is of "John Doe": `db.authors.find({name: "John Doe"})`. Let's say that this returns the document `{id: 8, name: "John Doe", twitter: "JohnDoe18272"}`.
- Find all blog entries written by him: `db.blog_entries.find({author_id: 8})`. Let's say that this returns the following list of blog posts:

{% highlight json %}
[{id: 26, author_id: 8, date: 2020-08-17,
  title: "A nice vacation", text: "..."},
 {id: 507, author_id: 8, date: 2020-08-23,
  title: "How I broke my leg", text: "..."}]
{% endhighlight %}

- Find all the comments that are linked to one of these posts: `db.comments.find({blog_entry_id: [26,507]})`.

As you can see, we need 3 different queries to get that information, which means that the database is accessed 3 times. In contrast, with embedding all the relevant information can be extracted with just a single query. Let's say that information is stored like this:
{% highlight json %}
[{id: 26, author: { name: "John Doe", twitter: "JohnDoe18272" },
  date: 2020-08-17,
  title: "A nice vacation", text: "...",
  comments: [ {date: ..., author: {...},
              {date: ..., author: {...}}
  ]},
 {id: 507, author: { name: "John Doe", twitter: "JohnDoe18272" },
  date: 2020-08-23,
  title: "How I broke my leg", text: "...",
  comments: [ {date: ..., author: {...},
              {date: ..., author: {...}}
  ]},
  {id: 507, author: { name: "Superman", twitter: "Clark" },
   date: 2020-09-03,
   title: "A view from the sky", text: "...",
   comments: [ {date: ..., author: {...},
               {date: ..., author: {...}}
   ]},
   ...
]
{% endhighlight %}

Now to get all comments on posts written by John Doe, you only need a single query: `db.blog_entries.find({name:"John Doe"})` and therefore a single trip to the database.

BTW: Notice how the author information is duplicated in this example. Again: find a _balance_ between linking and embedding...

### Document-databases are often aggregation-oriented
This possibility for embedding makes that document databases have an aspect of aggregation-orientation to them. Whereas in RDBMS new information is pulled apart and stored in different tables, in a document database all this information can be stored together.

For example, consider a system that needs to store genotyping information. With genotyping, part of an person's DNA is read and an A, C, T or G is assigned to particular positions in the genome (single nucleotide polymorphisms or SNPs). In a relational database model, it looks like this:

![primary and foreign keys]({{ site.baseurl }}/assets/primary_foreign_keys.png)

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

To get all information for `individual_A` we need to write a join that gets information from different tables:
{% highlight sql %}
SELECT i.name, i.ethnicity, s.name, s.chromosome, s.position, g.genotype
FROM individuals i, snps s, genotypes g
WHERE i.id = g.individual_id
AND s.id = g.snp_id
AND i.name = 'individual_A';
{% endhighlight %}

In a document database, we can store this by individual, for example in a `genotype_documents` collection:

{% highlight json %}
{ id: 1, name: "individual_A", ethnicity: "caucasian",
         genotypes: [ { name: "rs12345", chromosome: 1, position: 12345, genotype: "A/A" },
                      { name: "rs9876", chromosome: 1, position: 9876, genotype: "A/G" },
                      { name: "rs28465", chromosome: 5, position: 23456, genotype: "G/T" }]}
{ id: 1, name: "individual_B", ethnicity: "caucasian",
         genotypes: [ { name: "rs12345", chromosome: 1, position: 12345, genotype: "A/C" },
                      { name: "rs9876", chromosome: 1, position: 9876, genotype: "G/G" },
                      { name: "rs28465", chromosome: 5, position: 23456, genotype: "G/G" }]}
{% endhighlight %}

In this case, it is much easier to get all information for `individual_A`. Such query could simply be: `db.genotype_documents({name: 'individual_A'})`. This is because **_all data is aggregated by individual_**.

But what if we want all genotypes that were recorded for SNP `rs9876` across all individuals? In SQL, the query would be very similar to the one for `individual_A`:
{% highlight sql %}
SELECT i.name, i.ethnicity, s.name, s.chromosome, s.position, g.genotype
FROM individuals i, snps s, genotypes g
WHERE i.id = g.individual_id
AND s.id = g.snp_id
AND s.name = 'rs9876';
{% endhighlight %}

We do however loose the advantage of the individual-centric model completely with our document database: a query (although it might look simple) will have to extract a little piece of information from every single document in the database which is extremely costly. If we knew we were going to ask this question, it'd have been better to model the data like this:

{% highlight json %}
{ id: 1, name: "rs12345", chromosome: 1, position: 12345,
         genotypes: [ { name: "individual_A", genotype: "A/A"},
                      { name: "individual_B", genotype: "A/C"} ] },
{ id: 1, name: "rs9876", chromosome: 1, position: 9876,
         genotypes: [ { name: "individual_A", genotype: "A/G"},
                      { name: "individual_B", genotype: "G/G"} ] },
{ id: 1, name: "rs28465", chromosome: 1, position: 23456,
         genotypes: [ { name: "individual_A", genotype: "G/T"},
                      { name: "individual_B", genotype: "G/G"} ] }
{% endhighlight %}

So do you model your data by individual or by SNP? That depends...

- If you know beforehand that you'll be querying by individual and not by SNP, use the first version.
- If by SNP, use the latter.
- You could model in a similar way as the relational database with separate collections for `individuals`, `snps` and `genotypes`. In other words: using linking rather than embedding.
- You could do _both_, but not as the master dataset. In this case, you have a master dataset from which you recalculate these two different versions of the same data on a regular basis (daily, weekly, ..., depending on the update frequency). This latter approach fits in the Lambda Architecture that we'll talk about later.

## Homogeneous vs heterogeneous collections
Now should every collection be about one specific thing, or not? Above, we asked the question if every concept should be separate in their own collection or if we want to embed information, or if we want to merge different objects into a single document. Still, the documents within a collection would still be the same. Whether or not we embed the author information in the blog entries, the `blog_entries` collection is still about blog entries.

This is however not mandatory, and nothing keeps you from putting all kinds of documents all together in the same collection. Consider the example of a large multi-day conference with many speakers, who hold different talks in different rooms.

### Homogeneous design
In a homogeneous design, we put our speakers, rooms and talks in different collections:

_speakers_
{% highlight json %}
[ { id: 1, name: "John Doe", twitter: "JohnDoe18272" },
  { id: 2, name: "Superman", twitter: "Clark" },
  ... ]
{% endhighlight %}

_rooms_
{% highlight json %}
[ { id: 1, name: "1st floor left", floor: 1, capacity: 80},
  { id: 2, name: "lecture hall 2", floor: 1, capacity: 200},
  ... ]
{% endhighlight %}

_talks_
{% highlight json %}
[ { id: 1, speaker_id: 1, room_id: 4, time: "10am", title: "Fun with deep learning" },
  { id: 2, speaker_id: 1, room_id: 2, time: "2pm", title: "How I solved world hunger"},
  ... ]
{% endhighlight %}

### Heterogeneous design
The above is a perfectly valid approach for storing this type of data. In some cases, however, you might anticipate that you often want to have information from different types. Let's say that you expect to want to find everything that is related to room 4. In the above setup, you'd have to run 3 different queries; one for each collection.

Another approach is to actually put all that information together. To make sure that we can still query specific types of information (e.g. just the speakers), let's add an additional key `type` (can be anything). Let's call the collection `agenda`:

{% highlight json %}
[ { id: 1, type: "speaker", speaker_id: 1, name: "John Doe", twitter: "JohnDoe18272" },
  { id: 2, type: "speaker", speaker_id: 2, name: "Superman", twitter: "Clark" },
  { id: 3, type: "room", room_id: 1, name: "1st floor left", floor: 1, capacity: 80},
  { id: 4, type: "room", room_id: 2, name: "lecture hall 2", floor: 1, capacity: 200},
  { id: 5, type: "talk", speaker_id: 1, room_id: 4, time: "10am", title: "Fun with deep learning" },
  { id: 6, type: "talk", speaker_id: 1, room_id: 2, time: "2pm", title: "How I solved world hunger"},
  ... ]
{% endhighlight %}

Now to get all information available for room with ID 2, we just get `db.agenda.find({room_id: 2})` which will return speakers, rooms and talks:
{% highlight json %}
[ { id: 4, type: "room", room_id: 2, name: "lecture hall 2", floor: 1, capacity: 200},
  { id: 6, type: "talk", speaker_id: 1, room_id: 2, time: "2pm", title: "How I solved world hunger"},
  ... ]
{% endhighlight %}

To just get the talks that are given in that room (so not the room itself) we just add the additional constraint on `type`: `db.agenda.find({room_id: 2, type: "talk"})`.

<small><i>Source of some of this information: Ryan Crawcour & David Makogon</i></small>

{% include custom/series_nosql_next.html %}
