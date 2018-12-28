#!/bin/sh

#SBATCH --job-name stream_find_word

module load R

srun bash stream_find_word.sh
