CREATE QUOTA OR REPLACE limited_1 KEYED BY user_name
ON CLUSTER data_hub_dw_001
FOR INTERVAL 1 day MAX queries 1000, errors 0, result_rows 0, read_rows 0
TO readonly_dw;
