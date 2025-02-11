#!/bin/bash

# this script will do sliding window and left 5' trimming on paired end and orphan files
# no merging of overlapping reads
# this is third step in prepping reads for de novo assembly

#SBATCH --job-name=fastp
#SBATCH -o /hb/home/miclark/kelpEVOL_fq_gz_processing/logs/fastp_2nd-%j.out
#SBATCH --cpus-per-task=2 # originally 40, changing to 2 for testing
#SBATCH --time=01:00:00 # originally 00:00:00,
#SBATCH --mem=10G # originally not specified, using 10 for testing
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

######## runFASTP_1st_trim.sbatch  ##############
## runs FASTP to do 2nd read trimming          ##
##  mic updated this 2025-02-11 for UCSC hb    ##
#################################################
# usage: sbatch runFASTP_2_cssl.sbatch <indir> <outdir> <bp front trim>

# load modules 
module load parallel/20200122
module load fastp/0.23.2
module list 


INDIR=$1   			#/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp
OUTDIR=$2  			#/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp_fp2

if [[ -z "$3" ]]; then
	nBP_FRONT_TRIM=0
else
	nBP_FRONT_TRIM=$3
fi

FQPATTERN=*r1.fq.gz  		#determines files to be trimmed
EXTPATTERN=r[12]\.fq\.gz  	# pattern match to fq extensions
FWDEXT=r1.fq.gz
REVEXT=r2.fq.gz
THREADS=20 			#1/2 of total threads avail


# use read_length_counter.bash to determine reasonable minimum length cut off 
#MINLEN=$((33-$nBP_FRONT_TRIM))
#if [[ $MINLEN < 33 ]]; then
	MINLEN=15 # originally set to 33
#fi

mkdir $OUTDIR $OUTDIR/failed

# trim r1 & r2 files
ls $INDIR/$FQPATTERN | \
	sed -e "s/$EXTPATTERN//" -e 's/.*\///g' | \
	uniq | \
	parallel --no-notice -j $THREADS \
	fastp \
		--in1 $INDIR/{}$FWDEXT \
		--in2 $INDIR/{}$REVEXT \
		--out1 $OUTDIR/{}fp2_r1.fq.gz \
		--out2 $OUTDIR/{}fp2_r2.fq.gz \
		--unpaired1 $OUTDIR/failed/{}fp2_unprd.fq.gz \
		--unpaired2 $OUTDIR/failed/{}fp2_unprd.fq.gz \
		--failed_out $OUTDIR/failed/{}fp2_fail.fq.gz \
		-h $OUTDIR/{}r1r2_fastp.html \
		-j $OUTDIR/{}r1r2_fastp.json \
		--detect_adapter_for_pe \
		--trim_front1 $nBP_FRONT_TRIM \
		--trim_front2 $nBP_FRONT_TRIM \
		--length_required $MINLEN \
		--cut_front \
		--cut_front_window_size 1 \
		--cut_front_mean_quality 20 \
		--cut_right \
		--cut_right_window_size 10 \
		--cut_right_mean_quality 20 \
		--disable_trim_poly_g \
		--correction \
		--disable_quality_filtering \
		--unqualified_percent_limit 40 \
		--report_title "Second Trim R1R2" 

# run multiqc on the fp2 results
module load  multiqc
#srun crun multiqc $OUTDIR -n $OUTDIR/2nd_fastp_report
multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename 2nd_fastp_report --outdir $OUTDIR $OUTDIR

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------

