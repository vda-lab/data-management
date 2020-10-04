---
title: Improving performance
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-arangodb-improving-performance.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

As with any other database system, the actual setup of your database and how you write your query can have a huge impact on how fast the query runs.

## Indices
Consider the following query which returns all flights of the plane with tail number "N937AT".

{% highlight sql %}
FOR f IN flights
FILTER f.TailNum == 'N937AT'
RETURN f
{% endhighlight %}

This takes more than 3 seconds to run. If we _explain_ this query (click the "Explain" button instead of "Execute"), we see the following:
{% highlight sql %}
Query String:
 FOR f IN flights
 FILTER f.TailNum == 'N937AT'
 RETURN f

Execution plan:
 Id   NodeType                    Est.   Comment
  1   SingletonNode                  1   * ROOT
  2   EnumerateCollectionNode   286463     - FOR f IN flights   /* full collection scan */
  3   CalculationNode           286463       - LET #1 = (f.`TailNum` == "N937AT")   /* simple expression */   /* collections used: f : flights */
  4   FilterNode                286463       - FILTER #1
  5   ReturnNode                286463       - RETURN f

Indexes used:
 none

Optimization rules applied:
 none
{% endhighlight %}

We see that the query loops over all 286463 documents and checks for each if its `TailNum` is equal to `N937AT`. This is very expensive, as a _profile_ (Click the "Profile" button) also shows:
{% highlight sql %}
Query String:
 FOR f IN flights
 FILTER f.TailNum == 'N937AT'
 RETURN f

Execution plan:
 Id   NodeType                  Calls    Items   Runtime [s]   Comment
  1   SingletonNode                 1        1       0.00000   * ROOT
  2   EnumerateCollectionNode     287   286463       1.03926     - FOR f IN flights   /* full collection scan */
  3   CalculationNode             287   286463       0.10772       - LET #1 = (f.`TailNum` == "N937AT")   /* simple expression */   /* collections used: f : flights */
  4   FilterNode                    1       86       0.17727       - FILTER #1
  5   ReturnNode                    1       86       0.00000       - RETURN f

Indexes used:
 none

Optimization rules applied:
 none

Query Statistics:
 Writes Exec   Writes Ign   Scan Full   Scan Index   Filtered   Exec Time [s]
           0            0      286463            0     286377         1.32650

Query Profile:
 Query Stage           Duration [s]
 initializing               0.00000
 parsing                    0.00012
 optimizing ast             0.00000
 loading collections        0.00001
 instantiating plan         0.00007
 optimizing plan            0.00106
 executing                  1.32438
 finalizing                 0.00050
{% endhighlight %}

What we should do here, is create an index on `TailNum`. This will allow the system to pick those documents that match a certain tail number from a hash rather than having to check every single document. To create an index, go to `Collections`, and click on the `flights` collection. At the top you'll see `Indexes`.

<img src="{{ site.baseurl }}/assets/arangodb_indices_1.png" width="600px" />

We'll want to create a persistent index with the following settings (i.e. tail number is not unique across all flights, and is not sparse (in other words: tail number is almost always provided)):

<img src="{{ site.baseurl }}/assets/arangodb_indices_2.png" width="400px" />

After creating the index, an _explain_ shows that we are not doing a full collection scan anymore:
{% highlight sql %}
Query String:
 FOR f IN flights
 FILTER f.TailNum == 'N937AT'
 RETURN f

Execution plan:
 Id   NodeType        Est.   Comment
  1   SingletonNode      1   * ROOT
  6   IndexNode         60     - FOR f IN flights   /* persistent index scan */
  5   ReturnNode        60       - RETURN f

Indexes used:
 By   Name      Type         Collection   Unique   Sparse   Selectivity   Fields          Ranges
  6   TailNum   persistent   flights      false    false         1.66 %   [ `TailNum` ]   (f.`TailNum` == "N937AT")

Optimization rules applied:
 Id   RuleName
  1   use-indexes
  2   remove-filter-covered-by-index
  3   remove-unnecessary-calculations-2
{% endhighlight %}

And indeed, running _profile_ gives consistent results:
{% highlight sql %}
Query String:
 FOR f IN flights
 FILTER f.TailNum == 'N937AT'
 RETURN f

Execution plan:
 Id   NodeType        Calls   Items   Runtime [s]   Comment
  1   SingletonNode       1       1       0.00000   * ROOT
  6   IndexNode           1      86       0.00282     - FOR f IN flights   /* persistent index scan */
  5   ReturnNode          1      86       0.00000       - RETURN f

Indexes used:
 By   Name      Type         Collection   Unique   Sparse   Selectivity   Fields          Ranges
  6   TailNum   persistent   flights      false    false         1.66 %   [ `TailNum` ]   (f.`TailNum` == "N937AT")

Optimization rules applied:
 Id   RuleName
  1   use-indexes
  2   remove-filter-covered-by-index
  3   remove-unnecessary-calculations-2

Query Statistics:
 Writes Exec   Writes Ign   Scan Full   Scan Index   Filtered   Exec Time [s]
           0            0           0           86          0         0.00327

Query Profile:
 Query Stage           Duration [s]
 initializing               0.00000
 parsing                    0.00009
 optimizing ast             0.00001
 loading collections        0.00001
 instantiating plan         0.00003
 optimizing plan            0.00016
 executing                  0.00287
 finalizing                 0.00009
{% endhighlight %}


With the index, our query is 406 times faster. Instead of going over all 286463 documents in the original version, now it only checks 86.

## Avoid going over supernodes
(Note: the following is largely based on the white paper "Switching from Relational Databases to ArangoDB" available at [https://www.arangodb.com/arangodb-white-papers/white-paper-switching-relational-database/](https://www.arangodb.com/arangodb-white-papers/white-paper-switching-relational-database/))

_Super nodes_ are nodes in a graph with very high connectivity. Queries that touch those nodes will have to follow all those edges. Consider a database with songs information that is modelled like this:

<img src="{{ site.baseurl }}/assets/arangodb_songs.png" width="600px" /><br/>
<small>Source: White paper mentioned above</small>


There are 4 document collections (`Song`, `Artist`, `Album` and `Genre`), and 3 edge collections (`Made`, `PartOf` and `Has`).

Some of Aerosmith's data might look like this:

<img src="{{ site.baseurl }}/assets/arangodb_aerosmith.png" width="400px" /><br/>
<small>Source: White paper mentioned above</small>

Suppose that we want to answer this question: "“I just listened to a song called, Tribute and I liked it very much. I suspect that there may be other songs of the same genre as this song that I might enjoy. So, I want to find all of the albums of the same genre that were released in the same year". Here's a first stab at such query.

Version 1:
{% highlight sql %}
FOR s IN Song
  FILTER s.Title == "Tribute"
  // We want to find a Song called Tribute
    FOR album IN 1 INBOUND s PartOf
    // Now we have the Album this Song is released on
      FOR genre IN 1 OUTBOUND album Has
      // Now we have the genre of this Album
        FOR otherAlbum IN 1 INBOUND genre Has
        // All other Albums with this genre
          FILTER otherAlbum.year == album.year
          // Only keep those where the year is identical
            RETURN otherAlbum
{% endhighlight %}

<img src="{{ site.baseurl }}/assets/supernode_1.png" width="600px" />

All goes well until we hit `FOR otherAlbum IN 1 INBOUND genre Has`, because at that point it will follow all links to the albums of that genre. It's therefore better to first select all albums of the same year, and _filter_ for the genre. This way we'll only get a limited number of albums, and each of them has only one genre.

Version 2:
{% highlight sql %}
FOR s IN Song
  FILTER s.Title == "Tribute"
  // We want to find a Song called Tribute
    FOR album IN 1 INBOUND s PartOf
    // Now we have the Album this Song is released on
      FOR genre IN 1 OUTBOUND album Has
      // Get the genres of this Album
        FOR otherAlbum IN Album
        // Now we want all other Albums of the same year
          FILTER otherAlbum.Year == album.Year
          // So here we join album with album based on identical year
            FOR otherGenre IN 1 OUTBOUND otherAlbum Has
              FILTER otherGenre == genre
              // Validate that the genre of the other album is identical
              // to the genre of the original album
                RETURN otherAlbum
                // Finally return all albums of the same year
                // with the same genre
{% endhighlight %}

<img src="{{ site.baseurl }}/assets/supernode_2.png" width="600px" />

Again, a look at _explain_ helps a lot here.

{% include custom/series_nosql_next.html %}
