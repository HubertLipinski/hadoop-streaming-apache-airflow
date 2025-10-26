#!/bin/bash

# Skrypt uruchamiający zadanie Hive do przetwarzania wyników MapReduce i danych lotnisk
# Użycie: run_hive.sh input_dir4 output_dir3 output_dir6

set -e

usage() {
    echo "Użycie: $0 input_dir4 output_dir3 output_dir6"
    echo "  input_dir4  - Ścieżka HDFS do danych lotnisk (datasource4)"
    echo "  output_dir3 - Ścieżka HDFS do wyników MapReduce (dane wejściowe dla Hive)"
    echo "  output_dir6 - Ścieżka HDFS dla końcowego wyniku JSON"
    echo "Przykład: $0 /project1/input/datasource4 /project1/output_mr3 /project1/output6"
    exit 1
}

if [ $# -ne 3 ]; then
    echo "BŁĄD: Nieprawidłowa liczba parametrów. Oczekiwano 3, otrzymano $#"
    usage
fi

INPUT_DIR4="$1"
OUTPUT_DIR3="$2"
OUTPUT_DIR6="$3"

echo "========================================"
echo "Konfiguracja zadania Hive"
echo "========================================"
echo "Dane lotnisk (wejście):   $INPUT_DIR4"
echo "Wynik MapReduce:          $OUTPUT_DIR3"
echo "Wynik JSON:               $OUTPUT_DIR6"
echo "========================================"

# Pobierz katalog skryptu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HIVE_SCRIPT="$SCRIPT_DIR/hive.hql"

# Sprawdź wymagane pliki
if [ ! -f "$HIVE_SCRIPT" ]; then
    echo "BŁĄD: Nie znaleziono skryptu Hive: $HIVE_SCRIPT"
    exit 1
fi

# Zweryfikuj istnienie katalogów wejściowych
if ! hadoop fs -test -d "$INPUT_DIR4" 2>/dev/null; then
    echo "BŁĄD: Katalog danych lotnisk nie istnieje: $INPUT_DIR4"
    exit 1
fi

if ! hadoop fs -test -d "$OUTPUT_DIR3" 2>/dev/null; then
    echo "BŁĄD: Katalog wyników MapReduce nie istnieje: $OUTPUT_DIR3"
    exit 1
fi

# Wyczyść katalog wyjściowy dla powtarzalności
if hadoop fs -test -d "$OUTPUT_DIR6" 2>/dev/null; then
    echo "Usuwanie istniejącego katalogu wyjściowego: $OUTPUT_DIR6"
    hadoop fs -rm -f -r "$OUTPUT_DIR6"
fi

echo "Uruchamianie zadania Hive..."

# Uruchom zadanie Hive używając beeline
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default \
    --hiveconf output_dir3="$OUTPUT_DIR3" \
    --hiveconf input_dir4="$INPUT_DIR4" \
    --hiveconf output_dir6="$OUTPUT_DIR6" \
    -f "$HIVE_SCRIPT"

if [ $? -eq 0 ]; then
    echo "Zadanie Hive zakończone pomyślnie!"
    echo "Lokalizacja wyników: $OUTPUT_DIR6"
    echo "Przykładowe wyniki (pierwsze 10 rekordów):"
    hadoop fs -cat "$OUTPUT_DIR6/000000_0" 2>/dev/null | head -10 || \
        hadoop fs -cat "$OUTPUT_DIR6/*" 2>/dev/null | head -10 || \
        echo "Nie można wyświetlić przykładowych wyników"
else
    echo "BŁĄD: Zadanie Hive nie powiodło się!"
    exit 1
fi
