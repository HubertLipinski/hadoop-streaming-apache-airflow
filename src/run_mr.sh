#!/bin/bash

# Skrypt uruchamiający zadanie MapReduce dla Hadoop Streaming
# Użycie: run_mr.sh input_dir1 output_dir3

set -e

usage() {
    echo "Użycie: $0 input_dir1 output_dir3"
    echo "  input_dir1  - Ścieżka HDFS do danych wejściowych (dane lotów)"
    echo "  output_dir3 - Ścieżka HDFS dla wyników MapReduce"
    echo "Przykład: $0 /project1/input /project1/output_mr3"
    exit 1
}

if [ $# -ne 2 ]; then
    echo "BŁĄD: Nieprawidłowa liczba parametrów. Oczekiwano 2, otrzymano $#"
    usage
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"

echo "Zadanie MapReduce: $INPUT_DIR -> $OUTPUT_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPER_FILE="$SCRIPT_DIR/mapper.py"
REDUCER_FILE="$SCRIPT_DIR/reducer.py"
COMBINER_FILE="$SCRIPT_DIR/combiner.py"

# Sprawdź wymagane pliki
for file in "$MAPPER_FILE" "$REDUCER_FILE" "$COMBINER_FILE"; do
    if [ ! -f "$file" ]; then
        echo "BŁĄD: Nie znaleziono wymaganego pliku: $file"
        exit 1
    fi
done

chmod +x "$MAPPER_FILE" "$REDUCER_FILE" "$COMBINER_FILE"

# Wyczyść katalog wyjściowy dla powtarzalności
if hadoop fs -test -d "$OUTPUT_DIR" 2>/dev/null; then
    echo "Usuwanie istniejącego katalogu wyjściowego: $OUTPUT_DIR"
    hadoop fs -rm -f -r "$OUTPUT_DIR"
fi

# Zweryfikuj katalog wejściowy
if ! hadoop fs -test -d "$INPUT_DIR" 2>/dev/null; then
    echo "BŁĄD: Katalog wejściowy nie istnieje: $INPUT_DIR"
    exit 1
fi

echo "Uruchamianie zadania MapReduce..."

# Uruchom zadanie MapReduce
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
    echo "Zadanie MapReduce zakończone pomyślnie!"
    echo "Lokalizacja wyników: $OUTPUT_DIR"
    echo "Przykładowe wyniki:"
    hadoop fs -cat "$OUTPUT_DIR/part-*" | head -10 2>/dev/null || echo "Nie można wyświetlić przykładowych wyników"
else
    echo "BŁĄD: Zadanie MapReduce nie powiodło się!"
    exit 1
fi