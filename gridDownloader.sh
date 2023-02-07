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

# use that list to download all files in parallel.
cat $1/tamucc_files.txt | grep '^[-d]' | tr -s " " | cut -d " " -f9 | parallel --no-notice -kj40 wget -c -P $1 $2/{}
echo -e "\nFirst download completed.\nDownloading again in case partial downloads\n" 

# Second download to check for partial downloads
cat $1/tamucc_files.txt | grep '^[-d]' | tr -s " " | cut -d " " -f9 | parallel --no-notice -kj40 wget -c -P $1 $2/{}
echo -e "\nSecond download completed" 

# Checking sizes of files from source and lpwd
echo -e "Comparing file sizes from source and lpwd with (grep -vf)"

cd $1
cat tamucc_files.txt | grep '[zv]$' | tr -s " " | cut -d " " -f5,9 > tamucc_gzfiles
ls -lh *[zv] | tr -s " " | cut -d " " -f5,9 > odu_gzfiles

grep -vf tamucc_gzfiles odu_gzfiles > files_wDiff_sizes

if [[ -s files_wDiff_sizes ]]
then 
        echo -e "\nFiles with different sizes detected. Offending file(s) printed in files_wDiff_sizes. Please check files_wDiff_sizes and compare tamucc_files.txt with current downloaded data"
	rm tamucc_gzfiles odu_gzfiles
else 
	echo -e "\nNo size mismatch in files was detected"
        rm tamucc_gzfiles odu_gzfiles files_wDiff_sizes
fi

echo -e "\nIf your download did not work at all, click on the link to the files and visually check in your browser that there is a file named tamucc_files.txt or contact Eric e1garcia@odu.edu"

