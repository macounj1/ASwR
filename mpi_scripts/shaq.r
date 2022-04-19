
suppressMessages( library( kazaam ) )
source("shaq_rhdf5_section.r")

## create shaq class matrix from local pieces
B <- shaq( A, rowsA, ncol(A), checks = FALSE )

## svd ( shaq class: tall-skinny matrix )
Res <- svd( B, nu = 0, nv = 0 )

barrier( )

comm.cat( "results top( 16 ):", Res$d[ 1:16 ], "\n", quiet = TRUE )

## what's in shaq? (repeat "eigen only" without shaq class)
Ac <- allreduce( crossprod( A ) )
Res2 <- eigen( Ac, only.values = TRUE )
comm.cat( "results2 top( 16 ):", sqrt( Res2$values[ 1:16 ] ), "\n", quiet = TRUE )

finalize( )
