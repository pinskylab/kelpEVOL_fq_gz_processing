#!/bin/bash -l

# this script will do sliding window and left 5' trimming on paired end and orphan files
# no merging of overlapping reads
# this is third step in prepping reads for de novo assembly

#SBATCH --job-name=fastp
#SBATCH -o fastp_2nd_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env pire_genome_assembly/2021.07.01

export SINGULARITY_BIND=/home/e1garcia

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

#MINLEN=$((33-$nBP_FRONT_TRIM))
#if [[ $MINLEN < 33 ]]; then
	MINLEN=33
#fi

mkdir $OUTDIR $OUTDIR/failed

# trim r1 & r2 files
ls $INDIR/$FQPATTERN | \
	sed -e "s/$EXTPATTERN//" -e 's/.*\///g' | \
	uniq | \
	crun parallel --no-notice -j $THREADS \
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
module load container_env multiqc
#srun crun multiqc $OUTDIR -n $OUTDIR/2nd_fastp_report
srun crun multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename 2nd_fastp_report --outdir $OUTDIR $OUTDIR
