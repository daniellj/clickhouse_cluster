-- DW_REP
CREATE ROLE IF NOT EXISTS service_dw_rep
ON CLUSTER data_hub_dw_001;

ALTER ROLE service_dw_rep ON CLUSTER data_hub_dw_001
SETTINGS readonly = 0;

GRANT ON CLUSTER data_hub_dw_001
      INSERT
    , DELETE
    , UPDATE
    , SELECT
    , CREATE
    , TRUNCATE
    , ALTER TABLE
    , BACKUP
    , DROP DICTIONARY
    , DROP TABLE
    , DROP VIEW
    , OPTIMIZE
    , SHOW
ON dw_rep.*
TO service_dw_rep;

GRANT REMOTE ON *.* TO service_dw_rep;
GRANT CLUSTER ON *.* TO service_dw_rep;

GRANT ACCESS MANAGEMENT ON *.* TO service_dw_rep
ON CLUSTER data_hub_dw_001;
----------------------------------------------------------------
-- DW
CREATE ROLE IF NOT EXISTS service_dw
ON CLUSTER data_hub_dw_001;

ALTER ROLE service_dw ON CLUSTER data_hub_dw_001
SETTINGS readonly = 2;

GRANT ON CLUSTER data_hub_dw_001
SELECT ON dw.* TO service_dw;
----------------------------------------------------------------