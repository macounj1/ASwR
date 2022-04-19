source("../mnist/mnist_read.R")
suppressMessages(library(randomForest))
suppressMessages(library(pbdIO))
comm.set.seed(seed = 123, diff = TRUE)

n = nrow(train)
n_test = nrow(test)
my_trees = comm.chunk(512)
my_test_rows = comm.chunk(nrow(test), form = "vector")

my_rf = randomForest(train, y = train_lab, ntree = my_trees, norm.votes = FALSE)
all_rf = allgather(my_rf)
all_rf = do.call(combine, all_rf)

my_pred = as.vector(predict(all_rf, test[my_test_rows, ]))

correct = reduce(sum(my_pred == test_lab[my_test_rows]))
comm.cat("Proportion Correct:", correct/n_test, "\n")

finalize()
