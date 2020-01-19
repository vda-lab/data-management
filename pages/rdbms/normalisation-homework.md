---
title: Normalisation homework
keywords: rdbms
sidebar: rdbms_sidebar
permalink: rdbms-normalisation-homework.html
folder: rdbms
series: rdbms-series
weight: 23
---

**This is the assignment for homework 1. For the due date, see [the website for this part of the course]({{ site.baseurl }}/sdm.html).**.

Let's see if we can design a normalised database to hold the data for a pet shop. "Sally's Pet Shop" sells animal care merchandise and also lets you adopt an animal. The goal is to create a database to track the store operations: sales, orders, customer tracking, and basic animal data. The input that you have are:
- sales forms
- purchase order forms for animals
- purchase order forms for merchandise

## Sales
Here's a printout of an empty sales form.

<img src="{{ site.baseurl }}/assets/petshop_salesform.png" width="400px"/>

The assumptions that we take:
- there is only 1 customer per sale
- a sale is handled by 1 employee
- many customers can buy animals and merchandise
- an employee can handle many sales
- a customer can adopt several animals
- a customer can buy several merchandise items
- an animal can be adopted only once
- customer name is not unique

## Animal purchase orders
Here's an example of an empty purchase order form for animals:

<img src="{{ site.baseurl }}/assets/petshop_purchaseorderform.png" width="400px"/>

Assumptions that we will take when creating the database are:
- each order is placed with 1 supplier at a time
- each order is handled by 1 employee
- a supplier can receive many orders
- an employee can handle many orders
- many animals can be ordered with 1 order
- supplier name is not unique
- animal name is not unique

Exercise: create a fully normalised database schema for this pet shop example.

{% include custom/series_rdbms_next.html %}
