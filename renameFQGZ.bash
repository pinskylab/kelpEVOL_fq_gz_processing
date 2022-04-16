#!/bin/bash

# bash script to rename raw fq.gz files from NovoGene with TAMUCC sample name decode file

enable_lmod
module load parallel

if [[ -z "$1" ]]; then
        echo "please specify the name of the decode file"
        echo "bash renameFQGZ.bash NameOfDecodeFile.tsv"
        exit 1
else
        echo "decode file read into memory"
fi

if [[ -z "$2" ]]; then
        echo "rename not specified, original and new file names will be printed to screen"
        echo "bash renameFQGZ.bash $1"
        echo; echo "if you want to rename then bash renameFQGZ.bash $1 rename"; echo
        MODE="test"
elif [[ "$2" == rename ]]; then
        echo "rename specified, files will be renamed"
        read -p "Are you sure? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo
                echo "bash renameFQGZ.bash $1 rename"
                MODE="rename"
        else
                echo
                echo "rename aborted, original and new file names will be printed to screen"
                echo "bash renameFQGZ.bash $1"
                MODE="test"
        fi
else
        echo "rename not specified, original and new file names will be printed to screen"
        echo "bash renameFQGZ.bash $1 $2"
        echo; echo "if you want to rename then bash renameFQGZ.bash $1 rename"; echo
        MODE="test"
fi

origName=($(tail -n +2 $1 | \
                        tr -s " " "\t" | \
                        cut -f1 ))

newName=($(tail -n +2 $1 | \
                        tr -s " " "\t" | \
                        cut -f2))

#oldFileNames=($(ls *_1.fq.gz | \
#                               sed 's/1\.fq\.gz//'))

echo "writing original file names to file, origFileNames.txt..."
ls *_1.fq.gz | \
        sed 's/1\.fq\.gz//' | \
        sort > \
        origFileNames.txt

echo "writing newFileNames.txt..."
sed 's/_.*_\(L[1-9]\)/_\1/' origFileNames.txt > newFileNames.txt

echo "editing newFileNames.txt..."
parallel --no-notice -k --link sed -i "s/{1}/{2}/" newFileNames.txt ::: ${origName[@]} ::: ${newName[@]}

if [[ $MODE == rename ]]; then
        echo "preview of orig and new R1 file names..."
        parallel --no-notice -k --link "echo {1}1.fq.gz {2}1.fq.gz" :::: origFileNames.txt :::: newFileNames.txt

        echo "preview of orig and new R2 file names..."
        parallel --no-notice -k --link "echo {1}2.fq.gz {2}2.fq.gz" :::: origFileNames.txt :::: newFileNames.txt

        echo; echo "Last chance to back out. If the original and new file names look ok, then proceed."
        read -p "Are you sure you want to rename the files? " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo; echo "renaming R1 files..."
                parallel --no-notice -k --link "mv {1}1.fq.gz {2}1.fq.gz" :::: origFileNames.txt :::: newFileNames.txt

                echo "renaming R2 files..."
                parallel --no-notice -k --link "mv {1}2.fq.gz {2}2.fq.gz" :::: origFileNames.txt :::: newFileNames.txt
        else
                echo
                echo "rename aborted, exiting..."
                exit 1
        fi

else
        echo "preview of orig and new R1 file names..."
        parallel --no-notice -k --link "echo {1}1.fq.gz {2}1.fq.gz" :::: origFileNames.txt :::: newFileNames.txt

        echo "preview of orig and new R2 file names..."
        parallel --no-notice -k --link "echo {1}2.fq.gz {2}2.fq.gz" :::: origFileNames.txt :::: newFileNames.txt
fi
