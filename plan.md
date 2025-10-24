# Plan implementacji MapReduce (Hadoop Streaming)

## 1. Analiza zadania
- Przeczytać drugi dokument PDF z konkretnymi zadaniami dla zestawu 11
- Zrozumieć dokładnie jakie przetwarzanie wykonać na danych o lotach

## 2. Implementacja Hadoop Streaming
- **mapper.py** - skrypt mapper do przetwarzania rekordów CSV z lotami
- **reducer.py** - skrypt reducer do agregacji wyników
- **combiner.py** (opcjonalnie) - skrypt combiner do wstępnej agregacji
- **run_mr.sh** - skrypt uruchamiający z parametrami `input_dir1` i `output_dir3`

## 3. Wymagania techniczne
- Format wyjściowy: TextOutputFormat
- Parametryzacja: input_dir1, output_dir3  
- Skrypt musi być powtarzalny (usuwać katalog wyjściowy przed uruchomieniem)
- Wynik w HDFS jako input dla etapu Hive

## 4. Struktura plików
```
hadoop-streaming/
├── mapper.py
├── reducer.py
├── combiner.py (opcjonalnie)
└── run_mr.sh
```

## 5. Testowanie
- Przetestować na próbce danych przed pełnym uruchomieniem
- Sprawdzić poprawność formatu wyjściowego dla Hive

## Dane wejściowe (Zestaw 11 - flights-airports)

### datasource1 - informacje o lotach (flights)
Dane w formacie CSV z nagłówkiem:
- `flight_id` - unikalny identyfikator lotu (UUID)
- `flight_number` - numer lotu (np. LO123)
- `departure_airport_id` - identyfikator lotniska wylotu
- `arrival_airport_id` - identyfikator lotniska przylotu
- `scheduled_departure` - planowana data i godzina wylotu (yyyy-MM-dd'T'HH:mm)
- `scheduled_arrival` - planowana data i godzina przylotu (yyyy-MM-dd'T'HH:mm)
- `delay_min` - opóźnienie lotu w minutach
- `ticket_price_usd` - cena biletu w dolarach amerykańskich
- `airline` - linia lotnicza (LOT, Lufthansa, Ryanair, Emirates, Delta)
- `status` - status lotu (On time, Delayed, Cancelled)