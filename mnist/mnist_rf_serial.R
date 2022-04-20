source("../mnist/mnist_read.R")
library(randomForest)
set.seed(seed = 123)

n = nrow(train)
n_test = nrow(test)

all_rf = randomForest(train, y = train_lab, ntree = 512, norm.votes = FALSE)

pred = predict(all_rf, test)

correct = sum(pred == test_lab)
cat("Proportion Correct:", correct/(n_test), "\n")
