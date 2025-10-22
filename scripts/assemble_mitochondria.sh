#!/bin/bash
#
# assemble_mitochondria.sh
# Complete workflow for mitochondrial genome assembly using GetOrganelle
#
# Usage: bash assemble_mitochondria.sh SAMPLE_NAME READ1 READ2 [THREADS]
#
# Example:
#   bash assemble_mitochondria.sh zebrafish data/raw_reads/zf_R1.fq.gz data/raw_reads/zf_R2.fq.gz 8

set -e  # Exit on error
set -u  # Exit on undefined variable

# Check arguments
if [ $# -lt 3 ]; then
    echo "Error: Insufficient arguments"
    echo "Usage: $0 SAMPLE_NAME READ1 READ2 [THREADS]"
    echo ""
    echo "Arguments:"
    echo "  SAMPLE_NAME  - Sample identifier (e.g., 'zebrafish')"
    echo "  READ1        - Path to forward reads (R1) FASTQ file"
    echo "  READ2        - Path to reverse reads (R2) FASTQ file"
    echo "  THREADS      - Number of threads to use (default: 4)"
    exit 1
fi

SAMPLE_NAME=$1
READ1=$2
READ2=$3
THREADS=${4:-4}

# Validate input files
if [ ! -f "$READ1" ]; then
    echo "Error: Forward reads file not found: $READ1"
    exit 1
fi

if [ ! -f "$READ2" ]; then
    echo "Error: Reverse reads file not found: $READ2"
    exit 1
fi

# Create output directories
mkdir -p output
mkdir -p qc_reports
mkdir -p annotations

echo "========================================="
echo "GetOrganelle Mitochondrial Assembly"
echo "========================================="
echo "Sample: $SAMPLE_NAME"
echo "Forward reads: $READ1"
echo "Reverse reads: $READ2"
echo "Threads: $THREADS"
echo "========================================="
echo ""

# Step 1: Quality check (optional but recommended)
echo "[$(date)] Step 1: Running quality check..."
if command -v fastqc &> /dev/null; then
    fastqc "$READ1" "$READ2" -t "$THREADS" -o qc_reports/ 2>/dev/null || true
    echo "[$(date)] Quality check complete. Results in qc_reports/"
else
    echo "[$(date)] FastQC not found. Skipping quality check."
fi
echo ""

# Step 2: Assemble mitochondrial genome with GetOrganelle
echo "[$(date)] Step 2: Assembling mitochondrial genome..."
get_organelle_from_reads.py \
  -1 "$READ1" \
  -2 "$READ2" \
  -o "output/${SAMPLE_NAME}_mt" \
  -R 15 \
  -k 21,45,65,85,105 \
  -F animal_mt \
  -t "$THREADS"

if [ $? -eq 0 ]; then
    echo "[$(date)] Assembly complete!"
else
    echo "[$(date)] Assembly failed. Check logs in output/${SAMPLE_NAME}_mt/"
    exit 1
fi
echo ""

# Step 3: Check assembly results
echo "[$(date)] Step 3: Checking assembly results..."
if [ -f "output/${SAMPLE_NAME}_mt"/*.path_sequence.fasta ]; then
    ASSEMBLY_FILE=$(ls output/${SAMPLE_NAME}_mt/*.path_sequence.fasta | head -n 1)
    echo "Assembly file: $ASSEMBLY_FILE"
    
    # Get basic statistics if seqkit is available
    if command -v seqkit &> /dev/null; then
        echo "Assembly statistics:"
        seqkit stats "$ASSEMBLY_FILE"
    else
        echo "Number of sequences:"
        grep -c ">" "$ASSEMBLY_FILE" || echo "0"
    fi
else
    echo "Warning: No assembly file found!"
    echo "Check output/${SAMPLE_NAME}_mt/get_org.log.txt for details"
fi
echo ""

# Step 4: Annotate (if MitoZ is available)
echo "[$(date)] Step 4: Annotating mitochondrial genome..."
if command -v mitoz &> /dev/null; then
    if [ -f "output/${SAMPLE_NAME}_mt"/*.path_sequence.fasta ]; then
        ASSEMBLY_FILE=$(ls output/${SAMPLE_NAME}_mt/*.path_sequence.fasta | head -n 1)
        
        mitoz annotate \
          --fastafile "$ASSEMBLY_FILE" \
          --outprefix "annotations/${SAMPLE_NAME}_annotated" \
          --thread_number "$THREADS" \
          --clade Chordata \
          --genetic_code 2
        
        echo "[$(date)] Annotation complete! Results in annotations/"
    fi
else
    echo "[$(date)] MitoZ not found. Skipping annotation."
    echo "Install MitoZ with: conda install -c bioconda mitoz"
fi
echo ""

# Step 5: Generate summary report
echo "[$(date)] Step 5: Generating summary report..."
REPORT_FILE="output/${SAMPLE_NAME}_assembly_report.txt"

cat > "$REPORT_FILE" << EOF
Mitochondrial Genome Assembly Report
=====================================
Sample: $SAMPLE_NAME
Date: $(date)

Input Files:
- Forward reads: $READ1
- Reverse reads: $READ2

Parameters:
- Threads: $THREADS
- Organelle type: animal_mt
- K-mer values: 21,45,65,85,105
- Extension rounds: 15

Output Directory: output/${SAMPLE_NAME}_mt

EOF

if [ -f "output/${SAMPLE_NAME}_mt"/*.path_sequence.fasta ]; then
    ASSEMBLY_FILE=$(ls output/${SAMPLE_NAME}_mt/*.path_sequence.fasta | head -n 1)
    echo "Assembly: SUCCESS" >> "$REPORT_FILE"
    echo "Assembly file: $ASSEMBLY_FILE" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    if command -v seqkit &> /dev/null; then
        echo "Assembly Statistics:" >> "$REPORT_FILE"
        seqkit stats "$ASSEMBLY_FILE" >> "$REPORT_FILE"
    fi
else
    echo "Assembly: FAILED" >> "$REPORT_FILE"
    echo "Check logs: output/${SAMPLE_NAME}_mt/get_org.log.txt" >> "$REPORT_FILE"
fi

echo "[$(date)] Report saved to $REPORT_FILE"
echo ""

echo "========================================="
echo "Workflow Complete!"
echo "========================================="
echo "Output directory: output/${SAMPLE_NAME}_mt"
echo "Report: $REPORT_FILE"
if [ -d "annotations" ] && [ "$(ls -A annotations 2>/dev/null)" ]; then
    echo "Annotations: annotations/"
fi
echo "========================================="
