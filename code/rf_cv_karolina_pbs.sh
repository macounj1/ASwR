#!/bin/bash
#PBS -N rf
#PBS -l select=1:ncpus=128,walltime=00:50:00
#PBS -q qexp
#PBS -e rf_cv.e
#PBS -o rf_cv.o

cd ~/ASwR/code
pwd

module load R
echo "loaded R"

#time Rscript rf_cv_serial.r
#time Rscript rf_cv_mc.r 8
#time Rscript rf_cv_mc.r 16
time Rscript rf_cv_mc.r 32
time Rscript rf_cv_mc.r 64
time Rscript rf_cv_mc.r 128
