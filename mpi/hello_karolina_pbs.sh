#!/bin/bash
#PBS -N balance
#PBS -l select=2:mpiprocs=32,walltime=00:00:15
#PBS -q qexp
#PBS -e balance.e
#PBS -o balance.o

cat $BASH_SOURCE 
cd ~/KPMS-IT4I-EX/mpi
pwd

## module names can vary on different platforms
module load R
echo "loaded R"

## prevent warning when fork is used with MPI
export OMPI_MCA_mpi_warn_on_fork=0
export RDMAV_FORK_SAFE=1

# Fix for warnings from libfabric/1.12 bug
module swap libfabric/1.12.1-GCCcore-10.3.0 libfabric/1.13.2-GCCcore-11.2.0 

time mpirun --map-by ppr:16:node Rscript hello_balance.R
