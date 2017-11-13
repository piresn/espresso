################################ 
# import counts data
################################ 

mouse <- read.csv('dummydata/mouse.csv', row.names = 1)
human <- read.csv('dummydata/human.csv', row.names = 1)

################################ 
# meta data
################################

sample_id <- read.csv("dummydata/sampleID.csv")
samples <- read.csv("dummydata/samples.csv")

# make names comparable: sample names in headers had "-" replaced by "."s
# make the same for samples file:
levels(samples$sample) <- gsub('-', '.', levels(samples$sample))
samples$sample <- as.character(samples$sample)


# merge
meta <- merge(samples, sample_id, by = 'group_id')


################################
# export
################################

timestamp <- format(Sys.time(), "%b %d %Y")

save(mouse, human, meta, timestamp, file = 'dummydata/data.Rdata')
