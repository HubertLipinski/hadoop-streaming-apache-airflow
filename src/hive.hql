-- Hive script for processing MapReduce output and airports data
-- Purpose: JOIN MapReduce results with airports data, aggregate by country/continent, output as JSON

-- Use MapReduce execution engine (Tez has issues in this environment)
SET hive.execution.engine=mr;
SET hive.auto.convert.join=false;

-- Drop existing tables for repeatability
DROP TABLE IF EXISTS mapreduce_result;
DROP TABLE IF EXISTS airports_raw;
DROP VIEW IF EXISTS airports_table;
DROP TABLE IF EXISTS output_json;

-- Create external table for MapReduce output (datasource3)
CREATE EXTERNAL TABLE mapreduce_result (
    departure_airport_id STRING,
    status STRING,
    flight_count INT,
    avg_ticket_price DOUBLE
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE LOCATION '${hiveconf:output_dir3}';

-- Create raw table for airports data (datasource4)
-- Loads each line as a single STRING for flexible parsing
CREATE EXTERNAL TABLE airports_raw (
    line STRING
) STORED AS TEXTFILE LOCATION '${hiveconf:input_dir4}'
TBLPROPERTIES ("skip.header.line.count" = "1");

-- Create VIEW to intelligently parse airports CSV
-- Handles both correct records (6 fields) and problematic records (7 fields)
-- Problem: Some airport names contain commas (e.g., "Nitzsche, Heidenreich and Funk Airport")
CREATE VIEW airports_table AS
SELECT
    cols[0] as airport_id,
    -- If 7 fields, merge cols[1] and cols[2] as airport_name
    -- If 6 fields, just use cols[1] as airport_name
    CASE
        WHEN size(cols) = 7 THEN concat(cols[1], ',', cols[2])
        ELSE cols[1]
    END as airport_name,
    -- Last 4 fields are always in the same position from the end
    cols[size(cols)-4] as city,
    cols[size(cols)-3] as country,
    cols[size(cols)-2] as continent,
    cols[size(cols)-1] as type
FROM (
    SELECT split(line, ',') as cols
    FROM airports_raw
) parsed
WHERE size(cols) IN (6, 7);

-- Create output table with JSON SerDe
CREATE EXTERNAL TABLE output_json (
    continent STRING,
    country STRING,
    total_flights BIGINT,
    avg_ticket_price DOUBLE,
    rank_in_continent INT
) ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe' STORED AS TEXTFILE LOCATION '${hiveconf:output_dir6}';

-- Execute JOIN, aggregation, ranking and export to JSON
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
            -- WEIGHTED AVERAGE: suma(cena * liczba) / suma(liczba)
            -- Nie możemy użyć AVG(avg_ticket_price) bo to byłaby średnia ze średnich!
            SUM(mr.avg_ticket_price * mr.flight_count) / SUM(mr.flight_count) as avg_ticket_price
        FROM mapreduce_result mr
            INNER JOIN airports_table a ON mr.departure_airport_id = a.airport_id
        GROUP BY a.continent,
            a.country
    ) country_stats;
    
-- Tables remain available for debugging