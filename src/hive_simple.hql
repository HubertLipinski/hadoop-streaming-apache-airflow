-- Simplified Hive script for testing
SET hive.execution.engine=mr;
SET hive.auto.convert.join=false;
SET hive.optimize.reducededuplication=false;

DROP TABLE IF EXISTS mapreduce_result;
DROP TABLE IF EXISTS airports_table;
DROP TABLE IF EXISTS output_simple;

CREATE EXTERNAL TABLE mapreduce_result (
    departure_airport_id STRING,
    status STRING,
    flight_count INT,
    avg_ticket_price DOUBLE
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '${hiveconf:output_dir3}';

CREATE EXTERNAL TABLE airports_table (
    airport_id STRING,
    airport_name STRING,
    city STRING,
    country STRING,
    continent STRING,
    type STRING
) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ("separatorChar" = ",")
STORED AS TEXTFILE LOCATION '${hiveconf:input_dir4}'
TBLPROPERTIES ("skip.header.line.count" = "1");

-- Simple aggregation without window functions
CREATE EXTERNAL TABLE output_simple (
    continent STRING,
    country STRING,
    total_flights BIGINT,
    avg_ticket_price DOUBLE
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '${hiveconf:output_dir6}';

INSERT OVERWRITE TABLE output_simple
SELECT a.continent,
    a.country,
    SUM(mr.flight_count) as total_flights,
    SUM(mr.avg_ticket_price * mr.flight_count) / SUM(mr.flight_count) as avg_ticket_price
FROM mapreduce_result mr
INNER JOIN airports_table a ON mr.departure_airport_id = a.airport_id
GROUP BY a.continent, a.country;
