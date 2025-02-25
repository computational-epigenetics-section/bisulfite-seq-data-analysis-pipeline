#!/bin/bash
#
# Bismark WGBS Single-Sample Analysis Pipeline
#
# This script performs the following steps:
#   1. (Optional) Genome preparation: Build bisulfite indexes for your reference genome.
#      Uncomment if you haven’t done this already.
#   2. Quality trimming with Trim Galore! (paired-end)
#   3. Alignment with Bismark using Bowtie2
#   4. Deduplication of aligned reads
#   5. Methylation extraction to generate reports and bedGraph files
#
# Usage:
#   sbatch script.sh sampleID
#
# Example:
#   sbatch script.sh sample1

#SBATCH --job-name=bismark_single_sample
#SBATCH --output=bismark_single_sample_%j.out
#SBATCH --error=bismark_single_sample_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00

# Define variables: update these with your specific directories
GENOME_DIR="/path/to/genome"           # Path to the reference genome folder
RAW_DATA_DIR="/path/to/raw_data"         # Directory containing raw FASTQ files
TRIMMED_DIR="/path/to/trimmed"           # Directory to store trimmed FASTQ files
BISMARK_OUT="/path/to/bismark_output"    # Directory for Bismark output
THREADS=8                              # Number of cores to use

# Check for sample ID argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 sampleID"
    exit 1
fi
SAMPLE="$1"

# Create output directories if they do not exist
mkdir -p "${TRIMMED_DIR}" "${BISMARK_OUT}"

# Step 0: Genome Preparation (run only once per genome)
# Uncomment the following line if the genome hasn't been prepared yet.
# bismark_genome_preparation "${GENOME_DIR}"

# Step 1: Quality Trimming using Trim Galore!
trim_galore --paired --cores "${THREADS}" \
    --output_dir "${TRIMMED_DIR}" \
    "${RAW_DATA_DIR}/${SAMPLE}_R1.fastq.gz" "${RAW_DATA_DIR}/${SAMPLE}_R2.fastq.gz"

# Trim Galore! typically outputs files with the suffix _val_1.fq.gz and _val_2.fq.gz
READ1="${TRIMMED_DIR}/${SAMPLE}_R1_val_1.fq.gz"
READ2="${TRIMMED_DIR}/${SAMPLE}_R2_val_2.fq.gz"

# Step 2: Alignment with Bismark
bismark --genome "${GENOME_DIR}" --multicore "${THREADS}" \
    -1 "${READ1}" -2 "${READ2}" \
    -o "${BISMARK_OUT}"

# Bismark typically names the output BAM file as shown below.
BAM_FILE="${BISMARK_OUT}/${SAMPLE}_R1_val_1_bismark_bt2_pe.bam"

# Step 3: Deduplication (for paired-end data)
deduplicate_bismark --paired "${BAM_FILE}"
# Deduplicated file is usually named with a .deduplicated.bam suffix.
DEDUP_BAM="${BAM_FILE%.bam}.deduplicated.bam"

# Step 4: Methylation Extraction
bismark_methylation_extractor \
    --paired-end --comprehensive --bedGraph --cytosine_report \
    --genome_folder "${GENOME_DIR}" --multicore "${THREADS}" \
    "${DEDUP_BAM}"

echo "Bismark pipeline completed for sample ${SAMPLE}."
