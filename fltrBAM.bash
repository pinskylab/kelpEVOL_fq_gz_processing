
#!/bin/bash

bamDIR=$1
THREADS=40
INPATTERN=$bamDIR/*_raw.bam
#INPATTERN=$2  #must be in quotes in command line
OUTEXT=_fltrd.bam
INEXT=$(echo "$INPATTERN" | sed -e 's/^.*\///' -e 's/^.*\*//')

echo INPATTERN: "$INPATTERN"
echo INFILES: $INPATTERN
echo IN EXT: $INEXT
echo OUT EXT: $OUTEXT
echo THREADS: $THREADS

FILTER(){
        IN=$1
        OUT=$2
        bamtools filter \
        -forceCompression \
        -isMapped true \
        -isPrimaryAlignment true \
        -isPaired true \
        -isMateMapped true \
        -mapQuality ">30" \
        -tag "AS:>30" \
        -in $IN \
        -out $OUT
        samtools index $OUT
}
export -f FILTER

FILTER2(){
        IN=$1
        OUT=$2
        echo $IN $OUT

        samtools view -h \
        -F 0x904 \
        -f 0x1 \
        -q 30 \
        -@ 2 \
        -b \
        $IN > $OUT
        samtools index $OUT
}
export -f FILTER2

ls $INPATTERN |
sed "s/$INEXT//" |
parallel --no-notice -j $THREADS "FILTER2 {}$INEXT {}$OUTEXT"
echo `date` Completed!
