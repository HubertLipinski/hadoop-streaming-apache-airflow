#!/bin/bash
# MapReduce job runner for Hadoop Streaming
# Usage: run_mr.sh input_dir1 output_dir3

set -e

usage() {
    echo "Usage: $0 input_dir1 output_dir3"
    echo "  input_dir1  - HDFS path to input data (flights data)"
    echo "  output_dir3 - HDFS path for MapReduce output"
    echo "Example: $0 /project1/input /project1/output_mr3"
    exit 1
}

if [ $# -ne 2 ]; then
    echo "ERROR: Invalid number of parameters. Expected 2, got $#"
    usage
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"

echo "MapReduce Job: $INPUT_DIR -> $OUTPUT_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPER_FILE="$SCRIPT_DIR/mapper.py"
REDUCER_FILE="$SCRIPT_DIR/reducer.py"
COMBINER_FILE="$SCRIPT_DIR/combiner.py"

# Check required files
for file in "$MAPPER_FILE" "$REDUCER_FILE" "$COMBINER_FILE"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
done

chmod +x "$MAPPER_FILE" "$REDUCER_FILE" "$COMBINER_FILE"

# Clean output directory for repeatability
if hadoop fs -test -d "$OUTPUT_DIR" 2>/dev/null; then
    echo "Removing existing output directory: $OUTPUT_DIR"
    hadoop fs -rm -f -r "$OUTPUT_DIR"
fi

# Verify input directory
if ! hadoop fs -test -d "$INPUT_DIR" 2>/dev/null; then
    echo "ERROR: Input directory does not exist: $INPUT_DIR"
    exit 1
fi

echo "Starting MapReduce job..."

# Run MapReduce job
mapred streaming \
    -files "$MAPPER_FILE","$REDUCER_FILE","$COMBINER_FILE" \
    -mapper "mapper.py" \
    -reducer "reducer.py" \
    -combiner "combiner.py" \
    -input "$INPUT_DIR" \
    -output "$OUTPUT_DIR" \
    -jobconf mapreduce.job.reduces=4 \
    -jobconf mapreduce.map.output.compress=true \
    -jobconf mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec

if [ $? -eq 0 ]; then
    echo "MapReduce job completed successfully!"
    echo "Output location: $OUTPUT_DIR"
    echo "Sample output:"
    hadoop fs -cat "$OUTPUT_DIR/part-*" | head -10 2>/dev/null || echo "Could not display sample output"
else
    echo "ERROR: MapReduce job failed!"
    exit 1
fi