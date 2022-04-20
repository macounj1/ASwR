  
#' svdmod
#' 
#' Computes SVD for each image label in training data
#' Returns SVDs truncated to either k components or percent variability
#' 
svdmod = function(data, labels, k = NULL, pct = NULL, plots = FALSE) {
  ## trains svd model for each label

  if(is.null(k) & is.null(pct)) 
    stop("svdmod: At least one of k and pct must be provided")
  
  ulabels = unique(labels)
  models = setNames(vector("list", length(ulabels)), ulabels)
  
  ## train on each label data
  for(label in ulabels) {
    labdat = unname(as.matrix(data[labels == label, ]))
    udv = La.svd(labdat)
    
    if(!is.null(k)) { # k components
      ik = 1:k
    } else { # pct variability
      cvar = cumsum(udv$d^2)
      ik = 1:(which(100*cvar/cvar[length(cvar)] >= pct))[1]
    }
    mod = list(d = udv$d[ik], u = udv$u[, ik], vt = udv$vt[ik, ], 
               k = length(ik), pct = 100*sum(udv$d[ik]^2)/sum(udv$d^2))
    models[[label]] = mod
  }
  if(plots) lapply(models, function(x) plot(1:length(x$d), cumsum(x$d^2)))
  models
}

#' predict_svdmod
#' 
#' Computes classification of new images in test data
#' 
predict_svdmod = function(test, models) {
  np = nrow(test)
  pred = rep(NA, np)
  mnames = names(models)
  mloss = matrix(NA, nrow = np, ncol = length(mnames))
  colnames(mloss) = mnames
  
  y = as.matrix(test)   ## removed loop and set y as matrix
  for(m in mnames) {
    vt = models[[m]]$vt
    yhat = y %*% t(vt) %*% vt  ## transpose of t(vt) %*% vt %*% y
    mloss[, m] = rowSums((y - yhat)^2)/ncol(y) ## rowSums instead of sum
  }
  pred = apply(mloss, 1, function(x) mnames[which.min(x)]) ## apply over rows
  pred
}

#' image_ggplot
#' 
#' Produces a facet plot of first few basis vectors as images
#' 
image_ggplot = function(images, ivals, title) {
  library(ggplot2)
  image = rep(ivals, 28*28)
  lab = rep("component", 28*28)
  image = factor(paste(lab, image, sep = ": "))
  col = rep(rep(1:28, 28), each = length(ivals))
  row = rep(rep(1:28, each = 28), each = length(ivals))
  im = data.frame(image = image, row = row, col = col, 
                  val = as.numeric(images[ivals, ]))
  print(
    ggplot(im, aes(row, col, fill = val)) + geom_tile() + facet_wrap(~ image) +
      ggtitle(title)
  )
}

#' model_report
#' 
#' reports a summary for each label model of basis vectors
#' optionally plots basis images
#' 
model_report = function(models, kplot = 0) {
  for(m in names(models)) {
    mk = min(kplot, models[[m]]$k)
    cat("Model", m, ": size ", models[[m]]$k, " var captured ", 
        models[[m]]$pct, " %\n", sep = "") 
    if(kplot) image_ggplot(models[[m]]$vt, 1:mk, paste("Digit", m))
  }
}

library(parallel)
library(ggplot2)
source("../mnist/mnist_read.R")
source("../code/flexiblas_setup.r")
blas_threads = as.numeric(commandArgs(TRUE)[2])
fork_cores = as.numeric(commandArgs(TRUE)[3])
setback("OPENBLAS")
setthreads(blas_threads)

## Begin CV (This CV is with mclapply. Exercise 8 needs MPI parallelization.)
## set up cv parameters
nfolds = 10
pars = seq(80.0, 95, .2)      ## par values to fit
folds = sample( rep_len(1:nfolds, nrow(train)), nrow(train) ) ## random folds
cv = expand.grid(par = pars, fold = 1:nfolds)  ## all combinations

## function for parameter combination i
fold_err = function(i, cv, folds, train) {
  par = cv[i, "par"]
  fold = (folds == cv[i, "fold"])
  models = svdmod(train[!fold, ], train_lab[!fold], pct = par)
  predicts = predict_svdmod(train[fold, ], models)
  sum(predicts != train_lab[fold])
}

## apply fold_err() over parameter combinations
cv_err = mclapply(1:nrow(cv), fold_err, cv = cv, folds = folds, train = train,
                  mc.cores = fork_cores)

## sum fold errors for each parameter value
cv_err_par = tapply(unlist(cv_err), cv[, "par"], sum)

## plot cv curve with loess smoothing (ggplot default)
pdf("Crossvalidation.pdf")
  ggplot(data.frame(pct = pars, error = cv_err_par/nrow(train)), 
         aes(pct, error)) + geom_point() + geom_smooth() +
    labs(title = "Loess smooth with 95% CI of crossvalidation")
dev.off()
## End CV

## recompute with optimal pct
models = svdmod(train, train_lab, pct = 85)
pdf("BasisImages.pdf")
  model_report(models, kplot = 9)
dev.off()
predicts = predict_svdmod(test, models)
correct <- sum(predicts == test_lab)
cat("Proportion Correct:", correct/nrow(test), "\n")
