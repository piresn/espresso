library("shiny")
library("shinythemes")
library('shinyjs') # need install at Hoengg
library("shinyBS")
library("ggplot2")
library("RColorBrewer")
library("reshape2")
library('biomaRt')
library("dplyr")

source('scripts/functions.R')

initial_sel_genes <- "UCP1\nAXL"

# limited, use to skip biomart functions
offline = TRUE

if(offline){
  initial_sel_genes = "ENSMUSG00000031710\nENSMUSG00000002602"
}
                           
if(!offline){
  ensembl_human <- useMart("ensembl",
                           dataset = 'hsapiens_gene_ensembl')
  
  ensembl_mouse <- useMart("ensembl",
                           dataset = 'mmusculus_gene_ensembl')
}

mouse <- read.csv('dummydata/mouse.csv', row.names = 1)
human <- read.csv('dummydata/human.csv', row.names = 1)


################################ meta data

sample_id <- read.csv("dummydata/sampleID.csv")
samples <- read.csv("dummydata/samples.csv")

# make names comparable: sample names in headers had "-" replaced by "."s
# make the same for samples file:
levels(samples$sample) <- gsub('-', '.', levels(samples$sample))
samples$sample <- as.character(samples$sample)

# merge
meta <- merge(samples, sample_id, by = 'group_id')
rm(samples, sample_id)

##################################

database_version <- scan("dummydata/version", character(),
                         sep = ':', strip.white = TRUE)[c(2, 4)]

source('scripts/test.R')

