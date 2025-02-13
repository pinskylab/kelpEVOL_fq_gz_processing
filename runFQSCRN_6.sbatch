#!/bin/bash

# this script runs fastq_screen and outputs a report AND filtered data
# `mapdamage_log.xlsx` will create the arguments which should be copied into a config file

#SBATCH --job-name=fqscr_array

module load parallel/20200122
module load fastq-screen/0.16.0
module load bowtie/1.3.1-7
module list

echo $INDIR     					#INDIR=/work/hobi/cbird/pire_shotgunWGAvNoWGA/4sumstats_fq_fstp
echo $OUTDIR     
echo $FQPATTERN      					#PATTERN="*.fq.gz"

# need to update paths below when database is transfered to hummingbird
CONFFILE=/work/hobi/egarcia111/reference_databases/fastq_screen_nofish_20210424.conf      #tamucc
CONFFILE=/home/e1garcia/shotgun_PIRE/fastq_screen/indexed_databases/runFQSCRN_6_nofish.conf      #odu
FQSCRN=fastq_screen   #tamucc
#FQSCRN=/home/e1garcia/shotgun_PIRE/fastq_screen/FastQ-Screen-0.14.1/fastq_screen #odu
#FQSCRN=fastq_screen   #odu new
SUBSET=0
FILTER=000000000000
ALIGNER=bowtie2  #bwa or bowtie2
THREADS=${SLURM_CPUS_PER_TASK}  # ram usage can be high, >100gb, so don't increase this beyond PARALLELISM * 120gb < ram avail

echo INDIR=$INDIR
echo OUTDIR=$OUTDIR
echo CONFFILE=$CONFFILE
echo PATTERN=$FQPATTERN
echo PARALLELISM=$PARALLELISM
echo THREADS=$THREADS
echo SUBSET=$SUBSET
echo FILTER=$FILTER

all_samples=( $(ls $INDIR/$FQPATTERN) )
INFILES=${all_samples[${SLURM_ARRAY_TASK_ID}]}
echo INFILES:
echo ${INFILES}

# if data is being subset, then don't output fqgz files
if [ $SUBSET -gt 0 ]; then
	echo ""; echo `date` RUNNING FASTQ_SCREEN TO GENERATE REPORTS, SUBSET=$SUBSET
# else output fqgz files
else
	echo ""; echo `date` RUNNING FASTQ_SCREEN TO FILTER FQ FILES AND GENERATE REPORTS, NO SUBSETTING
fi

$FQSCRN \
	--aligner $ALIGNER \
	--conf $CONFFILE \
	--threads $THREADS \
	--tag \
	--force \
	--filter $FILTER \
	--subset $SUBSET \
	--outdir $OUTDIR \
	${INFILES}


#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------

