-- Hive script without RANK() for testing
-- Purpose: JOIN MapReduce results with airports data, aggregate by country/continent, output as JSON

-- Use Tez execution engine (default)
-- SET hive.execution.engine=tez;

-- Drop existing tables for repeatability
DROP TABLE IF EXISTS mapreduce_result;
DROP TABLE IF EXISTS airports_table;
DROP TABLE IF EXISTS output_json;

-- Create external table for MapReduce output (datasource3)
CREATE EXTERNAL TABLE mapreduce_result (
    departure_airport_id STRING,
    status STRING,
    flight_count INT,
    avg_ticket_price DOUBLE
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE LOCATION '${hiveconf:output_dir3}';

-- Create external table for airports data (datasource4)
-- Using OpenCSVSerde to handle commas within airport names
CREATE EXTERNAL TABLE airports_table (
    airport_id STRING,
    airport_name STRING,
    city STRING,
    country STRING,
    continent STRING,
    type STRING
) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ","
)
STORED AS TEXTFILE LOCATION '${hiveconf:input_dir4}'
TBLPROPERTIES ("skip.header.line.count" = "1");

-- Create output table with JSON SerDe (WITHOUT rank_in_continent for now)
CREATE EXTERNAL TABLE output_json (
    continent STRING,
    country STRING,
    total_flights BIGINT,
    avg_ticket_price DOUBLE
) ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe' STORED AS TEXTFILE LOCATION '${hiveconf:output_dir6}';

-- Execute JOIN, aggregation and export to JSON (NO RANKING)
INSERT OVERWRITE TABLE output_json
SELECT a.continent,
    a.country,
    SUM(mr.flight_count) as total_flights,
    SUM(mr.avg_ticket_price * mr.flight_count) / SUM(mr.flight_count) as avg_ticket_price
FROM mapreduce_result mr
INNER JOIN airports_table a ON mr.departure_airport_id = a.airport_id
GROUP BY a.continent, a.country;

-- Tables remain available for debugging
