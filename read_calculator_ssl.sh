#!/bin/bash

#SBATCH --job-name=readCal
#SBATCH --output=readCal-%j.out
#SBATCH -c 32
##SBATCH --mail-user=<your email>
##SBATCH --mail-type=begin
##SBATCH --mail-type=END

enable_lmod
module load parallel
export SINGULARITY_BIND=/home/e1garcia

#######  read_calculator_ssl.sh  ########

#read_calculator_ssl.sh counts the number of reads before and after each step in the pre-process of ssl data and creates 2 tables reporting
 # (1) "readLoss_table.tsv" the step-specific percent of read loss and final accumulative read loss
 # (2) "readsRemaining_table.tsv" the step-specific percent of reads remaining and final accumulative number of reads remaining

SPDIR=$1

# Determine # of threads
FILES_No=$(ls fq_raw_shotgun/*gz | wc -l)

if [[ "$FILES_No" -ge 32 ]]; then
        PARALLELISM=32
else
        PARALLELISM=$FILES_No
fi

# Create and move to preprocess_read_change directory
mkdir ${SPDIR}/preprocess_read_change
cd ${SPDIR}/preprocess_read_change

echo "read_calculator_ssl.sh counts the number of reads before and after each step in the pre-process of ssl data and creates 2 tables reporting
  (1) "readLoss_table.tsv" the step-specific percent of read loss and final accumulative read loss
  (2) "readsRemaining_table.tsv" the step-specific percent of reads remaining and final accumulative number of reads remaining" > README_read_calculator_ssl

## Create temporary files with read counts
ls ${SPDIR}/fq_raw_shotgun/*gz | parallel --no-notice -kj${PARALLELISM} "echo -n {}'	' && zgrep '^@' {} | wc -l" > raw.temp
ls ${SPDIR}/fq_fp1/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > fp1.temp
ls ${SPDIR}/fq_fp1_clmparray/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > clm.temp
ls ${SPDIR}/fq_fp1_clmparray_fp2/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > fp2.temp
ls ${SPDIR}/fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > fqscrn.temp
ls ${SPDIR}/fq_fp1_clmparray_fp2_fqscrn_repaired/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > repr.temp


#cat <(echo "file	#reads_raw	#reads_fp1	#reads_clmp	#reads_fp2	#reads_fqscrn	#reads_repr	#reads_remaining") <(\
#	paste raw.temp fp1.temp clm.temp fp2.temp) > 1_Catpaste


#cat <(echo "file        #_reads_raw      #_reads_fp1      #_reads_clmp     #_reads_fp2      #_reads_fqscrn   #_reads_repr     %_readLoss_fp1     %_readLoss_clmp     %_readLoss_fp2     %_readLoss_fqscrn     %_readLoss_repr     %_total_readLoss") <(\
#paste raw.temp fp1.temp clm.temp fp2.temp fqscrn.temp repr.temp | awk -F "\t" 'NR==FNR{i = ((($3/$2)*(-100))+100);print $0"\t"i }' | awk -F "\t" 'NR==FNR{i = ((($4/$3)*(-100))+100);print $0"\t"i }' | awk -F "\t" 'NR==FNR{i = ((($5/$4)*(-100))+100);print $0"\t"i }' | awk -F "\t" 'NR==FNR{i = ((($6/$5)*(-100))+100);print $0"\t"i }' | awk -F "\t" 'NR==FNR{i = ((($7/$6)*(-100))+100);print $0"\t"i }' | awk -F "\t" 'NR==FNR{i = ((($7/$2)*(-100))+100);print $0"\t"i }') >testMitable

cat <(echo "file 	#reads_raw	#reads_fp1	#reads_clmp	#reads_fp2	#reads_fqscrn	#reads_repr	%_readLoss_fp1	%_readLoss_clmp	%_readLoss_fp2	%_readLoss_fqscrn	%_readLoss_repr	%_total_readLoss") <(\
	paste raw.temp fp1.temp clm.temp fp2.temp fqscrn.temp repr.temp | \
		sed 's/.*fq\///' | \
		awk -F "\t" 'NR==FNR{i = ((($3/$2)*(-100))+100);print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ((($4/$3)*(-100))+100);print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ((($5/$4)*(-100))+100);print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ((($6/$5)*(-100))+100);print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ((($7/$6)*(-100))+100);print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ((($7/$2)*(-100))+100);print $0"\t"i }') > readLoss_table.tsv

cat <(echo "file	#_reads_raw	#_reads_fp1	#_reads_clmp	#_reads_fp2	#_reads_fqscrn	#_reads_repr	%_readsRemaining_fp1	%_readsRemaining_clmp	%_readsRemaining_fp2	%_readsRemaining_fqscrn	%_readsRemaining_repr	%_total_readsRemaining") <(\
	paste raw.temp fp1.temp clm.temp fp2.temp fqscrn.temp repr.temp | \
		sed 's/.*fq\///' | \
		awk -F "\t" 'NR==FNR{i = ($3/$2)*100;print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ($4/$3)*100;print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ($5/$4)*100;print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ($6/$5)*100;print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ($7/$6)*100;print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ($7/$2)*100;print $0"\t"i }') > readsRemaining_table.tsv

# Clean up
rm *temp

