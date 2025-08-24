# Operaciones

## Ver estado
docker compose ps
docker logs zbx-server -f
docker logs zbx-web -f

## Backup
DB_NAME=zabbix scripts/backup_mysql.sh backups/

## Restore
DB_NAME=zabbix scripts/restore_mysql.sh backups/mysql_zabbix_YYYYmmdd_HHMMSS.sql.gz

## Upgrade Zabbix
- Edita etiquetas de imagen a `alpine-7.0-latest` (ya lo están).
- docker compose pull && docker compose up -d
