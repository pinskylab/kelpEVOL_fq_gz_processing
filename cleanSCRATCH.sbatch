#!/bin/bash -l

#SBATCH --job-name=clnCLMP
#SBATCH -o clean_clumpify_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=20

enable_lmod
module load container_env pire_genome_assembly/2021.07.01

# this code is requires if the input files don't live within your own parent directory
# modify "e1garcia" to the user ID where the files are located
export SINGULARITY_BIND=/home/e1garcia


TMPDIR=$1                 #example= /scratch/e1garcia
PATTERN=$2                #example= "*clumpify*temp*"
THREADS=20



find ${TMPDIR} -name ${PATTERN} -print0 | xargs -0 -P $THREADS rm 

