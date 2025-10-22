# GetOrganelle Mitochondrial Genome Assembly

This project demonstrates how to assemble organelle genomes — specifically mitochondrial DNA — using **GetOrganelle**, a powerful tool for extracting organelle sequences from whole-genome shotgun data.

We use data from the **Mitofish** database and walk through the steps of environment setup, database configuration, genome assembly, and annotation.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Genome Assembly](#genome-assembly)
- [Annotation](#annotation)
- [Example Workflow](#example-workflow)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Overview

GetOrganelle is a toolkit designed to assemble organellar genomes from genomic skimming data. It's particularly effective for:
- Mitochondrial genomes
- Plastid/chloroplast genomes
- Nuclear ribosomal DNA

This tutorial focuses on **mitochondrial DNA assembly** using fish genomic data from Mitofish.

## Prerequisites

- Python 3.7 or higher
- At least 8GB RAM (16GB recommended)
- 20GB free disk space
- Basic command-line knowledge
- UNIX/Linux or macOS environment (Windows users can use WSL)

## Installation

### Option 1: Using Conda (Recommended)

```bash
# Create a new conda environment
conda env create -f environment.yml
conda activate getorganelle

# Install GetOrganelle
conda install -c bioconda getorganelle

# Download seed and label databases
get_organelle_config.py --add embplant_pt,embplant_mt,embplant_nr,animal_mt,fungus_mt
```

### Option 2: Using pip

```bash
# Install dependencies
pip install -r requirements.txt

# Install GetOrganelle from source
git clone https://github.com/Kinggerm/GetOrganelle.git
cd GetOrganelle
python setup.py install

# Download databases
get_organelle_config.py --add animal_mt
```

### Verify Installation

```bash
get_organelle_from_reads.py --version
```

## Database Setup

### Mitofish Database

Mitofish is a comprehensive database of fish mitochondrial genomes. To use it with GetOrganelle:

1. **Download reference genomes from Mitofish:**

```bash
# Create a directory for reference data
mkdir -p data/references

# Download fish mitochondrial genomes from NCBI/Mitofish
# Example: Download a reference genome (e.g., Zebrafish)
wget -O data/references/zebrafish_mt.fasta \
  "https://www.ncbi.nlm.nih.gov/nuccore/NC_002333.2?report=fasta"
```

2. **Prepare custom seed database (optional):**

```bash
# If you have species-specific references
mkdir -p custom_database
cp data/references/*.fasta custom_database/

# Index the custom database
cd custom_database
makeblastdb -in zebrafish_mt.fasta -dbtype nucl -parse_seqids
```

### Configure GetOrganelle for Animal Mitochondria

```bash
# Add animal mitochondrial database
get_organelle_config.py --add animal_mt

# Check configuration
get_organelle_config.py --list
```

## Genome Assembly

### Input Data Preparation

GetOrganelle works with paired-end Illumina reads. Organize your data:

```bash
mkdir -p data/raw_reads
# Place your FASTQ files here:
# - sample_R1.fastq.gz (forward reads)
# - sample_R2.fastq.gz (reverse reads)
```

### Basic Assembly Command

```bash
# Run GetOrganelle for mitochondrial genome assembly
get_organelle_from_reads.py \
  -1 data/raw_reads/sample_R1.fastq.gz \
  -2 data/raw_reads/sample_R2.fastq.gz \
  -o output/sample_mt \
  -R 15 \
  -k 21,45,65,85,105 \
  -F animal_mt \
  -t 4

# Parameters:
# -1, -2: Input paired-end reads
# -o: Output directory
# -R: Rounds of extension
# -k: K-mer values for assembly
# -F: Organelle type (animal_mt for animal mitochondria)
# -t: Number of threads
```

### Advanced Assembly Options

For challenging assemblies:

```bash
# High-coverage data
get_organelle_from_reads.py \
  -1 data/raw_reads/sample_R1.fastq.gz \
  -2 data/raw_reads/sample_R2.fastq.gz \
  -o output/sample_mt_advanced \
  -R 20 \
  -k 21,45,65,85,105,115 \
  -F animal_mt \
  -t 8 \
  --max-reads 1.5E7 \
  --pre-grouped
```

### Output Files

After assembly, check the output directory:

```bash
output/sample_mt/
├── animal_mt.K*.assembly_graph.fastg    # Assembly graph
├── animal_mt.K*.assembly_graph.fastg.extend_animal_mt-GenomeType_*.fasta  # Extended contigs
├── animal_mt.K*.path_sequence.fasta     # Final assembled sequence(s)
├── get_org.log.txt                       # Log file
└── filtered_spades/                      # SPAdes assembly intermediate files
```

## Annotation

### Using MitoZ for Annotation

```bash
# Install MitoZ (if not already installed)
conda install -c bioconda mitoz

# Run annotation
mitoz annotate \
  --fastafile output/sample_mt/animal_mt.K*.path_sequence.fasta \
  --outprefix sample_mt_annotated \
  --thread_number 4 \
  --clade Chordata \
  --genetic_code 2
```

### Using MITOS

```bash
# Alternative annotation tool
# Install MITOS from https://mitos2.bioinf.uni-leipzig.de/

# Run MITOS annotation
mitos2 -i output/sample_mt/animal_mt.K*.path_sequence.fasta \
  -o output/annotations/mitos \
  -r refseq81m \
  -c 2
```

### Visualization

```bash
# Install Bandage for graph visualization
conda install -c bioconda bandage

# Visualize assembly graph
Bandage image output/sample_mt/animal_mt.K*.assembly_graph.fastg \
  output/sample_mt/assembly_graph.png
```

## Example Workflow

Complete workflow script (`scripts/assemble_mitochondria.sh`):

```bash
#!/bin/bash
# Complete mitochondrial genome assembly workflow

SAMPLE_NAME=$1
READ1=$2
READ2=$3
THREADS=${4:-4}

# Step 1: Quality check (optional)
echo "Running quality check..."
fastqc $READ1 $READ2 -t $THREADS -o qc_reports/

# Step 2: Assemble mitochondrial genome
echo "Assembling mitochondrial genome..."
get_organelle_from_reads.py \
  -1 $READ1 \
  -2 $READ2 \
  -o output/${SAMPLE_NAME}_mt \
  -R 15 \
  -k 21,45,65,85,105 \
  -F animal_mt \
  -t $THREADS

# Step 3: Annotate
echo "Annotating mitochondrial genome..."
mitoz annotate \
  --fastafile output/${SAMPLE_NAME}_mt/*.path_sequence.fasta \
  --outprefix ${SAMPLE_NAME}_annotated \
  --thread_number $THREADS \
  --clade Chordata \
  --genetic_code 2

echo "Workflow complete!"
```

Usage:
```bash
bash scripts/assemble_mitochondria.sh zebrafish data/raw_reads/zf_R1.fq.gz data/raw_reads/zf_R2.fq.gz 8
```

## Troubleshooting

### Common Issues

**1. Assembly produces multiple contigs**
- Increase `-R` (rounds of extension)
- Try different k-mer values
- Check if coverage is sufficient (>30x recommended)

**2. Low coverage warnings**
```bash
# Reduce --max-reads or increase input data
get_organelle_from_reads.py ... --max-reads 5E6
```

**3. No organelle genome found**
- Verify input data quality
- Check that reads contain mitochondrial sequences
- Try using a custom seed database from a closely related species

**4. Memory errors**
- Reduce number of threads (`-t`)
- Reduce `--max-reads` parameter
- Use a machine with more RAM

### Quality Assessment

```bash
# Check assembly completeness
grep ">" output/sample_mt/*.path_sequence.fasta

# Verify typical mitochondrial genome size (fish: 15-18 kb)
seqkit stats output/sample_mt/*.path_sequence.fasta

# Check for circular assembly
grep "circular" output/sample_mt/get_org.log.txt
```

## Best Practices

1. **Pre-process reads**: Trim adapters and low-quality bases before assembly
2. **Coverage**: Aim for at least 30x mitochondrial coverage (100x+ is better)
3. **Multiple k-mers**: Use multiple k-mer values for robust assembly
4. **Reference selection**: Use closely related species references when available
5. **Validation**: Compare assembled genome with known references
6. **Circularity**: Verify that the mitochondrial genome is circular

## Data Structure

Recommended project organization:

```
GetOrganelle/
├── data/
│   ├── raw_reads/           # Input FASTQ files
│   ├── references/          # Reference genomes from Mitofish
│   └── custom_database/     # Custom seed databases
├── output/                  # Assembly outputs
├── annotations/             # Annotation results
├── scripts/                 # Workflow scripts
├── qc_reports/             # Quality control reports
├── environment.yml         # Conda environment
└── requirements.txt        # Python dependencies
```

## References

1. **GetOrganelle**: Jin et al. (2020) Genome Biology [https://github.com/Kinggerm/GetOrganelle](https://github.com/Kinggerm/GetOrganelle)
2. **Mitofish**: Sato et al. (2018) Molecular Biology and Evolution [http://mitofish.aori.u-tokyo.ac.jp/](http://mitofish.aori.u-tokyo.ac.jp/)
3. **MitoZ**: Meng et al. (2019) Nucleic Acids Research [https://github.com/linzhi2013/MitoZ](https://github.com/linzhi2013/MitoZ)
4. **MITOS**: Bernt et al. (2013) Nucleic Acids Research [https://mitos2.bioinf.uni-leipzig.de/](https://mitos2.bioinf.uni-leipzig.de/)

## Citation

If you use this workflow, please cite:

```
Jin, J.J., Yu, W.B., Yang, J.B., Song, Y., dePamphilis, C.W., Yi, T.S., & Li, D.Z. (2020).
GetOrganelle: a fast and versatile toolkit for accurate de novo assembly of organelle genomes.
Genome Biology, 21(1), 241.
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
