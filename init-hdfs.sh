#!/bin/bash
# Script to initialize HDFS with project data
# Run this inside the namenode container: docker-compose exec namenode bash init-hdfs.sh

set -e

echo "=========================================="
echo "Initializing HDFS for Hadoop Streaming Project"
echo "=========================================="

# Wait for HDFS to be ready
echo "Waiting for HDFS to be ready..."
until hadoop fs -ls / &>/dev/null; do
    echo "HDFS not ready yet, waiting..."
    sleep 5
done
echo "✓ HDFS is ready!"

# Create project directories
echo ""
echo "Creating HDFS directories..."
hadoop fs -mkdir -p /project1/input
hadoop fs -mkdir -p /project1/output_mr3
hadoop fs -mkdir -p /project1/output6
echo "✓ Directories created"

# Upload datasource1 (flights data)
echo ""
echo "Uploading datasource1 (flights data)..."
if hadoop fs -test -d /project1/input/datasource1; then
    echo "⚠ datasource1 already exists, skipping upload"
else
    hadoop fs -put /project/input/datasource1 /project1/input/
    echo "✓ datasource1 uploaded"
fi

# Upload datasource4 (airports data)
echo ""
echo "Uploading datasource4 (airports data)..."
if hadoop fs -test -d /project1/input/datasource4; then
    echo "⚠ datasource4 already exists, skipping upload"
else
    hadoop fs -put /project/input/datasource4 /project1/input/
    echo "✓ datasource4 uploaded"
fi

# Verify uploads
echo ""
echo "=========================================="
echo "Verification:"
echo "=========================================="
echo ""
echo "Datasource1 files:"
hadoop fs -ls /project1/input/datasource1 | head -10
echo ""
FLIGHTS_COUNT=$(hadoop fs -ls /project1/input/datasource1 | grep -c "flights")
echo "Total flights files: $FLIGHTS_COUNT"

echo ""
echo "Datasource4 files:"
hadoop fs -ls /project1/input/datasource4

echo ""
echo "=========================================="
echo "✓ HDFS Initialization Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Run MapReduce job:"
echo "   cd /project/src && bash run_mr.sh /project1/input/datasource1 /project1/output_mr3"
echo ""
echo "2. Run Hive job:"
echo "   cd /project/src && bash run_hive.sh /project1/input/datasource4 /project1/output_mr3 /project1/output6"
echo ""
echo "3. View results:"
echo "   hadoop fs -cat /project1/output6/* | head -20"
echo "=========================================="
