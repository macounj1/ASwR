suppressMessages( library( rhdf5 ) )
suppressMessages( library( pbdIO ) )

filename = "/scratch/project/dd-21-42/data/mnist/train.hdf5"
dataset1  = "image"
dataset2  = "label"

## get and broadcast dimensions to all processors
if ( comm.rank() == 0 ) {
   h5f = H5Fopen( filename, flags="H5F_ACC_RDONLY")
   h5d = H5Dopen( h5f, dataset1 )
   h5s = H5Dget_space( h5d )
   dims = H5Sget_simple_extent_dims( h5s )$size
   H5Dclose( h5d )
   H5Fclose( h5f )
} else dims = NA
dims = bcast( dims ) 

## get my local indices for contiguous data read
nlast = dims[length(dims)] # last dim moves slowest
my_ind = comm.chunk( nlast, form = "vector" )

## parallel read of local data
my_train = as.double( h5read( filename, dataset1, index = list( NULL, NULL, my_ind ) ))
my_train_lab = as.character( h5read( filename, dataset2, index = list( my_ind ) ) )
H5close( )

dim( my_train ) = c( prod( dims[-length(dims)] ), length(my_ind) )
my_train = t( my_train )  # now it's rowblock

## plot for debugging
# if(comm.rank() == 0) {
#   ivals = sample(nrow(train), 36)
#   library(ggplot2)
#   image = rep(ivals, 28*28)
#   lab = rep(train_lab[ivals], 28*28)
#   image = factor(paste(image, lab, sep = ": "))
#   col = rep(rep(1:28, 28), each = length(ivals))
#   row = rep(rep(1:28, each = 28), each = length(ivals))
#   im = data.frame(image = image, row = row, col = col, 
#                   val = as.numeric(unlist(train[ivals, ])))
#   ggplot(im, aes(row, col, fill = val)) + geom_tile() + facet_wrap(~ image)
# }

comm.print( dim(my_train), all.rank = TRUE )

finalize( )