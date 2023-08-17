#!/bin/bash -l

# this script will do all trimming, except 5'
# no merging of overlapping reads
# this is first step in prepping reads for de novo assembly

#SBATCH --job-name=fp_Ddup
#SBATCH -o fastp_Ddup_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod

################ change container, need fastp v22 or newer ############################
module load container_env pire_genome_assembly/2021.07.01
#########################################################################################

# this code is requires if the input files don't live within your own parent directory
# modify "e1garcia" to the user ID where the files are located
export SINGULARITY_BIND=/home/e1garcia


INDIR=$1                 #example= /home/e1garcia/shotgun_PIRE/Lle/fq_raw
OUTDIR=$2                #example= /home/e1garcia/shotgun_PIRE/fq_fp1
FQPATTERN=*.fq.gz        #determines files to be trimmed
EXTPATTERN=[12]\.fq\.gz  # pattern match to fq extensions
FWDEXT=1.fq.gz
REVEXT=2.fq.gz
THREADS=20 #1/2 of total threads avail

mkdir $OUTDIR $OUTDIR/failed

ls $INDIR/$FQPATTERN | \
	sed -e "s/$EXTPATTERN//" -e 's/.*\///g' | \
	uniq | \
	crun parallel --no-notice -j $THREADS \
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
		--dedup
		--dup_calc_accuracy 6
		--disable_adapter_trimming
		--disable_trim_poly_g
		--disable_quality_filtering
		--disable_length_filtering
		--report_title "fp_Ddup" 

#run multiqc 
module load container_env multiqc
#srun crun multiqc $OUTDIR -n $OUTDIR/fp_Ddup_report --interactive
srun crun multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename fp_Ddup_report --outdir $OUTDIR $OUTDIR
