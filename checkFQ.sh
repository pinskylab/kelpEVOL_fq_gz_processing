#!/bin/bash

#SBATCH --job-name=checkFQ
#SBATCH -o log-checkFQ-%j.out
#SBATCH -p main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --exclusive

# Normal fq.gz files would have the following format: Blocked GNU Zip Format (BGZF; gzip compatible), block length xxxxxx
# Alternative formats do not necessarily cause problems but they should be checked

echo -e "############  checkFQ.sh  ############\nThis script checks the zip and fastq\nformat in your .fq.gz files. Files with\npotentially problematic zip or fastq\nformats will be printed here and\nrespectively saved to:\n\nfiles_w_alternative_zip_format.txt\nfiles_w_bad_fastq_format.txt\n\nYou might want to try to redownload\nthese .fq.gz files and/or check for\nissues with the formats\n######################################\n\n"

# Directory with .fq.gz files
FQGZDIR=$1

#Move to working dir
cd $FQGZDIR

# Check the file format of each .fq.gz
ls *fq.gz | parallel --no-notice -kj40 file {} > file_types.txt

# Print files without Blocked GNU Zip Format
echo -e "Checking if any fq.gz file has another format other than <Blocked GNU Zip Format>.\nIf all downloaded files have the format: Blocked GNU Zip Format, files_w_alternative_zip_format.txt will be empty\n\n"

mkdir -p fqgz_fileCheck
echo "Files with an alternative zip format:"
cat file_types.txt | grep -v 'Blocked GNU Zip Format'
cat file_types.txt | grep -v 'Blocked GNU Zip Format'> files_w_alternative_zip_format 
mv file_types.txt fqgz_fileCheck

# Checking that files have proper FASTQ format (4 lines per sequence, where the 3rd is a "+")
echo -e "\nChecking if files have proper FASTQ format (4 lines per sequence, where the 3rd is a +)\nIf all files have proper fastq format files_w_bad_fastq_format.txt will not be created\n"

ls *fq.gz | sed 's/\.fq\.gz//' | parallel --no-notice -kj40 "zcat {}.fq.gz | paste - - - - | cut -f3 | sort | uniq -c > fqgz_fileCheck/{}.third_column.txt"

# Iterate through each file in the directory
for file in fqgz_fileCheck/*third_column.txt; do
    # Check if the file is a regular file and not a directory
    if [ -f "$file" ]; then
        line_count=$(wc -l < "$file")
	BASE=$(echo $file | sed -e 's/.*\///' -e 's/\.third_column\.txt//')
        if [ $line_count -gt 1 ]; then
		echo "File with one or more reads WITHOUT proper fastq format: $BASE.fq.gz"
		echo "$BASE.fq.gz" >> files_w_bad_fastq_format.txt
        elif [ $line_count -eq 1 ]; then
            echo "File with proper fastq format: $BASE.fq.gz"
        else
            echo "Empty file: $BASE.fq.gz"
        fi
    fi
done

