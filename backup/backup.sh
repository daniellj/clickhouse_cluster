#!/bin/bash

source /etc/clickhouse-backup/backup.env

NOW=$(date +%Y-%m-%d)

# Verifica a data do último backup FULL
LAST_FULL_DATE=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "full-*" | sed 's|.*/full-||' | sort -r | head -1)
DAYS_SINCE_LAST_FULL=$(dateutils.ddiff "$LAST_FULL_DATE" "$NOW" -f '%d' 2>/dev/null || echo 999)

# Define nome do backup
if [ "$DAYS_SINCE_LAST_FULL" -ge "$FULL_INTERVAL_DAYS" ]; then
    BACKUP_NAME="full-$NOW"
    echo "[BACKUP] Criando backup FULL: $BACKUP_NAME"
    clickhouse-backup create --full "$BACKUP_NAME"
else
    BACKUP_NAME="inc-$NOW"
    echo "[BACKUP] Criando backup INCREMENTAL: $BACKUP_NAME"
    clickhouse-backup create "$BACKUP_NAME"
fi

# Backup dos metadados RBAC
METADATA_DIR="$BACKUP_DIR/metadata-$NOW"
echo "[BACKUP] Salvando metadados RBAC em: $METADATA_DIR"
mkdir -p "$METADATA_DIR"
cp -r /var/lib/clickhouse/access "$METADATA_DIR/access"

# Restore automático em banco de testes
echo "[RESTORE] Restaurando backup para validação em 'test_restore_db'..."
LATEST_BACKUP=$(clickhouse-backup list | grep -E 'inc-|full-' | sort -r | head -1 | awk '{print $1}')
clickhouse-backup restore "$LATEST_BACKUP" --schema --data --rm --db="test_restore_db"

# Limpeza de backups antigos
echo "[CLEANUP] Removendo backups locais com mais de $RETENTION_DAYS dias..."
clickhouse-backup delete local --older-than "${RETENTION_DAYS}d"

echo "[DONE] Backup finalizado em $NOW"
