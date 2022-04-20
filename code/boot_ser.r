#zkouska gitu
library(boot)
cd4.rg = function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
cd4.mle = list(m = colMeans(cd4), v = var(cd4))
cd4.boot = boot(cd4, corr, R = 999, sim = "parametric", ran.gen = cd4.rg,
                 mle = cd4.mle)
boot.ci(cd4.boot,  type = c("norm", "basic", "perc"), conf = 0.9, h = atanh,
        hinv = tanh)


cd4.rg = function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
cd4.mle = list(m = colMeans(cd4), v = var(cd4))
run1 = function(...) boot(cd4, corr, R = 5000, sim = "parametric",
                           ran.gen = cd4.rg, mle = cd4.mle)
mc = 4 # set as appropriate for your hardware
set.seed(123, "L'Ecuyer") # for reproducibility
system.time({
  cd4.boot = do.call(c, parallel::mclapply(1:mc, run1))
})
boot.ci(cd4.boot, type = c("norm", "basic", "perc"), conf = 0.9,
          h = atanh, hinv = tanh)
system.time(
  do.call(c, lapply(1:mc, run1))
)

run1 <- function(...) {
  library(boot)
  cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
  cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
  boot(cd4, corr, R = 500, sim = "parametric", ran.gen = cd4.rg, mle = cd4.mle) 
}
cl <- makeCluster(mc)

## make this reproducible
clusterSetRNGStream(cl, 123)
library(boot) # needed for c() method on master
cd4.boot <- do.call(c, parLapply(cl, seq_len(mc), run1) )
boot.ci(cd4.boot,  type = c("norm", "basic", "perc"),
         conf = 0.9, h = atanh, hinv = tanh)
stopCluster(cl)