select * from system.grants
select * from system.macros
select * from system.metrics
select * from system.part_moves_between_shards
select * from system.parts
select * from system.privileges
select * from system.quota_limits
select * from system.quota_usage
select * from system.quotas
select * from system.remote_data_paths
select * from system.replicas
select * from system.replicated_merge_tree_settings
select * from system.replication_queue
select * from system.roles
select * from system.role_grants
select * from system.scheduler
select * from system.settings
select * from system.settings_profiles
select * from system.table_engines
select * from system.table_functions
select * from system.tables
select * from system.user_directories
select * from system.user_processes
select * from system.users
select * from system.zookeeper_connection
SELECT * FROM system.zookeeper WHERE path = '/' LIMIT 1
