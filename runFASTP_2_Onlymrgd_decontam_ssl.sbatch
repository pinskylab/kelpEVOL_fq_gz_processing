#!/bin/bash -l

# this script will do sliding window and left 5' trimming on paired end and orphan files
# no merging of overlapping reads
# this is third step in prepping reads for de novo assembly

#SBATCH --job-name=fastp
#SBATCH -o fastp_2nd_dctm_onlymrgd-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
#module load multiqc
#module load parallel

export SINGULARITY_BIND=/home/e1garcia

INDIR=$1   			#/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp
OUTDIR=$2  			#/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp_fp2
FQPATTERN=*R1.fq.gz  		#determines files to be trimmed
EXTPATTERN=R[12]\.fq\.gz  	# pattern match to fq extensions
FWDEXT=R1.fq.gz
REVEXT=R2.fq.gz
THREADS=20 			#1/2 of total threads avail

mkdir $OUTDIR $OUTDIR/failed

# trim r1 & r2 files
ls $INDIR/$FQPATTERN | \
	sed -e "s/$EXTPATTERN//" -e 's/.*\///g' | \
	uniq | \
	crun parallel --no-notice -j $THREADS \
	fastp \
		--in1 $INDIR/{}$FWDEXT \
		--in2 $INDIR/{}$REVEXT \
		--out1 $OUTDIR/{}fp2_R1.fq.gz \
		--out2 $OUTDIR/{}fp2_R2.fq.gz \
		--merged_out $OUTDIR/{}mrgd.fq.gz \
		--unpaired1 $OUTDIR/failed/{}fp2_unprd.fq.gz \
		--unpaired2 $OUTDIR/failed/{}fp2_unprd.fq.gz \
		--failed_out $OUTDIR/failed/{}fp2_fail.fq.gz \
		--merge \
		--length_required 140 \
		--disable_trim_poly_g \
		--disable_quality_filtering \
		--disable_adapter_trimming \
		--report_title "Second Trim R1R2" 

# run multiqc on the fp2 results

module load multiqc
srun crun multiqc $OUTDIR -n $OUTDIR/2nd_fastp_report
