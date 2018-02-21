# Espresso - RNA-seq gene expression visualization

This webtool provides an interface to visualize and compare gene expression across multiple RNA-seq datasets.


## Database creation

A new database can be generated using the R script _createDatabase.R_, using as input:

- Tab-delimited files with count data, using gene ids (Ensembl) as rows and sample names as columns (e.g. the output data files from featureCounts)

- A csv file with meta information about the samples, organized in the following columns:

  - **sample:** Unique sample identifier (must match the sample names in the count data files)
  - **group:** use to combine replicates and calculate the respective means. Rows with the same 'group' identifier will be pooled together as replicates on the plots
  - **project**: use to filter samples
  - **sample_info:** Verbose info about individual samples
  - **species**
  - **source:** Name of the original source of the data
  - **data_source:** url to the original source

- An optional text file with the names of samples that should be considered outliers and removed from the plots.


The location of the input files should be given as a yaml file:

```yaml

```

#### Run R script:

```r
Rscript createDatabase.R input_files.yaml
```

## Database update

The easiest way to update the database is to update the input_files.yaml file and re-run the createDatabase.R script.

If there is no access to the original count data files from a previous database, then create a new database using a new set of samples and merge the old and new databases.
