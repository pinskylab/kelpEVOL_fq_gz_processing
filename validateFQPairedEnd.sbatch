#!/bin/bash -l

# check to see if fastq files are formatted correctly

#SBATCH --job-name=vld8FQ
#SBATCH -o valiate_FQ_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env fastq_utils
export SINGULARITY_BIND=/home/e1garcia

dirPATH=$1
fqPATTERN=$2

: ${dirPATH:="."}

fileEXTENSIONS=($(ls $dirPATH/$fqPATTERN | sed 's/.*\(\.[rR]*[12]\.fa*s*t*q\.gz\)/\1/g' | sort | uniq))

ls $dirPATH/$fqPATTERN | \
  sed 's/\.[rR]*[12]\.fa*s*t*q\.gz//g' | \
  uniq | \
  parallel --no-notice -k crun.fastq_utils "fastq_info {}${fileEXTENSIONS[0]} {}${fileEXTENSIONS[0]}" > $dirPATH/fqValidationReport.txt

echo
echo Number of fq files evaluated: $(ls $dirPATH/$fqPATTERN | wc -l)
echo Number of fq files validated: $(grep -c "^OK$" $dirPATH/fqValidationReport.txt)
