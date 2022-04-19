library( pbdMPI, quietly = TRUE )
X <- as.matrix( iris[ , 1:4 ] )
k <- 3
comm.set.seed( seed = 123, diff = TRUE )
FUN <- function( n ) {
  isample <- sample( nrow(X), nrow(X), replace = TRUE )
  kmeans( X[ isample, ], k, iter.max = 100, nstart = 100 )$centers
}

my.means <- do.call( rbind, lapply( get.jid( 5000 ), FUN ) )
means <- gather( my.means )

if( comm.rank( ) == 0 ){
  means <- do.call( rbind, means )
  pdf( "means.pdf" )
    plot( X[ , c(1, 2) ], type = "n" )
    points( means[ , c(1, 2) ], col = rgb( 0, 0, 1, 0.2 ) )
    points( X[ , c(1, 2) ], col = iris[ , 5 ] )
  dev.off()
}
finalize()
