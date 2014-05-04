library(raster)
library(sp)
setwd("C:/Users/hkujala/work/Species influence/src/Zonation runs/Test data")


names <- c('Sp1', 'Sp2', 'Sp3', 'Sp4', 'Sp5', 'Sp6', 'Sp7')
results <- data.frame(names,NA)
colnames(results) <- c('Species', 'Rank_diff')


out_all <- raster('Output/out_all.rank.asc')
for (i in 1:length(names)){
  out_1missing <- raster(paste0('Output/out_missing', names[i], '.rank.asc'))
  diff <- out_all - out_1missing
  results[i,2] <- sum(abs(getValues(diff)), na.rm=T)
}

results
