# Wolfrum Lab RNA-seq database

This webtool allows comparing the expression of mouse and human genes in RNA-seq samples from the Wolfrum lab.

### Input genes

Up to 8 genes can be compared at the same time: use either the official gene name (e.g. Ucp1) or the Ensembl gene IDs (e.g. ENSMUSG00000031710). Only genes from the same species can be compared at the same time.

### Expression units

Individual gene expression can be represented as TPMs (transcripts per million) or RPKMs (Reads per kilobase of exon per million reads). TPM is a modification of RPKMs that is [more consistent between samples](https://www.ncbi.nlm.nih.gov/pubmed/22872506).

TPM/RPKMs are relatively simple expression units that account for intra-specific normalization, but [not for inter-sample normalization](https://haroldpimentel.wordpress.com/2014/05/08/what-the-fpkm-a-review-rna-seq-expression-units/).

**This means that TPMs/RPKMs are not an metric to compare gene expression between samples.**

TPM/RPKM values can provide an initial idea of interesting changes in gene expression, but any assessment of differential gene expression should be tested on a case-by-case basis using more suitable statistical techniques.

### Means

If the 'Show means only' option is selected, the geometric mean of replicate samples will be shown instead of the individual sample values.

### Filter

The list of projects and corresponding samples can be found in the 'Samples info' tab (top of the page).


#### Outliers

Individual samples can be excluded from the analysis. A small set of outliers is initially suggested, and can be called back by clicking the link 'Reset'.

### Plot

The output plot is automatically sorted based on the gene with the highest expression.


## Database

Information about the individual samples, including the source of the data, can be found on the 'Samples info' page.

All the samples were processed using a similar pipeline. Briefly:

- Reads were quality-based trimmed and known adaptors were removed using Trimmomatic 0.35
- Processed reads were mapped to the primary assembly of the human GRCh38 and mouse GRCm38 genomes (Ensembl Release 90) using STAR v2.5.3a
- Uniquely mapped reads overlapping exons were aggregated using featureCounts from the Subread package v1.5.3, using Ensembl 90 annotations





<a class = "md_foot" target = "_blank" href='https://github.com/piresn/espresso'><i class="fa fa-github fa-2x"></i>  Source code available on Github</a>
