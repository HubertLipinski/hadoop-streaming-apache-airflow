#!/bin/bash
# Hive job runner for processing MapReduce output and airports data
# Usage: run_hive.sh input_dir4 output_dir3 output_dir6

set -e

usage() {
    echo "Usage: $0 input_dir4 output_dir3 output_dir6"
    echo "  input_dir4  - HDFS path to airports data (datasource4)"
    echo "  output_dir3 - HDFS path to MapReduce output (input for Hive)"
    echo "  output_dir6 - HDFS path for final JSON output"
    echo "Example: $0 /project1/input/datasource4 /project1/output_mr3 /project1/output6"
    exit 1
}

if [ $# -ne 3 ]; then
    echo "ERROR: Invalid number of parameters. Expected 3, got $#"
    usage
fi

INPUT_DIR4="$1"
OUTPUT_DIR3="$2"
OUTPUT_DIR6="$3"

echo "========================================"
echo "Hive Job Configuration"
echo "========================================"
echo "Airports data (input):  $INPUT_DIR4"
echo "MapReduce result:       $OUTPUT_DIR3"
echo "JSON output:            $OUTPUT_DIR6"
echo "========================================"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HIVE_SCRIPT="$SCRIPT_DIR/hive.hql"

# Check required files
if [ ! -f "$HIVE_SCRIPT" ]; then
    echo "ERROR: Hive script not found: $HIVE_SCRIPT"
    exit 1
fi

# Verify input directories exist
if ! hadoop fs -test -d "$INPUT_DIR4" 2>/dev/null; then
    echo "ERROR: Airports data directory does not exist: $INPUT_DIR4"
    exit 1
fi

if ! hadoop fs -test -d "$OUTPUT_DIR3" 2>/dev/null; then
    echo "ERROR: MapReduce output directory does not exist: $OUTPUT_DIR3"
    exit 1
fi

# Clean output directory for repeatability
if hadoop fs -test -d "$OUTPUT_DIR6" 2>/dev/null; then
    echo "Removing existing output directory: $OUTPUT_DIR6"
    hadoop fs -rm -f -r "$OUTPUT_DIR6"
fi

echo "Starting Hive job..."

# Run Hive job using beeline
# NOTE: Using beeline instead of deprecated hive CLI
# IMPORTANT: -n flag with current user ensures proper authentication (required in BigData25)
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default \
    --hiveconf output_dir3="$OUTPUT_DIR3" \
    --hiveconf input_dir4="$INPUT_DIR4" \
    --hiveconf output_dir6="$OUTPUT_DIR6" \
    -f "$HIVE_SCRIPT"

if [ $? -eq 0 ]; then
    echo "========================================"
    echo "Hive job completed successfully!"
    echo "========================================"
    echo "Output location: $OUTPUT_DIR6"
    echo ""
    echo "Sample output (first 10 records):"
    echo "----------------------------------------"
    hadoop fs -cat "$OUTPUT_DIR6/000000_0" 2>/dev/null | head -10 || \
        hadoop fs -cat "$OUTPUT_DIR6/*" 2>/dev/null | head -10 || \
        echo "Could not display sample output"
    echo "========================================"
else
    echo "ERROR: Hive job failed!"
    exit 1
fi
