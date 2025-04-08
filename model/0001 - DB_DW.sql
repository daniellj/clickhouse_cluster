-- DROP
DROP DATABASE IF EXISTS dw_raw ON CLUSTER '{cluster}';
DROP DATABASE IF EXISTS dw_staging ON CLUSTER '{cluster}';

DROP DATABASE IF EXISTS dw_mart ON CLUSTER '{cluster}';
DROP DATABASE IF EXISTS dw ON CLUSTER '{cluster}';

-- CREATE
CREATE DATABASE IF NOT EXISTS dw_raw ON CLUSTER '{cluster}' COMMENT 'Data warehouse for raw data (bronze layer).';
CREATE DATABASE IF NOT EXISTS dw_staging ON CLUSTER '{cluster}' COMMENT 'Data warehouse for staging data (bronze layer).';

CREATE DATABASE IF NOT EXISTS dw_mart ON CLUSTER '{cluster}' COMMENT 'Data warehouse for consumption (gold layer).';
CREATE DATABASE IF NOT EXISTS dw ON CLUSTER '{cluster}' COMMENT 'Data warehouse distribuited data for consumption (gold layer).' SETTINGS allow_experimental_parallel_reading_from_replicas = 1;
