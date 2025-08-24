pipeline {
  agent any

  environment {
    DEPLOY_PATH = '/opt/zabbix-stack'
  }

  stages {
    stage('Preparar carpeta') {
      steps {
        sh """
          mkdir -p $DEPLOY_PATH
          mkdir -p $DEPLOY_PATH/zbx/alertscripts \
                   $DEPLOY_PATH/zbx/externalscripts \
                   $DEPLOY_PATH/zbx/snmptraps \
                   $DEPLOY_PATH/zbx/mibs
        """
      }
    }

    stage('Copiar archivos') {
      steps {
        sh """
          cp docker-compose.yml $DEPLOY_PATH/
          # (opcional) copia docs/scripts si los quieres en el host
          [ -d scripts ] && cp -r scripts $DEPLOY_PATH/ || true
          [ -f .env.example ] && cp .env.example $DEPLOY_PATH/.env || true
        """
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
EOF
            echo "Generado $DEPLOY_PATH/.env:"
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
            if curl -fsS http://localhost:8080/ >/dev/null; then
              echo 'UI OK en http://localhost:8080'
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
      echo "Despliegue OK. Accede a http://<HOST>:8080 (Admin / zabbix)"
    }
    failure {
      sh 'docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Image}}" || true'
      sh 'docker logs zbx-server --tail=200 || true'
      sh 'docker logs zbx-web --tail=200 || true'
    }
  }
}
