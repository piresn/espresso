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


################################################################
# function to import counts from FeatureCounts output
################################################################

import <- function(countsFile, skipRows = 1, remove_str = c("results.sorted.", ".BAM")){
  
  ## imports counts from feature counts output file
  # the remove_str is an optional vector of strings to be removed from sample names
  
  counts <- read.table(countsFile,
                       skip = skipRows, header = TRUE, row.names = 1, sep = '\t')
  counts <- subset(counts, select = -c(Chr, Start, End, Strand, Length))
  
  for(s in remove_str){
    names(counts) <- gsub(s, '', names(counts))
  }
  
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
# function to import and merge count files
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

total_mapped <- c()

for(i in c('mouse', 'human')){
  
  # get counts
  assign(i, combine_by_species(inputs[[i]]))
  
  # get gene lengths
  tmp <- NULL
  tmp <- import_gene_lengths(inputs[[i]][1])
  
  # calculate RPKMs
  assign(paste0(i, '_RPKM'),
         as.data.frame(rpkm(DGEList(get(i), genes = data.frame(length = tmp)))))
  
  total_mapped <- c(total_mapped, colSums(get(i), na.rm = TRUE))
}


### import meta data
meta <- read.csv(inputs$meta)

# Keep only samples in metadata that were actually imported
meta <- meta[meta$sample %in% names(total_mapped),]

# Add total number mapped reads per sample
meta$total_mapped <- total_mapped[as.character(meta$sample)]



### outliers
outliers <- scan(inputs$outliers, what = character(), quiet = TRUE)



### translate gene names using Biomart

print('Getting mouse gene names from biomaRt')
mouse_dict <- translate(rownames(mouse), mart = useEnsembl("ensembl", dataset = 'mmusculus_gene_ensembl'))
print('Getting human gene names from biomaRt')
human_dict <- translate(rownames(human), mart = useEnsembl("ensembl", dataset = 'hsapiens_gene_ensembl'))


################################################################
# export
################################################################

timestamp <- Sys.time()

print(paste('Saving database in', inputs$save_db_to))

save(mouse_RPKM, human_RPKM, meta, mouse_dict, human_dict, outliers, timestamp,
     file = inputs$save_db_to)
