library("shiny")
library("shinythemes")
library('shinyjs') # need install at Hoengg
library("shinyBS")
library("ggplot2")
library("RColorBrewer")
library("reshape2")
library('biomaRt')
library("dplyr")
library("shinycssloaders")

source('scripts/functions.R')


initial_sel_genes <- "UCP1\nAXL"


#################################
# import data
#################################

load('dummydata/data.Rdata')


#################################
# development
#################################

# limited, use to skip biomart functions
offline = FALSE

if(offline){
  initial_sel_genes = "ENSMUSG00000031710\nENSMUSG00000002602"
}

if(!offline){
  ensembl_human <- useMart("ensembl",
                           dataset = 'hsapiens_gene_ensembl')
  
  ensembl_mouse <- useMart("ensembl",
                           dataset = 'mmusculus_gene_ensembl')
}

source('scripts/test.R')

