-- RAW (dado original)
DROP TABLE IF EXISTS dw_rep.raw_order_details ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.raw_order_details ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Identifier of the order to which this item belongs.',
    product_id UInt64 COMMENT 'Identifier of the product included in the order.',
    unit_price Float64 COMMENT 'Unit price of the product at the time of the order.',
    quantity UInt64 COMMENT 'Quantity of the product ordered.',
    discount Float64 COMMENT 'Discount applied to the product in this order line, expressed as a decimal (e.g., 0.1 for 10%).',
    update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (orderID, productID) pair is retained during merges.'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/raw_order_details', '{replica}')
PARTITION BY toYYYYMM(update_ts)
ORDER BY (order_id, product_id, update_ts)
PRIMARY KEY (order_id, product_id)
SETTINGS index_granularity = 8192;

-- STAGING (Dado modelado: nomenclatura das colunas e tipos de dados ajustados; enriquimento de dados)
DROP TABLE IF EXISTS dw_rep.stg_order_details ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.stg_order_details ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Identifier of the order to which this item belongs.',
    product_id UInt64 COMMENT 'Identifier of the product included in the order.',
    unit_price Float64 COMMENT 'Unit price of the product at the time of the order.',
    quantity UInt64 COMMENT 'Quantity of the product ordered.',
    discount Float64 COMMENT 'Discount applied to the product in this order line, expressed as a decimal (e.g., 0.1 for 10%).',
    update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (orderID, productID) pair is retained during merges.'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/stg_order_details', '{replica}')
PARTITION BY toYYYYMM(update_ts)
ORDER BY (order_id, product_id, update_ts)
PRIMARY KEY (order_id, product_id)
SETTINGS index_granularity = 8192;

-- INTERMEDIATE (regras de negócio, joins e agregações)
DROP TABLE IF EXISTS dw_rep.int_order_details ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.int_order_details ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Identifier of the order to which this item belongs.',
    product_id UInt64 COMMENT 'Identifier of the product included in the order.',
    unit_price Float64 COMMENT 'Unit price of the product at the time of the order.',
    quantity UInt64 COMMENT 'Quantity of the product ordered.',
    discount Float64 COMMENT 'Discount applied to the product in this order line, expressed as a decimal (e.g., 0.1 for 10%).',
    update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (orderID, productID) pair is retained during merges.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/int_order_details', '{replica}', update_ts)
PARTITION BY toYYYYMM(update_ts)
ORDER BY (order_id, product_id, update_ts)
PRIMARY KEY (order_id, product_id)
SETTINGS index_granularity = 8192;

-- MART (visões de negócio)
DROP TABLE IF EXISTS dw_rep.mart_order_details ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.mart_order_details ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Identifier of the order to which this item belongs.',
    product_id UInt64 COMMENT 'Identifier of the product included in the order.',
    unit_price Float64 COMMENT 'Unit price of the product at the time of the order.',
    quantity UInt64 COMMENT 'Quantity of the product ordered.',
    discount Float64 COMMENT 'Discount applied to the product in this order line, expressed as a decimal (e.g., 0.1 for 10%).',
    update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (orderID, productID) pair is retained during merges.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/mart_order_details', '{replica}', update_ts)
PARTITION BY toYYYYMM(update_ts)
ORDER BY (order_id, product_id, update_ts)
PRIMARY KEY (order_id, product_id)
SETTINGS index_granularity = 8192;

-- DISTRIBUITED (tabelas distribuídas criadas sobre as tabelas replicadas da camada MARTS)
DROP TABLE IF EXISTS dw.order_details ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw.order_details ON CLUSTER '{cluster}' AS dw_rep.mart_order_details ENGINE = Distributed('{cluster}', dw_rep, mart_order_details, rand());
