# CoRSIV Capture Bisulfite Sequencing Analysis Pipeline


###  Software used (Updated: 02/06/2020)

```bash
trim_galore v0.4.4
FastQC v0.11.5
Bismark v0.18.1_dev
```



## Step1: Adapter Trimming

### Trim Galore is a wrapper script to automate quality and adapter trimming as well as quality control.
This software automatically
- removes base calls with a Phred score of 20 or lower (assuming Sanger encoding)
- removes sequences that got shorter than 50 bp

```bash

-q/--quality <INT>      Trim low-quality ends from reads in addition to adapter removal. For
                        RRBS samples, quality trimming will be performed first, and adapter
                        trimming is carried in a second round. Other files are quality and adapter
                        trimmed in a single pass. The algorithm is the same as the one used by BWA
                        (Subtract INT from all qualities; compute partial sums from all indices
                        to the end of the sequence; cut sequence at the index at which the sum is
                        minimal). Default Phred score: 20.
                        
--length <INT>          Discard reads that became shorter than length INT because of either
                        quality or adapter trimming. A value of '0' effectively disables
                        this behaviour. Default: 20 bp.
                        
--paired                This option performs length trimming of quality/adapter/RRBS trimmed reads for
                        paired-end files. To pass the validation test, both sequences of a sequence pair
                        are required to have a certain minimum length which is governed by the option
                        --length (see above). If only one read passes this length threshold the
                        other read can be rescued (see option --retain_unpaired). Using this option lets
                        you discard too short read pairs without disturbing the sequence-by-sequence order
                        of FastQ files which is required by many aligners.

                        Trim Galore! expects paired-end files to be supplied in a pairwise fashion, e.g.
                        file1_1.fq file1_2.fq SRR2_1.fq.gz SRR2_2.fq.gz ... .

R1=$(realpath $1)
R2=$(realpath $2)

# QUALITY TRIM READS
echo "Trimming reads..."
trim_galore --paired --dont_gzip -q 20 --length 50 $R1 $R2

```

## Step2: Check Data Quality

FastQC reads a set of sequence files and produces from each one a quality control report consisting of a number of different modules, each one of which will help to identify a different potential type of problem in your data.

```bash

-t --threads    Specifies the number of files which can be processed
                    simultaneously.  Each thread will be allocated 250MB of
                    memory so you shouldn't run more threads than your
                    available memory will cope with, and not more than
                    6 threads on a 32 bit machine

fastqc -t 4 $R1 $R2

```

# Step3: Using Bismark to map sequencing reads to the reference genome (hg38)

### 3.1 Prepare a new reference genome(hg38) to be used by bismark
The downloaded referece genome (.fa) should be in the same directory where this shell script is called from.

### 3.2 Mapping reads to referece genome using Bismark

Description of the parameters used:
 
```bash


-q/--fastq               The query input files (specified as <mate1>,<mate2> or <singles> are FASTQ
                         files (usually having extension .fg or .fastq). This is the default. See also
                         --solexa-quals.

-1: read 1 fastq file
-2: read 2 fastq file

 
bismark --multicore 10 -q --temp_dir ./bismark --genome /home/scott/genomes/human/gencode -1 $R1 -2 $R2

```


```python

```
