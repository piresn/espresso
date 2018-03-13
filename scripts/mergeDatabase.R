# run from the command line:
#
#   Rscript mergeDatabase.R [db1] [db2]
#
#

args <- commandArgs(TRUE)

env1 <- new.env()
env2 <- new.env()

cat('Loading data...\n')
load(args[1], envir = env1)
load(args[2], envir = env2)


###################################################
# merge RPKM files
###################################################

cat('Merging RPKMs...\n')

for(i in paste0(c('mouse', 'human'), '_RPKM')){
  
  x <- get(i, envir = env1)
  y <- get(i, envir = env2)
  
  if(any(colnames(x) %in% colnames(y))){
    stop("Identical sample names in the 2 databases.")
  }
  
  tmp <- merge(x = x, y = y,
               by = 0, all.x = TRUE)
  
  rownames(tmp) <- tmp$Row.names
  tmp$Row.names <- NULL
  assign(i, tmp)
}

###################################################
# merge metadata
###################################################

if(!all(colnames(env1$meta) == colnames(env2$meta))){
  stop(cat('\nMetadata tables columns do not match.',
           '\n database 1: ', colnames(env1$meta),
           '\n database 2: ', colnames(env2$meta)))
}

meta <- rbind(env1$meta, env2$meta)

###################################################
# use dictionary (Ensembl <-> Gene symbols) from database 1
###################################################

for(i in paste0(c('mouse', 'human'), '_dict')){
  assign(i, get(i, envir = env1))
}

###################################################
# merge outliers lists
###################################################

outliers <- c(env1$outliers, env2$outliers)

################################################################
# export
################################################################

timestamp <- Sys.time()

outfile <- 'merged.Rdata'
cat(paste('Saving database as', outfile, '...'))

save(mouse_RPKM, human_RPKM, meta, mouse_dict, human_dict, outliers, timestamp,
     file = outfile)

cat('\nFinished.\n')
