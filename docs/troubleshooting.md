# Troubleshooting

- UI no carga:
  - docker logs zbx-web --tail=200
  - scripts/healthcheck_ui.sh localhost 8080

- Zabbix Server no conecta a DB:
  - docker logs zbx-server --tail=200
  - Comprueba `.env` y health de `zbx-mysql`.

- MySQL lento o corrupto:
  - Reinicia solo MySQL: docker restart zbx-mysql
  - Restaura desde backup.
