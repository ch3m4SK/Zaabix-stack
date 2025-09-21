pipeline {
  agent any

  environment {
    DEPLOY_PATH = '/opt/zabbix-stack'
  }

  stages {
    stage('Deploy') {
      steps {
        sh """
          cd $DEPLOY_PATH
          docker compose up -d
        """
      }
    }
  }

  post {
    success {
      echo "Despliegue completado correctamente con docker compose up -d"
    }
    failure {
      echo "El despliegue falló. Revisa los logs de Jenkins y de Docker."
    }
  }
}
