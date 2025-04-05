CREATE QUOTA OR REPLACE unlimited KEYED BY user_name
ON CLUSTER data_hub_dw_001
FOR INTERVAL 1 month MAX queries 0, errors 0, result_rows 0, read_rows 0;
TO administrator, service;
