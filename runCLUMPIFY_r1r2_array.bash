#!/bin/bash

# wrapper file for runCLUMPIFY_r1r2_array.sbatch
# Begins an array job to de-duplicate trimmed reads. 
# Last updated: MIC 02/06/2025

# usage: ./runCLUMPIFY_r1r2_array.bash <indir> <outdir> <tmpdir> <nodes>

#Pass in the maximum number of nodes to use at once
nodes=$4

FQPATTERN=*r1.fq.gz
INDIR=$1
OUTDIR=$2
TMPDIR=$3
MEM=500G

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

all_samples=$(ls $INDIR/$FQPATTERN | \
	sed -e 's/r1\.fq\.gz//' -e 's/.*\///g')
all_samples=($all_samples)

# add nodes, threads, and ram per thread
# --cpus-per-task (-c)
# --nodes
# --mem-per-cpu

sbatch --job-name=clmp_r12 \
	--array=0-$((${#all_samples[@]}-1))%${nodes} \
	--export=INDIR=$INDIR,OUTDIR=$OUTDIR,TMPDIR=$TMPDIR,FQPATTERN=$FQPATTERN,MEM=$MEM \
	--output=./logs/clmp_r1r2_-%A_%a.out \
	--nodes=1 \
	--cpus-per-task=1 \
	--mem-per-cpu=50G \
	--time=06:00:00 \
	--partition=lab-mpinsky \
	--qos=pi-mpinsky \
	--account=pi-mpinsky \
	$SCRIPTPATH/runCLUMPIFY_r1r2_array.sbatch

echo ----------------------------------------------------------------------------------------

#$SCRIPTPATH/runCLUMPIFY_r1r2_array.sbatch ${INDIR} ${OUTDIR} ${TMPDIR} ${FQPATTERN}
