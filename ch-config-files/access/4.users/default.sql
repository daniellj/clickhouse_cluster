CREATE USER IF NOT EXISTS default
ON CLUSTER data_hub_dw_001
IDENTIFIED WITH SHA256_PASSWORD BY 'default'
SETTINGS PROFILE readonly_dw
DEFAULT ROLE readonly_dw;
