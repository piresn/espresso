a <- Sys.time()
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

loadtime1 <- Sys.time()-a

#################################
# Convert from RPKM to TPM
#################################

# this adds >1 second to loading time. Alternatively can store TPMs in database or calculate only for the selected genes.

f <- function(x) x*1e6 / sum(x)
mouse_TPM <- as.data.frame(apply(mouse_RPKM, 2, f))
human_TPM <- as.data.frame(apply(human_RPKM, 2, f))
loadtime2 <- Sys.time()-a


#################################
# development
#################################

source('scripts/test.R')