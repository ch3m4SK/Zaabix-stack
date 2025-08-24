#!/usr/bin/env bash
set -euo pipefail

# Requiere: contenedor mysql llamado "zbx-mysql"
# Uso: scripts/backup_mysql.sh [backup_dir]
BACKUP_DIR="${1:-backups}"
DB_NAME="${DB_NAME:-zabbix}"
TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"

mkdir -p "${BACKUP_DIR}"
echo "Creando backup de ${DB_NAME} en ${BACKUP_DIR}/mysql_${DB_NAME}_${TIMESTAMP}.sql.gz"
docker exec zbx-mysql sh -lc "mysqldump -u root -p\"\$MYSQL_ROOT_PASSWORD\" --single-transaction --routines --triggers ${DB_NAME}" \
  | gzip > "${BACKUP_DIR}/mysql_${DB_NAME}_${TIMESTAMP}.sql.gz"
echo "Backup completado."
