#!/bin/bash

#SBATCH --job-name=Wget
#SBATCH -o Wget-%j.out
#SBATCH --time=00:00:00
#SBATCH --exclusive
#SBATCH --ntasks=40
#SBATCH -p main

# this script download files (meant for fq.gz files) from TAMUCC "whebshare/grid"

# EXECUTE
# First, locate the grid parent directory (which is just a website link) where the files will be downloaded from. Usually Sharon will post this in the species slack channel.
# visually check in your browser that there is a file named tamucc_files.txt, which list the rest of the files in that directory
# execute as "sbatch grid_wget.sh <outdir> <link-to-files>

module load parallel
export SINGULARITY_BIND=/home/e1garcia  #odu

# downlownd the list of lifes
wget -P $1 $2/tamucc_files.txt

# use that list to download all files in parallel
cat $1/tamucc_files.txt | parallel --no-notice -kj40 wget -P $1 $2/{}

echo "If your download failed, click on the link to the files and visually check in your browser that there is a file named tamucc_files.txt or contact Eric e1garcia@odu.edu"
