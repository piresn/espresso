list_projects_sp <- function(sp){
  as.character(unique(subset(meta, species == sp)$project))
}


create_df <- function(species, genes, ensembl, experiment){
  
  x <- get(species)[genes, ]
  
  if(TRUE){
    tmp <- subset(meta, project %in% experiment)$sample
    x <- x[, tmp]
  }

  
  x$gene <- translate_ensembl(rownames(x), ensembl)
  
  x <- long_format(x)
}