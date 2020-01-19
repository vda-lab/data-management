---
title: Data in DNA sequencing and genotyping
keywords: rdbms
sidebar: rdbms_sidebar
toc: false
permalink: rdbms-dna-sequencing-and-genotyping.html
folder: rdbms
series: rdbms-series
weight: 3
---
The importance of DNA sequencing and genotyping is steadily increasing within research and health care. In genotyping, one reads the nucleotides at specific positions in the genome to check if the patient has an allele that for example constitutes a higher risk to certain diseases, or that indicates higher or lower sensitivity to certain medication.

For example, mutations in the BRCA1 and BRCA2 genes change a person's chance of getting breast cancer (see http://arup.utah.edu/database/BRCA/Variants/BRCA2.php for a list of possible mutations in BRCA2 and their pathogenicity). One of the many harmful mutations is a mutation at position 32,316,517 on chromosome 13 (in exon 2 of BRCA2) that changes a C to an A, resulting in a stop codon.

<img src="{{ site.baseurl }}/assets/brca2.png" />

Genotyping results therefore contain information on:
- the individual
- the polymorphism (i.e. identifying what nucleotide is changed) position in the genome (i.e. chr13 position 32,316,517)
- the allele (i.e. C or A)

For each, additional information can be recorded:
- for the individual: their name, ethnicity
- for the polymorphism: the unique identifier in a central database (in this case: rs878853592), the chromosome (chr13), the position (32,316,517), the allele that occurs in healthy individuals (i.e. C)

An example genotype table:
<img src="{{ site.baseurl }}/assets/genotype_table.png" />

This table contains the information for 3 polymorphisms (called rs12345, rs98765 and rs28465) for 2 individuals (individual_A and individual_B). Typically, thousands of polymorphisms are recorded for thousands of individuals.
A particular type of polymorphism is the single nucleotide polymorphism (SNP), which will be why tables below will be called `snps`.


{% include custom/series_rdbms_next.html %}
