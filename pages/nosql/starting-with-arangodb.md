---
title: Starting with ArangoDB
keywords: nosql
sidebar: nosql_sidebar
toc: false
permalink: nosql-starting-with-arangodb.html
folder: nosql
---
{% include custom/series_nosql_previous.html %}

<img src="{{ site.baseurl }}/assets/arangodb-positioning.png" width="600px"/>

## Installation
The easiest way to install ArangoDB is to download it from [here](https://www.arangodb.com/download-major/). Make sure to check the Installation Manual:
- for Windows: [https://www.arangodb.com/docs/stable/installation-windows.html](https://www.arangodb.com/docs/stable/installation-windows.html)
- for MacOS: [https://www.arangodb.com/docs/stable/installation-mac-osx.html](https://www.arangodb.com/docs/stable/installation-mac-osx.html) => probably easiest to use the second option and install it using the .dmg package
- linux: installation options available for CentOS, Fedora, Redhat, Debian, Ubuntu, SuSE and ArchLinux

For getting started with ArangoDB, see [here](https://www.arangodb.com/docs/stable/getting-started.html). Some of the following is extracted from that documentation. After installing ArangoDB, you can access the web interface at [http://localhost:8529](http://localhost:8529); log in as user `root` (without a password) and connect to the `_system` database. (Note that in a real setup, the root user would only be used for administrative purposes, and you would first create a new username. For the sake of simplicity, we'll take a shortcut here.)

## Web interface vs arangosh
In the context of this course, we will use the web interface for ArangoDB. Although very easy to use, it does have some shortcomings compared to the command line `arangosh`, or using ArangoDB from within programs written in python or other languages. For example, we won't be able to run centrality queries using the web interface. If you're even a little bit serious about using databases, you should get yourself acquainted with the shell as well.

{% include custom/series_nosql_next.html %}
