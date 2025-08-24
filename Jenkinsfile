pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  triggers {
    githubPush()
  }

  parameters {
    string(name: 'DB_NAME', defaultValue: 'zabbix', description: 'Nombre de la BD')
    string(name: 'DB_USER', defaultValue: 'zabbix', description: 'Usuario de la BD')
    string(name: 'PHP_TZ', defaultValue: 'Europe/Madrid', description: 'Timezone PHP')
    string(name: 'ZBX_SERVER_NAME', defaultValue: 'Zabbix Prod', description: 'Nombre mostrado en UI')
    string(name: 'ZBX_DEBUGLEVEL', defaultValue: '3', description: 'Nivel log server (0-5)')
    string(name: 'ZBX_STARTDISCOVERERS', defaultValue: '3', description: 'Discoverers')
    string(name: 'ZBX_STARTPOLLERS', defaultValue: '10', description: 'Pollers')
    string(name: 'ZBX_TIMEOUT', defaultValue: '10', description: 'Timeout Zabbix server')
    string(name: 'ZBX_AGENT_HOSTNAME', defaultValue: 'docker-host', description: 'Hostname del agent2')
    string(name: 'WEB_PORT', defaultValue: '8080', description: 'Puerto HTTP de Zabbix Web (host)')
    string(name: 'WEB_TLS_PORT', defaultValue: '8443', description: 'Puerto HTTPS de Zabbix Web (host)')
  }

  environment {
    COMPOSE_PROJECT_DIR = "${env.WORKSPACE}"
    DOCKER_COMPOSE = "docker compose"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git rev-parse --short HEAD || true'
      }
    }

    stage('Preflight: docker y compose') {
      steps {
        sh '''
          set -e
          docker version
          ${DOCKER_COMPOSE} version
        '''
      }
    }

    stage('Preparar directorios (bind mounts)') {
      steps {
        sh 'mkdir -p zbx/alertscripts zbx/externalscripts zbx/snmptraps zbx/mibs'
      }
    }

    stage('Escribir .env') {
      steps {
        withCredentials([
          string(credentialsId: 'zbx_db_pass', variable: 'SECRET_DB_PASS'),
          string(credentialsId: 'zbx_db_root_pass', variable: 'SECRET_DB_ROOT_PASS')
        ]) {
          sh '''
            cat > .env <<EOF
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${SECRET_DB_PASS}
DB_ROOT_PASS=${SECRET_DB_ROOT_PASS}
ZBX_SERVER_NAME=${ZBX_SERVER_NAME}
PHP_TZ=${PHP_TZ}
ZBX_DEBUGLEVEL=${ZBX_DEBUGLEVEL}
ZBX_STARTDISCOVERERS=${ZBX_STARTDISCOVERERS}
ZBX_STARTPOLLERS=${ZBX_STARTPOLLERS}
ZBX_TIMEOUT=${ZBX_TIMEOUT}
ZBX_AGENT_HOSTNAME=${ZBX_AGENT_HOSTNAME}
EOF
            echo "Generado .env:"
            sed 's/\\(DB_PASS\\|DB_ROOT_PASS\\)=.*/\\1=****/g' .env | tee /dev/stderr
          '''
        }
      }
    }

    stage('Pull imágenes') {
      steps {
        sh '${DOCKER_COMPOSE} -f docker-compose.yml --project-directory "${COMPOSE_PROJECT_DIR}" pull'
      }
    }

    stage('Desplegar (up -d)') {
      steps {
        sh '''
          ${DOCKER_COMPOSE} -f docker-compose.yml --project-directory "${COMPOSE_PROJECT_DIR}" up -d
          ${DOCKER_COMPOSE} ps
        '''
      }
    }

    stage('Healthcheck UI') {
      steps {
        sh """
          echo 'Comprobando UI en http://localhost:${WEB_PORT} ...'
          for i in \$(seq 1 24); do
            if curl -fsS http://localhost:${WEB_PORT}/ >/dev/null; then
              echo 'UI OK'
              exit 0
            fi
            echo "UI no disponible aún, reintentando (\$i/24)..."
            sleep 5
          done
          echo 'ERROR: UI no respondió a tiempo' >&2
          exit 1
        """
      }
    }
  }

  post {
    success {
      echo "Despliegue completado. Accede a http://<HOST>:${WEB_PORT} (Admin / zabbix)"
    }
    failure {
      sh 'docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Image}}" || true'
      sh 'docker logs zbx-server --tail=200 || true'
      sh 'docker logs zbx-web --tail=200 || true'
      echo "Fallo en el despliegue. Revisa los logs anteriores."
    }
    always {
      sh '${DOCKER_COMPOSE} ps || true'
    }
  }
}
