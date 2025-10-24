# Zestaw 11 – flights-airports

Dane sztuczne wygenerowane z użyciem biblioteki DataFaker (https://www.datafaker.net/)  
Uwaga! Dane pobieramy z miejsca wskazanego w ramach Twojego kursu

## Dwa zbiory danych

### `datasource1` – informacje o lotach (flights)

Dane mają format CSV, pliki posiadają nagłówek.  

Pola w pliku:

0. `flight_id` – unikalny identyfikator lotu (UUID)  
1. `flight_number` – numer lotu (np. LO123)  
2. `departure_airport_id` – identyfikator lotniska wylotu (`airport_id` ze słownika lotnisk)  
3. `arrival_airport_id` – identyfikator lotniska przylotu (`airport_id` ze słownika lotnisk)  
4. `scheduled_departure` – planowana data i godzina wylotu (`yyyy-MM-dd'T'HH:mm`)  
5. `scheduled_arrival` – planowana data i godzina przylotu (`yyyy-MM-dd'T'HH:mm`)  
6. `delay_min` – opóźnienie lotu w minutach  
7. `ticket_price_usd` – cena biletu w dolarach amerykańskich  
8. `airline` – linia lotnicza (`LOT`, `Lufthansa`, `Ryanair`, `Emirates`, `Delta`)  
9. `status` – status lotu (`On time`, `Delayed`, `Cancelled`)

### `datasource4` – informacje na temat lotnisk (airports)

Dane mają format CSV, pliki posiadają nagłówek.

Pola w pliku:

0. `airport_id` – unikalny identyfikator lotniska (kod IATA/ICAO)  
1. `airport_name` – nazwa lotniska  
2. `city` – miasto, w którym zlokalizowane jest lotnisko  
3. `country` – kraj, w którym zlokalizowane jest lotnisko  
4. `continent` – kontynent (`Europe`, `Asia`, `North America`, `South America`, `Africa`, `Oceania`)  
5. `type` – typ lotniska (`International`, `Regional`, `Domestic`)