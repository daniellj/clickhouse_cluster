CREATE USER OR REPLACE service_etl
ON CLUSTER data_hub_dw_001
--IDENTIFIED WITH SHA256_PASSWORD BY 'service_etl'
SETTINGS PROFILE service
DEFAULT ROLE service_rw;

GRANT service_rw, service_r
TO service_etl
ON CLUSTER data_hub_dw_001;
