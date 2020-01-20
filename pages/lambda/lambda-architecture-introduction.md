---
title: Introduction
keywords: lambda
sidebar: lambda_sidebar
toc: false
permalink: lambda-architecture-introduction.html
folder: lambda
series: lambda-series
weight: 7
---

When working with large, complex or continuously changing data (aka "Big Data"), no single tool can provide a complete solution. In a big data situation, often a variety of tools and techniques is used. The Lambda Architecture helps us to organise everything. It decomposes the problem of computing arbitrary functions on arbitrary data in real-time by decomposing it into 3 layers:
- batch layer (least complex)
- serving layer
- speed layer (most complex)

Here's the general picture:

![lambda]({{ site.baseurl }}/assets/lambda-overview.png)<br/>
<small><i>Lambda Architecture diagram (Costa & Santos, IAENG International Journal of Computer Science, 2017)</i></small>

Let's go through this figure layer by layer.

{% include custom/series_lambda_next.html %}
