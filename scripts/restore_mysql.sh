#!/usr/bin/env bash
set -euo pipefail

# Uso: scripts/restore_mysql.sh <dump.sql.gz>
DUMP_FILE="${1:?Indica el fichero .sql.gz}"
DB_NAME="${DB_NAME:-zabbix}"

echo "Restaurando ${DUMP_FILE} en BD ${DB_NAME}..."
gunzip -c "${DUMP_FILE}" | docker exec -i zbx-mysql sh -lc "mysql -u root -p\"\$MYSQL_ROOT_PASSWORD\" ${DB_NAME}"
echo "Restore completado."
