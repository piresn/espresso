# Wolfrum Lab RNA-seq database

This webtool allows comparing the expression of mouse and human genes in RNA-seq samples from the Wolfrum lab.

### Input genes

Up to 8 genes can be selected at the same time: you can use either the official gene name (e.g. Ucp1) or the Ensembl gene IDs (e.g. ENSMUSG00000031710) in the search box. Only genes from the same species can be selected at the same time.


### Means

If the 'Show means only' option is selected, the geometric mean of replicate samples will be shown instead of the individual sample values.


### Expression units

Individual gene expression can be represented as TPMs (transcripts per million) or RPKMs (reads per kilobase of exon per million reads). TPM is more consistent between samples than RPKM, and is therefore the recommended expression unit to use.

TPM/RPKMs provide intra-specific normalization based on gene length. This allows them to compare the expression of different genes in the same sample. However, [TPM/RPKMs do not provide inter-sample normalization](https://haroldpimentel.wordpress.com/2014/05/08/what-the-fpkm-a-review-rna-seq-expression-units/) and, therefore **are not an ideal metric to compare gene expression between different samples.**

TPM/RPKM values can provide an initial idea of interesting changes in gene expression between samples, but any final assessment of differential gene expression should be tested on a case-by-case basis using more appropriate statistical approaches.


### Filter

The list of projects and corresponding samples can be found in the 'Samples info' tab (top of the page).

Individual samples can also be excluded from the analysis. A small set of problematic samples is initially suggested, and can be called back by clicking the link 'Reset'.


### Plot

The output plot is automatically sorted based on the gene with the highest expression.


## Database

Information about the individual samples, including the source of the data, can be found on the 'Samples info' page.

All the samples were processed using a similar pipeline. Briefly:

- Reads were quality-based trimmed and known adaptors were removed.
- Processed reads were mapped to the primary assembly of the human GRCh38 and mouse GRCm38 genomes.
- Uniquely mapped reads overlapping exons were aggregated using Ensembl 90 annotations.



<a class = "md_foot" target = "_blank" href='https://github.com/piresn/espresso'>Source code available on Github <i class="fa fa-github"></i></a>
