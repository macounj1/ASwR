library(randomForest)
data(LetterRecognition, package = "mlbench")
set.seed(seed = 123, "L'Ecuyer-CMRG")

n = nrow(LetterRecognition)
n_test = floor(0.2 * n)
i_test = sample.int(n, n_test)
train = LetterRecognition[-i_test, ]
test = LetterRecognition[i_test, ]

ntree = 200
nfolds = 10
mtry_val = 1:(ncol(train) - 1)
folds = sample( rep_len(1:nfolds, nrow(train)), nrow(train) )
cv_df = data.frame(mtry = mtry_val, incorrect = rep(0, length(mtry_val)))
cv_pars = expand.grid(mtry = mtry_val, f = 1:nfolds)


###
fold_err = function(i, cv_pars, folds, train) {
  mtry = cv_pars[i, "mtry"]
  fold = (folds == cv_pars[i, "f"])
  rf.all = randomForest(lettr ~ ., train[!fold, ], ntree = ntree,
                        mtry = mtry, norm.votes = FALSE)
  
  ### FH 16.3.2022 18:04
  #rf.out = mclapply(ntree, 
  #                  function(x) randomForest(lettr ~ .,
  #                                           train, ntree=x, mtry = mtry,
  #                                           norm.votes = FALSE),
  #                  mc.cores = nc)
  #rf.all = do.call(combine, rf.out)
  ### FH 16.3.2022 18:04
  
  pred = predict(rf.all, train[fold, ])
  sum(pred != train$lettr[fold])
}


nc = as.numeric(commandArgs(TRUE)[1])
cat("Running with", nc, "cores\n")
system.time({
cv_err = parallel::mclapply(1:nrow(cv_pars), fold_err, cv_pars, folds = folds,
                              train = train, mc.cores = nc) 
err = tapply(unlist(cv_err), cv_pars[, "mtry"], sum)
})

pdf(paste0("rf_cv_mc", nc, ".pdf")); plot(mtry_val, err/(n - n_test)); dev.off()

rf.all = randomForest(lettr ~ ., train, ntree = ntree)
### FH 16.3.2022 18:00
#rf.out = mclapply(ntree, 
#                  function(x) randomForest(lettr ~ .,
#                                           train, ntree=x,
#                                           norm.votes = FALSE),
#                  mc.cores = nc)
#rf.all = do.call(combine, rf.out)
### FH 16.3.2022 18:00
pred = predict(rf.all, test)
correct = sum(pred == test$lettr)

mtry = mtry_val[which.min(err)]
rf.all = randomForest(lettr ~ ., train, ntree = ntree, mtry = mtry)
### FH 16.3.2022 18:00
#rf.out = mclapply(ntree, 
#                  function(x) randomForest(lettr ~ .,
#                                           train, ntree=x, mtry = mtry,
#                                           norm.votes = FALSE),
#                  mc.cores = nc)
#rf.all = do.call(combine, rf.out)
### FH 16.3.2022 18:00
pred_cv = predict(rf.all, test)
correct_cv = sum(pred_cv == test$lettr)
cat("Proportion Correct: ", correct/n_test, "(mtry = ", floor((ncol(test) - 1)/3),
    ") with cv:", correct_cv/n_test, "(mtry = ", mtry, ")\n", sep = "")

