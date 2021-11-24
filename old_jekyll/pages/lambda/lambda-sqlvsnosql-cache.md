---
title: Keep your cache current
keywords: lambda
sidebar: lambda_sidebar
toc: false
permalink: lambda-sqlvsnosql-cache.html
folder: lambda
---

So keeping things in RAM makes it possible to very quickly access them. This is what you do when you load data into a variable in your python/R/SAS/ruby/perl/... code.

Caching is used constantly by the computer you're using at this moment as well.

An important aspect of caching is calculating a key that can be used to retrieve the data (remember key/value stores?). This can for example be done by calculating a checksum, which looks at each byte of a document and returns a long sequence of letters and numbers. Different algorithms exists for this, such as `MD5` or `SHA-1`. Changing a single bit in a file (this file can be binary or not) will completely change the checksum.

Let's for example look at the checksum for the file that I'm writing right now. Here are the commands and output to get the MD5 and SHA-1 checksums for this file:

{% highlight csv %}
janaerts$ md5 2019-10-31-lambda-architecture.md
MD5 (2019-10-31-lambda-architecture.md) = a271e75efb769d5c47a6f2d040e811f4
janaerts$ shasum 2019-10-31-lambda-architecture.md
2ae358f1ac32cb9ce2081b54efc27dcc83b8c945  2019-10-31-lambda-architecture.md
{% endhighlight %}

As you can see, these are quite long strings and MD5 and SHA-1 are indeed two different algorithms to create a checksum. The moment that I wrote the "A" (of "As you can see") at the beginning of this paragraph, the checksum changed completely. Actually, below are the checksums after adding that single "A". Clearly, the checksums are completely different.

{% highlight csv %}
janaerts$ md5 2019-10-31-lambda-architecture.md
MD5 (2019-10-31-lambda-architecture.md) = b597d18879c46c8838ad2085d2c7d2f9
janaerts$ shasum 2019-10-31-lambda-architecture.md
45c5a96dd506b884866e00ba9227080a1afd6afc  2019-10-31-lambda-architecture.md
{% endhighlight %}

This consistent hashing can for example also be used to assign documents to specific database nodes.

In principle, it _is_ possible that 2 different documents have the same hash value. This is called _hash collision_. Don't worry about it too much, though. The MD5 algorithm generates a 128 bit string, which occurs once every 10^38 documents. If you generate a billion documents per second it would take 10 trillion times the age of the universe for a single accidental collision to occur...

Of course a group of researchers at Google tried to break this, and [they were actually successful](https://shattered.it) on February 23th 2017.

![shattered]({{ site.baseurl }}/assets/shattered.png)

To give you an idea of how difficult this is:
- it had taken them 2 years of research
- they performed 9,223,372,036,854,775,808 (9 quintillion) compressions
- they used 6,500 years of CPU computation time for phase 1
- they used 110 years of CPU computation time for phase 2

{% include custom/series_lambda_next.html %}
