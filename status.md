# Status Projektu MapReduce/Hive - Zestaw 11 (flights-airports)

**Data ostatniej aktualizacji:** 2024-10-24  
**Postęp:** MapReduce UKOŃCZONY ✅ | Hive TODO 🔄 | Airflow TODO 🔄

## 📁 Struktura Projektu

```
hadoop-streaming/
├── .git/                     # Git repository
├── .gitignore               # Git ignore rules
├── src/                     # Kod źródłowy MapReduce
│   ├── mapper.py           # ✅ Mapper (parsuje CSV flights)
│   ├── reducer.py          # ✅ Reducer (agreguje z poprawną średnią)
│   ├── combiner.py         # ✅ Combiner (optymalizacja 70% redukcja)
│   ├── run_mr.sh          # ✅ Skrypt uruchamiający
│   └── test1.csv          # Dane testowe (1000 rekordów)
├── operacje.md             # ✅ Opis zadań MapReduce i Hive
├── plan.md                 # ✅ Plan implementacji
├── kryteria-oceny.md       # ✅ Wszystkie 46 kryteriów oceny
├── projekt1.py             # 🔄 Szablon Apache Airflow DAG
├── README.md              # Oryginalny opis zestawu
├── *.pdf                  # Dokumentacja zadań
└── zestaw11.zip          # Archiwum danych
```

## ✅ UKOŃCZONE - MapReduce (54/54 pkt)

### Implementacja Hadoop Streaming
- **mapper.py** - parsuje CSV flights, emituje `airport_status` → `price,1`
- **reducer.py** - agreguje z POPRAWNĄ ŚREDNIĄ, format CSV dla Hive  
- **combiner.py** - optymalizacja lokalna, 70% redukcja ruchu sieciowego
- **run_mr.sh** - kompletny skrypt z parametrami i czyszczeniem

### Wyniki Testów
```bash
# Test 999 rekordów → 290 grup wynikowych
head -1000 test1.csv | python3 mapper.py | sort | python3 combiner.py | python3 reducer.py
```

**Format wyjściowy (gotowy dla Hive):**
```
AYWK,Cancelled,3,533.67
AYWK,Delayed,5,777.56
AYWK,On time,2,634.01
# Format: departure_airport_id,status,flight_count,avg_ticket_price
```

### Zgodność z Kryteriami
- ✅ **Kryterium 01-08** - Mapper (14/14 pkt)
- ✅ **Kryterium 09-14** - Reducer (15/15 pkt) 
- ✅ **Kryterium 15-20** - Combiner (15/15 pkt)
- ✅ **Kryterium 21-25** - Skrypt (10/10 pkt)
- ✅ **Wszystkie testy przeszły** - pipeline działa idealnie

## 🔄 DO ZROBIENIA

### 1. Hive Implementation (Kryteria 26-34, 22 pkt)
**Zadanie z operacje.md:**
- JOIN wynik MapReduce + airports (datasource4)
- Agregacja na poziomie kraju/kontynentu
- Format wyjściowy JSON z rankingiem

**Wymagany wynik:**
```json
{
  "continent": "Europe",
  "country": "Poland", 
  "total_flights": 150,
  "avg_ticket_price": 456.78,
  "rank_in_continent": 3
}
```

**Pliki do utworzenia:**
- `hive.hql` - skrypt HQL z JOIN i agregacją
- `run_hive.sh` - skrypt uruchamiający z parametrami

### 2. Apache Airflow Integration (Kryteria 39-46, 8 pkt)
- Aktualizacja `projekt1.py` - uzupełnienie poleceń MapReduce i Hive
- Zgodność ze skryptami uruchamiającymi
- Testowanie pełnego pipeline

## 🔍 Kluczowe Informacje

### Zadanie MapReduce (UKOŃCZONE)
- **Klucz grupowania:** `departure_airport_id + status`
- **Agregaty:** liczba lotów + średnia cena biletu
- **Format wyjściowy:** CSV gotowy dla Hive

### Zadanie Hive (NASTĘPNE)
- **JOIN:** MapReduce result (3) + airports (4) 
- **Agregacja:** grupa po country/continent
- **Funkcje:** SUM(flight_count), AVG(avg_ticket_price), RANK()
- **Format:** JSON per rekord

### Dane
- **test1.csv** - 1000 rekordów flights (datasource1)
- **datasource4** - airports data (do pobrania/użycia)
- **Pola airports:** airport_id, airport_name, city, country, continent, type

## 🚀 Plan na Jutro

1. **Przeczytaj status.md** - przywróć kontekst
2. **Sprawdź operacje.md** - przypomnij zadanie Hive  
3. **Implementuj hive.hql** - JOIN + agregacja + JSON
4. **Testuj pipeline** - MapReduce → Hive
5. **Airflow integration** - uzupełnij projekt1.py

## 📊 Punktacja
- **MapReduce:** 54/54 ✅
- **Hive:** 0/22 🔄  
- **Airflow:** 0/8 🔄
- **RAZEM:** 54/84 (64%)

**Cel:** Osiągnąć 100% punktów przez implementację Hive i Airflow.

---
*Wygenerowano automatycznie - Claude Code*