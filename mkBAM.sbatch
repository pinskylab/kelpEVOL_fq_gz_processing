#!/bin/bash -l

#SBATCH --job-name=mkBAM
#SBATCH -o mkBAM-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env bwa-mem2
export SINGULARITY_BIND=/home/e1garcia

#INPATTERN=./fq_fp1_clmp_fp2b_fqscrn_rprd/*.fq.gz
#REF=./GCF_902148845.1_fSalaFa1.1_chr1-23-mtgen.fna.gz
#OUTDIR=./mkBAM
#THREADS=40

INPATTERN=$1
REF=$2
OUTDIR=$3
THREADS=40

#FQEXT=.fq.gz
FQEXT=$(ls $INPATTERN | grep -P "\.[Rr]*1\.f.*$" | head -n1 | sed 's/.*[Rr]1\(.*\)/\1/')
#R1CODE=R1
R1CODE=$(ls $INPATTERN | grep -P "\.[Rr]*1$FQEXT" | head -n1 | sed "s/.*\.\([Rr]*1\)$FQEXT/\1/")
#R2CODE=R2
R2CODE=$(ls $INPATTERN | grep -P "\.[Rr]*2$FQEXT" | head -n1 | sed "s/.*\.\([Rr]*2\)$FQEXT/\1/")

R1EXT=$(echo .$R1CODE$FQEXT)

echo
echo In file pattern: "$INPATTERN"
echo Out dir: $OUTDIR
echo Ref genome: $REF
echo Threads: $THREADS
echo In file extension: $FQEXT
echo Reads 1 and 2 file codes: $R1CODE $R2CODE
echo Read 1 in file extension: $R1EXT

mkdir -p $OUTDIR

[ ! -f $REF.bwt.2bit.64 ] && crun bwa-mem2 index $REF

# create alignment maps
for i in $(ls $INPATTERN | grep "\.$R1CODE$FQEXT"); do
               FQ1=$i
               FQ2=$(echo $FQ1 | sed "s/$R1CODE$FQEXT/$R2CODE$FQEXT/")
               BAM=$(paste -d"/" <(echo $OUTDIR) <(echo $FQ1 | sed -e "s/^.*\///" -e "s/$R1EXT/_raw\.bam/"))
               echo; echo `date` ALIGNING $FQ1 AND $FQ2 TO $REF ...
               crun bwa-mem2 mem -t $THREADS $REF $FQ1 $FQ2 2> bwa.log | \
                        crun samtools view -@ $THREADS -SbT $REF - > $BAM 2> bam.log
               echo `date` SORTING $BAM ...
               crun samtools sort -@ $THREADS $BAM -o $BAM
               echo `date` INDEXING $BAM ...
               crun samtools index $BAM
               echo `date` COMPLETED; echo
done

