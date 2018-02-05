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


initial_sel_genes <- "UCP1\nAXL"


#################################
# import data
#################################

load('data/data.Rdata')

### outlier samples:
outliers <-  as.character(subset(meta, flag == 'outlier')$sample)

#################################
# development
#################################

source('scripts/test.R')
