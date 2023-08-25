#!/bin/bash

# this script runs fastq_screen and outputs a report AND filtered data
# `mapdamage_log.xlsx` will create the arguments which should be copied into a config file

#SBATCH --job-name=fqscr_array
#SBATCH --exclusive
#SBATCH -c 40

#module load parallel/gcc7/20190222  #tamucc
#module load fastq_screen/0.14.1  #tamucc
#module load bowtie2/gcc7/2.3.5.1  #tamucc

export SINGULARITY_BIND=/home/e1garcia  #odu
enable_lmod  #odu
module load container_env pire_genome_assembly/2021.07.01     #odu

INDIR=$1      					#INDIR=/work/hobi/cbird/pire_shotgunWGAvNoWGA/4sumstats_fq_fstp
OUTDIR=$2     
#TMPDIR=$(echo ${3}/fastqscrn${SLURM_ARRAY_TASK_ID})
FQPATTERN=$3       					#PATTERN="*.fq.gz"

CONFFILE=/work/hobi/egarcia111/reference_databases/fastq_screen_nofish_20210424.conf      #tamucc
CONFFILE=/home/e1garcia/shotgun_PIRE/fastq_screen/indexed_databases/runFQSCRN_6_nofish.conf      #odu
FQSCRN=fastq_screen   #tamucc
FQSCRN=/home/e1garcia/shotgun_PIRE/fastq_screen/FastQ-Screen-0.14.1/fastq_screen #odu
FQSCRN=/home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/gotanco-chanos_chanos/2nd_sequencing_run/fastq_screen   #odu new
SUBSET=0
FILTER=000000000000
ALIGNER=bowtie2  #bwa or bowtie2
THREADS=${SLURM_CPUS_ON_NODE}     # ram usage can be high, >100gb, so don't increase this beyond PARALLELISM * 120gb < ram avail

echo INDIR=$INDIR
#echo TMPDIR=$TMPDIR
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

#rm -rf $TMPDIR
#mkdir $TMPDIR

# if data is being subset, then don't output fqgz files
if [ $SUBSET -gt 0 ]; then
	echo ""; echo `date` RUNNING FASTQ_SCREEN TO GENERATE REPORTS, SUBSET=$SUBSET
# else output fqgz files
else
	echo ""; echo `date` RUNNING FASTQ_SCREEN TO FILTER FQ FILES AND GENERATE REPORTS, NO SUBSETTING
fi

INFLATED_INPUT="/dev/shm/$(basename ${INFILES%.gz})"
pigz -d -c "$INFILES"  > "$INFLATED_INPUT"

crun $FQSCRN \
	--aligner $ALIGNER \
	--conf $CONFFILE \
	--threads $THREADS \
	--tag \
	--force \
	--filter $FILTER \
	--subset $SUBSET \
	--outdir $OUTDIR \
	"$INFLATED_INPUT"

#ls $TMPDIR/* | \
#	parallel --no-notice -j ${THREADS} \
#		cp {} $OUTDIR

#rm -rf $TMPDIR
