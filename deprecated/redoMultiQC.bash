#!/bin/bash -l

# make all the metadata

	# raw
	# fp1
	# clmp
	# fp2
	# fqscrn
	# repair

# run this from dir that contains fq_raw, fq_fp1, ...
# bash redoMultiQC.bash

# raw
#assume fqc already run
inDIR=$(ls -d *raw*/ | head -n 1 | sed 's/\///')
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch "$inDIR" "fqc_raw_report" &&

# fp1
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch "fq_fp1" "1st_fastp_report" &&

# clmp
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report" "fq.gz" &&
#sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch "fq_fp1_clmp" "fqc_clmp_report"

# fp2
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch "fq_fp1_clmp_fp2" "2nd_fastp_report" &&

# fqscrn
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch "fq_fp1_clmp_fp2_fqscrn" "fastq_screen_report" &&

# repair
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" 
