CREATE ROLE IF NOT EXISTS readonly_dw
ON CLUSTER data_hub_dw_001;

ALTER ROLE readonly_dw ON CLUSTER data_hub_dw_001
SETTINGS readonly = 2;

GRANT ON CLUSTER data_hub_dw_001
SELECT ON dw.* TO readonly_dw;
