#!/bin/sh

#SBATCH --job-name=find_word
#SBATCH --mem=2G
#SBATCH --nodes=1



module load R

srun bash stream_find_word.sh
