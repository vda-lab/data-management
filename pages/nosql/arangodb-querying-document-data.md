---
title: Querying document data
keywords: nosql
sidebar: nosql_sidebar
toc: true
permalink: nosql-arangodb-querying-document-data.html
folder: nosql
---

Having stored our data in the `airports` and `flights` collections, we can query these in the `Query` section. An overview of the possible high-level operations can be found here: [https://www.arangodb.com/docs/stable/aql/operations.html](https://www.arangodb.com/docs/stable/aql/operations.html). From that website:

- `FOR`: Iterate over a collection or View, all elements of an array or traverse a graph
- `RETURN`: Produce the result of a query.
- `FILTER`: Restrict the results to elements that match arbitrary logical conditions.
- `SEARCH`: Query the (full-text) index of an ArangoSearch View
- `SORT`: Force a sort of the array of already produced intermediate results.
- `LIMIT`: Reduce the number of elements in the result to at most the specified number, optionally skip elements (pagination).
- `LET`: Assign an arbitrary value to a variable.
- `COLLECT`: Group an array by one or multiple group criteria. Can also count and aggregate.

We'll go over some of these below.

Note: When in the following section I write something like "equivalent in SQL" with an actual SQL query, this will actually be hypothetical. In other words: you cannot run that actual query on the ArangoDB database as that would not work. It _would_ work if you'd first make an SQL database (e.g. using sqlite as seen in the previous session) and created the necessary tables and rows...

## `RETURN`ing a result
The most straightforward way to get a document is to select it by key. When doing this, you have to prepend the key with the name of the collection:

{% highlight sql %}
RETURN DOCUMENT("airports/JFK")
{% endhighlight %}

The above basically treats the ArangoDB database as a key/value store.

You can also get multiple documents if you provide an array of keys instead of a single one:
{% highlight sql %}
RETURN DOCUMENT(["airports/JFK","airports/03D"])
{% endhighlight %}
Notice the square brackets around the keys!

## `FOR`: Looping over all documents
Remember that in SQL, a query looked like this:
{% highlight sql %}
SELECT state
FROM airports
WHERE lat > 35;
{% endhighlight %}

SQL is a _declarative_ language, which means that you tell the RDBMS _what_ you want, not _how_ to get it. This is not exactly true for AQL, which does need you to specify that you want to loop over all documents. The same query as the SQL one above in AQL would be:
{% highlight sql %}
FOR a IN airports
  FILTER a.lat > 35
  RETURN a
{% endhighlight %}

Similarly, the minimal SQL query is:
{% highlight sql %}
SELECT * FROM airports;
{% endhighlight %}

, whereas the minimal AQL query is:
{% highlight sql %}
FOR a IN airports
  RETURN a
{% endhighlight %}

You can nest `FOR` statements, in which case you'll get the cross project:
{% highlight sql %}
FOR a IN [1,2,3]
  FOR b IN [10,20,30]
    RETURN [a, b]
{% endhighlight %}

This will return:
{% highlight csv %}
1  10
2  10
3  10
1  20
2  20
3  20
1  30
2  30
3  30
{% endhighlight %}

If you don't want to return the whole document, you can specify this in the `RETURN` statement. This is called a _projection_. For example:
{% highlight sql %}
FOR a IN airports
  RETURN a.name
{% endhighlight %}

or

{% highlight sql %}
FOR a IN airports
  RETURN { "name": a.name, "state": a.state }
{% endhighlight %}

This is equivalent to specifying the column names in an SQL query:

{% highlight sql %}
SELECT name, state
FROM airports;
{% endhighlight %}

## Returning only `DISTINCT` results
{% highlight sql %}
FOR a IN airports
  RETURN DISTINCT a.state
{% endhighlight %}


## `FILTER`ing documents
Data can be filtered using `FILTER`:
{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  RETURN a
{% endhighlight %}

To combine different filters, you can use `AND` and `OR`:
{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  AND a.vip == true
  RETURN a
{% endhighlight %}

{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  OR a.vip == true
  RETURN a
{% endhighlight %}

It is often recommended to use parentheses to clarify the order of the filters:
{% highlight sql %}
FOR a IN airports
  FILTER ( a.state == 'CA' OR a.vip == true )
  RETURN a
{% endhighlight %}

Instead of `AND`, you can also apply multiple filters consecutively:
{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  FILTER a.vip == true
  RETURN a
{% endhighlight %}

## `SORT`ing the results
{% highlight sql %}
FOR a IN airports
  SORT a.lat
  RETURN [ a.name, a.lat ]
{% endhighlight %}

As in SQL, AQL allows you do sort in descending order:
{% highlight sql %}
FOR a IN airports
  SORT a.lat DESC
  RETURN [ a.name, a.lat ]
{% endhighlight %}

## Combining different filters, limits, etc
Remember that in SQL, you can combine different filters, sortings etc.

In SQL:
{% highlight sql %}
SELECT * FROM airports
WHERE a.state = 'CA'
AND a.lat > 20
AND vip = true
SORT BY lat
LIMIT 15;
{% endhighlight %}

In AQL, the different filters, sorts, limits, etc are applied top to bottom. This means that the following two do not necessarily give the same results:
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  FILTER a.state == 'CA'
  LIMIT 5
  RETURN a
{% endhighlight %}

{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  LIMIT 5
  FILTER a.state == 'CA'
  RETURN a
{% endhighlight %}

## Functions in ArangoDB
ArangoDB includes a large collections of functions that can be run at different levels, e.g. to analyse the underlying database, to calculate aggregates like minimum and maximum from an array, to calculating the geographical distance between two locations on a map, to concatenate strings, etc. For a full list of functions see [https://www.arangodb.com/docs/stable/aql/functions.html](https://www.arangodb.com/docs/stable/aql/functions.html).

Let's have a look at some of these.

### `CONCAT` and `CONCAT_SEPARATOR`
Using `CONCAT` and `CONCAT_SEPARATOR` we can return whole strings instead of just arrays and documents.

{% highlight sql %}
FOR f IN flights
  LIMIT 10
  RETURN [f.FlightNum, f._from, f._to]
{% endhighlight %}

{% highlight sql %}
FOR f IN flights
  LIMIT 10
  RETURN CONCAT("Flight ", f.FlightNum, " departs from ", f._from, " and goes to ", f._to, ".")
{% endhighlight %}

returns
{% highlight csv %}
[
"Flight 579 departs from airports/ATL and goes to airports/CHS.",
"Flight 2895 departs from airports/CLE and goes to airports/SAT.",
"Flight 7185 departs from airports/IAD and goes to airports/CLE.",
"Flight 859 departs from airports/JFK and goes to airports/PBI.",
"Flight 5169 departs from airports/CVG and goes to airports/MHT.",
"Flight 9 departs from airports/JFK and goes to airports/SFO.",
"Flight 1831 departs from airports/MIA and goes to airports/TPA.",
"Flight 5448 departs from airports/CVG and goes to airports/GSO.",
"Flight 878 departs from airports/FLL and goes to airports/JFK.",
"Flight 680 departs from airports/TPA and goes to airports/PBI."
]
{% endhighlight %}

Something similar can be done with providing a separator. This can be useful when you're creating a comma-separated file.

{% highlight sql %}
FOR f IN flights
  LIMIT 10
  RETURN CONCAT_SEPARATOR(' -> ', f._from, f._to)
{% endhighlight %}

returns
{% highlight csv %}
[
"airports/ATL -> airports/CHS",
"airports/CLE -> airports/SAT",
"airports/IAD -> airports/CLE",
"airports/JFK -> airports/PBI",
"airports/CVG -> airports/MHT",
"airports/JFK -> airports/SFO",
"airports/MIA -> airports/TPA",
"airports/CVG -> airports/GSO",
"airports/FLL -> airports/JFK",
"airports/TPA -> airports/PBI"
]
{% endhighlight %}

### `MIN` and `MAX`
These functions do what you expect them to do. See later in this post when we're looking at [aggregation](#aggregation).

{% highlight sql %}
RETURN MAX([1,5,20,1,4])
{% endhighlight %}


## Subqueries
Remember that in SQL, we can replace the table mentioned in the `FROM` clause with a whole SQL statement, something like this:
{% highlight sql %}
SELECT COUNT(*) FROM (
  SELECT name FROM airports
  WHERE state = 'TX');
{% endhighlight %}

We can do something similar with AQL. For argument's sake, let's wrap a simple query into another one which just returns the result of the inner query:
{% highlight sql %}
FOR s IN (
    FOR a IN airports
        COLLECT state = a.state WITH COUNT INTO nrAirports
        SORT nrAirports DESC
        RETURN {
            "state" : state,
            "nrAirports" : nrAirports
        }
    )
RETURN s
{% endhighlight %}
This is exactly the same as if we would have run only the inner query. An AQL query similar to the SQL query above:

{% highlight sql %}
FOR airport IN (
    FOR a IN airports
        FILTER a.state == "TX"
        RETURN a
    )
    COLLECT WITH COUNT INTO c
    RETURN c
{% endhighlight %}

## Joining collections
It is simple enough to combine different collections, just by nesting `FOR` loops but making sure that there exits a `FILTER` in the inner loop to match up IDs. For example, to list all destination airports and distances for flights where the departure airport lies in California:

{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  FOR f IN flights
    FILTER f._from == a._id
    RETURN DISTINCT {departure: a._id, arrival: f._to, distance: f.Distance}
{% endhighlight %}

Gives:
{% highlight csv %}
airports/ACV  airports/SFO  250
airports/ACV  airports/SMF  207
airports/ACV  airports/CEC  56
...
{% endhighlight %}

(Remember from above that using links in a document setting consitute a code smell. If you're doing this a lot, check if your data should be modelled as a graph. Further down when we're talking about ArangoDB as a graph database we'll write a version of this same query that uses a graph approach.)


What if we want to show the departure and arrival airports full names instead of their codes, and have an additional filter on the arrival airport? To do this, we need an additional join with the airports table:

{% highlight sql %}
FOR a1 IN airports
  FILTER a1.state == 'CA'
  FOR f IN flights
    FILTER f._from == a1._id
    FOR a2 in airports
      FILTER a2._id == f._to
      FILTER a2.state == 'CA'
      RETURN DISTINCT {
        departure: a1.name,
        arrival: a2.name,
        distance: f.Distance }
{% endhighlight %}

This will return something like the following:
{% highlight csv %}
Arcata  San Francisco International  250
Arcata  Sacramento International     207
Arcata  Jack McNamara                 56
...
{% endhighlight %}

The above joins are inner joins, which means that we will only find the departure airports for which such arrival airports exist (see the SQL session). What if we want to list the airports in California that do not have any flights to other airports in California? In this case, put the second `FOR` loop within the `RETURN` statement:
{% highlight sql %}
FOR a1 IN airports
  FILTER a1.state == 'CA'
  RETURN {
    departure: a1.name,
    arrival: (
        FOR f IN flights
            FILTER f._from == a1._id
            FOR a2 in airports
                FILTER a2._id == f._to
                FILTER a2.state == 'CA'
                RETURN DISTINCT a2.name
                )}
{% endhighlight %}

This returns:
{% highlight csv %}
...
Buchanan         []
Jack McNamara    ["San Francisco International","Arcata"]
Chico Municipal  ["San Francisco International"]
Camarillo        []
...
{% endhighlight %}

You'll see that e.g. Buchanan and Camarillo are also listed, which was not the case before.

## Grouping
To group results, AQL provides the `COLLECT` keyword. Note that this does grouping, but no aggregation. With `COLLECT` you create a new variable that will be used for the grouping.

{% highlight sql %}
FOR a IN airports
  COLLECT state = a.state INTO airportsByState
  RETURN {
    "state" : state,
    "airports" : airportsByState
  }
{% endhighlight %}

This code goes through each airport, and _collects_ the state that it's in. It'll return a list of states with for each the list of their airports:

{% highlight json %}
[
  {
    "state": "AK",
    "airports": [
      {
        "a": {
          "_key": "0AK",
          "_id": "airports/0AK",
          "_rev": "_ZYukZZy--e",
          "name": "Pilot Station",
          "city": "Pilot Station",
          "state": "AK",
          "country": "USA",
          "lat": 61.93396417,
          "long": "Pilot Station",
          "vip": false
        }
      },
      {
        "a": {
          "_key": "15Z",
          "_id": "airports/15Z",
          "_rev": "_ZYukZa---I",
          "name": "McCarthy 2",
          "city": "McCarthy",
          "state": "AK",
          "country": "USA",
          "lat": 61.43706083,
          "long": "McCarthy 2",
          "vip": false
        }
      },
      ...
{% endhighlight %}

The `a` in the output above refers to the `FOR a IN airports`. Using `FOR x IN airports` would have used `x` for each of the subdocuments above.

This output is however not ideal... We basically just want to have the airport codes instead of the complete document.

{% highlight sql %}
FOR a IN airports
  COLLECT state = a.state INTO airportsByState
  RETURN {
    "state" : state,
    "airports" : airportsByState[*].a._id
  }
{% endhighlight %}

This results in:

{% highlight csv %}
state  airports
AK     ["airports/0AK","airports/15Z","airports/16A","airports/17Z", ...]
AL     ["airports/02A","airports/06A","airports/08A","airports/09A", ...]
...
{% endhighlight %}

What is this `[*].a._id`? If we look at the output from the previous query, we get the full document for each airport, and the form of the output is:
{% highlight json %}
[
  {
    "state": "AK",
    "airports": [
      {
        "a": {..., "_id": "airports/0AK", ...}
      },
      {
        "a": {...,"_id": "airports/15Z", ...}
      },
      ...]
  }
]
{% endhighlight %}
The `[*].a._id` means "for each of these (`*`), return the value for `a._id`". This is very helpful if you want to extract a certain key from an array of documents.

`COLLECT` can be combined with the `WITH COUNT` pragma to return the number of items, for example:

{% highlight sql %}
FOR a IN airports
  COLLECT state = a.state WITH COUNT INTO nrAirports
  SORT nrAirports DESC
  RETURN {
    "state" : state,
    "nrAirports" : nrAirports
  }
{% endhighlight %}

{% highlight csv %}
AK  263
TX  209
CA  205
...
{% endhighlight %}

The above corresponds to the following in SQL:
{% highlight sql %}
SELECT state, count(*)
FROM airports
GROUP BY state;
{% endhighlight %}

Another example: how many flights does each carrier have?
{% highlight sql %}
FOR f IN flights
    COLLECT carrier = f.UniqueCarrier WITH COUNT INTO c
    SORT c DESC
    LIMIT 3
    RETURN {
        carrier: carrier,
        nrFlights: c
    }
{% endhighlight %}

The answer:
{% highlight csv %}
carrier  nrFlights
WN       48065
AA       24797
OO       22509
{% endhighlight %}
Apparently SouthWest Airlines (`WN`) has many more domestic flights than any other airline, including American Airlines (`AA`) and ... (I don't know what the OO stands for...)

## Aggregation
We can go further and make calculations as well. Note that we can only use `AGGREGATE` when we have run `COLLECT` before. When using `AGGREGATE` we create a new variable and assign it a value using one of the functions that we saw [here](#functions-in-arangodb).

What is the average flight distance?
{% highlight sql %}
FOR f IN flights
    COLLECT AGGREGATE
    avg_length = AVG(f.Distance)
    RETURN avg_length
{% endhighlight %}

The answer is 729.93 kilometers.

What is the shortest flight for each day of the week?
{% highlight sql %}
FOR f IN flights
  COLLECT dayOfWeek = f.DayOfWeek
  AGGREGATE minDistance = MIN(f.Distance)
  RETURN {
    "dow" : dayOfWeek,
    "minDistance": minDistance
  }
{% endhighlight %}

Based on this query, we see that there is actually a flight on Wednesday that is shorter than any other flight.
{% highlight csv %}
dow  minDistance
1    31
2    30
3    24
4    31
5    31
6    31
7    30
{% endhighlight %}

OK, now we're obviously interested in what those shortest flights are. Given what we have seen above, this will give us a map with those flights. For a geographical query, ArangoDB uses OpenStreetMap to visualise the returned points:

{% highlight sql %}
FOR f IN flights
  SORT f.Distance
  LIMIT 3
  LET myAirports = [DOCUMENT(f._from), DOCUMENT(f._to)]
  FOR a IN myAirports
    RETURN GEO_POINT(a.long, a.lat)
{% endhighlight %}

Here we used the `LET` operation (see above "Querying document data") for creating an array with two documents that we can loop over in the next lines using `FOR`.

![short flights]({{ site.baseurl }}/assets/arangodb-shortflights.png)

Intermezzo: now we're curious: what actually are the names of the airports with the shortest flight? (They should be included in the picture above, right?)

{% highlight sql %}
FOR f IN flights
    SORT f.Distance
    LIMIT 1
    LET from = (
        FOR a IN airports
        FILTER a._id == f._from
        RETURN a.name )
    LET to = (
        FOR a IN airports
        FILTER a._id == f._to
        RETURN a.name )
    RETURN [from[0], to[0], f.Distance]
{% endhighlight %}

Result:
{% highlight json %}
[
  [
    "Washington Dulles International",
    "Ronald Reagan Washington National",
    24
  ]
]
{% endhighlight %}

{% include custom/series_nosql_next.html %}
