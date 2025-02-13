#!/bin/bash

# this script sends several jobs each to their own compute node using an array, which limits the number of nodes used at one time

INDIR=$1
OUTDIR=$2
NUMNODES=1   # lab-mpinsky partition has one node
FQPATTERN=$3

if [[ -z "$FQPATTERN" ]]; then
       FQPATTERN=*.fq.gz
fi
mkdir $OUTDIR

all_samples=( $(ls $INDIR/$FQPATTERN) )

executable=/hb/home/miclark/kelpEVOL_fq_gz_processing/runFQSCRN_6.sbatch

# assigning to JOBID saves the job id to a variable to check later 
JOBID=$(sbatch --array=0-$((${#all_samples[@]}-1))%${NUMNODES} \
       --export=INDIR=$INDIR,OUTDIR=$OUTDIR,FQPATTERN=$FQPATTERN \
       --output=./logs/slurm-fqscrn.%A.%a.out \
       --nodes=1 \
       --cpus-per-task=20 \
       --mem-per-cpu=20G \
       --time=96:00:00 \
       --partition=lab-mpinsky \
       --qos=pi-mpinsky \
       --account=pi-mpinsky \
       $executable)
       
# NUMBER1=$(echo ${JOBID} | sed 's/[^0-9]*//g')
# sbatch --dependency=afterok:${NUMBER1} /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch $OUTDIR fqscrn_mqc
