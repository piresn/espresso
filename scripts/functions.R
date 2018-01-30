
process_ids <- function(input, idtype, ensembl, max) {
  
  out <- unlist(strsplit(input, split = '\n'))
  # limit to max number genes
  out <- out[1:max][!is.na(out[1:max])]
  
  if(idtype == 'GeneSymbol'){
    try({
      
      out <- getBM(attributes = c("ensembl_gene_id", "chromosome_name"),
                   filters = "external_gene_name",
                   values = out, mart = ensembl)
      
      # only allow genes annotated on the main chromosomes (i.e. remove alternate models on patches and haplotypes)
      # e.g. ABO has annotation in chromosome '9' and alternate in 'CHR_HG2030_PATCH'
      out <- subset(out, chromosome_name %in% c('X', 'Y', 'MT', as.character(seq(1, 22))))
      
      out <- unlist(out$ensembl_gene_id)
    })
  }
  return(out)
}

###########################################################
###########################################################

list_projects_sp <- function(sp){
  as.character(unique(subset(meta, species == sp)$project))
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
  
  # merge group infos
  x <- merge(x, meta, by = 'sample')
  
  return(x)
}

###########################################################
###########################################################

create_df <- function(species, genes, ensembl, experiment){
  
  x <- get(species)[genes, ]
  x$gene <- translate_ensembl(rownames(x), ensembl)
  x <- long_format(x)
  x <- subset(x, project %in% experiment)
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
    exp(mean(log(x + 1)))
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

express_plot <- function(x, gmeans, showmeans){
  
  breaks <- c(1 %o% 10^(-1:6))
  
  validate(need(nrow(x) > 0, 'Nothing to plot'))
  
  # match order groups between samples and replicate means
  x$group <- factor(x$group, levels = levels(gmeans$group))
  
  if(showmeans){
    
    g <- ggplot(data = gmeans, aes(x = group, y = gmean, fill = gene)) +
      geom_segment(aes(x=group, xend = group, y=0, yend = gmean, color = gene),
                   size = 2, alpha = 0.2, show.legend = FALSE) +
      geom_point(shape = 21, size = rel(5))
    
  }else{ 
    g <- ggplot(data = x, aes(x = sample, y = counts, fill = gene)) +
      facet_grid(group ~ .,
                 scales = "free_y",
                 space = "free_y",
                 switch = 'y', as.table = FALSE) +
      geom_segment(aes(xend = sample, y=0, yend = counts, color = gene),
                   size = 2, alpha = 0.3, show.legend = FALSE) +
      geom_point(shape = 21, size = rel(5)) +
      geom_hline(yintercept = 0) +
      scale_x_discrete(position = 'top')
  }
  
  g + scale_y_log10(breaks = breaks) +
    scale_fill_brewer(palette = 'Dark2') +
    scale_color_brewer(palette = 'Dark2') +
    labs(y = 'TPM (transcripts per million)') +
    coord_flip() +
    theme_classic(16) +
    theme(axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major.x = element_line(color = 'grey95'),
          axis.title.y = element_blank(),
          strip.text.y = element_text(angle = 180),
          strip.background = element_blank(),
          legend.title = element_blank(),
          legend.position = 'top')
}