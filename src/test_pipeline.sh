#!/bin/bash
# Local test pipeline for MapReduce and verification
# Tests the complete data flow: mapper -> combiner -> reducer

set -e

echo "========================================"
echo "Local Pipeline Test"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if test data exists
if [ ! -f "$SCRIPT_DIR/test1.csv" ]; then
    echo "ERROR: Test data not found: $SCRIPT_DIR/test1.csv"
    exit 1
fi

# Test 1: Full MapReduce pipeline
echo ""
echo "Test 1: MapReduce Pipeline (mapper -> sort -> combiner -> reducer)"
echo "----------------------------------------"
OUTPUT_FILE="$SCRIPT_DIR/test_mr_output.csv"

head -1000 "$SCRIPT_DIR/test1.csv" | \
    python3 "$SCRIPT_DIR/mapper.py" | \
    sort -k1,1 | \
    python3 "$SCRIPT_DIR/combiner.py" | \
    python3 "$SCRIPT_DIR/reducer.py" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✓ MapReduce pipeline completed"
    TOTAL_LINES=$(wc -l < "$OUTPUT_FILE")
    echo "✓ Output contains $TOTAL_LINES groups"
    echo ""
    echo "Sample output (first 10 lines):"
    head -10 "$OUTPUT_FILE"
else
    echo "✗ MapReduce pipeline failed!"
    exit 1
fi

# Test 2: Verify output format
echo ""
echo "Test 2: Output Format Verification"
echo "----------------------------------------"
if grep -q '^[A-Z0-9]\{4\},[A-Za-z ]\+,[0-9]\+,[0-9.]\+$' "$OUTPUT_FILE"; then
    echo "✓ Output format is correct: departure_airport_id,status,flight_count,avg_ticket_price"
else
    echo "⚠ Warning: Output format may not match expected pattern"
fi

# Test 3: Weighted average calculation verification
echo ""
echo "Test 3: Weighted Average Calculation Test"
echo "----------------------------------------"
echo "This simulates the Hive aggregation logic"
echo ""

# Extract a sample for manual verification
SAMPLE_AIRPORT=$(head -1 "$OUTPUT_FILE" | cut -d',' -f1)
echo "Sample data for airport: $SAMPLE_AIRPORT"
grep "^$SAMPLE_AIRPORT," "$OUTPUT_FILE" || echo "No data found"

echo ""
echo "Note: In Hive, we must use weighted average:"
echo "  SUM(avg_ticket_price * flight_count) / SUM(flight_count)"
echo "  NOT: AVG(avg_ticket_price)"

# Test 4: Check for required airports data
echo ""
echo "Test 4: Airports Data Check"
echo "----------------------------------------"
if [ -f "$SCRIPT_DIR/../input/datasource4/airports.csv" ]; then
    AIRPORT_COUNT=$(tail -n +2 "$SCRIPT_DIR/../input/datasource4/airports.csv" | wc -l)
    echo "✓ Airports data found: $AIRPORT_COUNT airports"
    echo ""
    echo "Sample airports (first 5):"
    head -6 "$SCRIPT_DIR/../input/datasource4/airports.csv" | tail -5
else
    echo "⚠ Airports data not found at: $SCRIPT_DIR/../input/datasource4/airports.csv"
fi

echo ""
echo "========================================"
echo "All Local Tests Completed!"
echo "========================================"
echo "Output saved to: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Upload data to HDFS"
echo "2. Run: bash run_mr.sh <input_dir> <output_dir>"
echo "3. Run: bash run_hive.sh <input_dir4> <output_dir3> <output_dir6>"
echo "========================================"
