-- RAW (dado original)
DROP TABLE IF EXISTS dw_rep.raw_products ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.raw_products ON CLUSTER '{cluster}'
(
        product_id Int64 COMMENT 'Unique identifier for the product.',
        product_name String COMMENT 'Name or title of the product.',
        supplier_id Int64 COMMENT 'Identifier of the supplier providing the product.',
        category_id Int64 COMMENT 'Identifier of the category to which the product belongs.',
        quantity_per_unit String COMMENT 'Description of the quantity per unit (e.g., 10 boxes x 20 bags).',
        unit_price Float64 COMMENT 'Selling price per unit of the product.',
        units_in_stock Int64 COMMENT 'Current number of units available in stock.',
        units_on_order Int64 COMMENT 'Number of units already ordered but not yet received.',
        reorder_level Int64 COMMENT 'Threshold at which new stock should be reordered.',
        discontinued Int64 COMMENT 'Indicates whether the product is no longer sold (1 = yes, 0 = no).',
        update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (productID) pair is retained during merges.'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/raw_products', '{replica}')
PARTITION BY toYYYYMM(update_ts)
ORDER BY (product_id, supplier_id, category_id, update_ts)
PRIMARY KEY (product_id)
SETTINGS index_granularity = 8192;

-- STAGING (Dado modelado: nomenclatura das colunas e tipos de dados ajustados; enriquimento de dados)
DROP TABLE IF EXISTS dw_rep.stg_products ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.stg_products ON CLUSTER '{cluster}'
(
        product_id Int64 COMMENT 'Unique identifier for the product.',
        product_name String COMMENT 'Name or title of the product.',
        supplier_id Int64 COMMENT 'Identifier of the supplier providing the product.',
        category_id Int64 COMMENT 'Identifier of the category to which the product belongs.',
        quantity_per_unit String COMMENT 'Description of the quantity per unit (e.g., 10 boxes x 20 bags).',
        unit_price Float64 COMMENT 'Selling price per unit of the product.',
        units_in_stock Int64 COMMENT 'Current number of units available in stock.',
        units_on_order Int64 COMMENT 'Number of units already ordered but not yet received.',
        reorder_level Int64 COMMENT 'Threshold at which new stock should be reordered.',
        discontinued Int64 COMMENT 'Indicates whether the product is no longer sold (1 = yes, 0 = no).',
        update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (productID) pair is retained during merges.'
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/stg_products', '{replica}')
PARTITION BY toYYYYMM(update_ts)
ORDER BY (product_id, supplier_id, category_id, update_ts)
PRIMARY KEY (product_id)
SETTINGS index_granularity = 8192;

-- INTERMEDIATE (regras de negócio, joins e agregações)
DROP TABLE IF EXISTS dw_rep.int_products ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.int_products ON CLUSTER '{cluster}'
(
        product_id Int64 COMMENT 'Unique identifier for the product.',
        product_name String COMMENT 'Name or title of the product.',
        supplier_id Int64 COMMENT 'Identifier of the supplier providing the product.',
        category_id Int64 COMMENT 'Identifier of the category to which the product belongs.',
        quantity_per_unit String COMMENT 'Description of the quantity per unit (e.g., 10 boxes x 20 bags).',
        unit_price Float64 COMMENT 'Selling price per unit of the product.',
        units_in_stock Int64 COMMENT 'Current number of units available in stock.',
        units_on_order Int64 COMMENT 'Number of units already ordered but not yet received.',
        reorder_level Int64 COMMENT 'Threshold at which new stock should be reordered.',
        discontinued Int64 COMMENT 'Indicates whether the product is no longer sold (1 = yes, 0 = no).',
        update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (productID) pair is retained during merges.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/int_products', '{replica}', update_ts)
PARTITION BY toYYYYMM(update_ts)
ORDER BY (product_id, supplier_id, category_id, update_ts)
PRIMARY KEY (product_id)
SETTINGS index_granularity = 8192;

-- MART (visões de negócio)
DROP TABLE IF EXISTS dw_rep.mart_products ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_rep.mart_products ON CLUSTER '{cluster}'
(
        product_id Int64 COMMENT 'Unique identifier for the product.',
        product_name String COMMENT 'Name or title of the product.',
        supplier_id Int64 COMMENT 'Identifier of the supplier providing the product.',
        category_id Int64 COMMENT 'Identifier of the category to which the product belongs.',
        quantity_per_unit String COMMENT 'Description of the quantity per unit (e.g., 10 boxes x 20 bags).',
        unit_price Float64 COMMENT 'Selling price per unit of the product.',
        units_in_stock Int64 COMMENT 'Current number of units available in stock.',
        units_on_order Int64 COMMENT 'Number of units already ordered but not yet received.',
        reorder_level Int64 COMMENT 'Threshold at which new stock should be reordered.',
        discontinued Int64 COMMENT 'Indicates whether the product is no longer sold (1 = yes, 0 = no).',
        update_ts DateTime DEFAULT now() COMMENT 'Timestamp used for versioning rows in ReplacingMergeTree. Ensures the most recent version of each (productID) pair is retained during merges.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/mart_products', '{replica}', update_ts)
PARTITION BY toYYYYMM(update_ts)
ORDER BY (product_id, supplier_id, category_id, update_ts)
PRIMARY KEY (product_id)
SETTINGS index_granularity = 8192;

-- DISTRIBUITED (tabelas distribuídas criadas sobre as tabelas replicadas da camada MARTS)
DROP TABLE IF EXISTS dw.products ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw.products ON CLUSTER '{cluster}' AS dw_rep.mart_products ENGINE = Distributed('{cluster}', dw_rep, mart_products, rand());
