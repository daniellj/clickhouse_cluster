-- RAW (dado original)
DROP TABLE IF EXISTS dw_raw.countries ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_raw.countries ON CLUSTER '{cluster}'
(
    id String COMMENT 'Unique identifier of the country in the source system.',
    lang_pt_br String COMMENT 'Country name in Brazilian Portuguese (pt-BR), unformatted.',
    lang_pt_br_formatted String COMMENT 'Country name in Brazilian Portuguese (pt-BR), with formatting applied (e.g., capitalization).',
    lang_en String COMMENT 'Country name in English (en), unformatted.',
    lang_en_formatted String COMMENT 'Country name in English (en), with formatting applied (e.g., capitalization).',
    alpha_2 String COMMENT 'ISO 3166-1 alpha-2 country code (2-letter format).',
    alpha_3 String COMMENT 'ISO 3166-1 alpha-3 country code (3-letter format).',
    create_date_ts DateTime COMMENT 'Timestamp of record creation or ingestion.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/dw_raw_countries', '{replica}', create_date_ts)
PARTITION BY substring(lang_en_formatted, 1, 1)
ORDER BY (alpha_2, alpha_3, create_date_ts)
PRIMARY KEY (alpha_2, alpha_3)
SETTINGS index_granularity = 8192;

-- STAGING (Dado modelado: nomenclatura das colunas e tipos de dados ajustados; enriquimento de dados)
DROP TABLE IF EXISTS dw_staging.countries ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw_staging.countries ON CLUSTER '{cluster}'
(
    id String COMMENT 'Unique identifier of the country in the source system.',
    lang_pt_br String COMMENT 'Country name in Brazilian Portuguese (pt-BR), unformatted.',
    lang_pt_br_formatted String COMMENT 'Country name in Brazilian Portuguese (pt-BR), with formatting applied (e.g., capitalization).',
    lang_en String COMMENT 'Country name in English (en), unformatted.',
    lang_en_formatted String COMMENT 'Country name in English (en), with formatting applied (e.g., capitalization).',
    alpha_2 String COMMENT 'ISO 3166-1 alpha-2 country code (2-letter format).',
    alpha_3 String COMMENT 'ISO 3166-1 alpha-3 country code (3-letter format).',
    continent String COMMENT 'Continent to which the country belongs, derived from ISO alpha-2 country code.',
    create_date_ts DateTime COMMENT 'Timestamp of record creation or ingestion.'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/dw_staging_countries', '{replica}', create_date_ts)
PARTITION BY substring(lang_en_formatted, 1, 1)
ORDER BY (alpha_2, alpha_3, create_date_ts)
PRIMARY KEY (alpha_2, alpha_3)
SETTINGS index_granularity = 8192;



-- DISTRIBUITED (tabelas distribuídas criadas sobre as tabelas replicadas da camada MARTS)
DROP TABLE IF EXISTS dw.countries ON CLUSTER '{cluster}' SYNC;

CREATE TABLE IF NOT EXISTS dw.countries ON CLUSTER '{cluster}' AS dw_mart.countries ENGINE = Distributed('{cluster}', dw_mart, countries, rand());
