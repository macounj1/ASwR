
source("mnist_read.R")

library(parallel)
library(randomForest)
set.seed(seed = 123, "L'Ecuyer-CMRG")

n = nrow(train)
n_test = nrow(test)

ncb = as.numeric(commandArgs(TRUE)[2])
cat("Build time (", ncb, "): \n")
system.time({
  ntree = lapply(splitIndices(512, ncb), length)
  rf = function(x, train, lab) 
    randomForest(train, y = lab, ntree=x, norm.votes = FALSE)
  rf.out = mclapply(ntree, rf, train = train, lab = train_lab, mc.cores = ncb)
  rf.all = do.call(combine, rf.out)
})

nct = as.numeric(commandArgs(TRUE)[3])
cat("Predict time (", nct, "): \n")
system.time({
  crows = splitIndices(nrow(test), nct) 
  rfp = function(x, rf.all, test) as.vector(predict(rf.all, test[x, ])) 
  cpred = mclapply(crows, rfp, rf.all = rf.all, test = test, mc.cores = nct) 
  pred = do.call(c, cpred) 
})

correct <- sum(pred == test_lab)
cat("Proportion Correct:", correct/(n_test), "\n")
