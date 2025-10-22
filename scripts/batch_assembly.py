#!/usr/bin/env python3
"""
batch_assembly.py

Batch processing script for multiple samples using GetOrganelle.
This script automates the assembly of mitochondrial genomes for multiple samples.

Usage:
    python scripts/batch_assembly.py --samples samples.txt --threads 8

Sample file format (samples.txt):
    sample_name1,path/to/R1.fq.gz,path/to/R2.fq.gz
    sample_name2,path/to/R1.fq.gz,path/to/R2.fq.gz
"""

import argparse
import csv
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description='Batch assembly of mitochondrial genomes using GetOrganelle'
    )
    parser.add_argument(
        '--samples',
        required=True,
        help='CSV file with sample information (name,R1,R2)'
    )
    parser.add_argument(
        '--threads',
        type=int,
        default=4,
        help='Number of threads per sample (default: 4)'
    )
    parser.add_argument(
        '--output-dir',
        default='output',
        help='Base output directory (default: output)'
    )
    parser.add_argument(
        '--kmer',
        default='21,45,65,85,105',
        help='K-mer values (default: 21,45,65,85,105)'
    )
    parser.add_argument(
        '--rounds',
        type=int,
        default=15,
        help='Extension rounds (default: 15)'
    )
    parser.add_argument(
        '--organelle-type',
        default='animal_mt',
        help='Organelle type (default: animal_mt)'
    )
    parser.add_argument(
        '--continue-on-error',
        action='store_true',
        help='Continue processing if a sample fails'
    )
    
    return parser.parse_args()


def read_samples(sample_file):
    """
    Read sample information from CSV file.
    
    Returns:
        list: List of tuples (sample_name, read1, read2)
    """
    samples = []
    
    try:
        with open(sample_file, 'r') as f:
            reader = csv.reader(f)
            for line_num, row in enumerate(reader, 1):
                if len(row) != 3:
                    print(f"Warning: Skipping line {line_num} - expected 3 columns, got {len(row)}")
                    continue
                
                sample_name, read1, read2 = [x.strip() for x in row]
                
                # Validate files exist
                if not os.path.exists(read1):
                    print(f"Warning: Read1 file not found for {sample_name}: {read1}")
                    continue
                if not os.path.exists(read2):
                    print(f"Warning: Read2 file not found for {sample_name}: {read2}")
                    continue
                
                samples.append((sample_name, read1, read2))
    
    except FileNotFoundError:
        print(f"Error: Sample file not found: {sample_file}")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading sample file: {e}")
        sys.exit(1)
    
    return samples


def run_getorganelle(sample_name, read1, read2, output_dir, args):
    """
    Run GetOrganelle for a single sample.
    
    Returns:
        bool: True if successful, False otherwise
    """
    sample_output = os.path.join(output_dir, f"{sample_name}_mt")
    
    cmd = [
        'get_organelle_from_reads.py',
        '-1', read1,
        '-2', read2,
        '-o', sample_output,
        '-R', str(args.rounds),
        '-k', args.kmer,
        '-F', args.organelle_type,
        '-t', str(args.threads)
    ]
    
    print(f"\n{'='*60}")
    print(f"Processing: {sample_name}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Command: {' '.join(cmd)}")
    print(f"{'='*60}\n")
    
    try:
        result = subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        print(f"\n[SUCCESS] {sample_name} completed successfully")
        return True
    
    except subprocess.CalledProcessError as e:
        print(f"\n[FAILED] {sample_name} failed with error:")
        print(e.stderr)
        return False
    
    except Exception as e:
        print(f"\n[ERROR] Unexpected error for {sample_name}:")
        print(str(e))
        return False


def generate_summary(results, output_dir):
    """Generate a summary report of the batch processing."""
    summary_file = os.path.join(output_dir, 'batch_assembly_summary.txt')
    
    with open(summary_file, 'w') as f:
        f.write("GetOrganelle Batch Assembly Summary\n")
        f.write("=" * 60 + "\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        total = len(results)
        successful = sum(1 for r in results if r['success'])
        failed = total - successful
        
        f.write(f"Total samples: {total}\n")
        f.write(f"Successful: {successful}\n")
        f.write(f"Failed: {failed}\n\n")
        
        f.write("Sample Details:\n")
        f.write("-" * 60 + "\n")
        
        for result in results:
            status = "SUCCESS" if result['success'] else "FAILED"
            f.write(f"{result['sample_name']:<30} {status}\n")
    
    print(f"\nSummary report saved to: {summary_file}")
    return summary_file


def main():
    """Main execution function."""
    args = parse_arguments()
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Read sample information
    print(f"Reading sample information from: {args.samples}")
    samples = read_samples(args.samples)
    
    if not samples:
        print("Error: No valid samples found in the input file")
        sys.exit(1)
    
    print(f"\nFound {len(samples)} samples to process")
    print(f"Parameters:")
    print(f"  - Threads per sample: {args.threads}")
    print(f"  - K-mer values: {args.kmer}")
    print(f"  - Extension rounds: {args.rounds}")
    print(f"  - Organelle type: {args.organelle_type}")
    print(f"  - Output directory: {args.output_dir}")
    
    # Process each sample
    results = []
    
    for i, (sample_name, read1, read2) in enumerate(samples, 1):
        print(f"\n\nProcessing sample {i}/{len(samples)}: {sample_name}")
        
        success = run_getorganelle(sample_name, read1, read2, args.output_dir, args)
        
        results.append({
            'sample_name': sample_name,
            'success': success
        })
        
        if not success and not args.continue_on_error:
            print(f"\nStopping batch processing due to failure (use --continue-on-error to override)")
            break
    
    # Generate summary
    print("\n" + "=" * 60)
    print("Batch Processing Complete")
    print("=" * 60)
    
    summary_file = generate_summary(results, args.output_dir)
    
    # Print summary
    total = len(results)
    successful = sum(1 for r in results if r['success'])
    failed = total - successful
    
    print(f"\nResults:")
    print(f"  Total: {total}")
    print(f"  Successful: {successful}")
    print(f"  Failed: {failed}")
    
    if failed > 0:
        print("\nFailed samples:")
        for result in results:
            if not result['success']:
                print(f"  - {result['sample_name']}")
    
    sys.exit(0 if failed == 0 else 1)


if __name__ == '__main__':
    main()
