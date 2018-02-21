# run from the command line:
#
#   Rscript createDatabase.R input_files.yaml
#
#

library(edgeR, quietly = TRUE)
library(biomaRt, quietly = TRUE)
library(yaml)


# yaml file with input file locations
args <- commandArgs(TRUE)
inputs <- read_yaml(args[1])
#inputs <- read_yaml('~/polybox/DatasetViz/mapping/input_files.yaml')


################################################################
# function to import counts from FeatureCounts output
################################################################

import <- function(countsFile){
  
  ## imports counts from feature counts output file
  
  counts <- read.table(countsFile,
                       skip = 1, header = TRUE, row.names = 1, sep = '\t')
  counts <- subset(counts, select = -c(Chr, Start, End, Strand, Length))
  names(counts) <- gsub('results.sorted.', '', names(counts))
  names(counts) <- gsub('.BAM', '', names(counts))
  
  return(counts)
}

################################################################
# function to get gene lengths
################################################################

import_gene_lengths <- function(countsFile){
  
  # imports gene lengths from a feature counts file
  
  gl <- read.table(countsFile,
                   skip = 1, header = TRUE,
                   row.names = 1, sep = '\t')$Length
  return(gl)
}


################################################################
# function to import / combine files
################################################################

combine_by_species <- function(projs){
  for(p in seq_along(projs)){
    
    print(paste('Processing', projs[p]))
    
    if(p == 1){
      x <- import(projs[p])
    } else{
      imp <- import(projs[p])
      stopifnot(rownames(imp) == rownames(x))
      x <- cbind(x, imp)
    }
  }
  return(x)
}


################################################################
# function to get gene names from BiomaRt
################################################################

translate <- function(x, mart){
  
  # get gene names from biomart
  new_name <- getBM(attributes = c("ensembl_gene_id", "external_gene_name"),
                    filters = "ensembl_gene_id",
                    values = x, mart = mart,
                    uniqueRows = TRUE)
  
  # match with Ensemble names
  dict <- data.frame(Ensembl = x,
                     name = new_name[match(x,
                                           new_name$ensembl_gene_id), "external_gene_name"],
                     stringsAsFactors = FALSE)
  
  # fix missing names (make them same as Ensembl ID)
  dict[(is.na(dict$name)), 'name'] <- dict[(is.na(dict$name)), 'Ensembl']
  
  return(dict)
}


################################################################
################################################################
################################################################

### import read counts
mouse <- combine_by_species(inputs$mouse)
human <- combine_by_species(inputs$human)

total_mapped <- c(colSums(mouse), colSums(human))


### Get gene lengths
# all counts files from same species need to use same set of genes

gene_lengths_mouse <- import_gene_lengths(inputs$mouse[1])
gene_lengths_human <- import_gene_lengths(inputs$human[1])


### Calculate RPKM
mouse_RPKM <- as.data.frame(rpkm(DGEList(mouse, genes = data.frame(length = gene_lengths_mouse))))
human_RPKM <- as.data.frame(rpkm(DGEList(human, genes = data.frame(length = gene_lengths_human))))


### Total sum RPKMs
mouse_sumRPKM <- colSums(mouse_RPKM)
human_sumRPKM <- colSums(human_RPKM)


### import meta data
meta <- read.csv(inputs$meta)



# Keep only samples that were actually imported
meta <- meta[meta$sample %in% names(total_mapped),]

# Write total number mapped reads per sample
meta$total_mapped <- total_mapped[as.character(meta$sample)]



# outliers
outliers <- scan(inputs$outliers, what = character(), quiet = TRUE)



### translate gene names using Biomart
print('Getting mouse gene names from biomaRt')
mouse_dict <- translate(rownames(mouse), mart = useEnsembl("ensembl", dataset = 'mmusculus_gene_ensembl'))
print('Getting human gene names from biomaRt')
human_dict <- translate(rownames(human), mart = useEnsembl("ensembl", dataset = 'hsapiens_gene_ensembl'))


################################################################
# export
################################################################

outfile <- paste0('db_', format(Sys.time(), "%d%b%y"), '.Rdata')

print(paste('Saving database', outfile, 'in', inputs$save_db_to))

save(mouse_RPKM, human_RPKM, mouse_sumRPKM, human_sumRPKM, meta, mouse_dict, human_dict, outliers,
     file = paste0(inputs$save_db_to, outfile))
