---
title: Data in clinical trials
keywords: rdbms
sidebar: rdbms_sidebar
toc: false
permalink: rdbms-clinical-trials.html
folder: rdbms
---
{% include custom/series_rdbms_previous.html %}

A clinical trial is a study involving the assessment of one or more regimens used in treating or preventing a specific illness or disease (McFadden, 2007). The design, aim, number of patients etc. depend on the phase of the clinical trial. Different types of data are collected:

- _Administrative data_ describes information to uniquely identify a patient and their contact details. Often, the name cannot be used due to the fact that multiple people can have the same name, but more importantly to ensure minimal identifiability (privacy); therefore a unique patient ID is generated at enrolment. In addition, information like the name of the trial and name of the center in large multicenter trials are recorded.
- _Research data_ is all information needed to answer study objective(s) in the protocol, including measurements of endpoints, relevant dates (study entry, treatment administration), etc. The amount of research data to be collected varies widely. It is important to collect only relevant data, as not all clinically relevant data is relevant research data. For example, exact timing of intervention may be relevant for clinical care (record in medical file), but not to answer research questions. Collection of irrelevant data increases time and effort to collect, enter, and process this data, increases the complexity of the database and risk for missing data, etc.

The trial protocol describes which data items need to be collected, based on which a Case Report Form (CRF) is developed. The CRF is the official clinical data-recording document used in a clinical study which stores all relevant patient info that is obtained in a clinical trial. It should be of high quality as a poor design can lead to unreliable data and possibly wrong conclusions of the study.

Items on a CRF are organised according to the following rationale:
- They should follow the time flow of the trial (when are the data collected?). For example, items collected at study entry (e.g., medical history,
treatment allocation, etc.) are grouped together and as well as for all follow-up phases (e.g., primary endpoint measures, adverse effects at particular time point).
- The should reflect the logistics and practical organisation of the trial (where and by whom are the data collected?). For example: some data at study entry may be collected by the CRA, other data by the physician; some data at study entry may be gathered in the cardiology department, other data in the radiology department.

Separate sections/pages on the CRF are created for each logical division.

Below are two annotated pages from a CRF. The red annotations are meant for the data management department and indicate which variable in the database each piece of information is stored in.

<img src="{{ site.baseurl }}/assets/CRF_1.png" width="75%"/>
<img src="{{ site.baseurl }}/assets/CRF_2.png" width="75%"/>

{% include custom/series_rdbms_next.html %}
