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

db <- list.files('data/', pattern = '^db_........Rdata')
timestamp <- format(as.Date(substr(db, 4, 10), "%d%b%y"), '%d %B %Y')

#in case of multiple data files, use the most recent
w <- which(timestamp == max(timestamp))
db <- db[w]
timestamp <- timestamp[w]


load(paste0('data/', db))



#################################
# development
#################################

source('scripts/test.R')