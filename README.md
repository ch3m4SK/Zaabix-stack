# Zabbix Stack (Docker Compose)

Stack: Zabbix Server + Zabbix Web (Nginx+PHP-FPM) + MySQL 8.

## Arranque local
```bash
cp .env.example .env   # Rellena valores si quieres probar local
mkdir -p zbx/alertscripts zbx/externalscripts zbx/snmptraps zbx/mibs
docker compose up -d
# UI: http://localhost:8080  (Admin / zabbix)
