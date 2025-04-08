-- DW_REP
CREATE ROLE IF NOT EXISTS service_rw
ON CLUSTER data_hub_dw_001;

ALTER ROLE service_rw ON CLUSTER data_hub_dw_001
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
ON dw_raw.*
TO service_rw;

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
ON dw_staging.*
TO service_rw;

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
ON dw_mart.*
TO service_rw;

----------------------------------------------------------------
-- DW
CREATE ROLE IF NOT EXISTS service_r
ON CLUSTER data_hub_dw_001;

ALTER ROLE service_r ON CLUSTER data_hub_dw_001
SETTINGS readonly = 2;

GRANT ON CLUSTER data_hub_dw_001
SELECT ON dw.* TO service_r;

-- Executar consultas distribuídas (como SELECT ... FROM cluster(...) ou com tabelas do tipo Distributed) em nome do usuário com acesso remoto, mesmo quando a tabela está em outro nó do cluster.
GRANT REMOTE ON *.* TO service_rw ON CLUSTER data_hub_dw_001;
GRANT REMOTE ON *.* TO service_r ON CLUSTER data_hub_dw_001;

-- Permite propagar os comandos para todos os nós do cluster
GRANT CLUSTER ON *.* TO service_rw;
GRANT CLUSTER ON *.* TO service_r;
