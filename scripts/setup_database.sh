#!/bin/bash
#
# setup_database.sh
# Setup GetOrganelle databases and download reference genomes
#
# Usage: bash setup_database.sh

set -e

echo "========================================="
echo "GetOrganelle Database Setup"
echo "========================================="
echo ""

# Check if GetOrganelle is installed
if ! command -v get_organelle_config.py &> /dev/null; then
    echo "Error: GetOrganelle is not installed!"
    echo "Please install GetOrganelle first:"
    echo "  conda install -c bioconda getorganelle"
    echo "  OR follow instructions in README.md"
    exit 1
fi

# Step 1: Add animal mitochondrial database
echo "[$(date)] Step 1: Adding animal mitochondrial database..."
get_organelle_config.py --add animal_mt

echo ""
echo "[$(date)] Step 2: Listing available databases..."
get_organelle_config.py --list

echo ""
echo "[$(date)] Step 3: Creating reference data directory..."
mkdir -p data/references

echo ""
echo "[$(date)] Step 4: Downloading example reference genomes from Mitofish..."
echo "Note: This downloads example fish mitochondrial genomes"
echo "For specific species, visit: http://mitofish.aori.u-tokyo.ac.jp/"

# Download example reference: Zebrafish (Danio rerio)
if [ ! -f data/references/zebrafish_mt.fasta ]; then
    echo "Downloading Zebrafish mitochondrial genome..."
    curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_002333.2&rettype=fasta&retmode=text" \
        > data/references/zebrafish_mt.fasta
    echo "  Saved to: data/references/zebrafish_mt.fasta"
fi

# Download example reference: Medaka (Oryzias latipes)
if [ ! -f data/references/medaka_mt.fasta ]; then
    echo "Downloading Medaka mitochondrial genome..."
    curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_004387.2&rettype=fasta&retmode=text" \
        > data/references/medaka_mt.fasta
    echo "  Saved to: data/references/medaka_mt.fasta"
fi

# Download example reference: Atlantic salmon (Salmo salar)
if [ ! -f data/references/salmon_mt.fasta ]; then
    echo "Downloading Atlantic Salmon mitochondrial genome..."
    curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_001960.1&rettype=fasta&retmode=text" \
        > data/references/salmon_mt.fasta
    echo "  Saved to: data/references/salmon_mt.fasta"
fi

echo ""
echo "[$(date)] Step 5: Creating custom database directory..."
mkdir -p custom_database

echo ""
echo "[$(date)] Step 6: Creating project directory structure..."
mkdir -p data/raw_reads
mkdir -p output
mkdir -p annotations
mkdir -p qc_reports

echo ""
echo "========================================="
echo "Database Setup Complete!"
echo "========================================="
echo ""
echo "Directory structure created:"
echo "  data/raw_reads/    - Place your FASTQ files here"
echo "  data/references/   - Reference genomes (3 fish species downloaded)"
echo "  output/            - Assembly results will be saved here"
echo "  annotations/       - Annotation results will be saved here"
echo "  qc_reports/        - Quality control reports"
echo ""
echo "Reference genomes downloaded:"
ls -lh data/references/
echo ""
echo "Next steps:"
echo "1. Place your paired-end FASTQ files in data/raw_reads/"
echo "2. Run assembly: bash scripts/assemble_mitochondria.sh SAMPLE_NAME READ1 READ2"
echo "========================================="
