#!/bin/bash

FQPATTERN=*r1.fq.gz
INDIR=$1
OUTDIR=$2
TMPDIR=$3

#Pass in the maximum number of nodes to use at once
nodes=$4

# pass in number of threads. since wahab has 40 threads per node, when we have ram limitation issues
#suggested values: 20 (2 jobs per node on wahab), 40 (1 job per node on wahab)
threads=$5

# ramPerThread.  In the bash file, we have the number of threads allowed to run for a job being 1, so this is the ram per 1 thread or 1 node.  Ultimately, the previous threads command controlls how many jobs can run on one node, eg 20 = 2 jobs/wahab node and 40 = 1 job per wahab node
# suggested values:  180g, 233g, 360g
ramPerThread=$6

# queue to submit job to
# suggested values: main   or   himem
queue=$7

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

all_samples=$(ls ${INDIR}/${FQPATTERN} | \
	sed -e 's/r1\.fq\.gz//' -e 's/.*\///g')
all_samples=(${all_samples})

sbatch --array=0-$((${#all_samples[@]}-1))%${nodes} -p $queue -c ${threads} ${SCRIPTPATH}/runCLUMPIFY_r1r2_array2.sbatch ${INDIR} ${OUTDIR} ${TMPDIR} ${FQPATTERN} ${ramPerThread}
