library(shiny)
library(shinythemes)
library(shinyjs)
library(shinyBS)
library(ggplot2)
library(RColorBrewer)
library(reshape2)
library(dplyr)
library(shinycssloaders)

source('scripts/functions.R')

#ggplot theme set
theme_set(theme_classic(16))

# set suggestions for genes in search box
initial_sel_genes <- "UCP1\nAXL"

#################################
# import data
#################################

# Database is stored as a RData file
# in case of multiple data files, use only the first

db <- list.files('data/', pattern = '.RData$')

load(paste0('data/', db[1]))

# available species
spp <- unlist(strsplit(ls(pattern = '_RPKM$'), '_RPKM'))

#################################
# RPKM sums for TPM calculations
#################################

for(i in spp){
  assign(paste0(i, "_sumRPKM"), colSums(get(paste0(i, '_RPKM'))))
}

