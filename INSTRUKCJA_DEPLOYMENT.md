# Instrukcja uruchomienia projektu Hadoop Streaming na klastrze uczelni

## 📋 Wymagania wstępne

- Dostęp do maszyny z klastrem Hadoop (BigData25 z zajęć)
- Zalogowany użytkownik z uprawnieniami do HDFS i YARN
- Działające usługi: HDFS, YARN, Hive

## 📦 Przygotowanie plików

### 1. Skopiuj folder projektu na maszynę uczelni

```bash
# Z lokalnej maszyny (Windows)
scp -r "C:\Users\hubert\Desktop\hadoop-streaming" user@uczelnia:/tmp/projekt_hadoop/

# LUB jeśli masz Git
git clone <repo_url> /tmp/projekt_hadoop
cd /tmp/projekt_hadoop
```

### 2. Sprawdź strukturę projektu

```bash
cd /tmp/projekt_hadoop
ls -la

# Powinno być:
# input/
#   datasource1/    (100 plików flights*.csv)
#   datasource4/    (airports.csv)
# src/
#   mapper.py
#   reducer.py
#   combiner.py
#   hive.hql
#   run_mr.sh
#   run_hive.sh
```

## 🚀 Krok 1: Upload danych do HDFS

```bash
# Utwórz strukturę katalogów w HDFS
hadoop fs -mkdir -p /user/$(whoami)/projekt1/input
hadoop fs -mkdir -p /user/$(whoami)/projekt1/output_mr3
hadoop fs -mkdir -p /user/$(whoami)/projekt1/output6

# Upload datasource1 (loty - 100 plików CSV)
hadoop fs -put input/datasource1 /user/$(whoami)/projekt1/input/

# Upload datasource4 (lotniska - airports.csv)
hadoop fs -put input/datasource4 /user/$(whoami)/projekt1/input/

# Weryfikacja
hadoop fs -ls /user/$(whoami)/projekt1/input/datasource1 | wc -l
# Powinno być ~101 (100 plików + linia nagłówka)

hadoop fs -ls /user/$(whoami)/projekt1/input/datasource4
# Powinien być airports.csv
```

## 🔧 Krok 2: Uruchom MapReduce Job

```bash
cd /tmp/projekt_hadoop/src

# Nadaj uprawnienia wykonywania
chmod +x run_mr.sh

# Uruchom MapReduce
bash run_mr.sh \
  /user/$(whoami)/projekt1/input/datasource1 \
  /user/$(whoami)/projekt1/output_mr3

# Skrypt automatycznie:
# - Czyści katalog wyjściowy (jeśli istnieje)
# - Uruchamia Hadoop Streaming z mapper, combiner, reducer
# - Wyświetla próbkę wyników
```

### Oczekiwany wynik MapReduce:

```
========================================
MapReduce Job Configuration
========================================
Input directory:  /user/user/projekt1/input/datasource1
Output directory: /user/user/projekt1/output_mr3
========================================
Starting MapReduce job...
...
MapReduce job completed successfully!
========================================
Output location: /user/user/projekt1/output_mr3

Sample output:
----------------------------------------
AYWK,Cancelled,3325,775.23
AYWK,Delayed,3315,762.45
AYWK,On time,3360,780.12
...
```

### Weryfikacja MapReduce:

```bash
# Sprawdź liczbę rekordów wyjściowych (powinno być ~300)
hadoop fs -cat /user/$(whoami)/projekt1/output_mr3/part-* | wc -l

# Sprawdź format: airport_id,status,flight_count,avg_ticket_price
hadoop fs -cat /user/$(whoami)/projekt1/output_mr3/part-* | head -10
```

## 📊 Krok 3: Uruchom Hive Job

```bash
cd /tmp/projekt_hadoop/src

# Nadaj uprawnienia wykonywania
chmod +x run_hive.sh

# Uruchom Hive (JOIN + agregacja + RANK + export do JSON)
bash run_hive.sh \
  /user/$(whoami)/projekt1/input/datasource4 \
  /user/$(whoami)/projekt1/output_mr3 \
  /user/$(whoami)/projekt1/output6
```

### Co robi skrypt Hive:

1. **Tworzy tabele**:
   - `mapreduce_result` - wyniki z MapReduce (datasource3)
   - `airports_raw` - surowa tabela dla lotnisk
   - `airports_table` - VIEW z inteligentnym parsowaniem CSV
   - `output_json` - tabela wyjściowa z JsonSerDe

2. **Wykonuje przetwarzanie**:
   - JOIN `mapreduce_result` z `airports_table` (po airport_id)
   - GROUP BY continent, country
   - Oblicza `total_flights` i `avg_ticket_price` (weighted average)
   - RANK() OVER (PARTITION BY continent ORDER BY total_flights DESC)
   - Export do JSON

3. **Inteligentne parsowanie CSV**:
   - Obsługuje poprawne rekordy (6 pól)
   - Obsługuje wadliwe rekordy (7 pól - nazwy z przecinkami)
   - VIEW automatycznie łączy nadmiarowe pola w `airport_name`

### Oczekiwany wynik Hive:

```
========================================
Hive Job Configuration
========================================
Airports data (input):  /user/user/projekt1/input/datasource4
MapReduce result:       /user/user/projekt1/output_mr3
JSON output:            /user/user/projekt1/output6
========================================
Starting Hive job...
...
Hive job completed successfully!
========================================
Output location: /user/user/projekt1/output6

Sample output (first 10 records):
----------------------------------------
{"continent":"Africa","country":"Egypt","total_flights":29850,"avg_ticket_price":765.23,"rank_in_continent":1}
{"continent":"Africa","country":"Kenya","total_flights":19920,"avg_ticket_price":778.45,"rank_in_continent":2}
{"continent":"Asia","country":"India","total_flights":39840,"avg_ticket_price":772.15,"rank_in_continent":1}
...
```

## ✅ Krok 4: Weryfikacja wyników

### 4.1 Sprawdź pliki wyjściowe

```bash
# Lista plików JSON
hadoop fs -ls /user/$(whoami)/projekt1/output6/

# Powinny być:
# 000000_0  (lub podobne)
# _SUCCESS
```

### 4.2 Sprawdź format JSON

```bash
# Wyświetl pierwsze 10 rekordów
hadoop fs -cat /user/$(whoami)/projekt1/output6/* | head -10

# Każda linia powinna być poprawnym JSON-em:
# {"continent":"...","country":"...","total_flights":...,"avg_ticket_price":...,"rank_in_continent":...}
```

### 4.3 Weryfikuj poprawność danych

```bash
# Ile kontynentów?
hadoop fs -cat /user/$(whoami)/projekt1/output6/* | \
  grep -o '"continent":"[^"]*"' | sort -u | wc -l
# Powinno być 5-6 unikalnych kontynentów

# Ile krajów?
hadoop fs -cat /user/$(whoami)/projekt1/output6/* | \
  grep -o '"country":"[^"]*"' | sort -u | wc -l
# Powinno być znacznie mniej niż 100 (bo nie wszystkie lotniska mają loty)

# Sprawdź ranking (rank_in_continent powinien być 1, 2, 3... dla każdego kontynentu)
hadoop fs -cat /user/$(whoami)/projekt1/output6/* | \
  jq -r '"\(.continent) \(.rank_in_continent) \(.country)"' | \
  sort | head -20
```

### 4.4 Pobierz wynik do lokalnego pliku

```bash
# Pobierz merged output
hadoop fs -getmerge /user/$(whoami)/projekt1/output6 output6_final.json

# Sprawdź lokalnie
cat output6_final.json | head -10

# Skopiuj na Windows
scp user@uczelnia:/tmp/projekt_hadoop/output6_final.json ~/Desktop/
```

## 🧪 Test poprawności VIEW (opcjonalnie)

Jeśli chcesz przetestować czy VIEW poprawnie parsuje wadliwe rekordy:

```bash
# Uruchom beeline
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default

# W beeline:
-- Sprawdź wadliwy rekord (7 pól)
SELECT * FROM airports_table WHERE airport_id = 'CZRJ';
-- Powinno być: airport_name = "Nitzsche, Heidenreich and Funk Airport"

-- Sprawdź poprawny rekord (6 pól)
SELECT * FROM airports_table WHERE airport_id = 'AYWK';
-- Powinno być: airport_name = "Ward Inc Airport"

-- Policz wszystkie rekordy (powinno być 100)
SELECT COUNT(*) FROM airports_table;

-- Wyjdź
!quit
```

## 🐛 Troubleshooting

### Problem: "Permission denied" podczas uploadu do HDFS

```bash
# Sprawdź uprawnienia
hadoop fs -ls /user/$(whoami)/

# Utwórz katalog jeśli nie istnieje
hadoop fs -mkdir -p /user/$(whoami)/projekt1

# Ustaw uprawnienia
hadoop fs -chmod -R 755 /user/$(whoami)/projekt1
```

### Problem: MapReduce job failed

```bash
# Sprawdź logi YARN
yarn logs -applicationId <application_id>

# Sprawdź YARN UI
# http://<resource_manager_host>:8088
```

### Problem: Hive job failed - Tez/MR errors

```bash
# Jeśli Tez nie działa, upewnij się że hive.hql używa MR:
# Linia 5: SET hive.execution.engine=mr;

# Sprawdź logi Hive
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default -e "SHOW TABLES;"
```

### Problem: Puste wyniki w output6

```bash
# Sprawdź czy tabele są utworzone
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default -e "SHOW TABLES;"

# Sprawdź czy dane są w tabelach
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default -e "SELECT COUNT(*) FROM mapreduce_result;"
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default -e "SELECT COUNT(*) FROM airports_table;"

# Sprawdź czy JOIN działa
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default -e "
SET hive.execution.engine=mr;
SELECT COUNT(*)
FROM mapreduce_result mr
INNER JOIN airports_table a ON mr.departure_airport_id = a.airport_id;
"
```

## 📝 Czyszczenie środowiska

Po zakończeniu testów:

```bash
# Usuń dane z HDFS
hadoop fs -rm -r /user/$(whoami)/projekt1

# Usuń tabele Hive
beeline -n "$(id -un)" -u jdbc:hive2://localhost:10000/default -e "
DROP TABLE IF EXISTS mapreduce_result;
DROP TABLE IF EXISTS airports_raw;
DROP VIEW IF EXISTS airports_table;
DROP TABLE IF EXISTS output_json;
"

# Usuń pliki lokalne
rm -rf /tmp/projekt_hadoop
```

## 📊 Oczekiwane statystyki końcowe

Po pomyślnym wykonaniu całego pipeline:

| Krok | Input | Output | Oczekiwana liczba rekordów |
|------|-------|--------|----------------------------|
| **MapReduce** | 1,000,100 lotów | output_mr3 | ~300 grup (airport_id + status) |
| **Hive JOIN** | 300 grup + 100 lotnisk | pośrednie | ~300 połączonych rekordów |
| **Hive GROUP BY** | 300 rekordów | pośrednie | ~50-70 krajów |
| **Hive RANK()** | 50-70 krajów | output6 (JSON) | ~50-70 rekordów z rankingiem |

## ✨ Kluczowe features rozwiązania

1. **Combiner w MapReduce**: Redukcja ruchu sieciowego o ~97%
2. **Weighted Average**: Poprawna średnia ważona zamiast średniej ze średnich
3. **Intelligent CSV Parsing**: VIEW automatycznie naprawia błędy w CSV (nazwy z przecinkami)
4. **Window Functions**: RANK() OVER dla rankingu krajów w kontynentach
5. **JSON Output**: Gotowe dane do dalszego przetwarzania w Airflow

## 📞 Wsparcie

Jeśli napotkasz problemy:
1. Sprawdź logi YARN: `yarn logs -applicationId <app_id>`
2. Sprawdź Web UI: http://<host>:8088
3. Sprawdź logi Hive: beeline + query z SET hive.execution.engine=mr

Powodzenia! 🚀
