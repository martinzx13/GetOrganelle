# GetOrganelle Quick Reference

## Installation

```bash
# Conda installation
conda install -c bioconda getorganelle
get_organelle_config.py --add animal_mt

# OR create environment
conda env create -f environment.yml
conda activate getorganelle
```

## Basic Assembly Command

```bash
get_organelle_from_reads.py \
  -1 forward_reads.fq.gz \
  -2 reverse_reads.fq.gz \
  -o output_directory \
  -F animal_mt \
  -t 4
```

## Common Parameters

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `-1` | Forward reads | Required | `reads_R1.fq.gz` |
| `-2` | Reverse reads | Required | `reads_R2.fq.gz` |
| `-o` | Output directory | Required | `output/sample_mt` |
| `-F` | Organelle type | Required | `animal_mt` |
| `-t` | Threads | 1 | `8` |
| `-R` | Extension rounds | 15 | `20` |
| `-k` | K-mer values | auto | `21,45,65,85,105` |
| `-s` | Seed file | auto | `custom_seed.fasta` |
| `--max-reads` | Max reads to use | all | `1E7` |

## Organelle Types

- `animal_mt` - Animal mitochondria
- `embplant_pt` - Plant plastids
- `embplant_mt` - Plant mitochondria
- `fungus_mt` - Fungal mitochondria
- `embplant_nr` - Plant nuclear ribosomal DNA

## K-mer Selection Guide

| Read Length | Recommended K-mers |
|-------------|-------------------|
| 100-150 bp | 21,45,65,85,105 |
| 150-250 bp | 21,55,85,105,125 |
| >250 bp | 31,65,95,115,127 |

## Troubleshooting Quick Fixes

### No genome found
```bash
# Try with limited reads
get_organelle_from_reads.py ... --max-reads 5E6

# Use custom seed from related species
get_organelle_from_reads.py ... -s reference.fasta
```

### Multiple contigs
```bash
# Increase extension rounds
get_organelle_from_reads.py ... -R 20

# Add more k-mers
get_organelle_from_reads.py ... -k 21,35,45,55,65,75,85,95,105
```

### Low coverage
```bash
# Use all reads, more rounds
get_organelle_from_reads.py ... -R 25 --reduce-reads-for-coverage inf
```

## Output Files

| File | Description |
|------|-------------|
| `*.path_sequence.fasta` | Final assembled sequence |
| `*.assembly_graph.fastg` | Assembly graph |
| `get_org.log.txt` | Assembly log |
| `filtered_spades/` | SPAdes intermediate files |

## Annotation

### MitoZ
```bash
mitoz annotate \
  --fastafile assembled.fasta \
  --outprefix annotated \
  --thread_number 4 \
  --clade Chordata \
  --genetic_code 2
```

### Genetic Codes
- 2: Vertebrate Mitochondrial
- 5: Invertebrate Mitochondrial
- 9: Echinoderm Mitochondrial
- 13: Ascidian Mitochondrial

## Validation Checks

```bash
# Check assembly size
seqkit stats output/*.path_sequence.fasta

# Check for circularity
grep -i "circular" output/get_org.log.txt

# Count sequences (should be 1)
grep -c ">" output/*.path_sequence.fasta

# Visualize graph
Bandage image output/*.assembly_graph.fastg output/graph.png
```

## Expected Genome Sizes

- Fish: 15-18 kb
- Mammals: 16-17 kb
- Birds: 16-18 kb
- Invertebrates: 14-20 kb

## Workflow Scripts

### Setup
```bash
bash scripts/setup_database.sh
```

### Assembly
```bash
bash scripts/assemble_mitochondria.sh sample_name \
  reads_R1.fq.gz reads_R2.fq.gz 8
```

## Resources

- GetOrganelle: https://github.com/Kinggerm/GetOrganelle
- Mitofish: http://mitofish.aori.u-tokyo.ac.jp/
- MitoZ: https://github.com/linzhi2013/MitoZ
- Documentation: See README.md and TUTORIAL.md
