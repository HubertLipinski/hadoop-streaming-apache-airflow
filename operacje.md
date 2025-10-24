# Zadania do wykonania - Zestaw 11: flights-airports

## Zadanie MapReduce (2)

**Zbiór danych:** `datasource1` (informacje o lotach)

**Operacja do wykonania:**
- Określ liczbę lotów wychodzących z każdego lotniska, kategoryzowanych według statusu lotu
- Oblicz średnią cenę biletu dla każdej grupy

**Format wyniku (3):**
- `departure_airport_id`: ID lotniska wylotu
- `status`: Status lotu (np. On time, Delayed, Cancelled)
- `flight_count`: Liczba lotów w grupie
- `avg_ticket_price`: Średnia cena biletu w USD

**Klucz grupowania:** `departure_airport_id + status`

## Zadanie Hive (5)

**Zbiory danych:** 
- Wynik MapReduce (3)
- `datasource4` (informacje o lotniskach)

**Operacja do wykonania:**
- Połącz dane o lotach z informacjami o lotniskach
- Oblicz podsumowania na poziomie kraju

**Format wyniku (6):**
- `continent`: Kontynent
- `country`: Kraj
- `total_flights`: Liczba lotów wychodzących z kraju
- `avg_ticket_price`: Średnia cena biletu dla lotów z kraju
- `rank_in_continent`: Ranking kraju według liczby lotów w ramach kontynentu

## Szczegóły implementacji

### MapReduce
**Mapper:**
- Parsuje dane CSV z `datasource1`
- Emituje klucz: `departure_airport_id + status`
- Emituje wartość: `(ticket_price, 1)` dla możliwości obliczenia średniej

**Reducer:**
- Agreguje dla każdej kombinacji (lotnisko, status)
- Oblicza: liczbę lotów (suma liczników) i średnią cenę (suma cen / liczba lotów)
- Emituje: `departure_airport_id, status, flight_count, avg_ticket_price`

### Hive
**Operacje:**
1. Załaduj wynik MapReduce jako tabelę
2. Załaduj `datasource4` (airports) jako tabelę  
3. Wykonaj JOIN według `departure_airport_id = airport_id`
4. Grupuj według `continent, country`
5. Oblicz agregaty: suma lotów, średnia cena
6. Dodaj ranking w ramach kontynentu
7. Wyeksportuj wynik w formacie JSON

**SQL logika:**
```sql
SELECT 
    continent,
    country,
    SUM(flight_count) as total_flights,
    AVG(avg_ticket_price) as avg_ticket_price,
    RANK() OVER (PARTITION BY continent ORDER BY SUM(flight_count) DESC) as rank_in_continent
FROM mapreduce_result mr
JOIN airports a ON mr.departure_airport_id = a.airport_id
GROUP BY continent, country
```