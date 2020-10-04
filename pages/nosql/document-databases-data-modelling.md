---
title: Data modelling
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-document-databases-data-modelling.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

When modelling data in a relational database, we typically try to create a _normalised database schema_. In such schema, different concepts are stored in different tables, and information is linked by referencing rows in different tables.

Consider the example of a blog. This information concerns different concepts: the blog itself, posts on that blog, authors, comments, and tags. This can be modelled like this in a relational database:

<img src="{{ site.baseurl }}/assets/blog_rdbms_schema.png" width="300px"/>


Each concept is stored in a separate table. To get all comments on posts written by John Doe, we can do this (we won't go into actual schemas here):
```SQL
SELECT c.date, c.comment
FROM authors a, blog_entries b, comments c
WHERE a.id = b.author_id
AND b.id = c.entry_id
AND a.name = "John Doe";
```

In document databases, we have to find a balance between _embedding_ and _referencing_.

## Embedding vs referencing
On the one extreme end, we can follow the same approach as in relational databases, and create a separate collection for each concept. So there would be a collection for `blogs`, one for `blog_entries`, for `authors`, for `comments` and `tags`. At the other extreme end, we can _embed_ some of this information. For example, a single blog entry can have the author name and email, the comments and tags _inside_ it.

A referencing-heavy approach:

<img src="{{ site.baseurl }}/assets/joining.png" width="300px"/>

A mixed reference-embed approach:

<img src="{{ site.baseurl }}/assets/linking-embedding.png" width="400px"/>

Now how do we decide if we should embed or reference data? The following points can help in that decision, but it should be clear that these are _not_ strict rules and everything depends on the use case.

### Use embedding for...
- _things that are queried together should be stored together_. In the blog example, it will be uncommon that you'd want to have a list of comments without them being linked to the blog entry itself. In this case, the comments can be embedded in the blog entry.
- _things with similar volatility_ (i.e. their rate of change is similar). For example, an `author` can have several social IDs on Facebook, Linkedin, Twitter, etc. These things will not change a lot so it makes sense to store them _inside_ the `author` document, rather than having a separate collection `social_networks` and link the information between documents.
- _set of values or subdocuments that are bounded_ (1-to-few relationship). For example, the number of tags for a blog entry will not be immense, and be static so we can embed that.

Data embedding has several advantages:
- The embedded objects are returned in the same query as the parent object, meaning that only 1 trip to the database is necessary. In the example above, if you'd query for a blog entry, you get the comments and tags with it for free.
- Objects in the same collection are generally stored sequentially on disk, leading to fast retrieval.
- If the document model matches your domain, it is much easier to understand than a normalised relational database.
- Embedding typically has better read performance.

### Use referencing for...
- _1-to-many relationships_. For example, a single author can write multiple blog posts. We don't want to copy the author's name, email, social network usernames, picture, etc into every single blog entry.
- _many-to-many relationships_. What is a single author has written multiple blog posts, and blog posts can be co-written by many authors?
- _related data that changes with different volatility_. Let's say that we also record "likes" and "shares" for blog posts. That information is much less important and changes much quicker than the blog entry itself. Instead of constantly updating the blog document, it's safer to keep this outside.

Referencing often has better write performance.

Typically you would _combine embedding and referencing_.

### On cross-collection queries
In many document database-implementations (e.g. mongodb) it is not possible to query across collections, which can make using referenced data much more difficult. A query in mongodb, for example, will look like this (don't worry about the exact syntax; it should be clear what this tries to do):
```json
db.comments.find({author_id: 5})
```
This will return all comments written by the author with ID 5. To get all comments on posts written by author John Doe we would have to do the following if we'd use a full referencing approach:
- Find out what the ID is of "John Doe": `db.authors.find({name: "John Doe"})`. Let's say that this returns the document `{id: 8, name: "John Doe", twitter: "JohnDoe18272"}`.
- Find all blog entries written by him: `db.blog_entries.find({author_id: 8})`. Let's say that this returns the following list of blog posts:

```json
[{id: 26,
  author_id: 8,
  date: 2020-08-17,
  title: "A nice vacation",
  text: "..."},
 {id: 507,
  author_id: 8,
  date: 2020-08-23,
  title: "How I broke my leg",
  text: "..."}]
```

- Find all the comments that are linked to one of these posts: `db.comments.find({blog_entry_id: [26,507]})`.

As you can see, we need 3 different queries to get that information, which means that the database is accessed 3 times. In contrast, with embedding all the relevant information can be extracted with just a single query. Let's say that information is stored like this:
```json
[{id: 26,
  author: {
    name: "John Doe",
    twitter: "JohnDoe18272"
  },
  date: 2020-08-17,
  title: "A nice vacation",
  text: "...",
  comments: [
    {date: ...,
     author: {...},
    {date: ...,
     author: {...}}
  ]},
 {id: 507,
   author: {
     name: "John Doe",
     twitter: "JohnDoe18272"
   },
  date: 2020-08-23,
  title: "How I broke my leg",
  text: "...",
  comments: [
    {date: ...,
     author: {...},
    {date: ...,
     author: {...}}
  ]},
  {id: 507,
    author: {
      name: "Superman",
      twitter: "Clark"
    },
   date: 2020-09-03,
   title: "A view from the sky",
   text: "...",
   comments: [
     {date: ...,
      author: {...},
     {date: ...,
      author: {...}}
   ]},
   ...
]
```
Now to get all comments on posts written by John Doe, you only need a single query: `db.blog_entries.find({name:"John Doe"})` and therefore a single trip to the database.

BTW: Notice how the author information is duplicated in this example. Again: find a _balance_ between linking and embedding...

## Homogeneous vs heterogeneous collections
Now should every collection be about one specific thing, or not? Above, we asked the question if every concept should be separate in their own collection or if we want to embed information, or if we want to merge different objects into a single document. Still, the documents within a collection would still be the same. Whether or not we embed the author information in the blog entries, the `blog_entries` collection is still about blog entries.

This is however not mandatory, and nothing keeps you from putting all kinds of documents all together in the same collection. Consider the example of a large multi-day conference with many speakers, who hold different talks in different rooms.

### Homogeneous design
In a homogeneous design, we put our speakers, rooms and talks in different collections:

_speakers_
```json
[ { id: 1,
    name: "John Doe",
    twitter: "JohnDoe18272" },
  { id: 2,
    name: "Superman",
    twitter: "Clark" },
  ... ]
```

_rooms_
```json
[ { id: 1,
    name: "1st floor left",
    floor: 1,
    capacity: 80},
  { id: 2,
    name: "lecture hall 2",
    floor: 1,
    capacity: 200},
  ... ]
```

_talks_
```json
[ { id: 1,
    speaker_id: 1,
    room_id: 4,
    time: "10am",
    title: "Fun with deep learning" },
  { id: 2,
    speaker_id: 1,
    room_id: 2,
    time: "2pm",
    title: "How I solved world hunger"},
  ... ]
```

### Heterogeneous design
The above is a perfectly valid approach for storing this type of data. In some cases, however, you might anticipate that you often want to have information from different types. Let's say that you expect to want to find everything that is related to room 4. In the above setup, you'd have to run 3 different queries; one for each collection.

Another approach is to actually put all that information together. To make sure that we can still query specific types of information (e.g. just the speakers), let's add an additional key `type` (can be anything). Let's call the collection `agenda`:

```json
[ { id: 1,
    type: "speaker",
    speaker_id: 1,
    name: "John Doe",
    twitter: "JohnDoe18272" },
  { id: 2,
    type: "speaker",
    speaker_id: 2,
    name: "Superman",
    twitter: "Clark" },
  { id: 3,
    type: "room",
    room_id: 1,
    name: "1st floor left",
    floor: 1,
    capacity: 80},
  { id: 4,
    type: "room",
    room_id: 2,
    name: "lecture hall 2",
    floor: 1,
    capacity: 200},
  { id: 5,
    type: "talk",
    speaker_id: 1,
    room_id: 4,
    time: "10am",
    title: "Fun with deep learning" },
  { id: 6,
    type: "talk",
    speaker_id: 1,
    room_id: 2,
    time: "2pm",
    title: "How I solved world hunger"},
  ... ]
```

Now to get all information available for room with ID 2, we just get `db.agenda.find({room_id: 2})` which will return speakers, rooms and talks:
```json
[ { id: 4,
    type: "room",
    room_id: 2,
    name: "lecture hall 2",
    floor: 1,
    capacity: 200},
  { id: 6,
    type: "talk",
    speaker_id: 1,
    room_id: 2,
    time: "2pm",
    title: "How I solved world hunger"},
  ... ]
```

To just get the talks that are given in that room (so not the room itself) we just add the additional constraint on `type`: `db.agenda.find({room_id: 2, type: "talk"})`.

<small><i>Source of some of this information: Ryan Crawcour & David Makogon</i></small>

{% include custom/series_nosql_next.html %}
