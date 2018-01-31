library(shiny)
library(shinythemes)
library(shinyjs)
library(shinyBS)
library(ggplot2)
library(RColorBrewer)
library(reshape2)
library(biomaRt)
library(dplyr)
library(shinycssloaders)

source('scripts/functions.R')


initial_sel_genes <- "UCP1\nAXL"


#################################
# import data
#################################

load('data/data.Rdata')

#################################
# development
#################################

# limited, use to skip biomart functions
offline = FALSE

if(offline){
  initial_sel_genes = "ENSMUSG00000031710\nENSMUSG00000002602"
}

if(!offline){
  ensembl_human <- useEnsembl("ensembl",
                           dataset = 'hsapiens_gene_ensembl')
  
  ensembl_mouse <- useEnsembl("ensembl",
                           dataset = 'mmusculus_gene_ensembl')
}

source('scripts/test.R')

