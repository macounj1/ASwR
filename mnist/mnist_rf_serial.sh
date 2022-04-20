#!/bin/bash
#PBS -N mnist_rf
#PBS -l select=1:ncpus=128,walltime=00:50:00
#PBS -q qexp
#PBS -e mnist_rf.e
#PBS -o mnist_rf.o

cd ~/KPMS-IT4I-EX/mnist
pwd

module load R
echo "loaded R"

time Rscript mnist_rf_serial.R
