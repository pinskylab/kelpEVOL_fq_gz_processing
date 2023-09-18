#!/bin/bash -l

# check to see if fastq files are formatted correctly

#SBATCH --job-name=vld8FQ
#SBATCH -o valiate_FQ_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env fastq_utils
export SINGULARITY_BIND=/home/e1garcia

fqPATTERN=$1

ls $fqPATTERN | \
  parallel --no-notice crun.fastq_utils "fastq_info {} > {}.validation"

echo
echo Number of fq files: $(ls $fqPATTERN | wc -l)
echo Number of fq files checked: $(ls *validation | wc -l)
echo Number of fq files validated: $(grep "^OK$" *validation)
