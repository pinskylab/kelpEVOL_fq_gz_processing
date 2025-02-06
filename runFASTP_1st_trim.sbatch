#!/bin/bash

#SBATCH --job-name=fastp
#SBATCH -o /hb/home/miclark/kelpEVOL_fq_gz_processing/logs/fastp_1stTrim-%j.out
#SBATCH --cpus-per-task=2 # originally 40, changing to 2 for testing 
#SBATCH --time=01:00:00 # originally 00:00:00,
#SBATCH --mem=10G # originally not specified, using 10 for testing 
#SBATCH --partition=128x24

######## runFASTP_1st_trim.sbatch  ##############
## runs FASTP to do read trimming              ##
##  mic updated this 2025-02-05 for UCSC hb    ##
#################################################

# this script will do all trimming, except 5'
# no merging of overlapping reads
# this is first step in prepping reads for de novo assembly

module load parallel/20200122
module load fastp/0.23.2

### pending deletion
# this code is requires if the input files don't live within your own parent directory
# modify "e1garcia" to the user ID where the files are located
# export SINGULARITY_BIND=/home/e1garcia
###

INDIR=$1                 #example= /home/e1garcia/shotgun_PIRE/Lle/fq_raw
OUTDIR=$2                #example= /home/e1garcia/shotgun_PIRE/fq_fp1
FQPATTERN=*.fq.gz        #determines files to be trimmed, change to match your files, fq.gz, fastq.gz etc. 
EXTPATTERN=[12]\.fq\.gz  # pattern match to fq extensions
FWDEXT=1.fq.gz
REVEXT=2.fq.gz
THREADS=2 #1/2 of total threads avail; originally 20 

mkdir $OUTDIR $OUTDIR/failed

ls $INDIR/$FQPATTERN | \
	sed -e "s/$EXTPATTERN//" -e 's/.*\///g' | \
	uniq | \
	parallel --no-notice -j $THREADS \
	fastp \
		--in1 $INDIR/{}$FWDEXT \
		--in2 $INDIR/{}$REVEXT \
		--out1 $OUTDIR/{}r1.fq.gz \
		--out2 $OUTDIR/{}r2.fq.gz \
		--unpaired1 $OUTDIR/failed/{}unprd.fq.gz \
		--unpaired2 $OUTDIR/failed/{}unprd.fq.gz \
		--failed_out $OUTDIR/failed/{}fail.fq.gz \
		-h $OUTDIR/{}fastp.html \
		-j $OUTDIR/{}fastp.json \
		--qualified_quality_phred 20 \
		--unqualified_percent_limit 40 \
		--length_required 33 \
		--low_complexity_filter \
		--complexity_threshold 30 \
		--detect_adapter_for_pe \
		--adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
		--adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
		--cut_tail \
		--cut_tail_window_size 1 \
		--cut_tail_mean_quality 20 \
		--trim_poly_g \
		--poly_g_min_len 10 \
		--trim_poly_x \
		--report_title "First Trim 4 De Novo" 

#run multiqc 
module load multiqc
#srun crun multiqc $OUTDIR -n $OUTDIR/1st_fastp_report --interactive
multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename 1st_fastp_report --outdir $OUTDIR $OUTDIR
