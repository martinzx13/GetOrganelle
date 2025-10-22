# GetOrganelle Tutorial: Mitochondrial Genome Assembly

## Introduction

This tutorial walks through a complete workflow for assembling and annotating mitochondrial genomes from fish genomic data using GetOrganelle and the Mitofish database.

## Prerequisites

Before starting, ensure you have:
- GetOrganelle installed (see README.md)
- At least 8GB RAM
- 20GB free disk space
- Paired-end Illumina sequencing data

## Quick Start

For the impatient, here's a 3-step quick start:

```bash
# 1. Setup databases
bash scripts/setup_database.sh

# 2. Place your FASTQ files in data/raw_reads/
cp /path/to/your/*_R1.fastq.gz data/raw_reads/
cp /path/to/your/*_R2.fastq.gz data/raw_reads/

# 3. Run assembly
bash scripts/assemble_mitochondria.sh my_sample \
  data/raw_reads/sample_R1.fastq.gz \
  data/raw_reads/sample_R2.fastq.gz \
  8
```

## Detailed Walkthrough

### Step 1: Environment Setup

#### Option A: Using Conda (Recommended)

```bash
# Create environment from file
conda env create -f environment.yml

# Activate environment
conda activate getorganelle

# Verify installation
get_organelle_from_reads.py --version
```

#### Option B: Manual Installation

```bash
# Create new environment
conda create -n getorganelle python=3.8

# Activate environment
conda activate getorganelle

# Install GetOrganelle
conda install -c bioconda getorganelle

# Install additional tools
conda install -c bioconda spades bowtie2 blast bandage fastqc seqkit
```

### Step 2: Database Configuration

```bash
# Run setup script
bash scripts/setup_database.sh
```

This script will:
- Download and configure GetOrganelle databases
- Create project directory structure
- Download example reference genomes from Mitofish:
  - Zebrafish (Danio rerio)
  - Medaka (Oryzias latipes)
  - Atlantic Salmon (Salmo salar)

#### Manual Database Setup

If you prefer manual setup:

```bash
# Add animal mitochondrial database
get_organelle_config.py --add animal_mt

# List available databases
get_organelle_config.py --list

# Download specific reference from Mitofish
wget -O data/references/species_mt.fasta \
  "https://www.ncbi.nlm.nih.gov/nuccore/ACCESSION?report=fasta"
```

### Step 3: Data Preparation

#### Organize Your Data

```bash
# Create directory structure
mkdir -p data/raw_reads

# Copy your sequencing data
cp /path/to/sample_R1.fastq.gz data/raw_reads/
cp /path/to/sample_R2.fastq.gz data/raw_reads/
```

#### Quality Check (Optional but Recommended)

```bash
# Run FastQC
fastqc data/raw_reads/*.fastq.gz -o qc_reports/ -t 4

# View results
open qc_reports/*.html  # macOS
xdg-open qc_reports/*.html  # Linux
```

#### Data Requirements

- **Format**: Paired-end FASTQ files (compressed or uncompressed)
- **Coverage**: At least 30x mitochondrial coverage (higher is better)
- **Quality**: Phred score ≥ 20 recommended
- **Read length**: 100bp or longer preferred

### Step 4: Genome Assembly

#### Basic Assembly

```bash
# Run assembly for a single sample
get_organelle_from_reads.py \
  -1 data/raw_reads/sample_R1.fastq.gz \
  -2 data/raw_reads/sample_R2.fastq.gz \
  -o output/sample_mt \
  -R 15 \
  -k 21,45,65,85,105 \
  -F animal_mt \
  -t 4
```

#### Using the Workflow Script

```bash
# Run complete workflow
bash scripts/assemble_mitochondria.sh sample_name \
  data/raw_reads/sample_R1.fastq.gz \
  data/raw_reads/sample_R2.fastq.gz \
  8  # number of threads
```

#### Parameter Explanation

- `-1, -2`: Input paired-end reads
- `-o`: Output directory
- `-R`: Rounds of extension (increase for difficult assemblies)
- `-k`: K-mer values (use multiple for robust assembly)
- `-F`: Organelle type (animal_mt for fish mitochondria)
- `-t`: Number of CPU threads

#### Advanced Assembly Options

For challenging samples:

```bash
# High-coverage assembly
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

### Step 5: Analyzing Results

#### Check Assembly Output

```bash
# View output directory
ls -lh output/sample_mt/

# Check for assembled sequence
cat output/sample_mt/*.path_sequence.fasta

# Get statistics
seqkit stats output/sample_mt/*.path_sequence.fasta
```

#### Expected Output Files

```
output/sample_mt/
├── animal_mt.K*.assembly_graph.fastg          # Assembly graph
├── animal_mt.K*.path_sequence.fasta           # Final sequence(s)
├── get_org.log.txt                            # Assembly log
└── filtered_spades/                           # SPAdes files
```

#### Validate Assembly

```bash
# Check if genome is circular
grep -i "circular" output/sample_mt/get_org.log.txt

# Verify size (fish mitochondria typically 15-18 kb)
seqkit stats output/sample_mt/*.path_sequence.fasta

# Count sequences (should be 1 for complete assembly)
grep -c ">" output/sample_mt/*.path_sequence.fasta
```

### Step 6: Genome Annotation

#### Using MitoZ

```bash
# Install MitoZ if needed
conda install -c bioconda mitoz

# Run annotation
mitoz annotate \
  --fastafile output/sample_mt/*.path_sequence.fasta \
  --outprefix annotations/sample_annotated \
  --thread_number 4 \
  --clade Chordata \
  --genetic_code 2
```

#### Annotation Output

MitoZ produces:
- GenBank format file (.gbf)
- Feature table (.tbl)
- Gene predictions (protein-coding, rRNA, tRNA)
- Circular genome visualization

#### Manual Annotation (Alternative)

```bash
# Using MITOS web server
# 1. Visit https://mitos2.bioinf.uni-leipzig.de/
# 2. Upload your assembled FASTA file
# 3. Select "Chordata" and genetic code 2
# 4. Download results
```

### Step 7: Visualization

#### Assembly Graph Visualization

```bash
# Install Bandage
conda install -c bioconda bandage

# Generate image
Bandage image output/sample_mt/*.assembly_graph.fastg \
  output/sample_mt/assembly_graph.png
```

#### View in Bandage GUI

```bash
# Open GUI
Bandage
# File → Load graph → Select .fastg file
```

### Step 8: Comparison with References

```bash
# Compare with reference from Mitofish
# Using BLAST
makeblastdb -in data/references/zebrafish_mt.fasta -dbtype nucl

blastn -query output/sample_mt/*.path_sequence.fasta \
  -db data/references/zebrafish_mt.fasta \
  -out output/sample_mt/blast_results.txt \
  -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore"
```

## Troubleshooting

### Problem: Assembly produces multiple contigs

**Solution:**
```bash
# Increase extension rounds
get_organelle_from_reads.py ... -R 20

# Try additional k-mer values
get_organelle_from_reads.py ... -k 21,35,45,55,65,75,85,95,105
```

### Problem: No organelle genome found

**Solutions:**
1. Check input data quality with FastQC
2. Verify sufficient coverage (use `--max-reads 5E6` to test with subset)
3. Try using a custom seed from a related species:

```bash
# Use closely related species as seed
get_organelle_from_reads.py ... -s data/references/related_species.fasta
```

### Problem: Assembly stops early

**Solution:**
```bash
# Increase memory/resources
# Reduce max-reads
get_organelle_from_reads.py ... --max-reads 1E7
```

### Problem: Circular genome not detected

**Solutions:**
1. Check log file for warnings
2. Manually verify overlap between contig ends
3. Try different k-mer combinations

## Best Practices

### Before Assembly

1. **Quality Control**: Always run FastQC on your data
2. **Coverage Estimation**: Ensure >30x mitochondrial coverage
3. **Trimming**: Remove adapters if present (use Trimmomatic or fastp)

### During Assembly

1. **Multiple K-mers**: Use at least 5 different k-mer values
2. **Adequate Resources**: Allocate sufficient RAM and CPU
3. **Monitor Progress**: Check log files during assembly

### After Assembly

1. **Validate Circularity**: Ensure genome is circular
2. **Check Size**: Compare with expected size for species
3. **Compare with References**: BLAST against known sequences
4. **Manual Inspection**: View assembly graph in Bandage

## Example Workflows

### Workflow 1: Single Sample

```bash
# Setup (once)
bash scripts/setup_database.sh

# Per sample
bash scripts/assemble_mitochondria.sh zebrafish_01 \
  data/raw_reads/zf01_R1.fq.gz \
  data/raw_reads/zf01_R2.fq.gz \
  8
```

### Workflow 2: Multiple Samples (Batch Processing)

```bash
# Create batch script
cat > process_all_samples.sh << 'EOF'
#!/bin/bash
for r1 in data/raw_reads/*_R1.fastq.gz; do
    r2=${r1/_R1/_R2}
    sample=$(basename $r1 _R1.fastq.gz)
    
    echo "Processing $sample..."
    bash scripts/assemble_mitochondria.sh $sample $r1 $r2 8
done
EOF

chmod +x process_all_samples.sh
./process_all_samples.sh
```

### Workflow 3: Low Coverage Data

```bash
# For samples with low coverage
get_organelle_from_reads.py \
  -1 data/raw_reads/lowcov_R1.fq.gz \
  -2 data/raw_reads/lowcov_R2.fq.gz \
  -o output/lowcov_mt \
  -R 20 \
  -k 21,35,45,55,65,75,85,95,105,115 \
  -F animal_mt \
  -t 8 \
  --reduce-reads-for-coverage inf
```

## Additional Resources

### Mitofish Database
- Website: http://mitofish.aori.u-tokyo.ac.jp/
- Search for fish species
- Download complete mitochondrial genomes
- Access phylogenetic data

### GetOrganelle Resources
- GitHub: https://github.com/Kinggerm/GetOrganelle
- Documentation: See GitHub wiki
- Issues: Report bugs or ask questions

### Citation

If you use this workflow, please cite:

```
Jin, J.J., Yu, W.B., Yang, J.B., Song, Y., dePamphilis, C.W., Yi, T.S., & Li, D.Z. (2020).
GetOrganelle: a fast and versatile toolkit for accurate de novo assembly of organelle genomes.
Genome Biology, 21(1), 241.
```

## Appendix

### Genetic Codes for Common Taxa

- Code 2: Vertebrate Mitochondrial (most fish, mammals, birds)
- Code 5: Invertebrate Mitochondrial (most invertebrates)
- Code 9: Echinoderm Mitochondrial
- Code 13: Ascidian Mitochondrial

### Expected Mitochondrial Genome Sizes

- Fish: 15,000 - 18,000 bp
- Mammals: 16,000 - 17,000 bp
- Birds: 16,000 - 18,000 bp
- Invertebrates: 14,000 - 20,000 bp

### Typical Mitochondrial Genes (Fish)

Protein-coding: 13 genes (ND1-6, ND4L, COX1-3, ATP6, ATP8, CYTB)
rRNA: 2 genes (12S, 16S)
tRNA: 22 genes
Control region: D-loop

---

**Last Updated**: October 2025
**Version**: 1.0
