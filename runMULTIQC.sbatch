#!/bin/bash -l

#this script runs multiqc on specified dir

#SBATCH --job-name=mqc
#SBATCH -o fastp_2nd_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env pire_genome_assembly/2021.07.01

export SINGULARITY_BIND=/home/e1garcia

DIR=$1
REPORTNAME=$2

# run multiqc on the fp2 results

crun multiqc $DIR -n $DIR/$REPORTNAME
