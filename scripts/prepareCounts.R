library(edgeR)
library(biomaRt)


# set location of count and metadata
setwd('~/polybox/DatasetViz/mapping/')


# location of output.tab file from feature counts
suffix <- "/results/counts/output.tab"

mouse_projs <- paste0(c('p2148_order3543',
                        'p2148_order3826',
                        'p2148_order3827',
                        'p2148_order3888_mouse',
                        '~/polybox/Lisi/mapping',
                        '~/polybox/Wenfei_Feb2018/mapping'),
                      suffix)

human_projs <- paste0(c('p1830_order1477',
                        'p1830_order1700',
                        'p1830_order2012_Miro',
                        'p2148_order3888_human',
                        'p1830_order2209'),
                      suffix)

# set file where to save data
save_output <- '~/polybox/DatasetViz/RNAseqVizApp/data/data.Rdata'

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
# Function to calculate TPMs
################################################################

tpm <- function(x){
  
  if(!'genes' %in% names(x)) stop('gene annotation information not available in DGEList')
  if(!'length' %in% names(x$genes)) stop('gene length info not present in DGEList annotation table')
  
  countToTpm <- function(counts, effLen) {
    # from https://haroldpimentel.wordpress.com/2014/05/08/what-the-fpkm-a-review-rna-seq-expression-units/
    rate <- log(counts) - log(effLen)
    denom <- log(sum(exp(rate)))
    exp(rate - denom + log(1e6))
  }
  out <- apply(x$counts, 2, countToTpm, effLen = x$genes$length)
  return(as.data.frame(out))
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
mouse <- combine_by_species(mouse_projs)
human <- combine_by_species(human_projs)



### Get gene lengths
# all counts files from same species need to use same set of genes

gene_lengths_mouse <- import_gene_lengths(mouse_projs[1])
gene_lengths_human <- import_gene_lengths(human_projs[1])




### Calculate TPMs
mouse <- tpm(DGEList(mouse, genes = data.frame(length = gene_lengths_mouse)))
human <- tpm(DGEList(human, genes = data.frame(length = gene_lengths_human)))




### import meta data
sample_id <- read.csv("metadata/sampleID.csv")
samples <- read.csv("metadata/samples.csv")
meta <- merge(samples, sample_id, by = 'group_id')

# outliers
outliers <- scan('metadata/outliers.txt', what = character())




### translate gene names using Biomart
mouse_dict <- translate(rownames(mouse), mart = useEnsembl("ensembl", dataset = 'mmusculus_gene_ensembl'))
human_dict <- translate(rownames(human), mart = useEnsembl("ensembl", dataset = 'hsapiens_gene_ensembl'))


################################################################
# export
################################################################

timestamp <- format(Sys.time(), "%b %d %Y")

save(mouse, human, meta, mouse_dict, human_dict, outliers, timestamp, file = save_output)
