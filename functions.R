
process_ids <- function(input, idtype, ensembl, max) {
  
  out <- unlist(strsplit(input, split = '\n'))
  # limit to max number genes
  out <- out[1:max][!is.na(out[1:max])]
  
  if(idtype == 'GeneSymbol'){
    try(out <- unlist(getBM(attributes = c("ensembl_gene_id"),
                            filters = "external_gene_name",
                            values = out, mart = ensembl)))
  }
  return(out)
}

###########################################################
###########################################################

translate_ensembl <- function(x, ensembl){
  
  out <- c()
  
  for(i in x){
    a <- ""
    try(a <- unlist(getBM(attributes = c("external_gene_name"),
                          filters = "ensembl_gene_id",
                          values = i, mart = ensembl)), silent = TRUE)
    
    if(length(a) > 0){
      out <- c(out, a)
    } else {
      out <- c(out, i)
    }
  }
  
  if(length(out) == 0) {return(character(0))}
  return(out)
}


long_format <- function(x){
  
  # fill with one row NAs in case x is empty
  if(nrow(x) == 0) {
    x$gene <- character(0)
  }
  
  # remove NAs from gene
  x <- x[complete.cases(x),]
  
  x <- melt(x, id.vars = c('gene'),
            variable.name = "sample",
            value.name = "counts")
  
  # match group infos
  x$sample <- as.character(x$sample)
  id <- samples[match(x$sample, samples$sample), 'id']
  x$group <- factor(sample_id[match(id, sample_id$id), "group"])
  
  return(x)
}


create_df <- function(species, genes, ensembl){
  
  x <- get(species)[genes,]
  
  x$gene <- translate_ensembl(rownames(x), ensembl)
  
  x <- long_format(x)
}


###########################################################
###########################################################

infoTable <- function(genes, ensembl){
  
  out <- data.frame()
  
  try({
    out <- getBM(attributes = c("ensembl_gene_id", "external_gene_name"),
                 filters = "ensembl_gene_id",
                 values = genes, mart = ensembl)
    
    colnames(out) <- c('EnsemblID', 'Symbol')
  })
  
  if(nrow(out) == 0){return(data.frame())}
  return(out)
}

###########################################################
###########################################################

calc_gmeans <- function(x){
  
  geom_mean <- function(x){
    exp(mean(log(x + 0.1)))
  }
  
  find_order <- function(x){
    top_gene <- x[1, "gene"]
    as.character(x[x$gene == top_gene, "group"])
  }
  
  y <- x %>%
    group_by(group, gene) %>%
    summarise(gmean = geom_mean(counts)) %>%
    arrange(desc(gmean))
  
  y <- as.data.frame(y)
  y$group <- factor(y$group, levels = rev(find_order(y)))
  
  return(y)
}

###########################################################
###########################################################

express_plot <- function(x, gmeans, reps){
  
  validate(need(nrow(x) > 0, 'Nothing to plot'))
  
  # match order groups between samples and replicate means
  x$group <- factor(x$group, levels = levels(gmeans$group))
  
  if(reps){
    
    g <- ggplot(data = gmeans, aes(x = group, y = counts,
                                   fill = gene)) +
      geom_point(aes(x = group, y = gmean),
                 shape = 21, size = rel(5)) +
      geom_point(data = x, aes(y = counts, color = gene), shape = 16,
                 size = rel(2.5), alpha = 0.3)
    
    
  }else{ 
    g <- ggplot(data = x, aes(x = sample, y = counts, fill = gene)) +
      facet_grid(group ~ .,
                 scales = "free_y", space = "free_y",
                 switch = "y", as.table = FALSE) + 
      geom_point(shape = 21, size = rel(3))
    
  }
  
  g + scale_y_log10() +
    scale_fill_brewer(palette = 'Set2') +
    scale_color_brewer(palette = 'Set2') +
    coord_flip() +
    theme_minimal(12)
}