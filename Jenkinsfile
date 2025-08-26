pipeline {
  agent any
  environment {
    TF_DIR = 'terraform'
    ANSIBLE_DIR = 'ansible'
  }
  stages {
    stage('Checkout pipeline repo') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
            cd ${TF_DIR}
            terraform init -input=false
            terraform apply -auto-approve -input=false
          '''
        }
      }
    }

    stage('Prepare Ansible Inventory') {
      steps {
        script {
          // read Terraform outputs
          def ip = sh(script: "terraform -chdir=${TF_DIR} output -raw public_ip", returnStdout: true).trim()
          def dns = sh(script: "terraform -chdir=${TF_DIR} output -raw public_dns", returnStdout: true).trim()
          echo "Instance IP: ${ip}"
          echo "Instance DNS: ${dns}"

          // create ansible hosts file
          writeFile file: "${ANSIBLE_DIR}/inventory.ini", text: "[ec2]\\n${ip} ansible_user=ubuntu"
        }
      }
    }

    stage('Run Ansible Playbook') {
      steps {
        // Use SSH private key stored in Jenkins credentials (type: SSH Username with private key)
        withCredentials([sshUserPrivateKey(credentialsId: 'abc-ssh', keyFileVariable: 'SSH_KEY')]) {
          sh '''
            chmod 600 ${SSH_KEY}
            cd ${ANSIBLE_DIR}
            ansible-playbook -i inventory.ini main.yml --private-key ${SSH_KEY} -e "ansible_python_interpreter=/usr/bin/python3"
          '''
        }
      }
    }

    stage('Show site URL') {
      steps {
        script {
          def dns = sh(script: "terraform -chdir=${TF_DIR} output -raw public_dns", returnStdout: true).trim()
          echo "✅ Your site should be live at: http://${dns}"
        }
      }
    }
  }
  post {
    failure {
      echo "Pipeline failed — check Terraform and Ansible logs above."
    }
  }
}

