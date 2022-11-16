#!/bin/bash -l

#this script runs multiqc on specified dir

#SBATCH --job-name=mqc
#SBATCH -o mqc-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
module load multiqc

export SINGULARITY_BIND=/home/e1garcia

DIR=$1
REPORTNAME=$2

# run multiqc on the fp1, fp2 and fastq screen results

srun crun multiqc $DIR -n $DIR/$REPORTNAME --interactive
