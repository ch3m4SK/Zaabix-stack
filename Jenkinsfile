pipeline {
  agent any

  environment {
    DEPLOY_PATH = '/opt/zabbix-stack'
    WEB_PORT = '8082'
    WEB_TLS_PORT = '8445'
  }

  stages {
    stage('Preparar carpeta') {
      steps {
        sh """
          mkdir -p $DEPLOY_PATH/zbx/alertscripts \
                   $DEPLOY_PATH/zbx/externalscripts \
                   $DEPLOY_PATH/zbx/snmptraps \
                   $DEPLOY_PATH/zbx/mibs
        """
      }
    }

    stage('Copiar archivos') {
      steps {
        sh "cp docker-compose.yml $DEPLOY_PATH/"
      }
    }

    stage('Escribir .env con credenciales') {
      steps {
        withCredentials([
          string(credentialsId: 'zbx_db_pass',      variable: 'SECRET_DB_PASS'),
          string(credentialsId: 'zbx_db_root_pass', variable: 'SECRET_DB_ROOT_PASS')
        ]) {
          sh """
            cat > $DEPLOY_PATH/.env <<EOF
DB_NAME=zabbix
DB_USER=zabbix
DB_PASS=${SECRET_DB_PASS}
DB_ROOT_PASS=${SECRET_DB_ROOT_PASS}
ZBX_SERVER_NAME=Zabbix Prod
PHP_TZ=Europe/Madrid
ZBX_DEBUGLEVEL=3
ZBX_STARTDISCOVERERS=3
ZBX_STARTPOLLERS=10
ZBX_TIMEOUT=10
ZBX_AGENT_HOSTNAME=docker-host
WEB_PORT=${WEB_PORT}
WEB_TLS_PORT=${WEB_TLS_PORT}
EOF
            sed 's/\\(DB_PASS\\|DB_ROOT_PASS\\)=.*/\\1=****/g' $DEPLOY_PATH/.env
          """
        }
      }
    }

    stage('Deploy') {
      steps {
        sh """
          cd $DEPLOY_PATH
          docker-compose pull
          docker-compose down || true
          docker-compose up -d
        """
      }
    }

    stage('Healthcheck UI') {
      steps {
        sh """
          for i in \$(seq 1 24); do
            if curl -fsS http://localhost:${WEB_PORT}/ >/dev/null; then
              echo 'UI OK en http://localhost:${WEB_PORT}'
              exit 0
            fi
            echo 'UI aún no disponible, reintentando...'; sleep 5
          done
          echo 'ERROR: UI no respondió a tiempo' >&2
          exit 1
        """
      }
    }
  }

  post {
    success {
      echo "Despliegue OK. Accede a http://<HOST>:${WEB_PORT} (Admin/zabbix)"
    }
    failure {
      sh 'docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Image}}" || true'
      sh 'docker logs zbx-server --tail=200 || true'
      sh 'docker logs zbx-web --tail=200 || true'
    }
  }
}
