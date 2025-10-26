-- Skrypt Hive do przetwarzania wyników MapReduce i danych lotnisk

-- Usuń istniejące tabele dla powtarzalności
DROP TABLE IF EXISTS mapreduce_result;
DROP TABLE IF EXISTS airports_raw;
DROP VIEW IF EXISTS airports_table;
DROP TABLE IF EXISTS output_json;

-- Utwórz tabelę zewnętrzną dla wyników MapReduce (datasource3)
CREATE EXTERNAL TABLE mapreduce_result (
    departure_airport_id STRING,
    status STRING,
    flight_count INT,
    avg_ticket_price DOUBLE
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE LOCATION '${hiveconf:output_dir3}';

-- Utwórz surową tabelę dla danych lotnisk (datasource4)
-- Ładuje każdą linię jako pojedynczy STRING dla elastycznego parsowania
CREATE EXTERNAL TABLE airports_raw (
    line STRING
) STORED AS TEXTFILE LOCATION '${hiveconf:input_dir4}'
TBLPROPERTIES ("skip.header.line.count" = "1");

-- Utwórz VIEW do inteligentnego parsowania CSV lotnisk
-- Obsługuje zarówno poprawne rekordy (6 pól) jak i problematyczne (7 pól)
-- Niektóre nazwy lotnisk zawierają przecinki (np. "Nitzsche, Heidenreich and Funk Airport")
CREATE VIEW airports_table AS
SELECT
    cols[0] as airport_id,
    -- Jeśli 7 pól połącz cols[1] i cols[2] jako airport_name
    -- Jeśli 6 pól użyj po prostu cols[1] jako airport_name
    CASE
        WHEN size(cols) = 7 THEN concat(cols[1], ',', cols[2])
        ELSE cols[1]
    END as airport_name,
    -- Ostatnie 4 pola są zawsze w tej samej pozycji od końca
    cols[size(cols)-4] as city,
    cols[size(cols)-3] as country,
    cols[size(cols)-2] as continent,
    cols[size(cols)-1] as type
FROM (
    SELECT split(line, ',') as cols
    FROM airports_raw
) parsed
WHERE size(cols) IN (6, 7);

-- Utwórz tabelę wyjściową z JSONSerDe
CREATE EXTERNAL TABLE output_json (
    continent STRING,
    country STRING,
    total_flights BIGINT,
    avg_ticket_price DOUBLE,
    rank_in_continent INT
) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe' STORED AS TEXTFILE LOCATION '${hiveconf:output_dir6}';

-- Wykonaj JOIN, agregację, ranking i eksport do JSON
INSERT OVERWRITE TABLE output_json
SELECT continent,
    country,
    total_flights,
    avg_ticket_price,
    RANK() OVER (
        PARTITION BY continent
        ORDER BY total_flights DESC
    ) as rank_in_continent
FROM (
        SELECT a.continent,
            a.country,
            SUM(mr.flight_count) as total_flights,
            -- ŚREDNIA WAŻONA: suma(cena * liczba) / suma(liczba)
            -- Nie możemy użyć AVG(avg_ticket_price) bo to byłaby średnia ze średnich!
            SUM(mr.avg_ticket_price * mr.flight_count) / SUM(mr.flight_count) as avg_ticket_price
        FROM mapreduce_result mr
            INNER JOIN airports_table a ON mr.departure_airport_id = a.airport_id
        GROUP BY a.continent,
            a.country
    ) country_stats;