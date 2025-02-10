#!/bin/bash

# Called by runCLUMPIFY_r1r2_array.bash, which starts an array job. 

# load modules 
module load java/8u151


#FQPATTERN=${4}
#TEMPDIR=${3}
#INDIR=${1}
#OUTDIR=${2}
THREADS=1   #clumpify uses a ton of ram, be conservative
GROUPS=auto   #controls how much ram is used, refer to manual
RAMPERTHREAD=233g   #have had to set as high as 233g with groups=1, was originally 180g

ulimit -n 40960 

ulimit -a

mkdir -p $OUTDIR

echo $SLURM_NODELIST

all_samples=$(ls $INDIR/$FQPATTERN | \
	sed -e 's/r1\.fq\.gz//' -e 's/.*\///g')
all_samples=($all_samples)

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}
echo ${sample_name}

#systemctl status  $PPID  
#systemctl status  $PPID  | head -1 | awk '{print $2}' | xargs systemctl show -p TasksMax
#cat /proc/sys/kernel/threads-max

/hb/software/apps/bbtools/gnu-39.01/clumpify.sh \
	in=${INDIR}/${sample_name}r1.fq.gz \
	in2=${INDIR}/${sample_name}r2.fq.gz \
	out=${OUTDIR}/${sample_name}clmp.r1.fq.gz \
	out2=${OUTDIR}/${sample_name}clmp.r2.fq.gz \
	groups=auto \
	lowcomplexity=t \
	overwrite=t \
	usetmpdir=t \
	tmpdir=${TEMPDIR} \
	deletetemp=t \
	dedupe=t \
	addcount=t \
	subs=2 \
	containment=t \
	consensus=f \
	-Xmx=480g

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------

