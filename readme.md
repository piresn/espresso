# Espresso - RNA-seq gene expression visualization

Espresso is a Shiny app that provides an interface to visualize and compare gene expression across multiple RNA-seq datasets.

### Required libraries:

Espresso runs successfully with the following packages on R 3.4.3:

```
shiny 1.0.5
shinythemes 1.1.1
shinyjs 1.0
shinyBS 0.61
ggplot2 2.2.1
RColorBrewer 1.1-2
reshape2 1.4.3
dplyr 0.7.4
shinycssloaders 0.2.0
```


All can be installed from CRAN, except shinycssloaders:
```
devtools::install_github('andrewsali/shinycssloaders')
```

# Database

The database consists of an RData object called db__ddmmyy_.RData that should be stored in the folder data. If multiple database files are present, only the most recent one (as judged by the file name) will be used.

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

If there is no access to the original count data files from a previous database, then create a new database using a new set of samples and merge the old and new databases. Make sure that there is no overlap between the sample names and group names of the two databases.
