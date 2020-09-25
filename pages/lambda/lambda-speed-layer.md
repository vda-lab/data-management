---
title: Speed layer
keywords: lambda
sidebar: lambda_sidebar
toc: true
permalink: lambda-speed-layer.html
folder: lambda
---

The answer to a question that we ask the serving layer will not include data that came in while the precomputation was running. The speed layer takes care of this. Similar to the batch layer, it creates a view of the data but those updates are incremental rather than a recomputation (see above). We won't go into the speed layer too much because in most cases we can get away with not having one. If you don't need a speed layer, don't include it.

Only mentioning that:
- the speed layer is significantly more complex than the batch layer because updates are incremental
- the speed layer requires random reads and writes in the data while the batch layer only needs batch reads and writes
- the speed layer is only responsible for data that is not yet included in the serving layer, therefore the amount of data to be handled is vastly smaller
- the speed layer views are transient, and any errors are short-lived

![friends-3]({{ site.baseurl }}/assets/friends-3.png)

{% include custom/series_lambda_next.html %}
