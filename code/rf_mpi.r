library(randomForest)
library(pbdMPI)
data(LetterRecognition, package = "mlbench")
comm.set.seed(seed = 7654321, diff = FALSE)

n = nrow(LetterRecognition)
n_test = floor(0.5 * n)
i_test = sample.int(n, n_test)
train = LetterRecognition[-i_test, ]
test = LetterRecognition[i_test, ][get.jid(n_test), ]

comm.set.seed(seed = 1e6 * runif(1), diff = TRUE)
my.rf = randomForest(lettr ~ ., train, ntree = 100 %/% comm.size(), norm.votes = FALSE)
rf.all = allgather(my.rf)
rf.all = do.call(combine, rf.all)
pred = as.vector(predict(rf.all, test))

sse = sum((pred - test$lettr)^2)
comm.cat("MSE =", reduce(sse)/n_test, "\n")

finalize()
