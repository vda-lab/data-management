---
title: Data modelling
keywords: nosql
sidebar: nosql_sidebar
toc: true
permalink: nosql-document-databases-data-modelling.html
folder: nosql
---
<!-- see https://www.youtube.com/watch?v=yuPjoC3jmPA -->

{% include custom/series_nosql_previous.html %}

## Think about how you will use the data
The starting point for modelling your data is different between an RDBMS and a document database. With an RDBMS, you typically start from the _data_; with a document database, you typically start from the _application_.

Think about how we will use the data, and how they will be accessed. Consider, for example, a movie dataset with actors and movies. For each actor we have their name , date of birth and the movies they acted in. For each movie, we have the title, release year, and tagline. There are different ways in which we can model this data in a document database, depending on what the intended use will be. So what do you want to _do_ with this data? Do you want to answer questions about the actors? Or about the movies?

So the two obvious approaches are _movie-centric_
{% highlight json %}
{ movie: "As Good As It Gets",
  released: 1997,
  tagline: "A comedy from the heart that goes for the throat",
  actors: [{ name: "Jack Nicholson", born: 1937 },
           { name: "Cuba Gooding Jr.", born: 1968 },
           { name: "Helen Hunt", born: 1963 },
           { name: "Greg Kinnear", born: 1963 }]},
{ movie: "A Few Good Men",
  released: 1992,
  tagline: "In the heart of the nation's capital, ...",
  actors: [{ name: "Jack Nicholson", born: 1937 },
           { name: "Demi Moore", born: 1962 },
           { name: "Cuba Gooding Jr.", born: 1968 },
           { name: "Tom Cruise", born: 1962 }]}
{% endhighlight %}

or _actor-centric_:

{% highlight json %}
{ name: "Jack Nicholson", born: 1937,
  movies: [{ name: "As Good As It Gets", released: 1997,
             tagline: "A comedy from the heart that goes for the throat" },
           { name: "A Few Good Men", released: 1992,
             tagline: "In the heart of the nation's capital, ..."}]},
{ name: "Cuba Gooding Jr.", born: 1968,
  movies: [{ name: "As Good As It Gets", released: 1997,
             tagline: "A comedy from the heart that goes for the throat" },
           { name: "A Few Good Men", released: 1992,
             tagline: "In the heart of the nation's capital, ..."},
           { name: "What Dreams May Come", released: 1998,
             tagline: "After life there is more. The end is just the beginning."}]},
{ name: "Tom Cruise", born: 1962,
  movies: [{ name: "A Few Good Men", released: 1992,
             tagline: "In the heart of the nation's capital, ..."},
           { name: "Jerry Maguire", released: 2000,
             tagline: "The rest of his life begins now."}]}
{% endhighlight %}

Searching using an actor-centric query in a movie-centric database will be very inefficient. If we want to know in how movies Jack Nicholson played using the first approach above, we have to go through _all_ documents and check which has him mentioned in the list of actors. Using the second approach above, we only have to get the single document about him and we have all the information.

Another option is to use _links_ or _references_. The `actors` collection could then be:
{% highlight json %}
{ _key: "JNich", name: "Jack Nicholson", born: 1937,
                 movies ["AGAIG","AFGM"]}
{ _key: "TCrui", name: "Tom Cruise", born: 1962,
                 movies: ["AFGM","JM"]}
{% endhighlight %}

and the `movies` collection:
{% highlight json %}
{ _key: "AGAIG", title: "As Good As It Gets", release: 1997,
                tagline: "A comedy from the heart that goes for the throat",
                actors: ["JNich", "CGood", "HHunt", "GKinn"]},
{ _key: "AFGM", title: "A Few Good Men", release: 1992,
                tagline: "In the heart of the nation's capital, ...",
                actors: ["JNich", "DMoor", "CGood", "TCrui"]}
{% endhighlight %}

In this case the `movies` or `actors` key in the document refers to the `_key` in the other collection.

The above are just some of the ways to model your data. Below, we'll go deeper into how you can approach different types of relationships between documents.

## Relationships between documents
So when do you embed, and when do you reference?

<!-- check https://www.youtube.com/embed/leNCfU5SYR8?version=3&rel=1&fs=1&autohide=2&showsearch=0&showinfo=1&iv_load_policy=1&wmode=transparent -->

### 1-to-1 relationships
If you have a 1-to-1 relationship, just add a key-value pair in the document. For example, an individual having only a single twitter account would just have that account added as a key-value pair:

{% highlight json %}
{ name: "Elon Musk",
  born: 1971,
  twitter: "@elonmusk" }
{% endhighlight %}

![]({{site.baseurl}}/assets/musk_twitter.png)

### 1-to-few relationships
If you have a 1-to-few relationship (i.e. a 1-to-many where the "many" is not "too many"), it's easiest to _embed_ the information in a list. For example for Elon Musk's citizenships:

{% highlight json %}
{ name: "Elon Musk",
  born: 1971,
  twitter: "@elonmusk",
  citizenships: [
    { country: "South Africa", since: 1971 },
    { country: "Canada", since: 1971 },
    { country: "USA", since: 2002 }
  ]}
{% endhighlight %}

### 1-to-many relationships
The above works as long as you don't have thousands of elements in such an array. Consider a car; which apparently on average consists of 30,000 parts. We don't want to store all information for each parts in a huge array. Because each element in that array will have information like it's name, number, cost, provider, how many we need, etc. In this case, we can choose to use _references_ instead of embedding.

![]({{site.baseurl}}/assets/carparts.jpg)

`cars` collection:
{% highlight json %}
{ _key: "car1",
  name: "left-handed Tesla Model S",
  manufacturer: "Tesla",
  catalog_number: 12345,
  parts: ["p1","p3","p17",...]}
{% endhighlight %}

`parts` collection:
{% highlight json %}
{ _key: "p1",
  partno: "123-ABC-987",
  name: "nr 4 bolt",
  qty: 105,
  cost: 0.54 },
{ _key: "p3",
  partno: "826-CKW-732",
  name: "nr 6 grommet",
  qty: 68,
  cost: 0.52 },
...
{% endhighlight %}

### 1-to-immense relationships
This works fine, until you're in the situation where you have a huge number of elements. You should _never_ use an array that is basically unbounded, so that grows really big. For example, think about sensors that store information every second, or server logs.

{% highlight json %}
{ id: "server_17",
  location: "server room 2",
  messages: [
    { date: "Oct 14 07:50:29",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    { date: "Oct 14 07:50:35",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    { date: "Oct 14 07:50:37",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    { date: "Oct 14 07:50:39",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    { date: "Oct 14 07:50:39",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    { date: "Oct 14 07:50:42",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    { date: "Oct 14 07:50:39",
      message: "Failed to bootstrap path  /System/Library, error = 2: No such file or directory" },
    { date: "Oct 14 07:50:43",
      message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
    ...
  ]}
{% endhighlight %}

A better approach here is to use a _reverse reference_, where the _host_ is referenced. That brings the log messages themselves first-grade documents.

`servers` collection:
{% highlight json %}
{ id: "server_17",
  location: "server room 2" }
{% endhighlight %}

`logs` collections:
{% highlight json %}
{ date: "Oct 14 07:50:29", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:35", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:37", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:39", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:39", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:42", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
{ date: "Oct 14 07:50:39", host: "server_17",
  message: "Failed to bootstrap path  /System/Library, error = 2: No such file or directory" },
{ date: "Oct 14 07:50:43", host: "server_17",
  message: "com.apple.xpc.launchd[1] <Notice>: Service exited due to SIGKILL" },
...
{% endhighlight %}

### many-to-many relationships
A possible approach to follow with many-to-many relationships is to create _reciprocal references_: the links are present twice. For example, authors and books: a single author can write multiple books; a single book can have multiple authors.

`books` collection:
{% highlight json %}
{ id: "go", ISBN13: "9780060853983",
  title: "Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch",
  authors: ["tprat","ngaim"] },
{ id: "gp", ISBN13: "9780060502935",
  title: "Going Postal (Discworld #33)",
  authors: ["tprat"] },
{ id: "sg", ISBN13: "9780552152976",
  title: "Small Gods (Discworld #13)",
  authors: ["tprat"] },
{ id: "tsa", ISBN13: "9780060842352",
  title: "The Stupidest Angel: A Heartwarming Tale of Christmas Terror",
  authors: ["cmoor"] }
{% endhighlight %}

`authors` collection:
{% highlight json %}
{ id: "tprat", name: "Terry Pratchett", books: ["go","gp","sg"] },
{ id: "ngaim", name: "Neil Gaiman", books: ["go"] },
{ id: "cmoor", name: "Christopher Moore", books: ["tsa"] }
{% endhighlight %}

**Big word of caution**: This approach can quickly lead to inconsistencies if not handled well. What if an author has written a certain book, but that book does not mention that author?

Another option is to use a collection specific for the links, similar to a linking table in an RDBMS:

`books` collection:
{% highlight json %}
{ id: "go", ISBN13: "9780060853983",
  title: "Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch" },
{ id: "gp", ISBN13: "9780060502935",
  title: "Going Postal (Discworld #33)" },
{ id: "sg", ISBN13: "9780552152976",
  title: "Small Gods (Discworld #13)" },
{ id: "tsa", ISBN13: "9780060842352",
  title: "The Stupidest Angel: A Heartwarming Tale of Christmas Terror" }
{% endhighlight %}

`authors` collection:
{% highlight json %}
{ id: "tprat", name: "Terry Pratchett" },
{ id: "ngaim", name: "Neil Gaiman" },
{ id: "cmoor", name: "Christopher Moore" }
{% endhighlight %}

`authorships` collection:
{% highlight json %}
{ author: "tprat", book: "go" },
{ author: "tprat", book: "gp" },
{ author: "tprat", book: "sg" },
{ author: "ngaim", book: "go" },
{ author: "cmoor", book: "tsa" },
{% endhighlight %}

### Other considerations
#### Use embedding for...
- _things that are queried together should be stored together_. In the blog example, it will be uncommon that you'd want to have a list of comments without them being linked to the blog entry itself. In this case, the comments can be embedded in the blog entry.
- _things with similar volatility_ (i.e. their rate of change is similar). For example, an `author` can have several social IDs on Facebook, Linkedin, Twitter, etc. These things will not change a lot so it makes sense to store them _inside_ the `author` document, rather than having a separate collection `social_networks` and link the information between documents.
- _set of values or subdocuments that are bounded_ (1-to-few relationship). For example, the number of tags for a blog entry will not be immense, and be static so we can embed that.

Data embedding has several advantages:
- The embedded objects are returned in the same query as the parent object, meaning that only 1 trip to the database is necessary. In the example above, if you'd query for a blog entry, you get the comments and tags with it for free.
- Objects in the same collection are generally stored sequentially on disk, leading to fast retrieval.
- If the document model matches your domain, it is much easier to understand than a normalised relational database.

#### Use referencing for...
- _1-to-many relationships_. For example, a single author can write multiple blog posts. We don't want to copy the author's name, email, social network usernames, picture, etc into every single blog entry.
- _many-to-many relationships_. What is a single author has written multiple blog posts, and blog posts can be co-written by many authors?
- _related data that changes with different volatility_. Let's say that we also record "likes" and "shares" for blog posts. That information is much less important and changes much quicker than the blog entry itself. Instead of constantly updating the blog document, it's safer to keep this outside.

Typically you would _combine embedding and referencing_.

## Conclusion
Data modelling in document-oriented databases is _not_ straightforward and there is no single solution. It all depends on what you want to do. This is different from data modelling in RDBMS where you can work towards a normalised database schema.

{% include custom/series_nosql_next.html %}
