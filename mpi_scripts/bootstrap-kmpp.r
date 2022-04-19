### file "bootstrap_kmpp.r"
library(pbdMPI, quietly = TRUE)
X <- as.matrix(iris[, 1:4])
k <- 3
comm.set.seed(seed = 123, diff = TRUE)
FUN <- function(n) {
  isample <- sample(nrow(X), nrow(X), replace = TRUE)
  kmeans(X[isample, ], k, iter.max = 100, nstart = 100)$centers
}
my.samples <- get.jid(5000)
my.means <- do.call(rbind, lapply(my.samples, FUN))
means <- do.call(rbind, allgather(my.means))

plots <- combn(ncol(X), 2)
my.plots <- plots[, get.jid(ncol(plots)), drop = FALSE]
plotFUN <- function(cols) {
  pdf(paste(k, "means", paste(cols, collapse = "-"), ".pdf", sep = ""))
    plot(X[, cols], type = "n")
    points(means[, cols], col = rgb(0, 0, 1, 0.2))
    points(X[, cols], col = iris[, 5])
  dev.off()
}
bits <- apply(my.plots, 2, plotFUN)
finalize()
