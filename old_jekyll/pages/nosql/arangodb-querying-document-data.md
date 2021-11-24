---
title: Querying document data
keywords: nosql
sidebar: nosql_sidebar
toc: true
permalink: nosql-arangodb-querying-document-data.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

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
  RETURN a.state
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

## Projections

If you don't want to return the whole document, you can specify this in the `RETURN` statement. This is called a _projection_. For example:
{% highlight sql %}
FOR a IN airports
  RETURN a.name
{% endhighlight %}

Apart from a single value per document, we can also return arrays or maps:

{% highlight sql %}
FOR a IN airports
  RETURN [a.name, a.state]
{% endhighlight %}

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

Important to note: all steps in the `FOR` loop are executed from top to bottom. So the order in which they appear is important (see further).

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

In AQL, the different filters, sorts, limits, etc are applied top to bottom, so order is important! This means that the following two do not necessarily give the same results.

Here are 2 versions (one correct, one wrong) of a query to get (max) 5 airports in California with a VIP lounge.
### Version 1
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  FILTER a.state == 'CA'
  LIMIT 5
  RETURN a
{% endhighlight %}

Let's break this down step by step and see what we get in the intermediate phases:
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  RETURN a
{% endhighlight %}

returns:

| _key | _id | _rev | name | city | state | country | lat | long | vip |
|--|--|--|--|--|--|--|--|--|--|
| AMA | airports/AMA | _ZbpOKxW-Aa | Amarillo International | Amarillo | TX | USA | 35.2193725 | -101.7059272 | true |
| ATL | airports/ATL | _ZbpOKxa-_E | William B Hartsfield-Atlanta Intl | Atlanta | GA | USA | 33.64044444 | -84.42694444 | true |
| DFW | airports/DFW | _ZbpOKxu--I | Dallas-Fort Worth International | Dallas-Fort Worth | TX | USA | 32.89595056 | -97.0372 | true |
| JFK | airports/JFK | _ZbpOKyK-Aa | John F Kennedy Intl | New York | NY | USA | 40.63975111 | -73.77892556 | true |
| LAX | airports/LAX | _ZbpOKyS-_c | Los Angeles International | Los Angeles | CA | USA | 33.94253611 | -118.4080744 | true |
| ORD | airports/ORD | _ZbpOKyq-AS | Chicago O'Hare International | Chicago | IL | USA | 41.979595 | -87.90446417 | true |
| SFO | airports/SFO | _ZbpOKz--A- | San Francisco International | San Francisco | CA | USA | 37.61900194 | -122.3748433 | true |

We see that there are 7 airports in the US with a VIP lounge. Let's add the second filter:
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  FILTER a.state == 'CA'
  RETURN a
{% endhighlight %}

returns:

| _key | _id | _rev | name | city | state | country | lat | long | vip |
|--|--|--|--|--|--|--|--|--|--|
| LAX | airports/LAX | _ZbpOKyS-_c | Los Angeles International | Los Angeles | CA | USA | 33.94253611 | -118.4080744 | true |
| SFO | airports/SFO | _ZbpOKz--A- | San Francisco International | San Francisco | CA | USA | 37.61900194 | -122.3748433 | true |

Finally, we limit the output to a maximum of 5 records, but we only have 2 anyway...

### Version 2
In the second version, we switched the `FILTER a.state == 'CA'` and `LIMIT 5`:
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  LIMIT 5
  FILTER a.state == 'CA'
  RETURN a
{% endhighlight %}

Again, let's see what happens step by step:
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  RETURN a
{% endhighlight %}

returns:

| _key | _id | _rev | name | city | state | country | lat | long | vip |
|--|--|--|--|--|--|--|--|--|--|
| AMA | airports/AMA | _ZbpOKxW-Aa | Amarillo International | Amarillo | TX | USA | 35.2193725 | -101.7059272 | true |
| ATL | airports/ATL | _ZbpOKxa-_E | William B Hartsfield-Atlanta Intl | Atlanta | GA | USA | 33.64044444 | -84.42694444 | true |
| DFW | airports/DFW | _ZbpOKxu--I | Dallas-Fort Worth International | Dallas-Fort Worth | TX | USA | 32.89595056 | -97.0372 | true |
| JFK | airports/JFK | _ZbpOKyK-Aa | John F Kennedy Intl | New York | NY | USA | 40.63975111 | -73.77892556 | true |
| LAX | airports/LAX | _ZbpOKyS-_c | Los Angeles International | Los Angeles | CA | USA | 33.94253611 | -118.4080744 | true |
| ORD | airports/ORD | _ZbpOKyq-AS | Chicago O'Hare International | Chicago | IL | USA | 41.979595 | -87.90446417 | true |
| SFO | airports/SFO | _ZbpOKz--A- | San Francisco International | San Francisco | CA | USA | 37.61900194 | -122.3748433 | true |

In the second step, we limit the output to maximum 5 records:

{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  LIMIT 5
  RETURN a
{% endhighlight %}

returns:

| _key | _id | _rev | name | city | state | country | lat | long | vip |
|--|--|--|--|--|--|--|--|--|--|
| AMA | airports/AMA | _ZbpOKxW-Aa | Amarillo International | Amarillo | TX | USA | 35.2193725 | -101.7059272 | true |
| ATL | airports/ATL | _ZbpOKxa-_E | William B Hartsfield-Atlanta Intl | Atlanta | GA | USA | 33.64044444 | -84.42694444 | true |
| DFW | airports/DFW | _ZbpOKxu--I | Dallas-Fort Worth International | Dallas-Fort Worth | TX | USA | 32.89595056 | -97.0372 | true |
| JFK | airports/JFK | _ZbpOKyK-Aa | John F Kennedy Intl | New York | NY | USA | 40.63975111 | -73.77892556 | true |
| LAX | airports/LAX | _ZbpOKyS-_c | Los Angeles International | Los Angeles | CA | USA | 33.94253611 | -118.4080744 | true |

If we look closely, we now have lost SFO airport...

In our final step, we pick those airports that are in California:
{% highlight sql %}
FOR a IN airports
  FILTER a.vip == true
  LIMIT 5
  FILTER a.state == 'CA'
  RETURN a
{% endhighlight %}

returns:

| _key | _id | _rev | name | city | state | country | lat | long | vip |
|--|--|--|--|--|--|--|--|--|--|
| LAX | airports/LAX | _ZbpOKyS-_c | Los Angeles International | Los Angeles | CA | USA | 33.94253611 | -118.4080744 | true |

Because we already lost SFO along the way we can't show that anymore, meaning that our output is not correct.

## LET: defining variables
In some cases it becomes complex or even impossible to put the whole query in a single nested combination of `FOR` loops, `FILTER`s and `SORT`s. Sometimes it's easier to extract some data separately. That's where `LET` comes in.

The following two queries give the same result:

{% highlight sql %}
FOR a IN airports
RETURN a
{% endhighlight %}

{% highlight sql %}
LET myAirports = (
  FOR a IN airports
  RETURN a
)

FOR m IN myAirports
RETURN m
{% endhighlight %}

Here's an example where a `LET` is necessary. If we want to find out which airports to get to in 2 stops starting from Adak (ADK), we could first find out which airports can be reached _directly_ from ADK, write those down, and then for each of these do a separate query to find the second airport. Or we can put the airports reached directly in an array that we loop over afterwards:

{% highlight sql %}
LET arrivals1 = (
    FOR f IN flights
    FILTER f._from == 'airports/ADK'
    RETURN f._to)

FOR a IN arrivals1
    FOR f IN flights
    FILTER f._from == a
    RETURN DISTINCT f._to
{% endhighlight %}

The output:
```
[ "airports/SEA", "airports/PDX", "airports/SLC", "airports/PHX",
  "airports/FAI", "airports/ADQ", "airports/JNU", "airports/MSP",
  "airports/OME", "airports/BET", "airports/SCC", "airports/HNL",
  "airports/CDV", "airports/LAS", "airports/OTZ", "airports/ORD",
  "airports/IAH", "airports/ADK" ]
```

Notice that the last element in the list is ADK itself because obviously you can reach it again in 2 stops.

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
    LIMIT 2
    RETURN a
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

Don't worry about the `COLLECT WITH COUNT INTO` yet. We'll come back to that below...

## Joining collections
### Inner joins
Just like inner joins in RDBMS, it is simple to combine different collections. In AQL we do this by nesting `FOR` loops. But like in RDBMS joins we have to make sure that there exists a `FILTER` in the inner loop to match up IDs. For example, to list all destination airports and distances for flights where the departure airport lies in California:

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

(Remember from above that using links in a document setting might consitute a code smell. If you're doing this a lot, check if your data should be modelled as a graph. Further down when we're talking about ArangoDB as a graph database we'll write a version of this same query that uses a graph approach.)

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

### Outer joins
The above joins are inner joins, which means that we will only find the departure airports for which such arrival airports exist (see the SQL session). What if we want to list the airports in California that do not have any flights to other airports in California as well? In this case, put the second `FOR` loop within the `RETURN` statement:
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

### Note on profiling
There are often many ways of getting to the correct results. However, some might be more efficient than others. Consider the example above where we list all destination airports and distances for flights where the departure airport lies in California. This will give 437 results:

| departure | arrival | distance |
|--|--|--|
| airports/ACV | airports/SFO | 250 |
| airports/ACV | airports/SMF | 207 |
| airports/ACV | airports/CEC | 56 |
| ... | ... | ... |

{% highlight sql %}
FOR a IN airports
  FILTER a.state == 'CA'
  FOR f IN flights
    FILTER f._from == a._id
    RETURN DISTINCT {departure: a._id, arrival: f._to, distance: f.Distance}
{% endhighlight %}

We could also have started with the flights, and for each flight check if the departure airport (`f._from`) lies in California.

{% highlight sql %}
FOR f IN flights
    LET dep_airport = (
        FOR a IN airports
            FILTER a._id == f._from
            RETURN a.state
    )
    FILTER dep_airport[0] == 'CA'
    RETURN DISTINCT {departure: f._from, arrival: f._to, distance: f.Distance}
{% endhighlight %}

This will give the same output, but run for a much longer time. The first version took 0.2 seconds; this second one 2.8 seconds. It is clear to see why: we apply a filter as soon as possible in the first version. A profile for this first version:

```
Execution plan:
 Id   NodeType                  Calls   Items   Runtime [s]   Comment
  1   SingletonNode                 1       1       0.00000   * ROOT
  2   EnumerateCollectionNode       4    3363       0.00305     - FOR a IN airports   /* full collection scan, projections: `_id`, `state` */
  3   CalculationNode               4    3363       0.00058       - LET #2 = (a.`state` == "CA")   /* simple expression */   /* collections used: a : airports */
  4   FilterNode                    1     205       0.00052       - FILTER #2
 11   IndexNode                    35   34202       0.16585       - FOR f IN flights   /* edge index scan, projections: `Distance`, `_to` */
  8   CalculationNode              35   34202       0.05951         - LET #6 = { "departure" : a.`_id`, "arrival" : f.`_to`, "distance" : f.`Distance` }   /* simple expression */   /* collections used: a : airports, f : flights */
  9   CollectNode                   1     437       0.04776         - COLLECT #8 = #6   /* distinct */
 10   ReturnNode                    1     437       0.00000         - RETURN #8
```

Profile for the second version:
```
Execution plan:
 Id   NodeType                   Calls    Items   Runtime [s]   Comment
  1   SingletonNode                  1        1       0.00000   * ROOT
  2   EnumerateCollectionNode      287   286463       0.14689     - FOR f IN flights   /* full collection scan */
  9   SubqueryNode                 287   286463       5.97333       - LET dep_airport = ...   /* const subquery */
  3   SingletonNode             286463   286463       0.35125         * ROOT
 16   IndexNode                 286463   286283       2.66140           - FOR a IN airports   /* primary index scan, projections: `state` */
 15   LimitNode                 286463   286283       0.72835             - LIMIT 0, 1
  7   CalculationNode           286463   286283       0.74753             - LET #7 = a.`state`   /* attribute expression */   /* collections used: a : airports */
  8   ReturnNode                286463   286283       0.71181             - RETURN #7
 10   CalculationNode              287   286463       0.17962       - LET #9 = (dep_airport[0] == "CA")   /* simple expression */
 11   FilterNode                    35    34202       0.10274       - FILTER #9
 12   CalculationNode               35    34202       0.05116       - LET #11 = { "departure" : f.`_from`, "arrival" : f.`_to`, "distance" : f.`Distance` }   /* simple expression */   /* collections used: f : flights */
 13   CollectNode                    1      437       0.04276       - COLLECT #13 = #11   /* distinct */
 14   ReturnNode                     1      437       0.00000       - RETURN #13
```

The `Calls` column shows how many times a particular line in the query is executed. In the first version, we check if the airport is in CA 3,363 times (as there are 3,363 airports). In the second version, we see that many of the steps in the query are performed 286,463 times (i.e. the number of records in the `flights` collection).

Take home message: think about the order in which you want to do things in a query. If possible, perform `FILTER`s and `LIMIT`s as early as possible.

## Grouping
SQL has the `GROUP BY` pragma, for example:

{% highlight sql %}
SELECT name, COUNT(*) AS c
FROM airports
GROUP BY name;
{% endhighlight %}

To group results, AQL provides the `COLLECT` keyword.

### COLLECT on its own
The simplest way to use `COLLECT` is for getting distinct values back. For example:

{% highlight sql %}
FOR a IN airports
COLLECT s = a.state
RETURN s
{% endhighlight %}

What happens here? The `COLLECT s = a.state` takes the `state` key for each airport, and adds it to the new set called `s`. This set will then contain all unique values. This is actually exactly the same as

{% highlight sql %}
FOR a IN airports
RETURN DISTINCT a.state
{% endhighlight %}

### COLLECT with INTO
What if you want to keep track of the records that actually make up the group itself?

{% highlight sql %}
FOR a IN airports
COLLECT s = a.state INTO airportsByState
RETURN { state: s, airports: airportsByState }
{% endhighlight %}

This code goes through each airport, and _collects_ the state that it's in. It'll return a list of states with for each the list of their airports:

{% highlight json %}
[
  {
    "state": "AK",
    "airports": [
      {
        "a": {
          "_key": "0AK", "_id": "airports/0AK", "_rev": "_ZYukZZy--e",
          "name": "Pilot Station", "city": "Pilot Station", "state": "AK", "country": "USA",
          "lat": 61.93396417, "long": "Pilot Station",
          "vip": false
        }
      },
      {
        "a": {
          "_key": "15Z", "_id": "airports/15Z", "_rev": "_ZYukZa---I",
          "name": "McCarthy 2", "city": "McCarthy", "state": "AK", "country": "USA",
          "lat": 61.43706083, "long": "McCarthy 2",
          "vip": false
        }
      },
      ...
{% endhighlight %}

The `a` in the output above refers to the `FOR a IN airports`. Using `FOR x IN airports` would have used `x` for each of the subdocuments above.

This output is however not ideal... We basically just want to have the airport codes instead of the complete document.

{% highlight sql %}
FOR a IN airports
  COLLECT s = a.state INTO airportsByState
  RETURN {
    "state" : s,
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
    "airports": [ { "a": {..., "_id": "airports/0AK", ...} },
                  { "a": {...,"_id": "airports/15Z", ...} },
                  ...]
  }
]
{% endhighlight %}
The `[*].a._id` means "for each of these (`*`), return the value for `a._id`". This is very helpful if you want to extract a certain key from an array of documents.

### COLLECT with WITH COUNT INTO
`COLLECT` can be combined with the `WITH COUNT INTO` pragma to return the number of items instead of the items themselves, for example:

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
Apparently SouthWest Airlines (`WN`) has many more domestic flights than any other airline, including American Airlines (`AA`) and SkyWest Airlines (`OO`).

### COLLECT with AGGREGATE
We can go further and make calculations on these groupings as well. When using `AGGREGATE` we create a new variable and assign it a value using one of the functions that we saw [here](#functions-in-arangodb).

What is the average flight distance?
{% highlight sql %}
FOR f IN flights
    COLLECT AGGREGATE avg_length = AVG(f.Distance)
    RETURN avg_length
{% endhighlight %}

The answer is 729.93 kilometers.

What is the shortest flight for each day of the week?
{% highlight sql %}
FOR f IN flights
  COLLECT dayOfWeek = f.DayOfWeek AGGREGATE minDistance = MIN(f.Distance)
  RETURN {
    "dow" : dayOfWeek,
    "minDistance": minDistance
  }
{% endhighlight %}

Based on this query, we see that Wednesday has the shortest flight.
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

Here we used the `LET` operation for creating an array with two documents that we can loop over in the next lines using `FOR`.

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
