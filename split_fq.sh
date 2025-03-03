#!/bin/bash

#SBATCH --time=2:00:00 -n6 -p dque

#Args: Input Fastq files

IN_FILE=$1
echo $IN_FILE

mkdir -p split

e=$(echo $IN_FILE|cut -f1,2 -d".")
echo $e

# This split the fastq.gz file for 10 million reads in each. to increase change the 40000000 number. each read is 4 lines that why this number is 4 x 10,000,000
zcat $IN_FILE | split --verbose -l 40000000 -d -a 4 --filter="pigz -p 2 -c > split/\$FILE.gz" - split.10m.$e
