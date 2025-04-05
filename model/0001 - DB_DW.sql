DROP DATABASE IF EXISTS dw_rep ON CLUSTER '{cluster}';
DROP DATABASE IF EXISTS dw ON CLUSTER '{cluster}';

CREATE DATABASE IF NOT EXISTS dw_rep ON CLUSTER '{cluster}' COMMENT 'Data warehouse replicated data.';
CREATE DATABASE IF NOT EXISTS dw ON CLUSTER '{cluster}' COMMENT 'Data warehouse distribuited data.' SETTINGS allow_experimental_parallel_reading_from_replicas = 1;
