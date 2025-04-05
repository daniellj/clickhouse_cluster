DROP TABLE IF EXISTS dw_rep.sales ON CLUSTER '{cluster}' SYNC;
DROP TABLE IF EXISTS dw.sales ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.sales ON CLUSTER '{cluster}'
(
    sale_id UInt64 COMMENT 'Sale identifier. Unique record.',
    sale_datetime DateTime COMMENT 'Datetime of the sale.',
    product_id UInt32 COMMENT 'Product identifier.',
    amount Float32 COMMENT 'Product value in BRL.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/sales', '{replica}', sale_datetime)
PARTITION BY toYYYYMM(sale_datetime)
ORDER BY (sale_id)
PRIMARY KEY (sale_id)
SETTINGS index_granularity = 8192;

CREATE TABLE IF NOT EXISTS dw.sales ON CLUSTER '{cluster}' AS dw_rep.sales ENGINE = Distributed('{cluster}', dw_rep, sales, rand());
