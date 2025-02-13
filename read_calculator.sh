#!/bin/bash

#SBATCH --job-name=readCal
#SBATCH --out=/hb/home/miclark/kelpEVOL_fq_gz_processing/logs/readCal-%j.out
#SBATCH --cpus-per-task=6
#SBATCH --mem=10G
#SBATCH --partition=128x24

module load parallel/20200122

#######  read_calculator.sh  ########

# edited to remove fq_fp1_clmp_fp2_fqscrn and beyond until those steps are running on hummingbird

#read_calculator.sh counts the number of reads before and after each step in the pre-process of ssl, cssl or lcwgs  data and creates 2 tables reporting
 # (1) the step-specific percent of read loss and final accumulative read loss "readLoss_table.tsv"
 # (2) the step-specific percent of read loss and final accumulative read loss "readsRemaining_table.tsv"

SPDIR=$1

# Determine # of threads
FILES_No=$(ls ${SPDIR}/*fq_raw*/*gz | wc -l)

if [[ "$FILES_No" -ge 32 ]]; then
        PARALLELISM=32
else
        PARALLELISM=$FILES_No
fi

# Create and move to preprocess_read_change directory
mkdir -p ${SPDIR}/preprocess_read_change
cd ${SPDIR}/preprocess_read_change

# Create temporary files with read counts
ls ${SPDIR}/*fq_raw*/*gz | parallel --no-notice -kj${PARALLELISM} "echo -n {}'	' && zgrep '^@' {} | wc -l" > raw.temp
ls ${SPDIR}/fq_fp1/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > fp1.temp
ls ${SPDIR}/fq_fp1_clmp/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > clm.temp
ls ${SPDIR}/fq_fp1_clmp_fp2/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > fp2.temp
#ls ${SPDIR}/fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > fqscrn.temp
#ls ${SPDIR}/fq_fp1_clmparray_fp2_fqscrn_repaired/*gz | parallel --no-notice -kj${PARALLELISM} "zgrep '^@' {} | wc -l" > repr.temp

# Perform calculations
cat <(echo "file        #reads_raw      #reads_fp1      #reads_clmp     #reads_fp2     %_readLoss_fp1  %_readLoss_clmp %_readLoss_fp2") <(\
        paste raw.temp fp1.temp clm.temp fp2.temp | \
                sed 's/.*fq\///' | \
                awk -F "\t" 'NR==FNR{i = ((($3/$2)*(-100))+100);print $0"\t"i }' | \
                awk -F "\t" 'NR==FNR{i = ((($4/$3)*(-100))+100);print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ((($5/$4)*(-100))+100);print $0"\t"i }') > readLoss_table.tsv

#cat <(echo "file	#reads_raw	#reads_fp1	#reads_clmp	#reads_fp2	#reads_fqscrn	#reads_repr	%_readLoss_fp1	%_readLoss_clmp	%_readLoss_fp2	%_readLoss_fqscrn	%_readLoss_repr	%_total_readLoss") <(\
#       paste raw.temp fp1.temp clm.temp fp2.temp fqscrn.temp repr.temp | \		
#		sed 's/.*fq\///' | \
#		awk -F "\t" 'NR==FNR{i = ((($3/$2)*(-100))+100);print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ((($4/$3)*(-100))+100);print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ((($5/$4)*(-100))+100);print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ((($6/$5)*(-100))+100);print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ((($7/$6)*(-100))+100);print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ((($7/$2)*(-100))+100);print $0"\t"i }') > readLoss_table.tsv

cat <(echo "file        #_reads_raw     #_reads_fp1     #_reads_clmp    #_reads_fp2       %_readsRemaining_fp1    %_readsRemaining_clmp   %_readsRemaining_fp2") <(\
        paste raw.temp fp1.temp clm.temp fp2.temp | \
                sed 's/.*fq\///' | \
                awk -F "\t" 'NR==FNR{i = ($3/$2)*100;print $0"\t"i }' | \
                awk -F "\t" 'NR==FNR{i = ($4/$3)*100;print $0"\t"i }' | \
		awk -F "\t" 'NR==FNR{i = ($5/$4)*100;print $0"\t"i }') > readsRemaining_table.tsv

#cat <(echo "file        #_reads_raw     #_reads_fp1     #_reads_clmp    #_reads_fp2     #_reads_fqscrn  #_reads_repr    %_readsRemaining_fp1    %_readsRemaining_clmp   %_readsRemaining_fp2    %_readsRemaining_fqscrn %_readsRemaining_repr   %_total_readsRemaining") <(\
#       paste raw.temp fp1.temp clm.temp fp2.temp fqscrn.temp repr.temp | \             
#		sed 's/.*fq\///' | \
#		awk -F "\t" 'NR==FNR{i = ($3/$2)*100;print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ($4/$3)*100;print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ($5/$4)*100;print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ($6/$5)*100;print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ($7/$6)*100;print $0"\t"i }' | \
#		awk -F "\t" 'NR==FNR{i = ($7/$2)*100;print $0"\t"i }') > readsRemaining_table.tsv

# Clean up
rm *temp

