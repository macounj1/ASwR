suppressMessages( library( rhdf5 ) )
suppressMessages( library( pbdIO ) )

filename <- "big_hdf5_data.h5"
dataset  <- "/dataset"

## get and broadcast the number of rows to all processors
if ( comm.rank() == 0 ) {
   h5f <- H5Fopen( filename )
   h5d <- H5Dopen( h5f, dataset )
   h5s <- H5Dget_space( h5d )
   rowsA <- H5Sget_simple_extent_dims( h5s )$size[1]

   H5Dclose( h5d )
   H5Fclose( h5f )
} else {
   rowsA <- 0
}
rowsA <- bcast( rowsA )

## get my local row indices
my_rows <- comm.chunk( rowsA, form = "vector", type = "balance" )

## parallel read of local data
A <- h5read(filename, dataset, index=list( my_rows, NULL ) )
H5close( )
