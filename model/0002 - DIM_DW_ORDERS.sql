-- RAW (dado original)
DROP TABLE IF EXISTS dw_rep.raw_orders ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.raw_orders ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Unique identifier for each order.',
    customer_id String COMMENT 'Identifier of the customer who placed the order.',
    employee_id UInt64 COMMENT 'Identifier of the employee responsible for the order.',
    order_date DateTime COMMENT 'Date when the order was placed.',
    required_date DateTime COMMENT 'Date by which the customer requested delivery.',
    shipped_date DateTime COMMENT 'Date when the order was shipped.',
    ship_via UInt64 COMMENT 'Shipping method used, typically referring to a shipping company ID.',
    freight Float64 COMMENT 'Shipping cost charged for the order.',
    ship_name String COMMENT 'Name of the recipient or company to which the order was shipped.',
    ship_address String COMMENT 'Street address for delivery.',
    ship_city String COMMENT 'City where the order was shipped.',
    ship_region String COMMENT 'Region, state, or province where the order was shipped.',
    ship_postal_code String COMMENT 'Postal or ZIP code for the delivery address.',
    ship_country String COMMENT 'Country to which the order was shipped.'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/raw_orders', '{replica}')
PARTITION BY toYYYYMM(order_date)
ORDER BY (order_id, customer_id, order_date)
PRIMARY KEY (order_id, customer_id)
SETTINGS index_granularity = 8192;

-- STAGING (Dado modelado: nomenclatura das colunas e tipos de dados ajustados; enriquimento de dados)
DROP TABLE IF EXISTS dw_rep.stg_orders ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.stg_orders ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Unique identifier for each order.',
    customer_id String COMMENT 'Identifier of the customer who placed the order.',
    employee_id UInt64 COMMENT 'Identifier of the employee responsible for the order.',
    order_date DateTime COMMENT 'Date when the order was placed.',
    required_date DateTime COMMENT 'Date by which the customer requested delivery.',
    shipped_date DateTime COMMENT 'Date when the order was shipped.',
    ship_via UInt64 COMMENT 'Shipping method used, typically referring to a shipping company ID.',
    freight Float64 COMMENT 'Shipping cost charged for the order.',
    ship_name String COMMENT 'Name of the recipient or company to which the order was shipped.',
    ship_address String COMMENT 'Street address for delivery.',
    ship_city String COMMENT 'City where the order was shipped.',
    ship_region String COMMENT 'Region, state, or province where the order was shipped.',
    ship_postal_code String COMMENT 'Postal or ZIP code for the delivery address.',
    ship_country String COMMENT 'Country to which the order was shipped.'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/stg_orders', '{replica}')
PARTITION BY toYYYYMM(order_date)
ORDER BY (order_id, customer_id, order_date)
PRIMARY KEY (order_id, customer_id)
SETTINGS index_granularity = 8192;

-- INTERMEDIATE (regras de negócio, joins e agregações)
DROP TABLE IF EXISTS dw_rep.int_orders ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.int_orders ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Unique identifier for each order.',
    customer_id String COMMENT 'Identifier of the customer who placed the order.',
    employee_id UInt64 COMMENT 'Identifier of the employee responsible for the order.',
    order_date DateTime COMMENT 'Date when the order was placed.',
    required_date DateTime COMMENT 'Date by which the customer requested delivery.',
    shipped_date DateTime COMMENT 'Date when the order was shipped.',
    ship_via UInt64 COMMENT 'Shipping method used, typically referring to a shipping company ID.',
    freight Float64 COMMENT 'Shipping cost charged for the order.',
    ship_name String COMMENT 'Name of the recipient or company to which the order was shipped.',
    ship_address String COMMENT 'Street address for delivery.',
    ship_city String COMMENT 'City where the order was shipped.',
    ship_region String COMMENT 'Region, state, or province where the order was shipped.',
    ship_postal_code String COMMENT 'Postal or ZIP code for the delivery address.',
    ship_country String COMMENT 'Country to which the order was shipped.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/int_orders', '{replica}', order_date)
PARTITION BY toYYYYMM(order_date)
ORDER BY (order_id, customer_id, order_date)
PRIMARY KEY (order_id, customer_id)
SETTINGS index_granularity = 8192;

-- MART (visões de negócio)
DROP TABLE IF EXISTS dw_rep.mart_orders ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.mart_orders ON CLUSTER '{cluster}'
(
    order_id UInt64 COMMENT 'Unique identifier for each order.',
    customer_id String COMMENT 'Identifier of the customer who placed the order.',
    employee_id UInt64 COMMENT 'Identifier of the employee responsible for the order.',
    order_date DateTime COMMENT 'Date when the order was placed.',
    required_date DateTime COMMENT 'Date by which the customer requested delivery.',
    shipped_date DateTime COMMENT 'Date when the order was shipped.',
    ship_via UInt64 COMMENT 'Shipping method used, typically referring to a shipping company ID.',
    freight Float64 COMMENT 'Shipping cost charged for the order.',
    ship_name String COMMENT 'Name of the recipient or company to which the order was shipped.',
    ship_address String COMMENT 'Street address for delivery.',
    ship_city String COMMENT 'City where the order was shipped.',
    ship_region String COMMENT 'Region, state, or province where the order was shipped.',
    ship_postal_code String COMMENT 'Postal or ZIP code for the delivery address.',
    ship_country String COMMENT 'Country to which the order was shipped.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/mart_orders', '{replica}', order_date)
PARTITION BY toYYYYMM(order_date)
ORDER BY (order_id, customer_id, order_date)
PRIMARY KEY (order_id, customer_id)
SETTINGS index_granularity = 8192;

-- DISTRIBUITED (tabelas distribuídas criadas sobre as tabelas replicadas da camada MARTS)
DROP TABLE IF EXISTS dw.orders ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw.orders ON CLUSTER '{cluster}' AS dw_rep.mart_orders ENGINE = Distributed('{cluster}', dw_rep, mart_orders, rand());
