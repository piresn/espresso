
process_ids <- function(input, idtype, dict, max) {
  
  x <- unlist(strsplit(input, split = '\n'))
  # limit to max number genes
  x <- x[1:max][!is.na(x[1:max])]
  
  if(idtype == 'GeneSymbol') x <- dict[toupper(dict$name) %in% toupper(x), 'Ensembl']
  
  return(x)
}

###########################################################
###########################################################

list_projects_sp <- function(sp){
  as.character(unique(subset(meta, species == sp)$project))
}

###########################################################
###########################################################

translate_ensembl <- function(x, dict){
  
  out <- c()
  
  for(i in x){
    
    a <- dict[dict$Ensembl == i, 'name']
    
    if(length(a) > 0) out <- c(out, a)
    else out <- c(out, i)
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

calc_TPM <- function(x, sum_rpkm){
  1e6 * sweep(x, 2, sum_rpkm, '/')
}

###########################################################
###########################################################

create_df <- function(species, metric, genes, dict, experiment, outliers_list){
  
  x <- get(paste(species, 'RPKM', sep = '_'))[genes, ]
  
  if(metric == 'TPM') x <- calc_TPM(x, get(paste0(species, '_sumRPKM')))
  
  x$gene <- translate_ensembl(rownames(x), dict)
  x <- long_format(x)
  x <- subset(x, project %in% experiment)
  
  #remove samples in outliers list
  x <- x[!x$sample %in% outliers_list,]
  
  return(x)
}

###########################################################
###########################################################

infoTable <- function(genes = NULL, dict = NULL, species = NULL){
  
  if(!is.null(genes) & !is.null(dict)){
    
    out <- dict[dict$Ensembl %in% genes, c('name', 'Ensembl')]
    
    if(nrow(out) > 0){

      out$more <- paste0('<a target = "_blank" href="https://www.ncbi.nlm.nih.gov/gene/?term=',
                         out$Ensembl,'"><img src="ncbi.ico" title="NCBI Gene"/></a>',
                         ' ',
                         '<a target = "_blank" href="https://www.ebi.ac.uk/gxa/genes/',
                         out$Ensembl,'"><img src="ebi.ico" title="EBI Expression Atlas"/></a>')

    }
    return(out)
  }
}

###########################################################
###########################################################

calc_gmeans <- function(x){
  
  geom_mean <- function(x){
    exp(mean(log(x + 0.01)))
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

express_plot <- function(x, gmeans, showmeans, metric){
  
  breaks <- c(1 %o% 10^(-1:6))
  
  validate(need(nrow(x) > 0, 'Nothing to plot'))
  
  # match order groups between samples and replicate means
  x$group <- factor(x$group, levels = levels(gmeans$group))
  
  # X axis title
  axis_title <- metric
  
  if(showmeans){
    
    g <- ggplot(data = gmeans, aes(x = group, y = gmean, fill = gene)) +
      geom_segment(aes(x=group, xend = group, y=0, yend = gmean, color = gene),
                   size = 2, alpha = 0.2, show.legend = FALSE) +
      geom_point(shape = 21, size = rel(5))
    
  }else{ 
    g <- ggplot(data = x, aes(x = sample, y = counts + 0.01, fill = gene)) +
      facet_grid(group ~ .,
                 scales = "free_y",
                 space = "free_y",
                 switch = 'y', as.table = FALSE) +
      geom_segment(aes(xend = sample, y=0, yend = counts + 0.01, color = gene),
                   size = 2, alpha = 0.3, show.legend = FALSE) +
      geom_point(shape = 21, size = rel(5)) +
      geom_hline(yintercept = 0) +
      scale_x_discrete(position = 'top') +
      theme(axis.text.y = element_text(colour = 'gray80', size = 8))
      
      
  }
  
  g + scale_y_log10(breaks = breaks, expand = c(0.05, 0),
                    labels = function(n){
                      format(n, drop0trailing = TRUE, scientific = FALSE)},
                    name = axis_title) +
    expand_limits(y = 0.1) +
    scale_fill_brewer(palette = 'Dark2') +
    scale_color_brewer(palette = 'Dark2') +
    coord_flip() +
    theme(axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major.x = element_line(color = 'grey95'),
          axis.title.y = element_blank(),
          strip.text.y = element_text(angle = 180, hjust = 1),
          strip.background = element_blank(),
          legend.title = element_blank(),
          legend.position = 'top',
          plot.margin = unit(c(1, 1, 1, 1), "cm"))
}