CREATE USER OR REPLACE service_etl
ON CLUSTER data_hub_dw_001
--IDENTIFIED WITH SHA256_PASSWORD BY 'service_etl'
SETTINGS PROFILE service
DEFAULT ROLE service_dw_rep;

GRANT service_dw_rep, service_dw
TO service_etl
ON CLUSTER data_hub_dw_001;

GRANT REMOTE ON *.* TO service_etl ON CLUSTER data_hub_dw_001;
