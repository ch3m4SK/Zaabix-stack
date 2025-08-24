# Jenkins Setup

1. Ejecutar Jenkins en Docker con socket:
   -v /var/run/docker.sock:/var/run/docker.sock

2. Verificar CLI:
   docker version
   docker compose version

3. Credenciales:
   - zbx_db_pass (Secret text)
   - zbx_db_root_pass (Secret text)

4. Webhook GitHub:
   URL: https://<jenkins>/github-webhook/
   Content-Type: application/json
   Events: Just the push event
