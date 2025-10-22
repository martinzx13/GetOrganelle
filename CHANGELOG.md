# Changelog

All notable changes to the GetOrganelle Mitochondrial Assembly project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-22

### Added

#### Documentation
- **README.md**: Comprehensive project documentation including:
  - Overview of GetOrganelle and mitochondrial genome assembly
  - Installation instructions (Conda and pip)
  - Database setup for Mitofish and GetOrganelle
  - Detailed assembly and annotation workflows
  - Troubleshooting guide
  - Best practices and validation checks
  - References and citations

- **TUTORIAL.md**: Step-by-step tutorial covering:
  - Environment setup (Conda and manual installation)
  - Database configuration and Mitofish integration
  - Data preparation and quality control
  - Genome assembly with detailed parameter explanations
  - Results analysis and validation
  - Annotation using MitoZ and MITOS
  - Visualization with Bandage
  - Multiple example workflows
  - Troubleshooting common issues
  - Appendix with genetic codes and expected genome sizes

- **QUICKREF.md**: Quick reference guide including:
  - Installation commands
  - Basic assembly syntax
  - Parameter reference table
  - K-mer selection guide
  - Troubleshooting quick fixes
  - Common validation checks

- **CONTRIBUTING.md**: Contribution guidelines covering:
  - Types of contributions accepted
  - Code style guidelines for Bash and Python
  - Testing requirements
  - Documentation standards
  - Pull request process
  - Community guidelines

#### Environment Configuration
- **environment.yml**: Conda environment specification with:
  - GetOrganelle and dependencies
  - SPAdes for de novo assembly
  - BLAST for sequence comparison
  - Bandage for graph visualization
  - Quality control tools (FastQC, seqkit)
  - Python scientific libraries
  - MitoZ for annotation

- **requirements.txt**: Python package dependencies including:
  - Biopython for sequence handling
  - NumPy and SciPy for numerical operations
  - Matplotlib and Seaborn for visualization
  - Pandas for data analysis

#### Scripts
- **scripts/setup_database.sh**: Database setup automation
  - Downloads and configures GetOrganelle databases
  - Creates project directory structure
  - Downloads example fish mitochondrial genomes from Mitofish:
    - Zebrafish (Danio rerio)
    - Medaka (Oryzias latipes)
    - Atlantic Salmon (Salmo salar)
  - Validates installation

- **scripts/assemble_mitochondria.sh**: Complete assembly workflow
  - Quality control with FastQC
  - Mitochondrial genome assembly with GetOrganelle
  - Assembly validation and statistics
  - Annotation with MitoZ (if available)
  - Generates comprehensive assembly report
  - Error handling and logging

- **scripts/batch_assembly.py**: Batch processing script
  - Processes multiple samples from CSV file
  - Parallel processing support
  - Progress tracking and reporting
  - Error handling with continue-on-error option
  - Summary report generation
  - Customizable parameters

#### Templates
- **config.template**: Configuration template with:
  - Assembly parameters (k-mer values, extension rounds)
  - Organelle type selection
  - Advanced options
  - Annotation settings (genetic code, taxonomic clade)
  - Quality control parameters
  - Project path definitions

- **samples.template**: Sample file template for batch processing
  - CSV format specification
  - Example entries for multiple samples

#### Project Structure
- **data/**: Data directories with .gitkeep files
  - `data/raw_reads/`: For input FASTQ files
  - `data/references/`: For reference genomes from Mitofish

- **output/**: Assembly output directory (excluded from git)

- **annotations/**: Annotation results directory (excluded from git)

- **qc_reports/**: Quality control reports directory (excluded from git)

- **.gitignore**: Git ignore rules for:
  - Data files (FASTQ)
  - Output directories
  - Assembly intermediate files
  - Python artifacts
  - IDE files
  - Logs and temporary files

### Features

#### Workflow Capabilities
- Complete mitochondrial genome assembly from paired-end reads
- Integration with Mitofish database for fish species
- Automated database setup and configuration
- Quality control integration
- Annotation support (MitoZ/MITOS)
- Assembly graph visualization
- Batch processing for multiple samples
- Comprehensive reporting

#### Supported Organisms
- Primary focus: Fish (animal_mt with Mitofish)
- Also supports: Other animals, plants, fungi (via GetOrganelle databases)

#### Key Features
- Automated workflow scripts
- Comprehensive documentation
- Example configurations
- Best practices included
- Troubleshooting guides
- Multiple validation checks

### Documentation Coverage

The project includes complete documentation for:
- Installation and setup
- Database configuration
- Assembly workflows
- Annotation procedures
- Quality control
- Results validation
- Troubleshooting
- Contribution guidelines

### Project Status

**Version 1.0.0** represents the initial complete release with:
- Full workflow implementation
- Comprehensive documentation
- Example scripts and templates
- Best practices guide
- Ready for production use

---

## Future Enhancements (Planned)

### Potential Future Additions
- Example datasets for testing
- Docker/Singularity containers
- Nextflow/Snakemake workflow implementations
- Additional annotation tools integration
- Automated quality metrics dashboard
- Integration with phylogenetic analysis tools
- Support for long-read sequencing (PacBio/Nanopore)

---

[1.0.0]: https://github.com/martinzx13/GetOrganelle/releases/tag/v1.0.0
