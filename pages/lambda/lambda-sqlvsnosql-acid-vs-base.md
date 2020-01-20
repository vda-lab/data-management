---
title: ACID vs BASE
keywords: lambda
sidebar: lambda_sidebar
toc: false
permalink: lambda-sqlvsnosql-acid-vs-base.html
folder: lambda
series: lambda-series
weight: 6
---

## ACID
RDBMS systems try to follow the ACID model for reliable database transactions. ACID stands for atomicity, consistency, isolation and durability. The prototypical example of a database that needs to comply to the ACID rules is one which handles bank transactions.

<img src="{{ site.baseurl }}/assets/bank.png" width="400px" />

- _Atomicity_: Exchange of funds in example must happen as an all-or-nothing transaction
- _Consistency_: Your database should never generate a report that shows a withdrawal from saving without the corresponding addition to the checking account. In other words: all reporting needs to be blocked during atomic operations.
- _Isolation_: Each part of the transaction occurs without knowledge of any other transaction
- _Durability_: Once all aspects of transaction are complete, it's permanent.

For a bank transaction it is crucial that either _all_ processes (withdraw and deposit) are performed or _none_.

The software to handle these rules is very complex. In some cases, 50-60% of the codebase for a database can be spent on enforcement of these rules. For this reason, newer databases often do not support database-level transaction management in their first release.

As a ground rule, you can consider ACID pessimistic systems that focus on consistency and integrity of data above all other considerations (e.g. temporarily blocking reporting mechanisms is a reasonable compromise to ensure systems return reliable and accurate information).

## BASE
BASE stands for:
- _Basic Availability_: Information and service capability are "basically available" (e.g. you can always generate a report).
- _Soft-state_: Some inaccuracy is temporarily allowed and data may change while being used to reduce the amount of consumed resources.
- _Eventual consistency_: Eventually, when all service logic is executed, the systems is left in a consistent state.

A good example of a BASE-type system is a database that handles shopping carts in an online store. It is no problem fs the back-end reports are inconsistent for a few minutes (e.g. the total number of items sold is a bit off); it's much more important that the customer can actually purchase things.

This means that BASE systems are basically optimistic as all parts of the system will eventually catch up and be consistent. BASE systems therefore tend to be much simpler and faster as they don't have to deal with locking and unlocking resources.

{% include custom/series_lambda_next.html %}
