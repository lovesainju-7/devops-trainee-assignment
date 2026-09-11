#!/bin/bash

BACKUP_DIR="/var/backups/db"

CONTAINER="devops-postgres"
DB_NAME="trainee_db"
DB_USER="trainee"

DATE=$(date +"%Y%m%d")
BACKUP_FILE="$BACKUP_DIR/db_backup_${DATE}.sql.gz"

echo "Starting database backup..."

docker exec "$CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]
then
    echo "Database backup completed successfully."
    echo "Backup file: $BACKUP_FILE"
else
    echo "[WARNING] Database backup failed."
    rm -f "$BACKUP_FILE"
    exit 1
fi
