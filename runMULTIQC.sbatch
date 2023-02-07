#!/bin/bash -l

#this script runs multiqc on specified dir

#SBATCH --job-name=mqc
#SBATCH -o mqc-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
#module load container_env pire_genome_assembly/2021.07.01
#module load multiqc
module load container_env multiqc
#module load container_env fastqc

export SINGULARITY_BIND=/home/e1garcia

DIR=$1
REPORTNAME=$2

# run multiqc on the fp1, fp2 and fastq screen results

srun crun multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename $REPORTNAME --outdir $DIR $DIR
