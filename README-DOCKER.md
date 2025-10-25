# Hadoop Streaming Project - Docker Setup

Kompletne środowisko Hadoop + Hive w Docker do lokalnego testowania projektu MapReduce/Hive.

## 📦 Zawartość Klastra

Docker Compose uruchamia następujące usługi:

| Usługa | Port | Opis |
|--------|------|------|
| **NameNode** | 9870 | HDFS Master - Web UI |
| **DataNode** | 9864 | HDFS Worker - Web UI |
| **ResourceManager** | 8088 | YARN Master - Web UI |
| **NodeManager** | 8042 | YARN Worker - Web UI |
| **HistoryServer** | 8188 | Job History - Web UI |
| **HiveServer2** | 10000 | Beeline JDBC |
| **HiveServer2 UI** | 10002 | Hive Web UI |
| **Hive Metastore** | 9083 | Metastore Service |
| **PostgreSQL** | 5432 | Hive Metastore DB |

## 🚀 Szybki Start

### 1. Uruchom klaster Hadoop

```bash
# Uruchom wszystkie kontenery w tle
docker-compose up -d

# Sprawdź status wszystkich kontenerów
docker-compose ps
```

**Oczekiwany output:**
```
NAME                     STATUS         PORTS
hadoop-namenode          Up (healthy)   0.0.0.0:9870->9870/tcp, 0.0.0.0:9000->9000/tcp
hadoop-datanode          Up             0.0.0.0:9864->9864/tcp
hadoop-resourcemanager   Up             0.0.0.0:8088->8088/tcp
hadoop-nodemanager       Up             0.0.0.0:8042->8042/tcp
hadoop-historyserver     Up             0.0.0.0:8188->8188/tcp
hadoop-hive-metastore    Up             0.0.0.0:9083->9083/tcp
hadoop-hive-server       Up             0.0.0.0:10000->10000/tcp, 0.0.0.0:10002->10002/tcp
hadoop-postgres          Up (healthy)   0.0.0.0:5432->5432/tcp
```

### 2. Poczekaj na inicjalizację

Klaster potrzebuje 1-2 minuty na pełną inicjalizację. Sprawdź status:

```bash
# Sprawdź logi NameNode
docker-compose logs namenode | tail -20

# Sprawdź logi Hive Server
docker-compose logs hive-server | tail -20
```

### 3. Wejdź do kontenera NameNode

```bash
docker-compose exec namenode bash
```

### 4. Zainicjalizuj HDFS (upload danych)

W kontenerze NameNode:

```bash
bash /project/init-hdfs.sh
```

**To co robi skrypt:**
- Czeka na gotowość HDFS
- Tworzy katalogi `/project1/input`, `/project1/output_mr3`, `/project1/output6`
- Uploaduje `datasource1` (flights) do HDFS
- Uploaduje `datasource4` (airports) do HDFS
- Weryfikuje upload

### 5. Uruchom MapReduce job

W kontenerze NameNode:

```bash
cd /project/src
bash run_mr.sh /project1/input/datasource1 /project1/output_mr3
```

**Oczekiwany output:**
```
MapReduce Job: /project1/input/datasource1 -> /project1/output_mr3
Starting MapReduce job...
...
MapReduce job completed successfully!
Output location: /project1/output_mr3
Sample output:
AYWK,Cancelled,3,533.67
AYWK,Delayed,5,777.56
AYWK,On time,2,634.01
...
```

### 6. Uruchom Hive job

W kontenerze NameNode (lub hive-server):

```bash
cd /project/src
bash run_hive.sh /project1/input/datasource4 /project1/output_mr3 /project1/output6
```

**Oczekiwany output:**
```
Hive Job Configuration
Airports data (input):  /project1/input/datasource4
MapReduce result:       /project1/output_mr3
JSON output:            /project1/output6
...
Hive job completed successfully!
Sample output (first 10 records):
{"continent":"Europe","country":"Poland","total_flights":150,"avg_ticket_price":675.68,"rank_in_continent":3}
...
```

### 7. Pobierz wyniki

```bash
# W kontenerze lub z hosta:
hadoop fs -getmerge /project1/output6 /project/output6.json
cat /project/output6.json | head -20
```

## 🌐 Web UI - Dostęp z przeglądarki

Po uruchomieniu klastra, otwórz w przeglądarce:

- **HDFS NameNode UI:** http://localhost:9870
- **YARN ResourceManager UI:** http://localhost:8088
- **YARN NodeManager UI:** http://localhost:8042
- **Job History UI:** http://localhost:8188
- **Hive Server2 UI:** http://localhost:10002

## 📝 Przydatne Komendy

### Zarządzanie kontenerami

```bash
# Uruchom klaster
docker-compose up -d

# Zatrzymaj klaster (zachowaj dane)
docker-compose stop

# Zatrzymaj i usuń kontenery (zachowaj volumes)
docker-compose down

# Usuń WSZYSTKO włącznie z danymi (UWAGA!)
docker-compose down -v

# Sprawdź logi
docker-compose logs -f namenode
docker-compose logs -f hive-server

# Restart konkretnej usługi
docker-compose restart namenode
```

### Praca w kontenerze

```bash
# Wejdź do NameNode
docker-compose exec namenode bash

# Wejdź do Hive Server
docker-compose exec hive-server bash

# Uruchom Beeline (Hive CLI)
docker-compose exec hive-server beeline -u jdbc:hive2://localhost:10000
```

### HDFS Commands

```bash
# Lista plików w HDFS
hadoop fs -ls /project1/input

# Wyświetl zawartość pliku
hadoop fs -cat /project1/output_mr3/part-00000 | head -20

# Usuń katalog
hadoop fs -rm -r /project1/output_mr3

# Pokaż wykorzystanie przestrzeni
hadoop fs -du -h /project1

# Pobierz plik z HDFS do lokalnego systemu
hadoop fs -get /project1/output6/000000_0 ./output.json
```

### Debugging

```bash
# Sprawdź czy HDFS działa
hadoop fs -ls /

# Sprawdź procesy Java w kontenerze
jps

# Sprawdź konfigurację Hadoop
hadoop version
hdfs getconf -confKey fs.defaultFS

# Sprawdź YARN applications
yarn application -list

# Sprawdź logi YARN application
yarn logs -applicationId <application_id>
```

## 🔧 Troubleshooting

### Problem: Kontener nie startuje

**Rozwiązanie:**
```bash
# Sprawdź logi
docker-compose logs <service_name>

# Restart usługi
docker-compose restart <service_name>
```

### Problem: HDFS nie odpowiada

**Rozwiązanie:**
```bash
# Restart NameNode
docker-compose restart namenode

# Poczekaj 30 sekund i sprawdź
docker-compose exec namenode hadoop fs -ls /
```

### Problem: Hive nie może połączyć się z Metastore

**Rozwiązanie:**
```bash
# Sprawdź czy PostgreSQL działa
docker-compose exec postgres psql -U hive -d metastore -c "\dt"

# Restart Hive services
docker-compose restart hive-metastore hive-server
```

### Problem: Brak pamięci dla YARN jobs

**Rozwiązanie:**
W `docker-compose.yml` zwiększ:
```yaml
nodemanager:
  environment:
    - YARN_CONF_yarn_nodemanager_resource_memory___mb=8192  # było 4096
    - YARN_CONF_yarn_nodemanager_resource_cpu___vcores=4    # było 2
```

## 🧪 Testowanie Pipeline

### Test 1: Lokalny test MapReduce (bez Hadoop)

```bash
cd src
bash test_pipeline.sh
```

### Test 2: MapReduce na klastrze

```bash
docker-compose exec namenode bash
cd /project/src
bash run_mr.sh /project1/input/datasource1 /project1/output_mr3
```

### Test 3: Hive na klastrze

```bash
docker-compose exec hive-server bash
cd /project/src
bash run_hive.sh /project1/input/datasource4 /project1/output_mr3 /project1/output6
```

### Test 4: Weryfikacja wyników

```bash
# MapReduce output
hadoop fs -cat /project1/output_mr3/part-* | wc -l
# Powinno być ~290 linii

# Hive output (JSON)
hadoop fs -cat /project1/output6/* | head -5
# Powinny być JSON-y z continent, country, total_flights, avg_ticket_price, rank_in_continent
```

## 📊 Monitorowanie

### HDFS Status

```bash
hadoop dfsadmin -report
```

### YARN Status

```bash
yarn node -list
yarn application -list
```

### Hive Tables

```bash
beeline -u jdbc:hive2://localhost:10000 -e "SHOW TABLES;"
beeline -u jdbc:hive2://localhost:10000 -e "DESCRIBE mapreduce_result;"
```

## 🛑 Zatrzymanie i Czyszczenie

```bash
# Zatrzymaj klaster (dane zachowane)
docker-compose stop

# Usuń kontenery (volumes zachowane)
docker-compose down

# Usuń WSZYSTKO włącznie z danymi
docker-compose down -v
docker volume prune -f
```

## 📚 Struktura Volumes

Docker tworzy następujące volumes dla trwałości danych:

- `postgres-data` - Hive Metastore database
- `namenode-data` - HDFS NameNode metadata
- `datanode-data` - HDFS DataNode blocks
- `resourcemanager-data` - YARN ResourceManager state
- `nodemanager-data` - YARN NodeManager local data
- `historyserver-data` - Job history logs

Dane w volumes **przetrwają** `docker-compose down`, ale zostaną usunięte przez `docker-compose down -v`.

## 🎯 Wynik Końcowy

Po pomyślnym uruchomieniu wszystkich kroków, powinieneś zobaczyć:

**MapReduce Output (`/project1/output_mr3`):**
```
AYWK,Cancelled,3,533.67
AYWK,Delayed,5,777.56
AYWK,On time,2,634.01
...
```

**Hive Output JSON (`/project1/output6`):**
```json
{"continent":"Asia","country":"India","total_flights":245,"avg_ticket_price":678.45,"rank_in_continent":1}
{"continent":"Europe","country":"Poland","total_flights":189,"avg_ticket_price":543.21,"rank_in_continent":2}
...
```

## 🚀 Następne kroki: Apache Airflow

Po zweryfikowaniu, że MapReduce i Hive działają, możesz zintegrować z Apache Airflow używając `projekt1.py`.

---

**Pytania?** Sprawdź logi: `docker-compose logs -f <service_name>`
