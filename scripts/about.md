# Wolfrum Lab RNA-seq database

All the samples were processed with a similar pipeline. Briefly:

- reads were trimmed according to quality scores and known adaptors were removed
- reads were mapped to the primary assembly of the human (GRCh38.90) and mouse (GRCm38.90) genomes (Ensembl Release 90) using STAR
- uniquely mapped reads were counted using featureCounts

The expression units ([TPMs and RPKMs](https://haroldpimentel.wordpress.com/2014/05/08/what-the-fpkm-a-review-rna-seq-expression-units/)) are not normalised between samples.

**This means that TPMs/RPKMs are not an ideal metric to compare gene expression between samples.**

TPM/RPKM values can provide an initial idea of interesting changes in gene expression, but any assessment of differential gene expression should be tested on a case-by-case basis using more suitable statistical techniques.



