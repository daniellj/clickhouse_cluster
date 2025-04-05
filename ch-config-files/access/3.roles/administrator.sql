CREATE ROLE IF NOT EXISTS administrator
ON CLUSTER data_hub_dw_001;

ALTER ROLE administrator ON CLUSTER data_hub_dw_001
SETTINGS readonly = 0;

GRANT ALL ON *.* TO administrator
ON CLUSTER data_hub_dw_001
WITH GRANT OPTION;

GRANT ACCESS MANAGEMENT ON *.* TO administrator
ON CLUSTER data_hub_dw_001;
