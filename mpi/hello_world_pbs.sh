#!/bin/bash
#PBS -N hw
#PBS -l select=1:mpiprocs=8,walltime=00:00:15
#PBS -q qexp
#PBS -e hw.e
#PBS -o hw.o

cd ~/KPMS-IT4I-EX/mpi
pwd

## module names can vary on different platforms
module load R
echo "loaded R"

# Fix for warnings from libfabric/1.12 bug
module swap libfabric/1.12.1-GCCcore-10.3.0 libfabric/1.13.2-GCCcore-11.2.0 

time mpirun -np 8 Rscript hello_world.R
