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

In addition, database creation using the standalone createDatabase.R script requires:
```
yaml 2.1.16
biomaRt 2.34.2
edgeR 3.20.8
limma 3.34.9
```
biomaRt, edgeR and limma can be installed from Bioconductor.


# Database

The database consists of an .RData file containing RPKM and metadata information. It should be manually copied to the folder `data/`.

## Database creation

A new database can be generated using the R script _createDatabase.R_, using as input:

- Tab-delimited files with count data, using gene ids (Ensembl) as rows and sample names as columns (e.g. the output data files from featureCounts). Counts for
different samples (from the same species) can be given in the same file tab-delimited file, or be split into multiple files.

  The required conditions are that 1) sample names (columns) are unique and 2) gene ids (rows) are the same in all the files. Missing values are not allowed.

- A csv file with meta infos, organized in the following columns:

  - **sample:** Unique sample identifier. It must match the sample names in the count data files (except for the optional string that is removed from the column names, such as _.BAM_ - see yaml file below)
  - **group:** use to combine replicates and calculate the respective means. Rows with the same 'group' identifier will be pooled together as replicates on the plots
  - **project**: use to filter samples. Ideally this would correspond to different RNA-seq runs
  - **sample_info:** Extra info about each individual sample
  - **species**: for reference only. The actual distinction between species is made in the yaml file with input file information (below)
  - **source:** Name of the original source of the data
  - **data_source:** url to the data source


- An optional text file with the names of samples that should be considered outliers and removed from the plots as a preset.

- A yaml file providing the parameters for createDatabase.R.

    Example params.yaml

```yaml
# Counts
mouse:
- /path/FeatureCounts_output1.tab
- /path/FeatureCounts_output2.tab

human:
- /path/FeatureCounts_output3.tab

# string to remove from the column names of counts file
remove_string_counts_table:
- .BAM

# Metadata
meta: /path/metadata.csv

# Preset outliers
outliers: /path/outliers.txt

# Where to save database
save_db_to: /path/db.RData
```

##### Run createDatabase.R:

```bash
Rscript createDatabase.R params.yaml
```

This will create an .Rdata file containing:

- RPKM values for mouse and human samples
- a metadata table
- dictionary tables for mouse and human genes that include the corresponding Ensembl and gene symbol annotations.
- a list of preset outliers
- a timestamp with the database creation date


_For the sake of simplicity, no inter-sample normalization step is performed in createDatabase.R. Nevertheless, this could be easily implemented, especially for small databases (e.g. apply EdgeR's calcNormFactors function to the dge object prior to RPKM conversion)._

## Database update

- The easiest way to update the database is to have both the original and the new files with count data locally available, update the params.yaml file, and re-run the `createDatabase.R` script.

- If there is no access to the original count data files from a previous database, then:
  - create a database using only the new set of samples using `createDatabase.R`
  - merge the old and new databases using the `mergeDatabase.R` script. This will create a _merged.RData_ database file. There should be no overlap between the names of samples (mandatory), groups and projects (unless this is actually desired) in the two input databases. An inner join is made between the count tables of the two input databases, so any missing genes from one of the input databases will not be present in the output. The dictionary from the first input database will be used.


- A third option is to start manually update the objects in an existing RData database: make inner join RPKMs, add new rows in meta table, and update timestamp.

# Other species

Espresso can be easily extended to RNA-seq from other species in addition to human and mouse. All that would be required are a few changes in the createDatabase.R script (including making sure that biomaRt works correctly), so that the database file also includes _newspecies_RPKM_ and _newspecies_dict_ objects.
