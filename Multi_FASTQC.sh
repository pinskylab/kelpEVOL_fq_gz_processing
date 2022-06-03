#!/bin/bash -l

#SBATCH --job-name=Multi_fastqc
#SBATCH -o Multi_fastqc-%j.out
#SBATCH -p main
#SBATCH -c 32

############# Multi_FASTQC.sh ###################
## runs FASTQC and MultiQC reports in parallel ##
##   contact: Eric Garcia, e1garcia@odu.edu    ##
##  ceb updated this 2022-06-02                ##
#################################################

## Requirements: parallel, fastqc, and multiqc in current session 
## To execute, type in the command line (do include quotes):
# sbatch Multi_FASTQC.sh "<extension of files to be processed in quotations>" "<full path to directory with the files to be processed>"


#### Details

# Multi_FASTQC.sh is a simple sbatch script that runs FASTQC and MultiQC reports in parallel with a single command 
# Results will be directed to a newly created sub-directory called Multi_FASTQC 
# For FASQC options use <fasqc --help> or visit  https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
# For MultiQC options use <multiqc --help> or visit  https://multiqc.info/

## Script Usage:
# 1.- Set the above slurm settings (#SBATCH) according to your system 
# 2.- Load parallel, fastqc and multiqc according to your system. Example:

enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc
export SINGULARITY_BIND=/home/e1garcia

# 3.- Execute the script
# in the command line, type "sbatch", the name of the script <Multi_FASTQC.sh>, the suffix identifying the files to be analyzed in quotations. The last can be file extensions or any other shared file identifier at the end of the files' names, and the full path to the directory containing the files to be processed
# example: <sbatch Multi_FASTQC.sh ".fq.gz" "home/e1garcia/shotgun/Tzo/shotgun_raw_fq/">

# Alternately, the suffix can be replaced by any regex expression that correctly identifies the files to be processed.
# If such regex does not occur at the end of file names, you'll need to remove the wild card " * " in the first fastqc statement in line 50

# Multi_FASTQC.sh has been tested in "fq", "fq.gz" and "bam" files.

#inDIR=$(echo $1 | sed 's/\\/$//')
inDIR=$1
PATTERN=$2

#run fastqc in parallel 
ls ${inDIR}/*${PATTERN} | parallel --no-notice -j32 "crun fastqc {}"

# run multiqc with specific report and subdirectory names
crun multiqc $inDIR -n $inDIR/fastqc_report

# move fastqc files to new subdirectory
#ls *fastqc.html | parallel -kj 32 "mv {} ../Multi_FASTQC" &&
#ls *fastqc.zip | parallel -kj 32 "mv {} ../Multi_FASTQC"
mv *out ../logs
