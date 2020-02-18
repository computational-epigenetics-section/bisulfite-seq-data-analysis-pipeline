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

# Step4: Extract methylation counts over each CpG site

### 4.1 Using Bismark methylation extractor
This step will extract the methylation information from the Bismark alignment output. bismark_methylation_extractor script operates on Bismark result files and extracts the methylation call for every single C analysed. The position of every single C will be written out to a new output file as follows.

<chromosome> <start position> <end position> <methylation percentage> <count methylated> <count unmethylated>
    
    
To get this coverage file, following parameters were used with the bismark_methylation_extractor script.


```bash
--bedGraph               After finishing the methylation extraction, the methylation output is written into a
                         sorted bedGraph file that reports the position of a given cytosine and its methylation 
                         state (in %, see details below).
                         
--cytosine_report        After the conversion to bedGraph has completed, the option '--cytosine_report' produces a
                         genome-wide methylation report for all cytosines in the genome.
                         
 

bismark_methylation_extractor  -p --comprehensive --report --multicore 8 $1 --bedGraph --buffer_size 8G --ample_memory --cytosine_report --gzip --genome_folder /home/scott/genomes/human/gencode
 
```

### 4.2 Coverage to Cytosine

```bash

coverage2cytosine --merge_CpG --genome_folder /home/scott/genomes/human/gencode $1 -o $1.cyt.cov
```

Starting from the coverage output, the Bismark methylation extractor can optionally also output a
genome-wide cytosine methylation report. The module coverage2cytosine was run individually to the bedGraph or coverage output so that every cytosine on both the top and bottom strands will be considered irrespective of whether they were actually covered by any reads in the experiment or not





```python

```
